
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
SOCAT_PID=""
VIRTUAL_SERIAL="/dev/ttyVIRTUAL"
TCP_PORT=9999

# Function to print colored output
print_status() {
    echo -e "${GREEN} $1${NC}"
}

print_error() {
    echo -e "${RED} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ  $1${NC}"
}

# Install socat if not present
install_socat() {
    if ! command -v socat &> /dev/null; then
        print_info "Installing socat..."
        sudo apt update && sudo apt install -y socat
        if [ $? -eq 0 ]; then
            print_status "socat installed successfully"
        else
            print_error "Failed to install socat"
            exit 1
        fi
    else
        print_status "socat is already installed"
    fi
}

# Setup TCP to Serial Bridge (RECOMMENDED METHOD)
setup_tcp_serial_bridge() {
    print_info "Setting up socat TCP-to-Serial bridge..."
    
    # Kill any existing socat processes
    pkill -f "socat.*ttyVIRTUAL" 2>/dev/null
    sleep 1
    
    # Remove existing virtual serial link
    rm -f "$VIRTUAL_SERIAL" 2>/dev/null
    
    # Create virtual serial port linked to TCP port
    # fork: allows multiple connections
    # reuseaddr: allows restarting quickly
    sudo socat pty,raw,echo=0,link="$VIRTUAL_SERIAL" tcp-listen:$TCP_PORT,reuseaddr,fork &
    
    # Store the process ID
    SOCAT_PID=$!
    print_status "socat bridge started (PID: $SOCAT_PID)"
    print_info "Virtual serial port: $VIRTUAL_SERIAL"
    print_info "TCP port: $TCP_PORT"
    
    # Wait for the link to be created
    sleep 3
    
    # Check if virtual serial port was created
    if [ -L "$VIRTUAL_SERIAL" ] || [ -c "$VIRTUAL_SERIAL" ]; then
        print_status "Virtual serial port created successfully"
        ls -la "$VIRTUAL_SERIAL"
        
        # Set permissions
        sudo chmod 666 "$VIRTUAL_SERIAL" 2>/dev/null
        print_status "Permissions set for virtual serial port"
    else
        print_error "Failed to create virtual serial port"
        return 1
    fi
}

# Test the connection
test_connection() {
    print_info "Testing virtual serial connection..."
    
    # Test if we can connect to TCP port
    if nc -z localhost $TCP_PORT 2>/dev/null; then
        print_status "TCP port $TCP_PORT is accessible"
        
        # Test sending a command
        print_info "Sending test command..."
        echo "PING" | timeout 2 nc localhost $TCP_PORT
        if [ $? -eq 0 ]; then
            print_status "Test command sent successfully"
        else
            print_warning "Test command failed (this might be normal if no gateway is listening)"
        fi
        
        # Check virtual serial port
        if [ -c "$VIRTUAL_SERIAL" ] || [ -L "$VIRTUAL_SERIAL" ]; then
            print_status "Virtual serial port is available"
        else
            print_error "Virtual serial port not found"
        fi
    else
        print_error "Cannot connect to TCP port $TCP_PORT"
        return 1
    fi
}

# Monitor socat traffic (for debugging)
monitor_traffic() {
    print_info "Monitoring virtual serial traffic..."
    print_warning "Press Ctrl+C to stop monitoring"
    
    # Monitor the virtual serial port
    if [ -n "$SOCAT_PID" ]; then
        sudo strace -e write,read -p $SOCAT_PID 2>&1 | \
            grep -E "(write|read)" --line-buffered
    else
        print_error "No socat process found to monitor"
    fi
}

# Cleanup function
cleanup_socat() {
    print_info "Cleaning up socat processes..."
    
    # Kill socat processes
    sudo pkill -f "socat.*ttyVIRTUAL" 2>/dev/null
    sudo pkill -f "socat.*tcp-listen" 2>/dev/null
    
    # Remove virtual serial port
    rm -f "$VIRTUAL_SERIAL" 2>/dev/null
    
    # Wait a moment
    sleep 1
    
    print_status "Cleanup complete"
}

# Start the virtual serial system
start_virtual_serial() {
    echo " Starting Virtual Serial Communication System"
    
    # Install socat
    install_socat
    
    # Setup TCP bridge
    setup_tcp_serial_bridge
    
    if [ $? -eq 0 ]; then
        echo ""
        print_status "System Ready!"
        echo ""
        print_info "Gateway should connect to: $VIRTUAL_SERIAL"
        print_info "UI Backend should connect to: TCP localhost:$TCP_PORT"
        echo ""
        print_info "Test commands:"
        echo "  telnet localhost $TCP_PORT"
        echo "  echo 'START_CONTAINER' | nc localhost $TCP_PORT"
        echo ""
        print_info "To stop: $0 stop"
        echo ""
        print_info "Gateway script usage:"
        echo "  python3 gateway.py"
    else
        print_error "Failed to setup virtual serial system"
        exit 1
    fi
}

# Show status
show_status() {
    print_info "Virtual Serial System Status"
    echo "================================"
    
    # Check if socat is running
    if pgrep -f "socat.*ttyVIRTUAL" > /dev/null; then
        print_status "socat bridge is running"
        echo "PID: $(pgrep -f 'socat.*ttyVIRTUAL')"
    else
        print_error "socat bridge is not running"
    fi
    
    # Check virtual serial port
    if [ -c "$VIRTUAL_SERIAL" ] || [ -L "$VIRTUAL_SERIAL" ]; then
        print_status "Virtual serial port exists: $VIRTUAL_SERIAL"
        ls -la "$VIRTUAL_SERIAL"
    else
        print_error "Virtual serial port not found"
    fi
    
    # Check TCP port
    if nc -z localhost $TCP_PORT 2>/dev/null; then
        print_status "TCP port $TCP_PORT is listening"
    else
        print_error "TCP port $TCP_PORT is not accessible"
    fi
}

# Usage examples
usage() {
    echo "Usage: $0 {start|stop|test|status|monitor|help}"
    echo ""
    echo "Commands:"
    echo "  start   - Start virtual serial system"
    echo "  stop    - Stop and cleanup"
    echo "  test    - Test the connection"
    echo "  status  - Show current status"
    echo "  monitor - Monitor traffic (debug mode)"
    echo "  help    - Show this help"
    echo ""
    echo "Example workflow:"
    echo "  1. $0 start"
    echo "  2. $0 test" 
    echo "  3. python3 gateway.py"
    echo "  4. Run UI backend on another device"
    echo "  5. $0 stop (when done)"
}

# Main script logic
case "${1:-}" in
    start)
        start_virtual_serial
        ;;
    stop)
        cleanup_socat
        ;;
    test)
        test_connection
        ;;
    status)
        show_status
        ;;
    monitor)
        monitor_traffic
        ;;
    help|*)
        usage
        ;;
esac