#!/usr/bin/env bash

# =============== 默认输入设置 ===============
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN="\033[0m"
SAVE_CURSOR="\033[s"
RESTORE_CURSOR="\033[u"
HIDE_CURSOR="\033[?25l"
SHOW_CURSOR="\033[?25h"
_red() { echo -e "\033[31m\033[01m$@\033[0m"; }
_green() { echo -e "\033[32m\033[01m$@\033[0m"; }
_yellow() { echo -e "\033[33m\033[01m$@\033[0m"; }
_blue() { echo -e "\033[36m\033[01m$@\033[0m"; }
# ==========================================
clear

if [ -n "$cname" ] >/dev/null 2>&1; then
    echo " CPU 型号          : $(_blue "$cname")"
elif [ -n "$Result_Systeminfo_CPUModelName" ] >/dev/null 2>&1; then
    echo " CPU 型号          : $(_blue "$Result_Systeminfo_CPUModelName")"
else
    echo " CPU 型号          : $(_blue "无法检测到CPU型号")"
fi
if [[ -n "$Result_Systeminfo_isPhysical" && "$Result_Systeminfo_isPhysical" = "1" ]] >/dev/null 2>&1; then
    if [ -n "$Result_Systeminfo_CPUSockets" ] && [ "$Result_Systeminfo_CPUSockets" -ne 0 ] &&
        [ -n "$Result_Systeminfo_CPUCores" ] && [ "$Result_Systeminfo_CPUCores" -ne 0 ] &&
        [ -n "$Result_Systeminfo_CPUThreads" ] && [ "$Result_Systeminfo_CPUThreads" -ne 0 ] >/dev/null 2>&1; then
        echo " CPU 核心数        : $(_blue "${Result_Systeminfo_CPUSockets} 物理核心, ${Result_Systeminfo_CPUCores} 总核心, ${Result_Systeminfo_CPUThreads} 总线程数")"
    elif [ -n "$cores" ]; then
        echo " CPU 核心数        : $(_blue "$cores")"
    else
        echo " CPU 核心数        : $(_blue "无法检测到CPU核心数量")"
    fi
elif [[ -n "$Result_Systeminfo_isPhysical" && "$Result_Systeminfo_isPhysical" = "0" ]] >/dev/null 2>&1; then
    if [[ -n "$Result_Systeminfo_CPUThreads" && "$Result_Systeminfo_CPUThreads" -ne 0 ]] >/dev/null 2>&1; then
        echo " CPU 核心数        : $(_blue "${Result_Systeminfo_CPUThreads}")"
    elif [ -n "$cores" ] >/dev/null 2>&1; then
        echo " CPU 核心数        : $(_blue "$cores")"
    else
        echo " CPU 核心数        : $(_blue "无法检测到CPU核心数量")"
    fi
else
    echo " CPU 核心数        : $(_blue "$cores")"
fi
if [ -n "$freq" ] >/dev/null 2>&1; then
    echo " CPU 频率          : $(_blue "$freq MHz")"
fi
if [ -n "$Result_Systeminfo_CPUCacheSizeL1" ] && [ -n "$Result_Systeminfo_CPUCacheSizeL2" ] && [ -n "$Result_Systeminfo_CPUCacheSizeL3" ] >/dev/null 2>&1; then
    echo " CPU 缓存          : $(_blue "L1: ${Result_Systeminfo_CPUCacheSizeL1} / L2: ${Result_Systeminfo_CPUCacheSizeL2} / L3: ${Result_Systeminfo_CPUCacheSizeL3}")"
elif [ -n "$ccache" ] >/dev/null 2>&1; then
    echo " CPU 缓存          : $(_blue "$ccache")"
fi
[[ -z "$CPU_AES" ]] && CPU_AES="\xE2\x9D\x8C Disabled" || CPU_AES="\xE2\x9C\x94 Enabled"
echo " AES-NI指令集      : $(_blue "$CPU_AES")"
[[ -z "$CPU_VIRT" ]] && CPU_VIRT="\xE2\x9D\x8C Disabled" || CPU_VIRT="\xE2\x9C\x94 Enabled"
echo " VM-x/AMD-V支持    : $(_blue "$CPU_VIRT")"
if [ -n "$Result_Systeminfo_Memoryinfo" ] >/dev/null 2>&1; then
    echo " 内存              : $(_blue "$Result_Systeminfo_Memoryinfo")"
elif [ -n "$tram" ] && [ -n "$uram" ] >/dev/null 2>&1; then
    echo " 内存              : $(_yellow "$tram MB") $(_blue "($uram MB 已用)")"
fi
if [ -n "$Result_Systeminfo_Swapinfo" ] >/dev/null 2>&1; then
    echo " Swap              : $(_blue "$Result_Systeminfo_Swapinfo")"
elif [ -n "$swap" ] && [ -n "$uswap" ] >/dev/null 2>&1; then
    echo " Swap              : $(_blue "$swap MB ($uswap MB 已用)")"
fi
if [ -n "$Result_Systeminfo_Diskinfo" ] >/dev/null 2>&1; then
    echo " 硬盘空间          : $(_blue "$Result_Systeminfo_Diskinfo")"
else
    echo " 硬盘空间          : $(_yellow "$disk_total_size GB") $(_blue "($disk_used_size GB 已用)")"
fi
if [ -n "$Result_Systeminfo_DiskRootPath" ] >/dev/null 2>&1; then
    echo " 启动盘路径        : $(_blue "$Result_Systeminfo_DiskRootPath")"
fi
echo " 系统在线时间      : $(_blue "$up")"
echo " 负载              : $(_blue "$load")"
if [ -n "$Result_Systeminfo_OSReleaseNameFull" ] >/dev/null 2>&1; then
    echo " 系统              : $(_blue "$Result_Systeminfo_OSReleaseNameFull")"
elif [ -n "$DISTRO" ] >/dev/null 2>&1; then
    echo " 系统              : $(_blue "$DISTRO")"
fi
echo " 架构              : $(_blue "$arch ($lbit Bit)")"
echo " 内核              : $(_blue "$kern")"
echo " TCP加速方式       : $(_yellow "$tcpctrl")"
echo " 虚拟化架构        : $(_blue "$Result_Systeminfo_VMMType")"
[[ -n "$nat_type_r" ]] && echo " NAT类型           : $(_blue "$nat_type_r")"
