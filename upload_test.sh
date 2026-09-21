#!/bin/bash
# Padavan 固件 Web 文件一键上传测试脚本
# 用法:
#   ./upload_test.sh <文件路径>           # 上传并挂载
#   ./upload_test.sh <文件路径> --restore  # 恢复原始
#   ./upload_test.sh --list               # 查看当前挂载
#   ./upload_test.sh --restore-all        # 恢复所有挂载

# 设备配置
DEVICE_IP="192.168.3.1"
DEVICE_USER="admin"
DEVICE_PASS="admin"

# Web 根目录（本地）
WEB_ROOT="/Volumes/Padavan/GitHub/test/trunk/user/www/n56u_ribbon_fixed"

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
    echo "  $0 <文件路径>           上传并挂载到设备"
    echo "  $0 <文件路径> --restore  恢复原始文件"
    echo "  $0 --list               查看当前挂载状态"
    echo "  $0 --restore-all        恢复所有挂载"
    echo ""
    echo "示例:"
    echo "  $0 state.js"
    echo "  $0 bootstrap/css/bootstrap.min.css"
    echo "  $0 state.js --restore"
    exit 1
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
    
    $SSH_CMD "mount | grep /www | awk '{print \$3}' | xargs -I{} umount {} 2>/dev/null" 2>/dev/null
    
    echo -e "${GREEN}✅ 所有挂载已恢复${NC}"
    echo ""
    list_mounts
}

# 主逻辑
case "$1" in
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
