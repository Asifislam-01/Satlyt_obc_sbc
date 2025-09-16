
import serial
import time
import requests
import json
import subprocess
import os
import sys
from datetime import datetime

class SatelliteGateway:
    def __init__(self, serial_port='/dev/ttyVIRTUAL', api_base='http://localhost:3000'):
        self.serial_port = serial_port
        self.api_base = api_base
        self.ser = None
        self.container_name = "satlyt-container"
        
    def connect_serial(self):
        """Connect to virtual serial port"""
        try:
            self.ser = serial.Serial(
                port=self.serial_port,
                baudrate=115200,
                timeout=1,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                bytesize=serial.EIGHTBITS
            )
            time.sleep(2)  # Wait for connection to stabilize
            print(f"Connected to virtual serial: {self.ser.name}")
            return True
        except Exception as e:
            print(f"Failed to connect to virtual serial: {e}")
            return False
    
    def send_to_obc(self, message):
        """Send message back through virtual serial (for responses)"""
        if self.ser:
            try:
                self.ser.write(f"{message}\n".encode('utf-8'))
                print(f"Sent to OBC: {message}")
            except Exception as e:
                print(f"Failed to send to OBC: {e}")
    
    def call_api(self, endpoint, method="GET", data=None):
        """Call Node.js API server"""
        try:
            url = f"{self.api_base}{endpoint}"
            if method == "POST":
                response = requests.post(url, json=data, timeout=5)
            else:
                response = requests.get(url, timeout=5)
            
            if response.status_code == 200:
                return response.json()
            else:
                print(f"API Error: {response.status_code}")
                return None
        except Exception as e:
            print(f"API Connection Error: {e}")
            return None
    
    def process_obc_command(self, command):
        """Process incoming command from virtual serial"""
        command = command.strip().upper()
        print(f"Processing OBC command: {command}")
        
        # Handle log messages (ignore)
        if command.startswith("[LOG]"):
            return None
            
        # Container management commands
        if command == "START_CONTAINER":
            return self.start_container()
        elif command == "STOP_CONTAINER":
            return self.stop_container()
        elif command == "GET_CONTAINER_STATUS":
            return self.get_container_status()
            
        # Model execution commands (from original gateway)
        elif command == "RUN_PAYLOAD":
            return self.call_run_model()
        elif command == "GET_STATUS":
            return self.call_execution_status()
        elif command == "GET_FILES":
            return self.call_get_file_number()
        elif command == "SHUTDOWN":
            return self.call_shutdown()
        elif command == "PING":
            return "PONG"
        elif command.startswith("SET_RESOURCE_LIMITS:"):
            return self.set_resource_limits(command)
        elif command == "RESET_RESOURCE_LIMITS":
            return self.reset_resource_limits()
        elif command.startswith("TEXT_PROMPT:"):
            return self.handle_text_prompt(command)
        else:
            return f"UNKNOWN_CMD:{command}"
    
    def start_container(self):
        """Start the Docker container"""
        try:
            print(" Starting Docker container...")
            result = subprocess.run(
                f"docker-compose -f ./docker-compose-up.yml up -d",
                shell=True, capture_output=True, text=True
            )
            
            if result.returncode == 0:
                print("Container started successfully")
                return "CONTAINER_STARTED"
            else:
                print(f"Failed to start container: {result.stderr}")
                return "CONTAINER_ERROR"
        except Exception as e:
            print(f"Error starting container: {e}")
            return "CONTAINER_ERROR"
    
    def stop_container(self):
        """Stop the Docker container"""
        try:
            print("Stopping Docker container...")
            result = subprocess.run(
                f"docker-compose -f ./docker-compose-up.yml down",
                shell=True, capture_output=True, text=True
            )
            
            if result.returncode == 0:
                print("Container stopped successfully")
                return "CONTAINER_STOPPED"
            else:
                print(f"Failed to stop container: {result.stderr}")
                return "CONTAINER_ERROR"
        except Exception as e:
            print(f"Error stopping container: {e}")
            return "CONTAINER_ERROR"
    
    def get_container_status(self):
        """Get Docker container status including CPU, memory, etc."""
        try:
            # Get container stats - use individual commands for better reliability
            cpu_cmd = f"docker stats {self.container_name} --no-stream --format '{{{{.CPUPerc}}}}'"
            mem_cmd = f"docker stats {self.container_name} --no-stream --format '{{{{.MemUsage}}}}'"
            mem_percent_cmd = f"docker stats {self.container_name} --no-stream --format '{{{{.MemPerc}}}}'"
            net_cmd = f"docker stats {self.container_name} --no-stream --format '{{{{.NetIO}}}}'"
            block_cmd = f"docker stats {self.container_name} --no-stream --format '{{{{.BlockIO}}}}'"
            
            cpu_result = subprocess.run(cpu_cmd, shell=True, capture_output=True, text=True)
            mem_result = subprocess.run(mem_cmd, shell=True, capture_output=True, text=True)
            mem_percent_result = subprocess.run(mem_percent_cmd, shell=True, capture_output=True, text=True)
            net_result = subprocess.run(net_cmd, shell=True, capture_output=True, text=True)
            block_result = subprocess.run(block_cmd, shell=True, capture_output=True, text=True)
            
            # Get container info
            info_cmd = f"docker inspect {self.container_name} --format='{{{{.State.Status}}}}\t{{{{.State.StartedAt}}}}\t{{{{.Config.Image}}}}'"
            info_result = subprocess.run(info_cmd, shell=True, capture_output=True, text=True)
            
            # Parse results - use real Docker stats
            cpu_percent = cpu_result.stdout.strip() if cpu_result.returncode == 0 else "N/A"
            mem_usage = mem_result.stdout.strip() if mem_result.returncode == 0 else "N/A"
            mem_percent = mem_percent_result.stdout.strip() if mem_percent_result.returncode == 0 else "N/A"
            net_io = net_result.stdout.strip() if net_result.returncode == 0 else "N/A"
            block_io = block_result.stdout.strip() if block_result.returncode == 0 else "N/A"
            
            info_parts = info_result.stdout.strip().split('\t')
            status = info_parts[0] if len(info_parts) > 0 else "unknown"
            started_at = info_parts[1] if len(info_parts) > 1 else "N/A"
            image = info_parts[2] if len(info_parts) > 2 else "N/A"
            
            status_data = {
                "container_name": self.container_name,
                "status": status,
                "cpu_percent": cpu_percent,
                "memory_usage": mem_usage,
                "memory_percent": mem_percent,
                "network_io": net_io,
                "block_io": block_io,
                "started_at": started_at,
                "image": image,
                "timestamp": datetime.now().isoformat()
            }
            
            return f"CONTAINER_STATUS:{json.dumps(status_data)}"
        except Exception as e:
            print(f"Error getting container status: {e}")
            return f"CONTAINER_ERROR:{str(e)}"
    
    # API methods from original gateway
    def call_run_model(self):
        """Call RUN-MODEL API"""
        try:
            print("Calling RUN-MODEL API...")
            result = self.call_api("/RUN-MODEL", "POST")
            if result:
                return "MODEL_STARTED"
            else:
                return "API_ERROR"
        except Exception as e:
            print(f" API Error: {e}")
            return "CONNECTION_ERROR"
    
    def call_execution_status(self):
        """Call MODEL-EXECUTION-STATUS API"""
        try:
            result = self.call_api("/MODEL-EXECUTION-STATUS")
            if result:
                return f"STATUS:{result['status']}"
            else:
                return "API_ERROR"
        except Exception as e:
            print(f" Status API Error: {e}")
            return "CONNECTION_ERROR"
    
    def call_get_file_number(self):
        """Call GET-FILE-NUMBER API"""
        try:
            result = self.call_api("/GET-FILE-NUMBER")
            if result:
                return f"FILES:{result['latest_result_file']}"
            else:
                return "API_ERROR"
        except Exception as e:
            print(f" File API Error: {e}")
            return "CONNECTION_ERROR"
    
    def call_shutdown(self):
        """Call SHUT-DOWN API"""
        try:
            result = self.call_api("/SHUT-DOWN", "POST")
            return "SHUTDOWN_ACK" if result else "SHUTDOWN_ERROR"
        except:
            return "SHUTDOWN_ERROR"
    
    
    def set_resource_limits(self, command):
        """Set Docker container resource limits using resource_manager.py"""
        try:
            # Parse command: SET_RESOURCE_LIMITS:cpu=0.5,memory=512M
            limits_data = command.split(":", 1)[1]
            limits_pairs = limits_data.split(",")
            
            cpu_limit = None
            memory_limit = None
            
            for pair in limits_pairs:
                if "=" in pair:
                    key, value = pair.split("=", 1)
                    key = key.strip().lower()
                    value = value.strip()
                    
                    if key == "cpu":
                        cpu_limit = value
                    elif key == "memory":
                        memory_limit = value
            
            if not cpu_limit and not memory_limit:
                return "RESOURCE_LIMITS_ERROR:No limits specified"
            
            # Call resource manager script
            cmd_parts = ["python3", "resource_manager.py", "set"]
            if cpu_limit:
                cmd_parts.append(cpu_limit)
            else:
                cmd_parts.append("1.0")  # Default CPU
                
            if memory_limit:
                cmd_parts.append(memory_limit)
            else:
                cmd_parts.append("1G")  # Default memory
            
            result = subprocess.run(cmd_parts, capture_output=True, text=True)
            
            if result.returncode == 0:
                return f"RESOURCE_LIMITS_SET:CPU={cpu_limit},Memory={memory_limit}"
            else:
                return f"RESOURCE_LIMITS_ERROR:{result.stderr}"
                
        except Exception as e:
            print(f" Error setting resource limits: {e}")
            return f"RESOURCE_LIMITS_ERROR:{str(e)}"
    
    def reset_resource_limits(self):
        """Reset Docker container resource limits to default"""
        try:
            result = subprocess.run(
                ["python3", "resource_manager.py", "reset"],
                capture_output=True, text=True
            )
            
            if result.returncode == 0:
                return "RESOURCE_LIMITS_RESET"
            else:
                return f"RESOURCE_LIMITS_ERROR:{result.stderr}"
                
        except Exception as e:
            print(f"Error resetting resource limits: {e}")
            return f"RESOURCE_LIMITS_ERROR:{str(e)}"
    
    def handle_text_prompt(self, command):
        """Handle text prompt from UI dashboard"""
        try:
            # Extract text from command: TEXT_PROMPT:your_text_here
            text_content = command.split(":", 1)[1]
            print(f"Received text prompt from UI: '{text_content}'")
            
            # For now, just echo back with OK appended
            response = f"{text_content} OK"
            print(f"Echoing back: '{response}'")
            
            return response
            
        except Exception as e:
            print(f"Error handling text prompt: {e}")
            return f"TEXT_PROMPT_ERROR:{str(e)}"
    
    def run(self):
        """Main loop to listen for commands"""
        print("Satellite Gateway Starting...")
        print("Waiting for virtual serial connection...")
        
        if not self.connect_serial():
            print("Failed to connect to virtual serial. Exiting...")
            return
        
        print("Gateway ready! Listening for commands...")
        print("Available commands:")
        print("  - START_CONTAINER")
        print("  - STOP_CONTAINER") 
        print("  - GET_CONTAINER_STATUS")
        print("  - RUN_PAYLOAD")
        print("  - GET_STATUS")
        print("  - GET_FILES")
        print("  - SHUTDOWN")
        print("  - PING")
        print("  - SET_RESOURCE_LIMITS:cpu=0.5,memory=512M")
        print("  - RESET_RESOURCE_LIMITS")
        print("  - TEXT_PROMPT:your_text_here")
        print("")
        
        try:
            while True:
                if self.ser and self.ser.in_waiting > 0:
                    try:
                        # Read command from virtual serial
                        raw_command = self.ser.readline().decode('utf-8', errors='ignore').strip()
                        if raw_command:
                            print(f"Received from OBC: '{raw_command}'")
                            
                            # Process command
                            response = self.process_obc_command(raw_command)
                            
                            # Send response back
                            if response:
                                self.send_to_obc(response)
                    
                    except Exception as e:
                        print(f" Error processing command: {e}")
                
                time.sleep(0.1)  # Small delay to prevent high CPU usage
                
        except KeyboardInterrupt:
            print("\n Gateway shutting down...")
            if self.ser:
                self.ser.close()
            print("Gateway stopped.")

if __name__ == "__main__":
    gateway = SatelliteGateway()
    gateway.run()