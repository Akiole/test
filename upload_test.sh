#!/bin/bash
# Padavan 固件 Web 文件一键上传测试脚本
# 用法:
#   ./upload_test.sh --all                # 上传整个 WEB_ROOT 目录到 /www (tmpfs 覆盖)
#   ./upload_test.sh <文件路径>           # 上传并挂载单个文件
#   ./upload_test.sh <文件路径> --restore  # 恢复原始文件
#   ./upload_test.sh --list               # 查看当前挂载
#   ./upload_test.sh --restore-all        # 恢复所有挂载 (含 /www tmpfs 覆盖)

# 设备配置
DEVICE_IP="192.168.3.1"
DEVICE_USER="admin"
DEVICE_PASS="admin"

# Web 根目录（本地）- 对应设备 /www/
WEB_ROOT="/Volumes/Padavan/GitHub/test/trunk/user/www/n56u_ribbon_fixed"
# 字典文件目录（本地）- 构建时生成 EN.dict 后上传到 /www/
DICT_DIR="/Volumes/Padavan/GitHub/test/trunk/user/www/dict"

# tmpfs 覆盖 /www 时的大小 (需大于 WEB_ROOT 总大小)
TMPFS_SIZE="20M"

# SSH 命令（带密码）
SSH_CMD="sshpass -p $DEVICE_PASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $DEVICE_USER@$DEVICE_IP"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 显示用法
usage() {
    echo "Padavan Web 文件一键上传测试工具"
    echo ""
    echo "用法:"
    echo "  $0 --all                上传整个 WEB_ROOT 目录到 /www (tmpfs 覆盖, 重启恢复)"
    echo "  $0 <文件路径>           上传并挂载单个文件"
    echo "  $0 <文件路径> --restore  恢复原始文件"
    echo "  $0 --list               查看当前挂载状态"
    echo "  $0 --restore-all        恢复所有挂载 (含 /www tmpfs 覆盖)"
    echo ""
    echo "示例:"
    echo "  $0 --all"
    echo "  $0 state.js"
    echo "  $0 bootstrap/css/bootstrap.min.css"
    echo "  $0 device-map/clients.asp"
    exit 1
}

# 批量上传整个 WEB_ROOT 目录 (tmpfs 覆盖 /www)
upload_all() {
    echo -e "${YELLOW}📤 批量上传整个目录...${NC}"
    echo "  本地: $WEB_ROOT"
    echo "  设备: $DEVICE_IP:/www"
    echo ""

    # 检查源目录
    if [ ! -d "$WEB_ROOT" ]; then
        echo -e "${RED}❌ 源目录不存在: $WEB_ROOT${NC}"
        exit 1
    fi

    local file_count=$(find "$WEB_ROOT" -type f ! -name '._*' | wc -l | tr -d ' ')
    local dir_size=$(du -sh "$WEB_ROOT" | cut -f1)
    echo "  文件数: $file_count, 大小: $dir_size"
    echo ""

    # 测试连接
    echo -e "${YELLOW}🔌 测试 SSH 连接...${NC}"
    if ! $SSH_CMD 'echo ok' >/dev/null 2>&1; then
        echo -e "${RED}❌ 无法连接到 $DEVICE_IP${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ 连接成功${NC}"
    echo ""

    # 先恢复可能存在的 /www tmpfs 覆盖
    $SSH_CMD "umount /www 2>/dev/null" 2>/dev/null

    # 挂载 tmpfs 覆盖 /www
    echo -e "${YELLOW}💾 挂载 tmpfs 到 /www (大小 $TMPFS_SIZE)...${NC}"
    if ! $SSH_CMD "mount -t tmpfs -o size=$TMPFS_SIZE tmpfs /www"; then
        echo -e "${RED}❌ tmpfs 挂载失败${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ tmpfs 挂载成功, /www 现在可写${NC}"
    echo ""

    # tar 管道上传 (不依赖 sftp, 排除 macOS 资源叉)
    echo -e "${YELLOW}📦 上传 Web 文件中...${NC}"
    cd "$WEB_ROOT"
    if ! COPYFILE_DISABLE=1 tar --exclude='._*' -cf - . | $SSH_CMD "tar xf - -C /www/"; then
        echo -e "${RED}❌ Web 文件上传失败${NC}"
        $SSH_CMD "umount /www 2>/dev/null" 2>/dev/null
        exit 1
    fi

    # 生成并上传字典文件 (EN.dict = EN.header + 各语言名称 + EN.footer)
    if [ -d "$DICT_DIR" ]; then
        echo -e "${YELLOW}📖 生成并上传字典文件...${NC}"
        local tmp_dict=$(mktemp -d)
        cp "$DICT_DIR/EN.header" "$tmp_dict/EN.dict"
        echo "LANG_BR=Brazil" >> "$tmp_dict/EN.dict"
        echo "LANG_CZ=Česky" >> "$tmp_dict/EN.dict"
        echo "LANG_DA=Dansk" >> "$tmp_dict/EN.dict"
        echo "LANG_DE=Deutsch" >> "$tmp_dict/EN.dict"
        echo "LANG_ES=Español" >> "$tmp_dict/EN.dict"
        echo "LANG_FI=Finsk" >> "$tmp_dict/EN.dict"
        echo "LANG_FR=Français" >> "$tmp_dict/EN.dict"
        echo "LANG_NO=Norsk" >> "$tmp_dict/EN.dict"
        echo "LANG_PL=Polski" >> "$tmp_dict/EN.dict"
        echo "LANG_RU=Pусский" >> "$tmp_dict/EN.dict"
        echo "LANG_SV=Svensk" >> "$tmp_dict/EN.dict"
        echo "LANG_UK=Українська" >> "$tmp_dict/EN.dict"
        echo "LANG_CN=简体中文" >> "$tmp_dict/EN.dict"
        cat "$DICT_DIR/EN.footer" >> "$tmp_dict/EN.dict"
        cp "$DICT_DIR"/*.dict "$tmp_dict/" 2>/dev/null
        cd "$tmp_dict"
        COPYFILE_DISABLE=1 tar --exclude='._*' -cf - . | $SSH_CMD "tar xf - -C /www/"
        rm -rf "$tmp_dict"
        echo -e "${GREEN}✅ 字典文件已上传${NC}"
    fi

    # 验证
    local remote_count=$($SSH_CMD "find /www -type f ! -name '._*' | wc -l" | tr -d ' ')
    local remote_size=$($SSH_CMD "du -sh /www | cut -f1")

    echo ""
    echo -e "${GREEN}✅ 上传完成!${NC}"
    echo "  本地文件数: $file_count -> 设备文件数: $remote_count"
    echo "  设备 /www 占用: $remote_size"
    echo ""

    # 重启 httpd (Padavan httpd 会缓存 ASP 文件, 必须重启才能生效)
    echo -e "${YELLOW}🔄 重启 httpd 使新文件生效...${NC}"
    $SSH_CMD "killall httpd 2>/dev/null; sleep 1; /usr/sbin/httpd -p 80 &" 2>/dev/null
    sleep 2
    if $SSH_CMD "pidof httpd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ httpd 已重启${NC}"
    else
        echo -e "${RED}❌ httpd 重启失败, 请手动重启${NC}"
    fi

    echo ""
    echo -e "${YELLOW}💡 提示:${NC}"
    echo "  - 刷新浏览器查看效果: http://$DEVICE_IP/"
    echo "  - /www 为 tmpfs 覆盖, 重启设备后自动恢复原始固件"
    echo "  - 立即恢复: $0 --restore-all"
}

# 上传并挂载
upload_and_mount() {
    local local_file="$1"
    
    # 检查文件是否存在
    if [ ! -f "$local_file" ]; then
        # 尝试在 WEB_ROOT 下查找
        if [ -f "$WEB_ROOT/$local_file" ]; then
            local_file="$WEB_ROOT/$local_file"
        else
            echo -e "${RED}❌ 文件不存在: $local_file${NC}"
            exit 1
        fi
    fi
    
    # 获取绝对路径
    local_file=$(cd "$(dirname "$local_file")" && pwd)/$(basename "$local_file")
    
    # 计算相对路径（相对于 WEB_ROOT）
    local rel_path="${local_file#$WEB_ROOT/}"
    
    # 如果文件不在 WEB_ROOT 下，用文件名
    if [ "$rel_path" = "$local_file" ]; then
        rel_path=$(basename "$local_file")
    fi
    
    # 设备上的目标路径
    local remote_path="/www/$rel_path"
    local tmp_path="/tmp/$(basename "$local_file")"
    
    echo -e "${YELLOW}📤 上传文件...${NC}"
    echo "  本地: $local_file"
    echo "  设备: $remote_path"
    echo ""
    
    # 上传文件（base64 编码传输）
    base64 -i "$local_file" | $SSH_CMD "base64 -d > $tmp_path" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 上传失败，请检查设备连接${NC}"
        exit 1
    fi
    
    # 取消旧挂载（如果有）
    $SSH_CMD "umount $remote_path 2>/dev/null" 2>/dev/null
    
    # 挂载覆盖
    $SSH_CMD "mount --bind $tmp_path $remote_path" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 上传并挂载成功！${NC}"
        echo ""
        # 重启 httpd (Padavan httpd 会缓存 ASP 文件)
        echo -e "${YELLOW}🔄 重启 httpd...${NC}"
        $SSH_CMD "killall httpd 2>/dev/null; sleep 1; /usr/sbin/httpd -p 80 &" 2>/dev/null
        sleep 2
        echo -e "${YELLOW}💡 提示:${NC}"
        echo "  - 刷新浏览器查看效果"
        echo "  - 重启设备后自动恢复原始"
        echo "  - 恢复原始: $0 $rel_path --restore"
    else
        echo -e "${RED}❌ 挂载失败${NC}"
        exit 1
    fi
}

# 恢复原始
restore_file() {
    local local_file="$1"
    
    # 计算相对路径
    if [ -f "$local_file" ]; then
        local_file=$(cd "$(dirname "$local_file")" && pwd)/$(basename "$local_file")
        local rel_path="${local_file#$WEB_ROOT/}"
    elif [ -f "$WEB_ROOT/$local_file" ]; then
        local rel_path="$local_file"
    else
        local rel_path="$local_file"
    fi
    
    local remote_path="/www/$rel_path"
    
    echo -e "${YELLOW}🔄 恢复原始: $remote_path${NC}"
    
    $SSH_CMD "umount $remote_path 2>/dev/null" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 已恢复原始${NC}"
    else
        echo -e "${YELLOW}⚠️  该文件未被挂载，无需恢复${NC}"
    fi
}

# 查看挂载列表
list_mounts() {
    echo -e "${YELLOW}📋 当前 /www 挂载状态:${NC}"
    echo ""
    $SSH_CMD "mount | grep /www" 2>/dev/null | while read line; do
        echo "  $line"
    done
    echo ""
    echo -e "${YELLOW}💡 提示:${NC}"
    echo "  - 恢复单个: $0 <文件名> --restore"
    echo "  - 恢复全部: $0 --restore-all"
}

# 恢复所有挂载
restore_all() {
    echo -e "${YELLOW}🔄 恢复所有 /www 挂载...${NC}"
    echo ""

    # 先恢复 /www 的 tmpfs 覆盖 (如果有)
    $SSH_CMD "umount /www 2>/dev/null" 2>/dev/null
    # 再恢复单个文件的 mount --bind
    $SSH_CMD "mount | grep /www | awk '{print \$3}' | xargs -I{} umount {} 2>/dev/null" 2>/dev/null

    echo -e "${GREEN}✅ 所有挂载已恢复${NC}"
    echo ""
    list_mounts
}

# 主逻辑
case "$1" in
    --all)
        upload_all
        ;;
    --list)
        list_mounts
        ;;
    --restore-all)
        restore_all
        ;;
    --help|-h|"")
        usage
        ;;
    *)
        FILE="$1"
        if [ "$2" = "--restore" ]; then
            restore_file "$FILE"
        else
            upload_and_mount "$FILE"
        fi
        ;;
esac
