#!/usr/bin/env bash
[[ $- == *i* ]] || return 0

# ── Colors ───────────────────────────────────────────────────────────────────
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

clear

# ── ASCII Logo ────────────────────────────────────────────────────────────────
echo -e "${CYAN}"
if command -v figlet >/dev/null 2>&1; then
  figlet -f slant "COMMANDOR"
else
  echo "   ___  ___  _  _  __  __   __   __ _  ____   ___  ____ "
  echo "  / __)/ _ \( \/ )(  \/  ) / _\ (  ( \(    \ /   \(  _ \\"
  echo " ( (__(  O ))  (  )    (  /    \/    / ) D (  O  O ))   /"
  echo "  \___)\___/(__/  (__/\_) \_/\_/\_)__)  (____/ \___/(__\_)"
fi
echo -e "${RESET}"

echo -e "                 ${WHITE}${BOLD}HOSTING SERVER${RESET}"
echo -e "                    ${GREEN}@xpT_T${RESET}"
echo

# ── Divider ───────────────────────────────────────────────────────────────────
echo -e "${GRAY}════════════════════════════════════════════════════════════${RESET}"

# ── System Info ───────────────────────────────────────────────────────────────
echo -e " ${CYAN}${BOLD}SYSTEM INFORMATION${RESET}"
echo -e " ${GRAY}────────────────────────────────────────────────────────────${RESET}"
echo -e "  Hostname  : ${WHITE}$(hostname)${RESET}"
echo -e "  OS        : ${WHITE}$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo "Linux")${RESET}"
echo -e "  Kernel    : ${WHITE}$(uname -r)${RESET}"
echo -e "  Uptime    : ${WHITE}$(uptime -p 2>/dev/null | sed 's/up //' || uptime | awk -F',' '{print $1}' | awk '{print $3,$4}')${RESET}"

# ── Resource Usage ────────────────────────────────────────────────────────────
echo
echo -e " ${CYAN}${BOLD}RESOURCE USAGE${RESET}"
echo -e " ${GRAY}────────────────────────────────────────────────────────────${RESET}"

# CPU usage (1-second sample)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' 2>/dev/null || echo "N/A")
echo -e "  CPU       : ${WHITE}${CPU_USAGE}% used${RESET}"

# CPU cores
CPU_CORES=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "?")
echo -e "  CPU Cores : ${WHITE}${CPU_CORES} core(s)${RESET}"

# RAM
MEM_LINE=$(free -h 2>/dev/null | awk 'NR==2')
MEM_USED=$(echo "$MEM_LINE" | awk '{print $3}')
MEM_TOTAL=$(echo "$MEM_LINE" | awk '{print $2}')
MEM_PCT=$(free 2>/dev/null | awk 'NR==2 {printf "%.0f", $3/$2*100}')
echo -e "  Memory    : ${WHITE}${MEM_USED} / ${MEM_TOTAL} (${MEM_PCT}%)${RESET}"

# Disk
DISK_LINE=$(df -h / 2>/dev/null | awk 'NR==2')
DISK_USED=$(echo "$DISK_LINE" | awk '{print $3}')
DISK_TOTAL=$(echo "$DISK_LINE" | awk '{print $2}')
DISK_PCT=$(echo "$DISK_LINE" | awk '{print $5}')
echo -e "  Disk      : ${WHITE}${DISK_USED} / ${DISK_TOTAL} (${DISK_PCT})${RESET}"

# ── Dev Tools ─────────────────────────────────────────────────────────────────
echo
echo -e " ${CYAN}${BOLD}DEVELOPMENT TOOLS${RESET}"
echo -e " ${GRAY}────────────────────────────────────────────────────────────${RESET}"
command -v node    >/dev/null && echo -e "  Node.js   : ${WHITE}$(node --version)${RESET}"
command -v npm     >/dev/null && echo -e "  NPM       : ${WHITE}$(npm --version)${RESET}"
command -v python3 >/dev/null && echo -e "  Python    : ${WHITE}$(python3 --version 2>&1 | awk '{print $2}')${RESET}"
command -v pm2     >/dev/null && echo -e "  PM2       : ${WHITE}v$(pm2 --version 2>/dev/null | tail -1)${RESET}"
command -v pnpm    >/dev/null && echo -e "  pnpm      : ${WHITE}v$(pnpm --version 2>/dev/null)${RESET}"
command -v yarn    >/dev/null && echo -e "  Yarn      : ${WHITE}v$(yarn --version 2>/dev/null)${RESET}"
command -v tsc     >/dev/null && echo -e "  TypeScript: ${WHITE}v$(tsc --version 2>/dev/null | awk '{print $2}')${RESET}"

# ── Listening Ports ───────────────────────────────────────────────────────────
echo
echo -e " ${CYAN}${BOLD}LISTENING PORTS${RESET}"
echo -e " ${GRAY}────────────────────────────────────────────────────────────${RESET}"
PORTS=$(ss -tlnp 2>/dev/null | awk 'NR>1 {
  split($4,a,":");
  port=a[length(a)];
  match($6,/users:\(\("([^"]+)"/,m);
  proc=m[1]; if(proc=="") proc="?";
  if(port != "") printf "  %-6s  %s\n", port, proc
}' | sort -u -k1 -n)

if [[ -n "$PORTS" ]]; then
  echo -e "  ${GRAY}PORT    PROCESS${RESET}"
  echo "$PORTS" | while IFS= read -r line; do
    echo -e "  ${WHITE}${line}${RESET}"
  done
else
  echo -e "  ${GRAY}No listening ports found${RESET}"
fi

# ── PM2 Processes ─────────────────────────────────────────────────────────────
if command -v pm2 >/dev/null 2>&1; then
  echo
  echo -e " ${CYAN}${BOLD}PM2 PROCESSES${RESET}"
  echo -e " ${GRAY}────────────────────────────────────────────────────────────${RESET}"
  PM2_LIST=$(pm2 jlist 2>/dev/null)
  if [[ -z "$PM2_LIST" || "$PM2_LIST" == "[]" ]]; then
    echo -e "  ${GRAY}No PM2 processes running${RESET}"
  else
    echo -e "  ${GRAY}NAME              STATUS     CPU    MEM    PID${RESET}"
    echo "$PM2_LIST" | python3 -c "
import sys, json
try:
  procs = json.load(sys.stdin)
  for p in procs:
    name   = p.get('name','?')[:16]
    status = p.get('pm2_env',{}).get('status','?')
    pid    = p.get('pid','?')
    cpu    = p.get('monit',{}).get('cpu','?')
    mem_b  = p.get('monit',{}).get('memory',0)
    mem    = f'{mem_b//1024//1024}MB' if isinstance(mem_b,int) else '?'
    color  = '\033[1;32m' if status=='online' else '\033[1;31m'
    rst    = '\033[0m'
    print(f'  {name:<17} {color}{status:<10}{rst} {str(cpu)+\"%\":<6} {mem:<6} {pid}')
except Exception as e:
  print(f'  (parse error: {e})')
" 2>/dev/null || echo -e "  ${GRAY}(could not parse PM2 list)${RESET}"
  fi
fi

# ── Footer ────────────────────────────────────────────────────────────────────
echo
echo -e "${GRAY}════════════════════════════════════════════════════════════${RESET}"
echo -e "  ${YELLOW}${BOLD}Quick commands:${RESET}  ${WHITE}pm2 list${RESET} │ ${WHITE}pm2 logs${RESET} │ ${WHITE}htop${RESET} │ ${WHITE}tmux${RESET}"
echo -e "${GRAY}════════════════════════════════════════════════════════════${RESET}"
echo -e "  ${GREEN}${BOLD}COMMANDOR HOSTING SERVER${RESET}  ${GRAY}│${RESET}  Contact: ${WHITE}@xpT_T${RESET}"
echo -e "${GRAY}════════════════════════════════════════════════════════════${RESET}"
echo
