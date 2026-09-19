# BusyBox 1.37.0 dhcp6c + IPv6 修复说明

## 概述
本 patch 将完整的 dhcp6c（wide-dhcpv6 移植版）移植回 BusyBox 1.37.0，并修复了多个编译和运行时 bug，解决了 Padavan 固件 IPv6 无法获取地址的问题。

## 问题背景
BusyBox 从 1.24.x 升级到 1.37.0 后，完整的 dhcp6c 被移除，换成了功能简化的 udhcpc6（仅支持 information-request，不支持 IA_NA/IA_PD 前缀委派），导致运营商 DHCPv6 无法正常获取 IPv6 前缀。

## 修改文件清单（17 个文件）

### 新增文件（11 个 dhcp6c 源文件）
- `networking/udhcp/dhcp6.h` — DHCPv6 协议定义
- `networking/udhcp/dhcp6c.c` — dhcp6c 主程序
- `networking/udhcp/dhcp6c.h` — dhcp6c 头文件
- `networking/udhcp/dhcp6c_auth.c` — DHCPv6 认证
- `networking/udhcp/dhcp6c_auth.h` — 认证头文件
- `networking/udhcp/dhcp6c_common.c` — 通用函数
- `networking/udhcp/dhcp6c_config.c` — 配置文件解析
- `networking/udhcp/dhcp6c_config.h` — 配置头文件
- `networking/udhcp/dhcp6c_ia.c` — IA（身份关联）处理
- `networking/udhcp/dhcp6c_script.c` — 脚本调用
- `networking/udhcp/dhcp6c_socket.c` — 套接字初始化

### 修改文件（6 个）
- `networking/udhcp/Kbuild.src` — 添加 dhcp6c 编译规则
- `networking/udhcp/Config.src` — 添加 CONFIG_DHCP6C 和 CONFIG_FEATURE_DHCP6_AUTH 配置选项
- `networking/udhcp/dhcp6c.c` — 修复 opt_complementary、getopt32 格式、添加 applet 注册
- `networking/udhcp/dhcp6c_config.c` — 修复 udhcp_read_interface 参数数量（5→4）
- `networking/udhcp/dhcp6c_common.c` — 添加 #include <sys/uio.h>
- `libbb/udp_io.c` — **关键修复**：recv_from_to 函数设置 IPv6 sin6_scope_id
- `busybox.config` — 启用 CONFIG_DHCP6C，禁用 CONFIG_UDHCPC6
- `user/rc/src/net6.c` — 修复 control_if_ipv6_all 的 if6_on 数组（添加 "all"）
- `user/rc/src/net_wan6.c` — 恢复 start_dhcp6c/stop_dhcp6c 使用 dhcp6c

## 修复的 8 个 bug 详解

### 1. 缺失 dhcp6.h 头文件
**症状**：`fatal error: dhcp6.h: No such file or directory`
**修复**：从 BusyBox 1.24.x 复制缺失的 dhcp6.h

### 2. .config 重复定义 UDHCPC6
**症状**：`warning: trying to reassign symbol UDHCPC6`
**修复**：清理 busybox.config 中重复的 UDHCPC6 行

### 3. opt_complementary 未声明
**症状**：`error: 'opt_complementary' undeclared`
**原因**：BusyBox 1.37.0 中 opt_complementary 不再是全局变量
**修复**：通过 getopt32 的 `^` 前缀传递 complementary 信息

### 4. udhcp_read_interface 参数过多
**症状**：`error: too many arguments to function 'udhcp_read_interface'`
**原因**：BusyBox 1.37.0 移除了第 5 个 mtu 参数
**修复**：调用从 5 参数改为 4 参数

### 5. writev 隐式声明
**症状**：`error: implicit declaration of function 'writev'`
**修复**：dhcp6c_common.c 添加 `#include <sys/uio.h>`

### 6. 缺少 applet 注册
**症状**：dhcp6c 编译成功但 busybox --list 中没有 dhcp6c
**原因**：BusyBox 1.37.0 需要 `//applet:IF_XXX(APPLET(...))` 注释注册
**修复**：在 dhcp6c.c 中添加 applet 注册注释

### 7. getopt32 选项字符串格式错误
**症状**：`dhcp6c: NO OPT f!`
**原因**：`^complementary\0选项` 顺序写反了
**修复**：改为 `^选项\0complementary` 格式

### 8. recv_from_to 不设置 sin6_scope_id（最关键）
**症状**：`dhcp6c: unexpected interface ((null))`，收到 DHCPv6 回复但被丢弃
**原因**：BusyBox 1.37.0 的 libbb/udp_io.c 中 recv_from_to 函数处理 IPv6 pktinfo 时只复制了 sin6_addr，没有复制 ipi6_ifindex 到 sin6_scope_id
**修复**：添加 `to6->sin6_scope_id = ((struct in6_pktinfo*)(CMSG_DATA(cmsgptr)))->ipi6_ifindex;`

## 验证结果
- dhcp6c 进程正常运行：`/sbin/dhcp6c -D LL ppp0`
- LAN 口获取全球单播 IPv6 前缀：`2408:8256:ec80:130c::/64`
- IPv6 连通性正常：ping 2400:3200::1 延迟 ~43ms
- IPv6 DNS 解析正常

## 升级到 BusyBox 新版本时的注意事项

1. **dhcp6c 可能仍需移植** — BusyBox 官方从 1.25 后未重新加入 dhcp6c
2. **检查 recv_from_to bug 是否修复** — 重点检查 libbb/udp_io.c 是否设置了 sin6_scope_id
3. **API 兼容性检查**：
   - opt_complementary 是否仍通过 getopt32 的 ^ 前缀传递
   - udhcp_read_interface 参数数量是否变化
   - applet 注册方式是否变化
4. **配置选项检查** — CONFIG_DHCP6C、CONFIG_FEATURE_DHCP6_AUTH 是否需要调整依赖
5. **测试要点**：
   - dhcp6c 能否正常启动
   - 能否收到 DHCPv6 Advertise/Reply
   - LAN 口能否获取 IPv6 前缀
   - IPv6 连通性测试

## Patch 应用方法
```bash
cd /path/to/padavan
git apply busybox-1.37.0-dhcp6c-ipv6-fixes.patch
```

## 生成日期
2026-09-19
