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

- **跨 AP RSSI 采集**：主路由定时从其他 Padavan AP 拉取无线客户端列表，合并显示信号强度
- **跨 AP 设备名称采集**：同时采集各 AP 的 DHCP 主机名，本地无名称时自动显示跨 AP 名称
- **自动定时采集**：启动后自动配置 cron，每分钟执行一次
- **前端自动刷新**：页面每 30 秒自动重新加载跨 AP 数据，实时更新
- **零侵入**：未配置 `ap_slave_ips` 时功能不启用，不影响原有行为

## 修改文件清单

| 文件 | 说明 |
|------|------|
| `trunk/user/www/n56u_ribbon_fixed/device-map/clients.asp` | 跨 AP RSSI + 设备名称合并逻辑，30秒自动刷新 |
| `trunk/user/www/n56u_ribbon_fixed/lan_clients.asp` | 新增 `wireless_last` 变量输出 |
| `trunk/user/www/n56u_ribbon_fixed/ap_rssi.js` | 前端数据缓存占位文件（新增） |
| `trunk/user/scripts/files/usr/bin/ap_rssi_collect.sh` | 跨 AP 无线客户端采集脚本（RSSI + 主机名） |
| `trunk/user/scripts/files/usr/bin/autostart.sh` | 启动时自动配置 cron 定时任务 |
| `trunk/user/www/dict/CN.dict` | 新增 `wired_conn=网线连接` 字典项 |

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

1. 每台 AP 的 `lan_clients.asp` 输出 `wireless_last`（该 AP 的无线客户端 MAC 与 RSSI）和 `ipmonitor_last`（客户端列表含 DHCP 主机名）
2. 主路由的采集脚本通过 `wget --header="Authorization: Basic ..."` 拉取各 AP 数据
3. 解析并合并 RSSI 与主机名，写入 `/tmp/ap_wireless.js`，并 `mount --bind` 覆盖 `/www/ap_rssi.js`
4. 前端设备状态页面加载 `/ap_rssi.js`，将其他 AP 的无线客户端合并到本地列表，本地无名称时使用跨 AP 采集的主机名

### 数据格式

```javascript
var ap_wireless = {
  "AA:BB:CC:DD:EE:FF": {"rssi": -57, "name": "iPhone"},
  "11:22:33:44:55:66": {"rssi": -72, "name": ""}
};
```

- `rssi`：无线信号强度（dBm）
- `name`：DHCP 主机名（已去除 `.lan` 后缀，无名称时为空字符串）

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
7. **设备名称来源**：从各 AP 的 DHCP 租约（`ipmonitor_last`）中提取主机名，无 DHCP 名称的设备显示为空
8. **MAC 格式统一**：前端使用 `simplyMAC()` 统一 MAC 格式（去除冒号），确保跨 AP 数据正确匹配
9. **前端自动刷新**：页面每 30 秒自动重新加载 `/ap_rssi.js`，无需手动刷新即可看到最新数据

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

### 其他 AP 的设备不显示名称

1. 确认采集脚本版本支持名称采集（应包含 `ipmonitor_last` 解析）：
   ```bash
   grep -c "ipmonitor_last" /etc/storage/ap_rssi_collect.sh
   ```
2. 检查采集到的数据是否包含名称：
   ```bash
   cat /www/ap_rssi.js | grep -o '"name":"[^"]*"' | grep -v '""'
   ```
3. 确认设备在其他 AP 上有 DHCP 主机名（无名称的设备显示为空）
4. 确认 `/etc/storage/ap_rssi_collect.sh` 是最新版本（cron 每分钟运行此版本）：
   ```bash
   ls -la /etc/storage/ap_rssi_collect.sh
   ```
5. 强制刷新浏览器页面（Cmd+Shift+R），或等待 30 秒自动刷新

### 采集脚本不自动运行

1. 检查 cron 任务：
   ```bash
   cat /etc/storage/cron/crontabs/admin
   ```
2. 检查 `ap_slave_ips` 是否非空（为空时不会配置 cron）
3. 手动执行 `/usr/bin/ap_rssi_collect.sh` 测试

# AP 中继自动守护 (AP Relay auto-daemon)

AP-Client 模式下的智能中继守护进程，支持多 AP 自动切换、信号阈值触发、漫游保护和连接质量评估。提供独立的 Web UI 配置页面。

## 功能特性

### 第一阶段：基础重构 + 可靠性

- **配置持久化**：AP 列表保存到 `/etc/storage/ap_relay.conf`，重启不丢失
- **防重复运行**：进程检查 + PID 文件双重保护
- **Lock 自动清理**：启动时清理残留的 `/tmp/apc.lock`
- **代码重构**：`connAPSite` 提取 7 个公共辅助函数，消除 2G/5G 重复代码
- **模式检查**：非 AP-Client 模式或配置为空时不启动守护

### 第二阶段：智能切换

- **信号阈值触发**：当前信号低于阈值时自动扫描周围 AP
- **切换迟滞**：候选信号需比当前强指定 dBm 以上才切换，避免临界震荡
- **漫游保护**：切换后 N 秒内不再切换，防止频繁切换
- **连接质量评估**：基于 ping 延迟/丢包率，质量差也触发切换评估
- **每 30 秒评估一次**：避免频繁扫描导致无线网络瞬断

### 第三阶段：Web UI 配置页面

- **独立配置页面**：`/Advanced_APRelay_Content.asp`
- **实时状态显示**：守护进程状态、当前模式、SSID、BSSID、信号强度、连接质量
- **AP 列表可视化编辑**：textarea 编辑，支持注释
- **参数表单**：基础参数 + 智能切换参数，开关联动置灰
- **操作按钮**：刷新状态、立即扫描、重启守护、查看日志
- **httpd 服务组**：新增 `APRelayConfig` 服务组，14 个 nvram 变量一键保存

## 修改文件清单

| 文件 | 说明 |
|------|------|
| `trunk/user/scripts/files/usr/bin/ap_script.sh` | 守护进程主脚本（完全重写） |
| `trunk/user/scripts/files/usr/bin/sh_ezscript.sh` | 扩展脚本集合（connAPSite 重构 + 智能切换函数） |
| `trunk/user/scripts/files/usr/bin/autostart.sh` | 启动时复制脚本到 /etc/storage/ 并运行 |
| `trunk/user/httpd/src/variables.c` | 新增 `APRelayConfig` 服务组（14个 nvram 变量） |
| `trunk/user/www/n56u_ribbon_fixed/Advanced_APRelay_Content.asp` | AP 中继配置页面（新增） |
| `trunk/user/www/n56u_ribbon_fixed/ap_relay_status.asp` | 状态数据接口（新增） |
| `trunk/user/www/n56u_ribbon_fixed/ap_relay_log.asp` | 日志查看页面（新增） |

## 工作原理

```
┌─────────────────────────────────────────────────────────┐
│                    autostart.sh (启动时)                  │
│  cp /usr/bin/ap_script.sh → /etc/storage/ap_script.sh   │
│  cp /usr/bin/sh_ezscript.sh → /etc/storage/sh_ezscript.sh│
│  /etc/storage/ap_script.sh &                              │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│                  ap_script.sh (主流程)                    │
│  1. init_nvram_defaults()  初始化默认参数                │
│  2. load_config()           从 nvram/文件加载 AP 列表    │
│  3. 检查 AP-Client 模式 (rt_mode_x > 2 || wl_mode_x > 2)│
│  4. 防重复运行检查                                        │
│  5. 生成守护进程 /tmp/sh_apauto.sh 并启动                │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│              sh_apauto.sh (守护进程，每15秒循环)          │
│                                                           │
│  ┌─ 状态更新 ────────────────────────────────────────┐  │
│  │  iwconfig 获取当前 SSID/BSSID/信号强度             │  │
│  │  写入 nvram ap_relay_status (JSON)                 │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  ┌─ 断线重连 ────────────────────────────────────────┐  │
│  │  ap_check=0: ping 223.5.5.5 失败 → connAPSite    │  │
│  │  ap_check=1: 无线接口断开 → connAPSite             │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  ┌─ 定时搜寻 ────────────────────────────────────────┐  │
│  │  ap_time_check ≥ 10: 每隔N秒搜寻最优先信号         │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  ┌─ 智能切换 (每30秒) ───────────────────────────────┐  │
│  │  ap_auto_switch=1 且 信号<阈值 或 质量差           │  │
│  │  → 扫描周围 AP → 找最强候选 → 差值≥迟滞 → 切换     │  │
│  │  → 标记漫游保护 (ap_roam_protect 秒)               │  │
│  └────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 使用方法

### 1. 开启 AP-Client 模式

在 Web UI → 高级设置 → 无线 → 无线模式中，将 2.4G 或 5G 的工作模式设置为：
- **AP-Client**（模式3，AP 被禁用）
- **AP-Client + AP**（模式4，不支持 WDS）

### 2. 配置 AP 中继

访问配置页面：
```
http://路由器IP/Advanced_APRelay_Content.asp
```

在页面中配置：
- **AP 列表**：每行一个 AP，格式 `频段@模式@角色@SSID@密码@BSSID`
- **基础参数**：触发条件、定时搜寻间隔、搜寻排序、黑名单
- **智能切换参数**：开关、阈值、迟滞、漫游保护、质量检查

点击"保存配置"。

### 3. 验证

- 配置页面顶部显示当前连接状态（SSID、信号强度等）
- 系统日志中可看到 `【AP 中继】` 和 `【连接 AP】` 相关日志
- 点击"查看日志"按钮可查看最近 50 条 AP 中继日志

## AP 列表配置格式

```
# 注释行以 # 开头
# 格式：频段@工作模式@客户端角色@SSID@密码@BSSID
#
# 频段:     2=2.4GHz  5=5GHz
# 工作模式: 3=AP-Client(AP被禁用)  4=AP-Client+AP(不支持WDS)
# 客户端角色: 0=LAN bridge  1=WAN (Wireless ISP)
# SSID:     目标AP的名称
# 密码:     目标AP的密码
# BSSID:    目标AP的MAC地址(SSID含中文时必填，大小写不限)

# 示例：
2@4@1@ASUS_2.4G@1234567890
5@4@1@ASUS_5G@1234567890@34:bd:f9:1f:d2:b1
```

**多 AP 优先级**：第一行最优先（按配置顺序模式）；或自动连接最强信号（最强信号模式）。

## 配置项说明

### 基础参数

| NVRAM 变量 | 默认值 | 说明 |
|------------|--------|------|
| `ap_check` | `0` | 守护触发条件：0=Internet 断线后搜寻；1=信号断开时搜寻 |
| `ap_inet_check` | `0` | 连接成功条件：0=连上即可；1=连上且能联网 |
| `ap_time_check` | `0` | 定时搜寻间隔(秒)：0=成功后停止；≥10=每隔N秒搜寻最优信号 |
| `ap_black` | `0` | 黑名单功能：0=关闭；1=启用（无法联网的 AP 自动加入黑名单） |
| `ap_fenge` | `@` | 配置字段分隔符 |
| `ap_rule` | `0` | 搜寻排序：0=按配置顺序(首行最优先)；1=自动连接最强信号 |
| `ap_relay_list` | （模板） | AP 列表配置文本（含注释） |

### 智能切换参数

| NVRAM 变量 | 默认值 | 说明 |
|------------|--------|------|
| `ap_auto_switch` | `0` | 智能切换开关：0=关闭；1=启用 |
| `ap_switch_threshold` | `-75` | 切换信号阈值(dBm)：当前信号低于此值时触发扫描评估 |
| `ap_switch_hysteresis` | `10` | 切换迟滞(dBm)：候选信号需比当前强多少才切换 |
| `ap_roam_protect` | `60` | 漫游保护(秒)：切换后多久内不再切换 |
| `ap_quality_check` | `0` | 连接质量检查：0=关闭；1=启用（ping 延迟/丢包率评估） |
| `ap_quality_ping_loss` | `50` | 质量检查丢包率阈值(%)：超过则认为质量差 |
| `ap_quality_ping_delay` | `200` | 质量检查延迟阈值(ms)：超过则认为质量差 |

### 信号强度参考

| 信号强度 | 质量 | 建议 |
|----------|------|------|
| -30 ~ -50 dBm | 极好 | 无需切换 |
| -50 ~ -65 dBm | 良好 | 稳定连接 |
| -65 ~ -75 dBm | 一般 | 可能触发切换评估 |
| -75 ~ -85 dBm | 较差 | 建议切换 |
| < -85 dBm | 很差 | 几乎不可用 |

## 注意事项

1. **必须在 AP-Client 模式下使用**：路由模式下守护进程不会启动
2. **扫描会导致瞬断**：每次扫描周围 AP 时无线网络会短暂断开（约1-2秒）
3. **配置持久化**：所有配置保存到 nvram，AP 列表同时同步到 `/etc/storage/ap_relay.conf`
4. **脚本位置**：运行时脚本在 `/etc/storage/`，固件中的脚本在 `/usr/bin/`，启动时自动复制
5. **智能切换默认关闭**：需要手动在配置页面启用 `ap_auto_switch`
6. **漫游保护很重要**：设置过短可能导致频繁切换震荡，建议 ≥30 秒
7. **迟滞值避免震荡**：建议 ≥5 dBm，否则在两个 AP 信号接近时会频繁切换

## 故障排查

### 守护进程不启动

1. 确认当前是 AP-Client 模式：
   ```bash
   nvram get rt_mode_x  # 2G: >2 表示 AP-Client
   nvram get wl_mode_x  # 5G: >2 表示 AP-Client
   ```
2. 确认 AP 列表非空：
   ```bash
   cat /etc/storage/ap_relay.conf | grep -v '^#' | grep -v '^$'
   ```
3. 查看日志：
   ```bash
   logread | grep "AP 中继"
   ```
4. 手动启动测试：
   ```bash
   /etc/storage/ap_script.sh
   ```

### 不自动切换 AP

1. 确认智能切换已启用：
   ```bash
   nvram get ap_auto_switch  # 应为 1
   ```
2. 确认当前信号低于阈值：
   ```bash
   iwconfig apcli0 | grep "Signal level"   # 2G
   iwconfig apclii0 | grep "Signal level"  # 5G
   ```
3. 确认候选 AP 信号比当前强迟滞值以上
4. 确认不在漫游保护期内：
   ```bash
   cat /tmp/ap_last_switch  # 切换时间戳
   ```
5. 查看智能切换日志：
   ```bash
   logread | grep "智能切换"
   ```

### 连接不上目标 AP

1. 确认 SSID、密码、BSSID 配置正确
2. 确认目标 AP 在范围内：
   ```bash
   iwpriv ra0 set SiteSurvey=1; sleep 1; iwpriv ra0 get_site_survey
   ```
3. 确认认证/加密模式匹配（WPA2-PSK/AES 等）
4. 查看连接日志：
   ```bash
   logread | grep "连接 AP"
   ```

### Web UI 配置页面不显示

1. 确认已编译包含新文件的固件（`Advanced_APRelay_Content.asp` 等）
2. 直接访问 URL：`http://路由器IP/Advanced_APRelay_Content.asp`
3. 确认 httpd 已重启（编译刷入后自动重启）
