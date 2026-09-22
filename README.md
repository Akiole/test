# padavan #

This project is based on original rt-n56u with latest mtk 4.4.198 kernel, which is fetch from D-LINK GPL code.

#### Extra functions / changes
- Adding user/chinadns-ng , and fix shadowsocks + chinadns-ng using local domain whitellist.
- AP Relay auto-daemon
- 跨 AP 无线客户端 RSSI 显示（多 Padavan AP 组网时，主路由可显示连到其他 AP 的设备信号强度）


#### SS/SSR
- Transparent proxy (iptables) wasn't cleaned completely, this issue is fixed.
- Adding DNSProxy , Local DNS integrated with SS/SSR 
- Dnsmasq optimization specially for SS/SSR 
- Resolve DNS pollution - Adding DNS i/p in china-route mode
- Fast-open option is enabled according to linux version
##### Enhancements in this repo

- commits has beed rewritten on top of [hanwckf/rt-n56u](https://github.com/hanwckf/rt-n56u) repo for better history tracking
- Optimized Makefiles and build scripts, added a toplevel Makefile
- Added ccache support, may save up to 50%+ build time
- Upgraded the toolchain and libc:
  - gcc 13.3.0
  - musl 1.2.5 / uClibc-ng 1.0.52
 - OpenWrt style package Makefile
 - Enabled kernel cgroups support
 - Fixed K2P led label names
 - Replaced udpxy with msd_lite
 - Replaced Web Console with ttyd
 - Upgraded libs and user packages
 - And a lot of package related fixes
 - ...

# Features

- Based on 4.4.198 Linux kernel
- Support MT7621 based devices
- Support MT7615D/MT7615N/MT7915D wireless chips
- Support raeth and mt7621 hwnat with legency driver
- Support qca shortcut-fe
- Support IPv6 NAT based on netfilter
- Support WireGuard integrated in kernel
- Support fullcone NAT (by Chion82)
- Support LED&GPIO control via sysfs

# Supported devices
- 360-T6GS (没有机器测试，自行判断)
- 360-T6M (from https://github.com/BINGHUAice/padavan-4.4, 没有机器测试，自行判断)
- B70
- BELL-A040WQ
- C-Life-XG1 (from https://github.com/vb1980/padavan-4.4, 没有机器测试，自行判断)
- CMCC-A9 (没有机器测试，自行判断)
- CR660x
- DIR-878
- DIR-882
- EA7500 (from https://github.com/MNM28/padavan-4.4, 没有机器测试，自行判断)
- EW1800GX-Pro (没有机器测试，自行判断)
- FCJ-GAX1800B (from https://github.com/vb1980/padavan-4.4, 富春江G-AX1800黑色版本, 自测可用, 网口配置和白色版不一样, 4根天线都是ipex可拆, ttl排针焊接好了, 做工比白色版好些)
- FCJ-GAX1800W (from https://github.com/ddyjyj/padavan-4.4, 富春江G-AX1800, 自测可用)
- GHL (from https://github.com/fangenhui520/padavan-4.4, 没有机器测试，自行判断)
- HAR-20S2U1 (from https://github.com/vb1980/padavan-4.4, 没有机器测试，自行判断)
- JDCloud RE-CP-02 (无线宝鲁班, from https://github.com/240038901/padavan-4.4, 没有机器测试，自行判断)
- JDCloud RE-SP-01B (from https://github.com/MeIsReallyBa/padavan-4.4, 没有机器测试，自行判断)
- JCG-836PRO
- JCG-AC860M
- JCQ-Q10Pro (from https://github.com/vb1980/padavan-4.4, 没有机器测试，自行判断)
- JCQ-Q11Pro (from https://github.com/qewwqewq22/padavan11, 没有机器测试，自行判断)
- JCG-Q20
- JCG-Y2
- K2P
- K2P-USB
- KOMI-A8 (from https://github.com/vb1980/padavan-4.4, 没有机器测试，自行判断)
- MAIPU-MPAX18 (没有机器测试，自行判断)
- MI-4
- MI-R3G
- MI-R3P
- MI-R4A (from https://github.com/vipshmily/padavan-4.4, 自测可用)
- MR2600
- MSG1500
- MSG1500-Z (from https://github.com/TurBoTse/padavan, 自测可用)
- NETGEAR-BZV
- NETGEAR-R6800 (from https://github.com/MNM28/padavan-4.4, 没有机器测试，自行判断)
- NETGEAR-R7450 (from https://github.com/vipshmily/padavan-4.4, 自测可用)
- NEWIFI
- NEWIFI3 (partially from https://github.com/GH-X/padavan-4.4, 无需拆除C48电容, 没有机器测试，自行判断)
- NX18Plus (没有机器测试，自行判断)
- QM-B1 (from https://github.com/monw/padavan, 没有机器测试，自行判断)
- R2100
- RM2100
- RT-AC85P
- SIM-AX1800T (from https://github.com/vb1980/padavan-4.4, 没有机器测试，自行判断)
- TX1801 Plus (from https://github.com/MNM28/padavan-4.4, 没有机器测试，自行判断)
- WDR8620 (from https://github.com/fzn0268/padavan-4.4, 没有机器测试，自行判断)
- WRL18M4GD (from https://github.com/vb1980/padavan-4.4, 没有机器测试，自行判断)
- WE410443-TC (from https://github.com/akw28888/padavan-4.4, 没有机器测试，自行判断)
- WIA3300-10 (from https://github.com/vb1980/padavan-4.4, 西加云杉WIA3300-10, 自测可用)
- WR1200JS
- XY-C1
- ZTE-E8820S
- ZTE-E8820V2
- ZTT-RX6000(from https://github.com/vb1980/padavan-4.4, 中天科技RX6000的Wifi6运营商机器, ttl刷机简单, 使用R3G分区, r3g breed刷入, 自测可用)
# Compilation steps

- Install dependencies
  ```sh
  # Debian/Ubuntu
  sudo apt install unzip libtool-bin ccache curl cmake gperf gawk flex bison nano xxd \
      fakeroot kmod cpio bc zip git python3-docutils gettext automake autopoint \
      texinfo build-essential help2man pkg-config zlib1g-dev libgmp3-dev \
      libmpc-dev libmpfr-dev libncurses5-dev libltdl-dev wget libc-dev-bin liblzma-dev
  ```
  **Optional:**
  - install [golang](https://go.dev/doc/install) for building go programs
    ```sh
    sudo rm -rf /usr/local/go
    curl -fsSL https://go.dev/dl/go1.20.10.linux-amd64.tar.gz | sudo tar -C /usr/local -xz
    echo "export PATH=\$PATH:/usr/local/go/bin" | sudo tee /etc/profile.d/go.sh
    source /etc/profile.d/go.sh
    go version
    ```
  - install [nodejs](https://nodejs.org/en/download) for building [AdGuardHome](trunk/user/adguardhome)
    ```sh
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt update
    sudo apt install -y nodejs
    node -v
    ```
- Clone source code
  ```sh
  git clone https://github.com/TurBoTse/padavan.git
  ```
- Modify template file and start compiling
  ```sh
  # (Optional) Modify template file
  # vi trunk/configs/templates/K2P.config

  # Start compiling with: make PRODUCT_NAME
  make K2P

  # To build firmware for other devices, clean the tree after previous build
  make clean
  ```

# Package Development

- Makefile examples
  - [Makefile project](trunk/libs/libpcre/Makefile) 
  - [CMake project](trunk/user/ttyd/Makefile)
- Compiling a single package (cd to `trunk` first)
  - build: `make libs/libpcre_only`
  - clean: `make libs/libpcre_clean`
  - romfs: `make libs/libpcre_romfs`

# Manuals

- Controlling GPIO and LEDs via sysfs
- How to use NAND RWFS partition
- How to use IPv6 NAT and fullcone NAT
- How to add new device support with device tree

# 跨 AP 无线客户端 RSSI 显示

在多 AP（Padavan 固件）组网环境下，主路由的设备状态页面只能显示直接连到自身无线接口的客户端 RSSI。本功能增加了跨 AP 无线客户端采集，让连到其他 AP 的设备也能在主路由上显示信号强度。

## 功能特性

- **跨 AP RSSI 采集**：主路由定时从其他 Padavan AP 拉取无线客户端列表，合并显示
- **自动定时采集**：启动后自动配置 cron，每分钟执行一次
- **零侵入**：未配置 `ap_slave_ips` 时功能不启用，不影响原有行为

## 修改文件清单

| 文件 | 说明 |
|------|------|
| `trunk/user/www/n56u_ribbon_fixed/device-map/clients.asp` | 跨 AP RSSI 合并逻辑 |
| `trunk/user/www/n56u_ribbon_fixed/lan_clients.asp` | 新增 `wireless_last` 变量输出 |
| `trunk/user/www/n56u_ribbon_fixed/ap_rssi.js` | 前端数据缓存占位文件（新增） |
| `trunk/user/scripts/files/usr/bin/ap_rssi_collect.sh` | 跨 AP 无线客户端采集脚本（新增） |
| `trunk/user/scripts/files/usr/bin/autostart.sh` | 启动时自动配置 cron 定时任务 |

## 工作原理

```
┌─────────────┐   每分钟 wget (Basic Auth)   ┌─────────────┐
│  主路由     │ ──────────────────────────────▶ │  AP 节点 1  │
│  (cron)     │ ◀────────────────────────────── │             │
│             │   wireless_last = {MAC:RSSI}    └─────────────┘
│             │
│             │   ┌─────────────┐
│             │ ─▶│  AP 节点 2  │
│             │ ◀─│             │
│             │   └─────────────┘
│             │
│  合并写入    │
│  /tmp/ap_wireless.js │
│  (mount --bind 到 /www/ap_rssi.js) │
└─────────────┘
       │
       ▼
  前端页面加载 /ap_rssi.js
  合并到本地 wireless 对象
  重新渲染设备列表
```

1. 每台 AP 的 `lan_clients.asp` 输出 `wireless_last`（该 AP 的无线客户端 MAC 与 RSSI）
2. 主路由的采集脚本通过 `wget --header="Authorization: Basic ..."` 拉取各 AP 数据
3. 合并后写入 `/tmp/ap_wireless.js`，并 `mount --bind` 覆盖 `/www/ap_rssi.js`
4. 前端设备状态页面加载 `/ap_rssi.js`，将其他 AP 的无线客户端合并到本地列表

## 使用方法

### 1. 配置 AP 列表

SSH 登录主路由，执行：

```bash
# 设置其他 AP 的 IP（空格分隔多个）
nvram set ap_slave_ips="192.168.3.2 192.168.3.3"

# 如果其他 AP 的登录账号密码不是默认的 admin/admin
nvram set ap_slave_user="admin"
nvram set ap_slave_pass="your_password"

# 保存
nvram commit
```

### 2. 生效方式

- **重启主路由**：`autostart.sh` 会自动配置 cron 并执行一次采集
- **或手动执行**：`/usr/bin/ap_rssi_collect.sh`

### 3. 验证

打开主路由 Web 界面 → 设备状态地图（`/device-map/clients.asp`），连到其他 AP 的无线设备应该也会显示 RSSI 信号条。

## 配置项说明

| NVRAM 变量 | 默认值 | 说明 |
|------------|--------|------|
| `ap_slave_ips` | （空） | 其他 AP 的 IP 列表，空格分隔。为空则不启用采集 |
| `ap_slave_user` | `admin` | 其他 AP 的 Web 登录用户名 |
| `ap_slave_pass` | `admin` | 其他 AP 的 Web 登录密码 |

## 注意事项

1. **所有 AP 必须刷入相同固件**：每台 AP 都需要 `lan_clients.asp` 输出 `wireless_last`，否则采集不到数据
2. **AP 之间网络需互通**：主路由需要能访问其他 AP 的 Web 管理端口（80）
3. **采集间隔**：默认每分钟一次，可在 `autostart.sh` 中修改 cron 表达式
4. **mount --bind**：采集脚本用 `mount --bind` 覆盖 `/www/ap_rssi.js`，重启后自动重新挂载
5. **去重逻辑**：前端合并时会跳过已存在的 MAC，不会重复显示
6. **RSSI 来源限制**：只能获取各 AP 自身的无线客户端信号，无法获取有线设备或非 Padavan AP 的信号

## 故障排查

### 其他 AP 的设备不显示 RSSI

1. 确认其他 AP 已刷入包含本补丁的固件
2. 手动执行采集脚本查看输出：
   ```bash
   /usr/bin/ap_rssi_collect.sh
   cat /tmp/ap_wireless.js
   ```
3. 测试能否访问其他 AP 的接口：
   ```bash
   wget --header="Authorization: Basic $(echo -n admin:admin | base64)" -qO- http://192.168.3.2/lan_clients.asp
   ```
4. 确认 `ap_slave_ips` 配置正确且已 `nvram commit`

### 采集脚本不自动运行

1. 检查 cron 任务：
   ```bash
   cat /etc/storage/cron/crontabs/admin
   ```
2. 检查 `ap_slave_ips` 是否非空（为空时不会配置 cron）
3. 手动执行 `/usr/bin/ap_rssi_collect.sh` 测试
