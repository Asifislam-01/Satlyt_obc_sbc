
import subprocess
import sys
import json
import re
import os

class ResourceManager:
    def __init__(self, compose_file='docker-compose-up.yml'):
        self.compose_file = compose_file
        self.container_name = 'satlyt-container'
        
    
    def set_resource_limits(self, cpu_limit=None, memory_limit=None):
        """
        Set Docker container resource limits
        
        Args:
            cpu_limit (str): CPU limit (e.g., '0.5', '1.0', '2.0')
            memory_limit (str): Memory limit (e.g., '512M', '1G', '2G')
        
        Returns:
            dict: Result with status and message
        """
        try:
            print(f" Setting resource limits: CPU={cpu_limit}, Memory={memory_limit}")
            
            # Step 1: Stop current container
            print("Stopping current container...")
            stop_result = subprocess.run(
                f"docker-compose -f {self.compose_file} down",
                shell=True, capture_output=True, text=True
            )
            
            if stop_result.returncode != 0:
                return {
                    "success": False,
                    "message": f"Failed to stop container: {stop_result.stderr}",
                    "error": "STOP_CONTAINER_FAILED"
                }
            
            # Step 2: Update docker-compose file
            print(" Updating docker-compose file...")
            update_result = self.update_compose_file(cpu_limit, memory_limit)
            if not update_result["success"]:
                return update_result
            
            
            # Step 3: Remove old container to force recreation
            print(" Removing old container to force recreation...")
            remove_result = subprocess.run(
                f"docker rm {self.container_name}",
                shell=True, capture_output=True, text=True
            )
            
            # Step 4: Start container with new limits (force recreate)
            print(" Starting container with new resource limits...")
            start_result = subprocess.run(
                f"docker-compose -f {self.compose_file} up -d --force-recreate",
                shell=True, capture_output=True, text=True
            )
            
            if start_result.returncode != 0:
                return {
                    "success": False,
                    "message": f"Failed to start container: {start_result.stderr}",
                    "error": "START_CONTAINER_FAILED"
                }
            
            # Step 4: Verify container is running
            print("Verifying container status...")
            verify_result = self.verify_container_status()
            if not verify_result["success"]:
                return verify_result
            
            # Step 5: Wait a moment for container to fully start
            import time
            time.sleep(2)
            
            # Step 6: Get current resource limits
            current_limits = self.get_current_limits()
            
            
            return {
                "success": True,
                "message": f"Resource limits applied successfully",
                "limits": {
                    "cpu": cpu_limit,
                    "memory": memory_limit
                },
                "current_limits": current_limits,
                "container_status": verify_result["status"]
            }
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Error setting resource limits: {str(e)}",
                "error": "EXCEPTION"
            }
    
    def update_compose_file(self, cpu_limit, memory_limit):
        """Update docker-compose file with resource limits"""
        try:
            # Read current file
            with open(self.compose_file, 'r') as f:
                content = f.read()
            
            # Create resource limits section
            limits_section = f'''    deploy:
      resources:
        limits:
          cpus: '{cpu_limit or "1.0"}'
          memory: {memory_limit or "1G"}
        reservations:
          cpus: '{float(cpu_limit or 1.0) * 0.5}'
          memory: {memory_limit or "512M"}'''
            
            # Check if deploy section already exists
            if 'deploy:' in content:
                # Remove existing deploy section first
                pattern = r'\n\s*deploy:.*?(?=\n\s*[a-zA-Z]|\n\s*$|\Z)'
                content = re.sub(pattern, '', content, flags=re.DOTALL)
            
            # Add new deploy section
            content = content.replace(
                'container_name: satlyt-container',
                f'container_name: satlyt-container\n{limits_section}'
            )
            
            # Write updated content
            with open(self.compose_file, 'w') as f:
                f.write(content)
            
            return {"success": True}
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Error updating compose file: {str(e)}",
                "error": "FILE_UPDATE_FAILED"
            }
    
    def reset_resource_limits(self):
        """Reset to default (no limits)"""
        try:
            print("Resetting resource limits to default...")
            
            # Stop container
            stop_result = subprocess.run(
                f"docker-compose -f {self.compose_file} down",
                shell=True, capture_output=True, text=True
            )
            
            # Reset compose file to original
            original_content = """services:
  satlyt-server:
    build: ./satlyt_clean
    ports:
      - "3000:3000"
    volumes:
      - ./satlyt_clean/results:/app/results
      - ./satlyt_clean/errors:/app/errors
    container_name: satlyt-container"""
            
            with open(self.compose_file, 'w') as f:
                f.write(original_content)
            
            # Start container
            start_result = subprocess.run(
                f"docker-compose -f {self.compose_file} up -d",
                shell=True, capture_output=True, text=True
            )
            
            if start_result.returncode != 0:
                return {
                    "success": False,
                    "message": f"Failed to start container: {start_result.stderr}",
                    "error": "START_CONTAINER_FAILED"
                }
            
            return {
                "success": True,
                "message": "Resource limits reset to default (unlimited)",
                "limits": {"cpu": "unlimited", "memory": "unlimited"}
            }
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Error resetting limits: {str(e)}",
                "error": "EXCEPTION"
            }
    
    def get_current_limits(self):
        """Get current resource limits from running container"""
        try:
            # Get container inspect info
            result = subprocess.run(
                f"docker inspect {self.container_name}",
                shell=True, capture_output=True, text=True
            )
            
            if result.returncode != 0:
                return {"cpu": "unknown", "memory": "unknown"}
            
            import json
            container_info = json.loads(result.stdout)[0]
            
            # Extract resource limits
            cpu_limit = "unlimited"
            memory_limit = "unlimited"
            
            if 'HostConfig' in container_info:
                host_config = container_info['HostConfig']
                
                # Check for CPU limits
                if 'CpuQuota' in host_config and host_config['CpuQuota'] > 0:
                    cpu_quota = host_config['CpuQuota']
                    cpu_period = host_config.get('CpuPeriod', 100000)
                    cpu_limit = f"{cpu_quota / cpu_period:.1f}"
                elif 'CpuCount' in host_config and host_config['CpuCount'] > 0:
                    cpu_limit = f"{host_config['CpuCount']}"
                
                # Check for memory limits
                if 'Memory' in host_config and host_config['Memory'] > 0:
                    memory_bytes = host_config['Memory']
                    if memory_bytes >= 1024**3:
                        memory_limit = f"{memory_bytes / (1024**3):.1f}G"
                    elif memory_bytes >= 1024**2:
                        memory_limit = f"{memory_bytes / (1024**2):.0f}M"
                    else:
                        memory_limit = f"{memory_bytes}B"
            
            
            return {"cpu": cpu_limit, "memory": memory_limit}
            
        except Exception as e:
            print(f"Could not get current limits: {e}")
            return {"cpu": "unknown", "memory": "unknown"}
    
    def verify_container_status(self):
        """Verify container is running and healthy"""
        try:
            # Check if container is running
            result = subprocess.run(
                f"docker ps --filter name={self.container_name} --format '{{{{.Status}}}}'",
                shell=True, capture_output=True, text=True
            )
            
            if result.returncode != 0 or not result.stdout.strip():
                return {
                    "success": False,
                    "message": "Container is not running",
                    "error": "CONTAINER_NOT_RUNNING"
                }
            
            status = result.stdout.strip()
            if "Up" not in status:
                return {
                    "success": False,
                    "message": f"Container status: {status}",
                    "error": "CONTAINER_NOT_HEALTHY"
                }
            
            return {
                "success": True,
                "status": status,
                "message": "Container is running and healthy"
            }
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Error verifying container: {str(e)}",
                "error": "VERIFICATION_FAILED"
            }

def main():
    """Command line interface"""
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 resource_manager.py set <cpu_limit> <memory_limit>")
        print("  python3 resource_manager.py reset")
        print("  python3 resource_manager.py status")
        print("")
        print("Examples:")
        print("  python3 resource_manager.py set 0.5 512M")
        print("  python3 resource_manager.py set 1.0 1G")
        print("  python3 resource_manager.py reset")
        print("  python3 resource_manager.py status")
        sys.exit(1)
    
    manager = ResourceManager()
    command = sys.argv[1].lower()
    
    if command == "set":
        if len(sys.argv) < 4:
            print(" Error: CPU and memory limits required")
            print("Usage: python3 resource_manager.py set <cpu_limit> <memory_limit>")
            sys.exit(1)
        
        cpu_limit = sys.argv[2]
        memory_limit = sys.argv[3]
        
        result = manager.set_resource_limits(cpu_limit, memory_limit)
        
        if result["success"]:
            print(f" {result['message']}")
            print(f" Applied limits: CPU={result['limits']['cpu']}, Memory={result['limits']['memory']}")
            print(f" Current limits: CPU={result['current_limits']['cpu']}, Memory={result['current_limits']['memory']}")
        else:
            print(f" {result['message']}")
            sys.exit(1)
    
    elif command == "reset":
        result = manager.reset_resource_limits()
        
        if result["success"]:
            print(f" {result['message']}")
        else:
            print(f"{result['message']}")
            sys.exit(1)
    
    elif command == "status":
        limits = manager.get_current_limits()
        status = manager.verify_container_status()
        
        print(f" Current resource limits:")
        print(f"   CPU: {limits['cpu']}")
        print(f"   Memory: {limits['memory']}")
        print(f"Container status: {status['status'] if status['success'] else 'Error'}")
    
    else:
        print(f" Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()
