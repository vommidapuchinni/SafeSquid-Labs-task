#!/bin/bash

# Function to display the top 10 applications consuming the most CPU and memory
function top_apps {
    echo "Top 10 CPU-consuming applications:"
    ps aux --sort=-%cpu | head -n 11
    echo ""
    echo "Top 10 Memory-consuming applications:"
    ps aux --sort=-%mem | head -n 11
}

# Function to display network monitoring information
function network_monitor {
    echo "Network Monitoring:"
    # Number of concurrent connections
    echo "Concurrent connections:"
    netstat -an | grep ESTABLISHED | wc -l
    # Packet drops
    echo "Packet Drops:"
    netstat -s | grep 'packet receive errors\|packets pruned\|packets dropped'
    
    # MB in and out
    echo "Network Traffic:"
    ifconfig | grep 'RX packets\|TX packets'
}

# Function to display disk usage
function disk_usage {
    echo "Disk Usage:"
    df -h
    echo ""
    echo "Partitions using more than 80% space:"
    df -h | awk '$5 > 80 {print $0}'
}

# Function to display system load
function system_load {
    echo "System Load:"
    uptime
    echo ""
    echo "CPU Usage:"
    mpstat
}

# Function to display memory usage
function memory_usage {
    echo "Memory Usage:"
    free -h
}

# Function to monitor processes
function process_monitor {
    echo "Process Monitoring:"
    # Number of active processes
    echo "Active Processes:"
    ps aux | wc -l
    # Top 5 processes in terms of CPU and memory usage
    echo "Top 5 CPU-consuming processes:"
    ps aux --sort=-%cpu | head -n 6
    echo ""
    echo "Top 5 Memory-consuming processes:"
    ps aux --sort=-%mem | head -n 6
}

# Function to monitor essential services
function service_monitor {
    echo "Service Monitoring:"
    # Monitoring services like sshd, nginx/apache, iptables
    services=("sshd" "nginx" "apache2" "iptables")
    for service in "${services[@]}"
    do
        systemctl is-active --quiet $service && echo "$service is running" || echo "$service is NOT running"
    done
}

# Function to display the complete dashboard
function dashboard {
    echo "=== System Monitoring Dashboard ==="
    top_apps
    echo ""
    network_monitor
    echo ""
    disk_usage
    echo ""
    system_load
    echo ""
    memory_usage
    echo ""
    process_monitor
    echo ""
    service_monitor
    echo "==================================="
}

# Check for command-line switches
while [ "$1" != "" ]; do
    case $1 in
        -cpu )       system_load;;
        -memory )    memory_usage;;
        -network )   network_monitor;;
        -disk )      disk_usage;;
        -process )   process_monitor;;
        -service )   service_monitor;;
        -dashboard ) dashboard;;
        * )          echo "Invalid option. Use -cpu, -memory, -network, -disk, -process, -service, or -dashboard";;
    esac
    shift
done
