/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

/*
 * stage2c: gpio_btn.c rewritten to read buttons from the input
 * subsystem (/dev/input/eventX) instead of NETLINK_KOBJECT_UEVENT.
 *
 * Modern kernels expose GPIO buttons as evdev devices:
 *   - KEY_RESTART   (0x198): reset / WPS reset
 *   - KEY_WPS_BUTTON(0x216): hardware WPS button
 *
 * We scan /dev/input/eventX for devices advertising these keys and
 * block-read struct input_event. On key-down (value==1) we dispatch
 * to btn_action(), which keeps its original notify_rc chain.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <errno.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/poll.h>
#include <sys/inotify.h>
#include <linux/input.h>

#include "nvram_linux.h"
#include "netutils.h"
#include "rc.h"
#include "shutils.h"
#include "gpioutils.h"

#define BEEP_PIN 1

#ifndef KEY_WPS_BUTTON
#define KEY_WPS_BUTTON  0x216
#endif
#ifndef KEY_RESTART
#define KEY_RESTART     0x198
#endif

static void
beep(void)
{
	doSystem("gpio enable %d 2>/dev/null; gpep --beep 2>/dev/null", BEEP_PIN);
}

void
btn_action(int btn_code)
{
	int i;
	char *nvram_button_value = NULL;
	char nvram_button[24];

	switch (btn_code)
	{
	case BTN_RESET:
		nvram_button_value = nvram_safe_get("btn_reset");
		if (!nvram_button_value)
			break;
		if (!strcmp(nvram_button_value, "reset"))
			system("notify_rc restart");
		else if (!strcmp(nvram_button_value, "wps"))
			system("notify_rc restart_wps");
		else if (!strcmp(nvram_button_value, "wps_reset"))
			system("notify_rc restart_wpsreset");
		break;
	case BTN_WPS:
		system("notify_rc restart_wps");
		break;
	case BTN_FN1:
		strcpy(nvram_button, "btn_fn1");
		nvram_button_value = nvram_safe_get(nvram_button);
		if (!nvram_button_value)
			break;
		for (i = 0; i < 10; i++)
		{
			if (!strncmp(nvram_button_value, "power", 5))
			{
				doSystem("power off");
				break;
			}
			nvram_button_value += strlen(nvram_button_value) + 1;
		}
		break;
	case BTN_FN2:
		strcpy(nvram_button, "btn_fn2");
		nvram_button_value = nvram_safe_get(nvram_button);
		if (!nvram_button_value)
			break;
		for (i = 0; i < 10; i++)
		{
			if (!strncmp(nvram_button_value, "power", 5))
			{
				doSystem("power off");
				break;
			}
			nvram_button_value += strlen(nvram_button_value) + 1;
		}
		break;
	}
}

/*
 * Scan /dev/input for an evdev device that supports the given key.
 * Returns an open fd (caller closes), or -1.
 */
static int
open_button_device(int keycode)
{
	DIR *dir;
	struct dirent *de;
	char path[64];
	unsigned long evbit[(KEY_MAX / (8*sizeof(long))) + 1] = {0};
	unsigned long keybit[(KEY_MAX / (8*sizeof(long))) + 1] = {0};
	int fd;

	dir = opendir("/dev/input");
	if (!dir)
		return -1;

	while ((de = readdir(dir)) != NULL) {
		if (strncmp(de->d_name, "event", 5) != 0)
			continue;

		snprintf(path, sizeof(path), "/dev/input/%s", de->d_name);
		fd = open(path, O_RDONLY | O_NONBLOCK);
		if (fd < 0)
			continue;

		if (ioctl(fd, EVIOCGBIT(0, sizeof(evbit)), evbit) < 0) {
			close(fd);
			continue;
		}
		if (!(evbit[EV_KEY / (8*sizeof(long))] & (1UL << (EV_KEY % (8*sizeof(long)))))) {
			close(fd);
			continue;
		}

		if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(keybit)), keybit) < 0) {
			close(fd);
			continue;
		}
		if (keybit[keycode / (8*sizeof(long))] & (1UL << (keycode % (8*sizeof(long))))) {
			closedir(dir);
			return fd;
		}
		close(fd);
	}

	closedir(dir);
	return -1;
}

void *
start_button_thread(void *thread_arg)
{
	struct input_event ev;
	int fd_reset = -1, fd_wps = -1;
	struct pollfd pfd[2];
	int nfd = 0;

	(void)thread_arg;

	beep();

	fd_reset = open_button_device(KEY_RESTART);
	fd_wps   = open_button_device(KEY_WPS_BUTTON);

	if (fd_reset < 0 && fd_wps < 0) {
		/* No button input device available; exit thread quietly. */
		beep();
		return NULL;
	}

	if (fd_reset >= 0) {
		pfd[nfd].fd = fd_reset;
		pfd[nfd].events = POLLIN;
		nfd++;
	}
	if (fd_wps >= 0) {
		pfd[nfd].fd = fd_wps;
		pfd[nfd].events = POLLIN;
		nfd++;
	}

	while (1) {
		int r, i;
		r = poll(pfd, nfd, -1);
		if (r <= 0)
			continue;

		for (i = 0; i < nfd; i++) {
			if (!(pfd[i].revents & POLLIN))
				continue;
			while (read(pfd[i].fd, &ev, sizeof(ev)) > 0) {
				if (ev.type != EV_KEY)
					continue;
				if (ev.value != 1)   /* only key-down */
					continue;
				if (pfd[i].fd == fd_reset && ev.code == KEY_RESTART) {
					beep();
					btn_action(BTN_RESET);
				} else if (pfd[i].fd == fd_wps && ev.code == KEY_WPS_BUTTON) {
					beep();
					btn_action(BTN_WPS);
				}
			}
		}
	}

	if (fd_reset >= 0) close(fd_reset);
	if (fd_wps >= 0)   close(fd_wps);
	return NULL;
}

/*
 * ------------------------------------------------------------------
 * stage2c: legacy-symbol thin wrappers for gpio_btn.
 *
 * The old gpio_btn.c exposed:
 *   - get_state_led_pwr() -> LED state for PWR LED
 *   - start_gpio_btn()    -> fork/eval /sbin/gpio_btn daemon once
 *   - btn_main()          -> daemon main loop (old uevent netlink path)
 *
 * start_button_thread() is the new evdev loop; btn_main() below reuses
 * it. All three symbols are preserved so rc.h and callers keep linking.
 * ------------------------------------------------------------------
 */

/* LED_ON / LED_OFF expected from gpioutils.h or headers; if not
 * defined, fall back to active-low convention used by Padavan. */
#ifndef LED_ON
#define LED_ON   1
#endif
#ifndef LED_OFF
#define LED_OFF  0
#endif

int
get_state_led_pwr(void)
{
	int i_led;

	if (nvram_get_int("front_led_pwr") == 0) {
		/* POWER always OFF */
		i_led = LED_ON;
	} else {
		/* POWER always ON */
		i_led = LED_OFF;
	}

	return i_led;
}

int
start_gpio_btn(void)
{
	if (pids("gpio_btn"))
		return 0;

	return eval("/sbin/gpio_btn");
}

int
btn_main(int argc, char *argv[])
{
	(void)argc;
	(void)argv;

	/* Daemonize then enter the evdev button loop. */
	if (daemon(0, 0) < 0) {
		perror("daemon");
		exit(errno);
	}

	logmessage("gpio_btn", "service started (evdev).");
	start_button_thread(NULL);
	return 0;
}
