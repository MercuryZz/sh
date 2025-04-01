#
# ===========================================================================
# -> 系统信息模块 (Entrypoint) -> 执行
function Func_Systeminfo_GetSysteminfo() {
    API_Systeminfo_GetCPUinfo
    API_Systeminfo_GetVMMinfo
    API_Systeminfo_GetMemoryinfo
    API_Systeminfo_GetDiskinfo
    API_Systeminfo_GetOSReleaseinfo
    API_Systeminfo_GetLinuxKernelinfo
}
# -> 系统信息模块 (DisplayOutput) -> 输出系统信息
function Func_Systeminfo_ShowSysteminfo() {
    echo -e "\n${Font_Yellow} -> System Information${Font_Suffix}\n"
    echo -e " ${Font_Yellow}CPU Model Name:${Font_Suffix}\t\t${Font_SkyBlue}${Result_Systeminfo_CPUModelName}"
    echo -e " ${Font_Yellow}CPU Cache Size:${Font_Suffix}\t\t${Font_SkyBlue}L1: ${Result_Systeminfo_CPUCacheSizeL1} / L2: ${Result_Systeminfo_CPUCacheSizeL2} / L3: ${Result_Systeminfo_CPUCacheSizeL3}"
    if [ "${Result_Systeminfo_isPhysical}" = "1" ]; then
        echo -e " ${Font_Yellow}CPU Specifications:${Font_Suffix}\t\t${Font_SkyBlue}${Result_Systeminfo_CPUSockets} Socket(s), ${Result_Systeminfo_CPUCores} Core(s), ${Result_Systeminfo_CPUThreads} Thread(s)"
        if [ "${Result_Systeminfo_VirtReady}" = "1" ]; then
            if [ "${Result_Systeminfo_IOMMU}" = "1" ]; then
                echo -e " ${Font_Yellow}Virtualization Ready:${Font_Suffix}\t\t${Font_SkyBlue}Yes (Based on ${Result_Systeminfo_CPUVMX}, IOMMU Enabled)${Font_Suffix}"
            else
                echo -e " ${Font_Yellow}Virtualization Ready:${Font_Suffix}\t\t${Font_SkyBlue}Yes (Based on ${Result_Systeminfo_CPUVMX})${Font_Suffix}"
            fi
        else
            echo -e " ${Font_Yellow}Virtualization Ready:${Font_Suffix}\t\t${Font_SkyBlue}No${Font_Suffix}"
        fi
    elif [ "$Result_Systeminfo_isPhysical" = "0" ]; then
        echo -e " ${Font_Yellow}CPU Specifications:${Font_Suffix}\t\t${Font_SkyBlue}${Result_Systeminfo_CPUThreads} vCPU(s)${Font_Suffix}"
        if [ "${Result_Systeminfo_VirtReady}" = "1" ]; then
            if [ "${Result_Systeminfo_IOMMU}" = "1" ]; then
                echo -e " ${Font_Yellow}Virtualization Ready:${Font_Suffix}\t\t${Font_SkyBlue}Yes (Based on ${Result_Systeminfo_CPUVMX}, Nested Virtualization Enabled, IOMMU Enabled${Font_Suffix})"
            else
                echo -e " ${Font_Yellow}Virtualization Ready:${Font_Suffix}\t\t${Font_SkyBlue}Yes (Based on ${Result_Systeminfo_CPUVMX}, Nested Virtualization Enabled${Font_Suffix})"
            fi
        else
            echo -e " ${Font_Yellow}Virtualization Ready:${Font_Suffix}\t\t${Font_SkyBlue}No${Font_Suffix}"
        fi
    fi
    echo -e " ${Font_Yellow}Virtualization Type:${Font_Suffix}\t\t${Font_SkyBlue}${Result_Systeminfo_VMMType}${Font_Suffix}"
    echo -e " ${Font_Yellow}Memory Usage:${Font_Suffix}\t\t\t${Font_SkyBlue}${Result_Systeminfo_Memoryinfo}${Font_Suffix}"
    echo -e " ${Font_Yellow}Swap Usage:${Font_Suffix}\t\t\t${Font_SkyBlue}${Result_Systeminfo_Swapinfo}${Font_Suffix}"
    echo -e " ${Font_Yellow}Disk Usage:${Font_Suffix}\t\t\t${Font_SkyBlue}${Result_Systeminfo_Diskinfo}${Font_Suffix}"
    echo -e " ${Font_Yellow}Boot Disk:${Font_Suffix}\t\t\t${Font_SkyBlue}${Result_Systeminfo_DiskRootPath}${Font_Suffix}"
    echo -e " ${Font_Yellow}OS Release:${Font_Suffix}\t\t\t${Font_SkyBlue}${Result_Systeminfo_OSReleaseNameFull}${Font_Suffix}"
    echo -e " ${Font_Yellow}Kernel Version:${Font_Suffix}\t\t${Font_SkyBlue}${Result_Systeminfo_LinuxKernelVersion}${Font_Suffix}"
    return 0
}
#
# -> 系统信息模块 (Collector) -> 获取CPU信息
function API_Systeminfo_GetCPUinfo() {
    # CPU 基础信息检测
    local r_modelname && r_modelname="$(lscpu -B 2>/dev/null | grep -oP -m1 "(?<=Model name:).*(?=)" | sed -e 's/^[ ]*//g')"
    local r_cachesize_l1d_b && r_cachesize_l1d_b="$(lscpu -B 2>/dev/null | grep -oP "(?<=L1d cache:).*(?=)" | sed -e 's/^[ ]*//g')"
    local r_cachesize_l1i_b && r_cachesize_l1i_b="$(lscpu -B 2>/dev/null | grep -oP "(?<=L1i cache:).*(?=)" | sed -e 's/^[ ]*//g')"
    local r_cachesize_l1_b && r_cachesize_l1_b="$(echo "$r_cachesize_l1d_b" "$r_cachesize_l1i_b" | awk '{printf "%d\n",$1+$2}')"
    local r_cachesize_l1_k && r_cachesize_l1_k="$(echo "$r_cachesize_l1_b" | awk '{printf "%.2f\n",$1/1024}')"
    local t_cachesize_l1_k && t_cachesize_l1_k="$(echo "$r_cachesize_l1_b" | awk '{printf "%d\n",$1/1024}')"
    if [ "$t_cachesize_l1_k" -ge "1024" ]; then
        local r_cachesize_l1_m && r_cachesize_l1_m="$(echo "$r_cachesize_l1_k" | awk '{printf "%.2f\n",$1/1024}')"
        local r_cachesize_l1="$r_cachesize_l1_m MB"
    else
        local r_cachesize_l1="$r_cachesize_l1_k KB"
    fi
    local r_cachesize_l2_b && r_cachesize_l2_b="$(lscpu -B 2>/dev/null | grep -oP "(?<=L2 cache:).*(?=)" | sed -e 's/^[ ]*//g')"
    local r_cachesize_l2_k && r_cachesize_l2_k="$(echo "$r_cachesize_l2_b" | awk '{printf "%.2f\n",$1/1024}')"
    local t_cachesize_l2_k && t_cachesize_l2_k="$(echo "$r_cachesize_l2_b" | awk '{printf "%d\n",$1/1024}')"
    if [ "$t_cachesize_l2_k" -ge "1024" ]; then
        local r_cachesize_l2_m && r_cachesize_l2_m="$(echo "$r_cachesize_l2_k" | awk '{printf "%.2f\n",$1/1024}')"
        local r_cachesize_l2="$r_cachesize_l2_m MB"
    else
        local r_cachesize_l2="$r_cachesize_l2_k KB"
    fi
    local r_cachesize_l3_b && r_cachesize_l3_b="$(lscpu -B 2>/dev/null | grep -oP "(?<=L3 cache:).*(?=)" | sed -e 's/^[ ]*//g')"
    local r_cachesize_l3_k && r_cachesize_l3_k="$(echo "$r_cachesize_l3_b" | awk '{printf "%.2f\n",$1/1024}')"
    local t_cachesize_l3_k && t_cachesize_l3_k="$(echo "$r_cachesize_l3_b" | awk '{printf "%d\n",$1/1024}')"
    if [ "$t_cachesize_l3_k" -ge "1024" ]; then
        local r_cachesize_l3_m && r_cachesize_l3_m="$(echo "$r_cachesize_l3_k" | awk '{printf "%.2f\n",$1/1024}')"
        local r_cachesize_l3="$r_cachesize_l3_m MB"
    else
        local r_cachesize_l3="$r_cachesize_l3_k KB"
    fi
    local r_sockets && r_sockets="$(lscpu -B 2>/dev/null | grep -oP "(?<=Socket\(s\):).*(?=)" | sed -e 's/^[ ]*//g')"
    if [ "$r_sockets" -ge "2" ]; then
        local r_cores && r_cores="$(lscpu -B 2>/dev/null | grep -oP "(?<=Core\(s\) per socket:).*(?=)" | sed -e 's/^[ ]*//g')"
        r_cores="$(echo "$r_sockets" "$r_cores" | awk '{printf "%d\n",$1*$2}')"
        local r_threadpercore && r_threadpercore="$(lscpu -B 2>/dev/null | grep -oP "(?<=Thread\(s\) per core:).*(?=)" | sed -e 's/^[ ]*//g')"
        local r_threads && r_threads="$(echo "$r_cores" "$r_threadpercore" | awk '{printf "%d\n",$1*$2}')"
        r_threads="$(echo "$r_threadpercore" "$r_cores" | awk '{printf "%d\n",$1*$2}')"
    else
        local r_cores && r_cores="$(lscpu -B 2>/dev/null | grep -oP "(?<=Core\(s\) per socket:).*(?=)" | sed -e 's/^[ ]*//g')"
        local r_threadpercore && r_threadpercore="$(lscpu -B 2>/dev/null | grep -oP "(?<=Thread\(s\) per core:).*(?=)" | sed -e 's/^[ ]*//g')"
        local r_threads && r_threads="$(echo "$r_cores" "$r_threadpercore" | awk '{printf "%d\n",$1*$2}')"
    fi
    # CPU AES能力检测
    # local t_aes && t_aes="$(awk -F ': ' '/flags/{print $2}' /proc/cpuinfo 2>/dev/null | grep -oE "\baes\b" | sort -u)"
    # [[ "${t_aes}" = "aes" ]] && Result_Systeminfo_CPUAES="1" || Result_Systeminfo_CPUAES="0"
    # CPU AVX能力检测
    # local t_avx && t_avx="$(awk -F ': ' '/flags/{print $2}' /proc/cpuinfo 2>/dev/null | grep -oE "\bavx\b" | sort -u)"
    # [[ "${t_avx}" = "avx" ]] && Result_Systeminfo_CPUAVX="1" || Result_Systeminfo_CPUAVX="0"
    # CPU AVX512能力检测
    # local t_avx512 && t_avx512="$(awk -F ': ' '/flags/{print $2}' /proc/cpuinfo 2>/dev/null | grep -oE "\bavx512\b" | sort -u)"
    # [[ "${t_avx512}" = "avx" ]] && Result_Systeminfo_CPUAVX512="1" || Result_Systeminfo_CPUAVX512="0"
    # CPU 虚拟化能力检测
    local t_vmx_vtx && t_vmx_vtx="$(awk -F ': ' '/flags/{print $2}' /proc/cpuinfo 2>/dev/null | grep -oE "\bvmx\b" | sort -u)"
    local t_vmx_svm && t_vmx_svm="$(awk -F ': ' '/flags/{print $2}' /proc/cpuinfo 2>/dev/null | grep -oE "\bsvm\b" | sort -u)"
    if [ "$t_vmx_vtx" = "vmx" ]; then
        Result_Systeminfo_VirtReady="1"
        Result_Systeminfo_CPUVMX="Intel VT-x"
    elif [ "$t_vmx_svm" = "svm" ]; then
        Result_Systeminfo_VirtReady="1"
        Result_Systeminfo_CPUVMX="AMD-V"
    else
        if [ -c "/dev/kvm" ]; then
            Result_Systeminfo_VirtReady="1"
            Result_Systeminfo_CPUVMX="unknown"
        else
            Result_Systeminfo_VirtReady="0"
            Result_Systeminfo_CPUVMX="unknown"
        fi
    fi
    # 输出结果
    Result_Systeminfo_CPUModelName="$r_modelname"
    Result_Systeminfo_CPUSockets="$r_sockets"
    Result_Systeminfo_CPUCores="$r_cores"
    Result_Systeminfo_CPUThreads="$r_threads"
    Result_Systeminfo_CPUCacheSizeL1="$r_cachesize_l1"
    Result_Systeminfo_CPUCacheSizeL2="$r_cachesize_l2"
    Result_Systeminfo_CPUCacheSizeL3="$r_cachesize_l3"
}
#
# -> 系统信息模块 (Collector) -> 获取内存及Swap信息
function API_Systeminfo_GetMemoryinfo() {
    # 内存信息
    local r_memtotal_kib && r_memtotal_kib="$(awk '/MemTotal/{print $2}' /proc/meminfo | head -n1)"
    local r_memtotal_mib && r_memtotal_mib="$(echo "$r_memtotal_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_memtotal_gib && r_memtotal_gib="$(echo "$r_memtotal_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    local r_meminfo_memfree_kib && r_meminfo_memfree_kib="$(awk '/MemFree/{print $2}' /proc/meminfo | head -n1)"
    local r_meminfo_buffers_kib && r_meminfo_buffers_kib="$(awk '/Buffers/{print $2}' /proc/meminfo | head -n1)"
    local r_meminfo_cached_kib && r_meminfo_cached_kib="$(awk '/Cached/{print $2}' /proc/meminfo | head -n1)"
    local r_memfree_kib && r_memfree_kib="$(echo "$r_meminfo_memfree_kib" "$r_meminfo_buffers_kib" "$r_meminfo_cached_kib" | awk '{printf $1+$2+$3}')"
    local r_memfree_mib && r_memfree_mib="$(echo "$r_memfree_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_memfree_gib && r_memfree_gib="$(echo "$r_memfree_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    local r_memused_kib && r_memused_kib="$(echo "$r_memtotal_kib" "$r_memfree_kib" | awk '{printf $1-$2}')"
    local r_memused_mib && r_memused_mib="$(echo "$r_memused_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_memused_gib && r_memused_gib="$(echo "$r_memused_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    # 交换信息
    local r_swaptotal_kib && r_swaptotal_kib="$(awk '/SwapTotal/{print $2}' /proc/meminfo | head -n1)"
    local r_swaptotal_mib && r_swaptotal_mib="$(echo "$r_swaptotal_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_swaptotal_gib && r_swaptotal_gib="$(echo "$r_swaptotal_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    local r_swapfree_kib && r_swapfree_kib="$(awk '/SwapFree/{print $2}' /proc/meminfo | head -n1)"
    local r_swapfree_mib && r_swapfree_mib="$(echo "$r_swapfree_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_swapfree_gib && r_swapfree_gib="$(echo "$r_swapfree_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    local r_swapused_kib && r_swapused_kib="$(echo "$r_swaptotal_kib" "${r_swapfree_kib}" | awk '{printf $1-$2}')"
    local r_swapused_mib && r_swapused_mib="$(echo "$r_swapused_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_swapused_gib && r_swapused_gib="$(echo "$r_swapused_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    # 数据加工
    if [ "$r_memused_kib" -lt "1024" ] && [ "$r_memtotal_kib" -lt "1048576" ]; then
        Result_Systeminfo_Memoryinfo="$r_memused_kib KiB / $r_memtotal_mib MiB"
    elif [ "$r_memused_kib" -lt "1048576" ] && [ "$r_memtotal_kib" -lt "1048576" ]; then
        Result_Systeminfo_Memoryinfo="$r_memused_mib MiB / $r_memtotal_mib MiB"
    elif [ "$r_memused_kib" -lt "1048576" ] && [ "$r_memtotal_kib" -lt "1073741824" ]; then
        Result_Systeminfo_Memoryinfo="$r_memused_mib MiB / $r_memtotal_gib GiB"
    else
        Result_Systeminfo_Memoryinfo="$r_memused_gib GiB / $r_memtotal_gib GiB"
    fi
    if [ "$r_swaptotal_kib" -eq "0" ]; then
        Result_Systeminfo_Swapinfo="[ no swap partition or swap file detected ]"
    elif [ "$r_swapused_kib" -lt "1024" ] && [ "$r_swaptotal_kib" -lt "1048576" ]; then
        Result_Systeminfo_Swapinfo="$r_swapused_kib KiB / $r_swaptotal_mib MiB"
    elif [ "$r_swapused_kib" -lt "1024" ] && [ "$r_swaptotal_kib" -lt "1073741824" ]; then
        Result_Systeminfo_Swapinfo="$r_swapused_kib KiB / $r_swaptotal_gib GiB"
    elif [ "$r_swapused_kib" -lt "1048576" ] && [ "$r_swaptotal_kib" -lt "1048576" ]; then
        Result_Systeminfo_Swapinfo="$r_swapused_mib MiB / $r_swaptotal_mib MiB"
    elif [ "$r_swapused_kib" -lt "1048576" ] && [ "$r_swaptotal_kib" -lt "1073741824" ]; then
        Result_Systeminfo_Swapinfo="$r_swapused_mib MiB / $r_swaptotal_gib GiB"
    else
        Result_Systeminfo_Swapinfo="$r_swapused_gib GiB / $r_swaptotal_gib GiB"
    fi
}
#
# -> 系统信息模块 (Collector) -> 获取磁盘信息
function API_Systeminfo_GetDiskinfo() {
    # 磁盘信息
    local r_diskpath_root && r_diskpath_root="$(df -x tmpfs / | awk "NR>1" | sed ":a;N;s/\\n//g;ta" | awk '{print $1}')"
    local r_disktotal_kib && r_disktotal_kib="$(df -x tmpfs / | grep -oE "[0-9]{4,}" | awk 'NR==1 {print $1}')"
    local r_disktotal_mib && r_disktotal_mib="$(echo "$r_disktotal_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_disktotal_gib && r_disktotal_gib="$(echo "$r_disktotal_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    local r_disktotal_tib && r_disktotal_tib="$(echo "$r_disktotal_kib" | awk '{printf "%.2f\n",$1/1073741824}')"
    local r_diskused_kib && r_diskused_kib="$(df -x tmpfs / | grep -oE "[0-9]{4,}" | awk 'NR==2 {print $1}')"
    local r_diskused_mib && r_diskused_mib="$(echo "$r_diskused_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_diskused_gib && r_diskused_gib="$(echo "$r_diskused_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    local r_diskused_tib && r_diskused_tib="$(echo "$r_diskused_kib" | awk '{printf "%.2f\n",$1/1073741824}')"
    local r_diskfree_kib && r_diskfree_kib="$(df -x tmpfs / | grep -oE "[0-9]{4,}" | awk 'NR==3 {print $1}')"
    local r_diskfree_mib && r_diskfree_mib="$(echo "$r_diskfree_kib" | awk '{printf "%.2f\n",$1/1024}')"
    local r_diskfree_gib && r_diskfree_gib="$(echo "$r_diskfree_kib" | awk '{printf "%.2f\n",$1/1048576}')"
    local r_diskfree_tib && r_diskfree_tib="$(echo "$r_diskfree_kib" | awk '{printf "%.2f\n",$1/1073741824}')"
    # 数据加工
    Result_Systeminfo_DiskRootPath="$r_diskpath_root"
    if [ "$r_diskused_kib" -lt "1048576" ]; then
        Result_Systeminfo_Diskinfo="$r_diskused_mib MiB / $r_disktotal_mib MiB"
    elif [ "$r_diskused_kib" -lt "1048576" ] && [ "$r_disktotal_kib" -lt "1073741824" ]; then
        Result_Systeminfo_Diskinfo="$r_diskused_mib MiB / $r_disktotal_gib GiB"
    elif [ "$r_diskused_kib" -lt "1073741824" ] && [ "$r_disktotal_kib" -lt "1073741824" ]; then
        Result_Systeminfo_Diskinfo="$r_diskused_gib GiB / $r_disktotal_gib GiB"
    elif [ "$r_diskused_kib" -lt "1073741824" ] && [ "$r_disktotal_kib" -ge "1073741824" ]; then
        Result_Systeminfo_Diskinfo="$r_diskused_gib GiB / $r_disktotal_tib TiB"
    else
        Result_Systeminfo_Diskinfo="$r_diskused_tib TiB / $r_disktotal_tib TiB"
    fi
}
#
# -> 系统信息模块 (Collector) -> 获取虚拟化信息
function API_Systeminfo_GetVMMinfo() {
    if [ -f "/usr/bin/systemd-detect-virt" ]; then
        local r_vmmtype && r_vmmtype="$(/usr/bin/systemd-detect-virt 2>/dev/null)"
        case "${r_vmmtype}" in
        kvm)
            Result_Systeminfo_VMMType="KVM"
            Result_Systeminfo_VMMTypeShort="kvm"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        xen)
            Result_Systeminfo_VMMType="Xen Hypervisor"
            Result_Systeminfo_VMMTypeShort="xen"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        microsoft)
            Result_Systeminfo_VMMType="Microsoft Hyper-V"
            Result_Systeminfo_VMMTypeShort="microsoft"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        vmware)
            Result_Systeminfo_VMMType="VMware"
            Result_Systeminfo_VMMTypeShort="vmware"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        oracle)
            Result_Systeminfo_VMMType="Oracle VirtualBox"
            Result_Systeminfo_VMMTypeShort="oracle"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        parallels)
            Result_Systeminfo_VMMType="Parallels"
            Result_Systeminfo_VMMTypeShort="parallels"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        qemu)
            Result_Systeminfo_VMMType="QEMU"
            Result_Systeminfo_VMMTypeShort="qemu"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        amazon)
            Result_Systeminfo_VMMType="Amazon Virtualization"
            Result_Systeminfo_VMMTypeShort="amazon"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        docker)
            Result_Systeminfo_VMMType="Docker"
            Result_Systeminfo_VMMTypeShort="docker"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        openvz)
            Result_Systeminfo_VMMType="OpenVZ (Virutozzo)"
            Result_Systeminfo_VMMTypeShort="openvz"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        lxc)
            Result_Systeminfo_VMMTypeShort="lxc"
            Result_Systeminfo_VMMType="LXC"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        lxc-libvirt)
            Result_Systeminfo_VMMType="LXC (Based on libvirt)"
            Result_Systeminfo_VMMTypeShort="lxc-libvirt"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        uml)
            Result_Systeminfo_VMMType="User-mode Linux"
            Result_Systeminfo_VMMTypeShort="uml"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        systemd-nspawn)
            Result_Systeminfo_VMMType="Systemd nspawn"
            Result_Systeminfo_VMMTypeShort="systemd-nspawn"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        bochs)
            Result_Systeminfo_VMMType="BOCHS"
            Result_Systeminfo_VMMTypeShort="bochs"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        rkt)
            Result_Systeminfo_VMMType="RKT"
            Result_Systeminfo_VMMTypeShort="rkt"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        zvm)
            Result_Systeminfo_VMMType="S390 Z/VM"
            Result_Systeminfo_VMMTypeShort="zvm"
            Result_Systeminfo_isPhysical="0"
            return 0
            ;;
        none)
            Result_Systeminfo_VMMType="Dedicated"
            Result_Systeminfo_VMMTypeShort="none"
            Result_Systeminfo_isPhysical="1"
            if test -f "/sys/class/iommu/dmar0/uevent"; then
                Result_Systeminfo_IOMMU="1"
            else
                Result_Systeminfo_IOMMU="0"
            fi
            return 0
            ;;
        *)
            echo -e "${Msg_Error} API_Systeminfo_GetVirtinfo(): invalid result (${r_vmmtype}), please check parameter!"
            exit 1
            ;;
        esac
    elif [ -f "/.dockerenv" ]; then
        Result_Systeminfo_VMMType="Docker"
        Result_Systeminfo_VMMTypeShort="docker"
        Result_Systeminfo_isPhysical="0"
        return 0
    elif [ -c "/dev/lxss" ]; then
        Result_Systeminfo_VMMType="Windows Subsystem for Linux"
        Result_Systeminfo_VMMTypeShort="wsl"
        Result_Systeminfo_isPhysical="0"
        return 0
    else
        Result_Systeminfo_VMMType="Dedicated"
        Result_Systeminfo_VMMTypeShort="none"
        if test -f "/sys/class/iommu/dmar0/uevent"; then
            Result_Systeminfo_IOMMU="1"
        else
            Result_Systeminfo_IOMMU="0"
        fi
        return 0
    fi
}
#
# -> 系统信息模块 (Collector) -> 获取Linux发行版信息
function API_Systeminfo_GetOSReleaseinfo() {
    local r_arch && r_arch="$(arch)"
    Result_Systeminfo_OSArch="$r_arch"
    # CentOS/Red Hat 判断
    if [ -f "/etc/centos-release" ] || [ -f "/etc/redhat-release" ]; then
        Result_Systeminfo_OSReleaseNameShort="centos"
        local r_prettyname && r_prettyname="$(grep -oP '(?<=\bPRETTY_NAME=").*(?=")' /etc/os-release)"
        local r_elrepo_version && r_elrepo_version="$(rpm -qa | grep -oP "el[0-9]+" | sort -ur | head -n1)"
        case "$r_elrepo_version" in
        9 | el9)
            Result_Systeminfo_OSReleaseVersionShort="9"
            Result_Systeminfo_OSReleaseNameFull="$r_prettyname ($r_arch)"
            return 0
            ;;
        8 | el8)
            Result_Systeminfo_OSReleaseVersionShort="8"
            Result_Systeminfo_OSReleaseNameFull="$r_prettyname ($r_arch)"
            return 0
            ;;
        7 | el7)
            Result_Systeminfo_OSReleaseVersionShort="7"
            Result_Systeminfo_OSReleaseNameFull="$r_prettyname ($r_arch)"
            return 0
            ;;
        6 | el6)
            Result_Systeminfo_OSReleaseVersionShort="6"
            Result_Systeminfo_OSReleaseNameFull="$r_prettyname ($r_arch)"
            return 0
            ;;
        *)
            echo -e "${Msg_Error} API_Systeminfo_GetOSReleaseinfo(): invalid result (CentOS/Redhat-$r_prettyname ($r_arch)), please check parameter!"
            exit 1
            ;;
        esac
    elif [ -f "/etc/lsb-release" ]; then # Ubuntu
        Result_Systeminfo_OSReleaseNameShort="ubuntu"
        local r_prettyname && r_prettyname="$(grep -oP '(?<=\bPRETTY_NAME=").*(?=")' /etc/os-release)"
        Result_Systeminfo_OSReleaseVersion="$(grep -oP '(?<=\bVERSION=").*(?=")' /etc/os-release)"
        Result_Systeminfo_OSReleaseVersionShort="$(grep -oP '(?<=\bVERSION_ID=").*(?=")' /etc/os-release)"
        Result_Systeminfo_OSReleaseNameFull="$r_prettyname ($r_arch)"
        return 0
    elif [ -f "/etc/debian_version" ]; then # Debian
        Result_Systeminfo_OSReleaseNameShort="debian"
        local r_prettyname && r_prettyname="$(grep -oP '(?<=\bPRETTY_NAME=").*(?=")' /etc/os-release)"
        Result_Systeminfo_OSReleaseVersion="$(grep -oP '(?<=\bVERSION=").*(?=")' /etc/os-release)"
        Result_Systeminfo_OSReleaseVersionShort="$(grep -oP '(?<=\bVERSION_ID=").*(?=")' /etc/os-release)"
        Result_Systeminfo_OSReleaseNameFull="$r_prettyname ($r_arch)"
        return 0
    else
        echo -e "${Msg_Error} API_Systeminfo_GetOSReleaseinfo(): invalid result ($r_prettyname ($r_arch)), please check parameter!"
        exit 1
    fi
}
#
# -> 系统信息模块 (Collector) -> 获取Linux内核版本信息
function API_Systeminfo_GetLinuxKernelinfo() {
    # 获取原始数据
    Result_Systeminfo_LinuxKernelVersion="$(uname -r)"
}

Func_Systeminfo_GetSysteminfo
Func_Systeminfo_ShowSysteminfo
