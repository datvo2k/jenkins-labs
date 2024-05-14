#!/bin/bash

# Declare Paths & Settings.
SYS_PATH="/etc/sysctl.conf"
PROF_PATH="/etc/profile"
SSH_PORT=""
SSH_PATH="/etc/ssh/sshd_config"

# Green, Yellow & Red Messages.
green_msg() {
    tput setaf 2
    echo "[*] ----- $1"
    tput sgr0
}

yellow_msg() {
    tput setaf 3
    echo "[*] ----- $1"
    tput sgr0
}

red_msg() {
    tput setaf 1
    echo "[*] ----- $1"
    tput sgr0
}

# Root
check_if_running_as_root() {
    ## If you want to run as another user, please modify $EUID to be owned by this user
    if [[ "$EUID" -ne '0' ]]; then
        echo
        red_msg 'Error: You must run this script as root!'
        echo
        sleep 0.5
        exit 1
    fi
}

# Check Root
check_if_running_as_root
sleep 0.5

# Update & Upgrade & Remove & Clean
complete_update() {
    echo
    yellow_msg 'Updating the System... (This can take a while.)'
    echo
    sleep 0.5

    sudo apt -q update
    sudo apt -y upgrade
    sudo apt -y full-upgrade
    sudo apt -y autoremove
    sleep 0.5

    ## Again :D
    sudo apt -y -q autoclean
    sudo apt -y clean
    sudo apt -q update
    sudo apt -y upgrade
    sudo apt -y full-upgrade
    sudo apt -y autoremove --purge

    echo
    green_msg 'System Updated & Cleaned Successfully.'
    echo
    sleep 0.5
}

# Install useful packages
installations() {
    echo
    yellow_msg 'Installing Useful Packages...'
    echo
    sleep 0.5

    ## Networking packages
    sudo apt -q -y install apt-transport-https

    ## System utilities
    sudo apt -q -y install apt-utils bash-completion busybox ca-certificates cron curl gnupg2 locales lsb-release nano preload screen software-properties-common ufw unzip vim wget xxd zip

    ## Miscellaneous
    sudo apt -q -y install dialog htop net-tools

    echo
    green_msg 'Useful Packages Installed Succesfully.'
    echo
    sleep 0.5
}

# Enable packages at server boot
enable_packages() {
    sudo systemctl enable cron preload
    echo
    green_msg 'Packages Enabled Succesfully.'
    echo
    sleep 0.5
}

# Set the server TimeZone to the VPS IP address location.
set_timezone() {
    echo
    yellow_msg 'Setting TimeZone based on VPS IP address...'
    sleep 0.5

    sudo timedatectl set-ntp true
    sudo systemctl restart systemd-timesyncd
    sudo timedatectl set-timezone Asia/Ho_Chi_Minh
    
    green_msg "Timezone set to Asia/Ho_Chi_Minh"
}

# Fix DNS Temporarly
fix_dns() {
    echo
    yellow_msg "Fixing DNS Temporarily."
    sleep 0.5

    DNS_PATH="/etc/resolv.conf"
    cp $DNS_PATH /etc/resolv.conf.bak

    yellow_msg "Default resolv.conf file saved. Directory: /etc/resolv.conf.bak"
    sleep 0.5

    sed -i '/nameserver/d' $DNS_PATH
    echo 'nameserver 8.8.8.8' >>$DNS_PATH
    echo 'nameserver 8.8.4.4' >>$DNS_PATH

    green_msg "DNS Fixed Temporarily."
    echo
    sleep 0.5
}

enable_ipv6_support() {
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.forwarding=1
    sysctl -w net.ipv6.conf.default.forwarding=1
    echo "net.ipv4.ip_forward = 1" >/etc/sysctl.d/ip_forward.conf
    echo "net.ipv6.conf.all.forwarding = 1" >>/etc/sysctl.d/ip_forward.conf
    echo "net.ipv6.conf.default.forwarding = 1" >>/etc/sysctl.d/ip_forward.conf
    sysctl -p /etc/sysctl.d/ip_forward.conf
    if [[ $(sysctl -a | grep 'disable_ipv6.*=.*1') || $(cat /etc/sysctl.{conf,d/*} | grep 'disable_ipv6.*=.*1') ]]; then
        sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
        echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
        sysctl -w net.ipv6.conf.all.disable_ipv6=0
    fi

    green_msg "IPV6 enabled."
    echo
    sleep 0.5
}

# Remove old SSH config to prevent duplicates.
remove_old_ssh_conf() {
    ## Make a backup of the original sshd_config file
    cp $SSH_PATH /etc/ssh/sshd_config.bak

    echo
    yellow_msg 'Default SSH Config file Saved. Directory: /etc/ssh/sshd_config.bak'
    echo
    sleep 1

    ## Remove these lines
    sed -i -e 's/#UseDNS yes/UseDNS no/' \
        -e 's/#Compression no/Compression yes/' \
        -e 's/Ciphers .*/Ciphers aes256-ctr,chacha20-poly1305@openssh.com/' \
        -e '/MaxAuthTries/d' \
        -e '/MaxSessions/d' \
        -e '/TCPKeepAlive/d' \
        -e '/ClientAliveInterval/d' \
        -e '/ClientAliveCountMax/d' \
        -e '/AllowAgentForwarding/d' \
        -e '/AllowTcpForwarding/d' \
        -e '/GatewayPorts/d' \
        -e '/PermitTunnel/d' \
        -e '/PrintLastLog/d' \
        -e '/X11Forwarding/d' "$SSH_PATH"

}

update_ssh_config() {
    echo
    yellow_msg 'Optimizing SSH...'
    echo
    sleep 0.5

    ## Enable TCP keep-alive messages
    echo "TCPKeepAlive yes" | tee -a "$SSH_PATH"

    ## Configure client keep-alive messages
    echo "ClientAliveInterval 3000" | tee -a "$SSH_PATH"
    echo "ClientAliveCountMax 100" | tee -a "$SSH_PATH"

    ## Allow agent forwarding
    echo "AllowAgentForwarding yes" | tee -a "$SSH_PATH"

    ## Allow TCP forwarding
    echo "AllowTcpForwarding yes" | tee -a "$SSH_PATH"

    ## Enable gateway ports
    echo "GatewayPorts yes" | tee -a "$SSH_PATH"

    ## Enable tunneling
    echo "PermitTunnel yes" | tee -a "$SSH_PATH"

    ## Enable X11 graphical interface forwarding
    echo "X11Forwarding yes" | tee -a "$SSH_PATH"

    echo "PrintLastLog yes" | tee -a "$SSH_PATH"

    ## Restart the SSH service to apply the changes
    sudo systemctl restart ssh

    echo
    green_msg 'SSH is Optimized.'
    echo
    sleep 0.5
}

# SYSCTL Optimization
sysctl_optimizations() {
    ## Make a backup of the original sysctl.conf file
    cp $SYS_PATH /etc/sysctl.conf.bak

    echo
    yellow_msg 'Default sysctl.conf file Saved. Directory: /etc/sysctl.conf.bak'
    echo
    sleep 1

    echo
    yellow_msg 'Optimizing the Network...'
    echo
    sleep 0.5

    sed -i -e '/fs.file-max/d' \
        -e '/net.core.default_qdisc/d' \
        -e '/net.core.netdev_max_backlog/d' \
        -e '/net.core.optmem_max/d' \
        -e '/net.core.somaxconn/d' \
        -e '/net.core.rmem_max/d' \
        -e '/net.core.wmem_max/d' \
        -e '/net.core.rmem_default/d' \
        -e '/net.core.wmem_default/d' \
        -e '/net.ipv4.tcp_rmem/d' \
        -e '/net.ipv4.tcp_wmem/d' \
        -e '/net.ipv4.tcp_congestion_control/d' \
        -e '/net.ipv4.tcp_fastopen/d' \
        -e '/net.ipv4.tcp_fin_timeout/d' \
        -e '/net.ipv4.tcp_keepalive_time/d' \
        -e '/net.ipv4.tcp_keepalive_probes/d' \
        -e '/net.ipv4.tcp_keepalive_intvl/d' \
        -e '/net.ipv4.tcp_max_orphans/d' \
        -e '/net.ipv4.tcp_max_syn_backlog/d' \
        -e '/net.ipv4.tcp_max_tw_buckets/d' \
        -e '/net.ipv4.tcp_mem/d' \
        -e '/net.ipv4.tcp_mtu_probing/d' \
        -e '/net.ipv4.tcp_notsent_lowat/d' \
        -e '/net.ipv4.tcp_retries2/d' \
        -e '/net.ipv4.tcp_sack/d' \
        -e '/net.ipv4.tcp_dsack/d' \
        -e '/net.ipv4.tcp_slow_start_after_idle/d' \
        -e '/net.ipv4.tcp_window_scaling/d' \
        -e '/net.ipv4.tcp_adv_win_scale/d' \
        -e '/net.ipv4.tcp_ecn/d' \
        -e '/net.ipv4.tcp_ecn_fallback/d' \
        -e '/net.ipv4.tcp_syncookies/d' \
        -e '/net.ipv4.udp_mem/d' \
        -e '/net.ipv6.conf.all.disable_ipv6/d' \
        -e '/net.ipv6.conf.default.disable_ipv6/d' \
        -e '/net.ipv6.conf.lo.disable_ipv6/d' \
        -e '/net.unix.max_dgram_qlen/d' \
        -e '/vm.min_free_kbytes/d' \
        -e '/vm.swappiness/d' \
        -e '/vm.vfs_cache_pressure/d' \
        -e '/net.ipv4.conf.default.rp_filter/d' \
        -e '/net.ipv4.conf.all.rp_filter/d' \
        -e '/net.ipv4.conf.all.accept_source_route/d' \
        -e '/net.ipv4.conf.default.accept_source_route/d' \
        -e '/net.ipv4.neigh.default.gc_thresh1/d' \
        -e '/net.ipv4.neigh.default.gc_thresh2/d' \
        -e '/net.ipv4.neigh.default.gc_thresh3/d' \
        -e '/net.ipv4.neigh.default.gc_stale_time/d' \
        -e '/net.ipv4.conf.default.arp_announce/d' \
        -e '/net.ipv4.conf.lo.arp_announce/d' \
        -e '/net.ipv4.conf.all.arp_announce/d' \
        -e '/kernel.panic/d' \
        -e '/vm.dirty_ratio/d' \
        -e '/^#/d' \
        -e '/^$/d' \
        "$SYS_PATH"

    cat <<EOF >>"$SYS_PATH"


################################################################
################################################################


# /etc/sysctl.conf
# These parameters in this file will be added/updated to the sysctl.conf file.

## File system settings
## ----------------------------------------------------------------

# Set the maximum number of open file descriptors
fs.file-max = 1000000


## Network core settings
## ----------------------------------------------------------------

# Specify default queuing discipline for network devices
net.core.default_qdisc = fq_codel

# Configure maximum network device backlog
net.core.netdev_max_backlog = 32768

# Set maximum socket receive buffer
net.core.optmem_max = 262144

# Define maximum backlog of pending connections
net.core.somaxconn = 65536

# Configure maximum TCP receive buffer size
net.core.rmem_max = 33554432

# Set default TCP receive buffer size
net.core.rmem_default = 1048576

# Configure maximum TCP send buffer size
net.core.wmem_max = 33554432

# Set default TCP send buffer size
net.core.wmem_default = 1048576


## TCP settings
## ----------------------------------------------------------------

# Define socket receive buffer sizes
net.ipv4.tcp_rmem = 16384 1048576 33554432

# Specify socket send buffer sizes
net.ipv4.tcp_wmem = 16384 1048576 33554432

# Set TCP congestion control algorithm to BBR
net.ipv4.tcp_congestion_control = bbr

# Configure TCP FIN timeout period
net.ipv4.tcp_fin_timeout = 25

# Set keepalive time (seconds)
net.ipv4.tcp_keepalive_time = 1200

# Configure keepalive probes count and interval
net.ipv4.tcp_keepalive_probes = 7
net.ipv4.tcp_keepalive_intvl = 30

# Define maximum orphaned TCP sockets
net.ipv4.tcp_max_orphans = 819200

# Set maximum TCP SYN backlog
net.ipv4.tcp_max_syn_backlog = 20480

# Configure maximum TCP Time Wait buckets
net.ipv4.tcp_max_tw_buckets = 1440000

# Define TCP memory limits
net.ipv4.tcp_mem = 65536 1048576 33554432

# Enable TCP MTU probing
net.ipv4.tcp_mtu_probing = 1

# Define minimum amount of data in the send buffer before TCP starts sending
net.ipv4.tcp_notsent_lowat = 32768

# Specify retries for TCP socket to establish connection
net.ipv4.tcp_retries2 = 8

# Enable TCP SACK and DSACK
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1

# Disable TCP slow start after idle
net.ipv4.tcp_slow_start_after_idle = 0

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = -2

# Enable TCP ECN
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_ecn_fallback = 1

# Enable the use of TCP SYN cookies to help protect against SYN flood attacks
net.ipv4.tcp_syncookies = 1


## UDP settings
## ----------------------------------------------------------------

# Define UDP memory limits
net.ipv4.udp_mem = 65536 1048576 33554432


## IPv6 settings
## ----------------------------------------------------------------

# Enable IPv6
net.ipv6.conf.all.disable_ipv6 = 0

# Enable IPv6 by default
net.ipv6.conf.default.disable_ipv6 = 0

# Enable IPv6 on the loopback interface (lo)
net.ipv6.conf.lo.disable_ipv6 = 0


## UNIX domain sockets
## ----------------------------------------------------------------

# Set maximum queue length of UNIX domain sockets
net.unix.max_dgram_qlen = 256


## Virtual memory (VM) settings
## ----------------------------------------------------------------

# Specify minimum free Kbytes at which VM pressure happens
vm.min_free_kbytes = 65536

# Define how aggressively swap memory pages are used
vm.swappiness = 10

# Set the tendency of the kernel to reclaim memory used for caching of directory and inode objects
vm.vfs_cache_pressure = 250


## Network Configuration
## ----------------------------------------------------------------

# Configure reverse path filtering
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.all.rp_filter = 2

# Disable source route acceptance
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Neighbor table settings
net.ipv4.neigh.default.gc_thresh1 = 512
net.ipv4.neigh.default.gc_thresh2 = 2048
net.ipv4.neigh.default.gc_thresh3 = 16384
net.ipv4.neigh.default.gc_stale_time = 60

# ARP settings
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2

# Kernel panic timeout
kernel.panic = 1

# Set dirty page ratio for virtual memory
vm.dirty_ratio = 20


################################################################
################################################################


EOF

    sudo sysctl -p

    echo
    green_msg 'Network is Optimized.'
    echo
    sleep 0.5
}

# UFW Optimizations
ufw_optimizations() {
    echo
    yellow_msg 'Installing & Optimizing UFW...'
    echo
    sleep 0.5

    ## Purge firewalld to install UFW.
    sudo apt -y purge firewalld

    ## Install UFW if it isn't installed.
    sudo apt update -q
    sudo apt install -y ufw

    ## Disable UFW
    sudo ufw disable

    ## Open default ports.
    sudo ufw allow OpenSSH
    sudo ufw allow 80/tcp
    sudo ufw allow 80/udp
    sudo ufw allow 443/tcp
    sudo ufw allow 443/udp
    sudo ufw allow 8080/tcp
    sudo ufw allow 8080/udp
    sleep 0.5

    ## Change the UFW config to use System config.
    sed -i 's+/etc/ufw/sysctl.conf+/etc/sysctl.conf+gI' /etc/default/ufw

    ## Enable & Reload
    echo "y" | sudo ufw enable
    sudo ufw reload
    echo
    green_msg 'UFW is Installed & Optimized. (Open your custom ports manually.)'
    echo
    sleep 0.5
}

kernel_hardening() {
    echo
    yellow_msg 'Modify the Kernel... (This can take a while.)'
    echo
    sleep 0.5

    echo 'fs.suid_dumpable = 0' >/etc/sysctl.d/50-kernel-restrict.conf 2>/dev/null
    echo "kernel.randomize_va_space = 2" >/etc/sysctl.d/50-rand-va-space.conf 2>/dev/null
    echo "dev.tty.ldisc_autoload = 0" >/etc/sysctl.d/50-ldisc-autoload.conf 2>/dev/null
    echo "fs.protected_fifos = 2" >/etc/sysctl.d/50-protected-fifos.conf 2>/dev/null
    echo "kernel.core_uses_pid = 1" >/etc/sysctl.d/50-core-uses-pid.conf 2>/dev/null
    echo "kernel.sysrq = 0" >/etc/sysctl.d/50-sysrq.conf 2>/dev/null
    echo "kernel.unprivileged_bpf_disabled = 1" >/etc/sysctl.d/50-unprivileged-bpf.conf 2>/dev/null
    echo "kernel.yama.ptrace_scope = 1" >/etc/sysctl.d/50-ptrace-scope.conf 2>/dev/null
    echo "net.core.bpf_jit_harden = 2" >/etc/sysctl.d/50-bpf-jit-harden.conf 2>/dev/null

    echo
    green_msg 'Kernel hardening has done.'
    echo
    sleep 0.5
}

remove_telnet() {
    sudo apt-get -y --purge remove telnet nis ntpdate >/dev/null 2>&1
}

main() {
    complete_update
    sleep 0.5

    installations
    sleep 0.5

    enable_packages
    sleep 0.5

    set_timezone
    sleep 0.5

    fix_dns
    sleep 0.5

    remove_old_ssh_conf
    sleep 0.5

    update_ssh_config
    sleep 0.5

    sysctl_optimizations
    sleep 0.5

    ufw_optimizations
    sleep 0.5

    kernel_hardening
    sleep 0.5

    reboot
}

main