#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${CYAN}==================== SERVER INFORMATION ====================${NC}"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${YELLOW}Distribution${NC} : ${WHITE}$PRETTY_NAME${NC}"
else
    echo -e "${YELLOW}Distribution${NC} : ${RED}Unknown${NC}"
fi

echo -e "${YELLOW}Hostname    ${NC} : ${WHITE}$(hostname)${NC}"
echo -e "${YELLOW}Kernel      ${NC} : ${WHITE}$(uname -r)${NC}"

echo -e "\n${MAGENTA}CPU Info:${NC}"
cpu_model=$(grep -m 1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)
cpu_cores=$(grep -c ^processor /proc/cpuinfo)
cpu_load=$(uptime | awk -F'load average:' '{ print $2 }' | xargs)
echo -e "  ${YELLOW}Model   ${NC}: ${WHITE}$cpu_model${NC}"
echo -e "  ${YELLOW}Cores   ${NC}: ${WHITE}$cpu_cores${NC}"
echo -e "  ${YELLOW}LoadAvg ${NC}: ${WHITE}$cpu_load${NC}"

echo -e "\n${MAGENTA}Memory Info:${NC}"
free -h | awk '/^Mem:/ {printf "  %sTotal:%s %s | %sUsed:%s %s | %sFree:%s %s\n", "'$YELLOW'", "'$NC'", $2, "'$YELLOW'", "'$NC'", $3, "'$YELLOW'", "'$NC'", $4}'
swap=$(free -h | awk '/^Swap:/ {printf "  %sSwap :%s %s | %sUsed:%s %s | %sFree:%s %s\n", "'$YELLOW'", "'$NC'", $2, "'$YELLOW'", "'$NC'", $3, "'$YELLOW'", "'$NC'", $4}')
if [[ -n "$swap" ]]; then
    echo -e "$swap"
fi

echo -e "\n${MAGENTA}Disk Usage:${NC}"
df -h --output=target,size,used,avail,pcent | grep -E '^/|^Mounted' | awk -v Y="$YELLOW" -v N="$NC" -v W="$WHITE" '{printf "  %s%-12s%s Size: %s%-8s%s Used: %s%-8s%s Avail: %s%-8s%s Usage: %s%s%s\n", Y, $1, N, W, $2, N, W, $3, N, W, $4, N, W, $5, N}'

echo -e "\n${MAGENTA}Network Info:${NC}"
ip -o -4 addr show | awk -v Y="$YELLOW" -v N="$NC" -v W="$WHITE" '{print "  " Y "Interface:" N " " W $2 N " | " Y "Address:" N " " W $4 N}' | grep -v 'lo '

echo -e "\n${MAGENTA}Kubernetes Info:${NC}"
if command -v kubectl >/dev/null 2>&1; then
    context=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$context" ]]; then
        echo -e "  ${YELLOW}Context   ${NC}: ${WHITE}$context${NC}"
        kubectl cluster-info 2>/dev/null | grep -E 'master|control plane|Kubernetes control plane' | sed "s/^/  $WHITE/" | sed "s/\$/ $NC/"
        nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
        echo -e "  ${YELLOW}Node Count${NC}: ${WHITE}$nodes${NC}"
    else
        echo -e "  ${RED}No context set or no access to cluster.${NC}"
    fi
else
    echo -e "  ${YELLOW}kubectl not installed${NC}"
fi

echo -e "${CYAN}===========================================================${NC}"
