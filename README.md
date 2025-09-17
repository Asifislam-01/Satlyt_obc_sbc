# Satellite Gateway System

A comprehensive satellite communication gateway system that enables communication between On-Board Computer (OBC) systems and Docker-based satellite processing containers.

## 🏗️ Architecture Overview

The system consists of three main components:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   OBC System    │◄──►│  Gateway Script  │◄──►│  Docker Container   │
│                 │    │   (gateway.py)   │    │   (satlyt-server)   │
│ Virtual Serial  │    │                  │    │                     │
│ Communication   │    │ Resource Manager │    │ Node.js API Server  │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
```

### Components

1. **Gateway Script (`gateway.py`)**: 
   - Main communication bridge between OBC and Docker container
   - Handles virtual serial communication
   - Manages Docker container lifecycle
   - Provides resource management capabilities

2. **Docker Container (`satlyt-container`)**:
   - Node.js API server running on port 3000
   - Processes satellite data and ML models
   - Volume-mounted results and errors directories
   - Configurable resource limits

3. **Resource Manager (`resource_manager.py`)**:
   - Dynamic Docker container resource allocation
   - CPU and memory limit management
   - Container lifecycle control

4. **Virtual Serial Setup (`setup_virtual_serial.sh`)**:
   - Creates virtual serial port `/dev/ttyVIRTUAL`
   - TCP bridge for remote communication
   - Enables OBC integration

##  Quick Start

### Prerequisites

- Python 3.7+
- Docker and Docker Compose
- Node.js 18+ (for local development)
- `socat` utility
- Linux/macOS environment

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd satellite-gateway
   ```

2. **Setup virtual serial communication**:
   ```bash
   chmod +x setup_virtual_serial.sh
   ./setup_virtual_serial.sh start
   ```

3. **Start the gateway**:
   ```bash
   python3 gateway.py
   ```

4. **In another terminal, start the Docker container**:
   ```bash
   docker-compose -f docker-compose-up.yml up -d
   ```

##  Detailed Setup Instructions

### Step 1: Environment Setup

#### Install Dependencies

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install -y python3 python3-pip docker.io docker-compose socat
sudo systemctl start docker
sudo systemctl enable docker
```

**macOS**:
```bash
brew install python3 docker docker-compose socat
```

**Python Dependencies**:
```bash
pip3 install pyserial requests
```

### Step 2: Virtual Serial Configuration

The virtual serial system creates a bridge between your OBC system and the gateway:

```bash
# Start virtual serial system
./setup_virtual_serial.sh start

# Check status
./setup_virtual_serial.sh status

# Test connection
./setup_virtual_serial.sh test
```

**Configuration Details**:
- Virtual Serial Port: `/dev/ttyVIRTUAL`
- TCP Port: `9999`
- Bridge Type: TCP-to-Serial using `socat`

### Step 3: Docker Container Setup

#### Build and Run Container

```bash
# Build the container
docker-compose -f docker-compose-up.yml build

# Start the container
docker-compose -f docker-compose-up.yml up -d

# Check container status
docker ps
```

#### Volume Mounting

The container automatically mounts:
- `./satlyt_clean/results` → `/app/results` (output files)
- `./satlyt_clean/errors` → `/app/errors` (error logs)

### Step 4: Gateway Configuration

#### Basic Configuration

Edit `gateway.py` to modify:
- Serial port: `serial_port='/dev/ttyVIRTUAL'`
- API endpoint: `api_base='http://localhost:3000'`
- Container name: `container_name = "satlyt-container"`

#### Resource Management

Set container resource limits:
```bash
# Set CPU and memory limits
python3 resource_manager.py set 0.5 512M

# Reset to default (unlimited)
python3 resource_manager.py reset

# Check current limits
python3 resource_manager.py status
```

##  Communication Protocol

### Supported Commands

| Command | Description | Response |
|---------|-------------|----------|
| `START_CONTAINER` | Start Docker container | `CONTAINER_STARTED` |
| `STOP_CONTAINER` | Stop Docker container | `CONTAINER_STOPPED` |
| `GET_CONTAINER_STATUS` | Get container stats | `CONTAINER_STATUS:{json}` |
| `RUN_PAYLOAD` | Execute ML model | `MODEL_STARTED` |
| `GET_STATUS` | Get execution status | `STATUS:{status}` |
| `GET_FILES` | Get file count | `FILES:{count}` |
| `SHUTDOWN` | Shutdown system | `SHUTDOWN_ACK` |
| `PING` | Health check | `PONG` |
| `SET_RESOURCE_LIMITS:cpu=0.5,memory=512M` | Set limits | `RESOURCE_LIMITS_SET` |
| `RESET_RESOURCE_LIMITS` | Reset limits | `RESOURCE_LIMITS_RESET` |
| `TEXT_PROMPT:message` | Send text message | `{message} OK` |

### API Endpoints

The Docker container exposes these REST API endpoints:

- `POST /RUN-MODEL` - Start model execution
- `GET /MODEL-EXECUTION-STATUS` - Get execution status
- `GET /GET-FILE-NUMBER` - Get file counts
- `POST /SHUT-DOWN` - Shutdown container
- `GET /LIST-FILES` - List all files
- `POST /CREATE-ERROR` - Create error log

##  Docker Configuration

### Dockerfile

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY server.js ./
RUN mkdir -p /app/results /app/errors
EXPOSE 3000
CMD ["node", "server.js"]
```

### Docker Compose

```yaml
services:
  satlyt-server:
    build: ./satlyt_clean
    ports:
      - "3000:3000"
    volumes:
      - ./satlyt_clean/results:/app/results
      - ./satlyt_clean/errors:/app/errors
    container_name: satlyt-container
```

### Resource Limits

The system supports dynamic resource allocation:

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

##  Customization

### Adding New Commands

1. **In `gateway.py`**:
   ```python
   def process_obc_command(self, command):
       # Add new command handling
       elif command == "YOUR_COMMAND":
           return self.handle_your_command()
   ```

2. **In `server.js`**:
   ```javascript
   app.post("/YOUR-ENDPOINT", (req, res) => {
       // Handle your endpoint
       res.json({ status: "success" });
   });
   ```

### Modifying Container Behavior

Edit `satlyt_clean/server.js` to:
- Change model execution logic
- Modify file output format
- Add new API endpoints
- Implement custom processing

### Resource Management

Customize resource limits in `resource_manager.py`:
- CPU allocation strategies
- Memory management policies
- Container restart policies

##  Troubleshooting

### Common Issues

#### 1. Virtual Serial Port Not Found
```bash
# Check if socat is running
./setup_virtual_serial.sh status

# Restart virtual serial
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
```

#### 2. Container Won't Start
```bash
# Check Docker status
docker ps -a

# Check logs
docker logs satlyt-container

# Rebuild container
docker-compose -f docker-compose-up.yml down
docker-compose -f docker-compose-up.yml up -d --build
```

#### 3. Gateway Connection Issues
```bash
# Test API connectivity
curl http://localhost:3000/MODEL-EXECUTION-STATUS

# Check container status
docker inspect satlyt-container
```

#### 4. Permission Issues
```bash
# Fix virtual serial permissions
sudo chmod 666 /dev/ttyVIRTUAL

# Fix Docker permissions
sudo usermod -aG docker $USER
# Log out and back in
```

### Debug Mode

Enable debug monitoring:
```bash
# Monitor virtual serial traffic
./setup_virtual_serial.sh monitor

# Check gateway logs
python3 gateway.py 2>&1 | tee gateway.log
```

### Log Files

- Gateway logs: Console output
- Container logs: `docker logs satlyt-container`
- Results: `./satlyt_clean/results/`
- Errors: `./satlyt_clean/errors/`

## 📊 Monitoring and Maintenance

### Health Checks

```bash
# Check system status
./setup_virtual_serial.sh status
docker ps
python3 resource_manager.py status

# Test full workflow
echo "PING" | nc localhost 9999
echo "START_CONTAINER" | nc localhost 9999
```

### Performance Monitoring

The system provides real-time container statistics:
- CPU usage percentage
- Memory usage and percentage
- Network I/O
- Block I/O
- Container uptime

### Maintenance Tasks

1. **Regular Cleanup**:
   ```bash
   # Clean old result files
   find ./satlyt_clean/results -name "*.txt" -mtime +7 -delete
   
   # Clean Docker images
   docker system prune -f
   ```

2. **Resource Optimization**:
   ```bash
   # Monitor resource usage
   docker stats satlyt-container
   
   # Adjust limits as needed
   python3 resource_manager.py set 1.0 1G
   ```

##  Security Considerations

- Virtual serial port permissions
- Docker container isolation
- Network access controls
- File system permissions
- Resource limits to prevent DoS

##  API Reference

### Gateway Commands

All commands are sent via virtual serial and return responses in the same channel.

### Container API

Base URL: `http://localhost:3000`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/RUN-MODEL` | Start model execution |
| GET | `/MODEL-EXECUTION-STATUS` | Get execution status |
| GET | `/GET-FILE-NUMBER` | Get file counts |
| POST | `/SHUT-DOWN` | Shutdown container |
| GET | `/LIST-FILES` | List all files |
| POST | `/CREATE-ERROR` | Create error log |

##  Support

**Important Note**: The configurations provided in this README are based on our specific setup. For your own setup, you may need to make some adjustments as mentioned in the configuration sections above.

For technical support and questions:
- Check the troubleshooting section above
- Review container logs and system outputs
- Test individual components using the provided commands
- Verify your Docker and virtual serial configurations
- If you encounter any errors or issues not covered in this guide, feel free to contact us anytime

**Contact Information**: [Add your contact details here]

##  License

[Add your license information here]

---

**Note**: This system is designed for satellite communication scenarios and requires proper hardware integration for production use.
