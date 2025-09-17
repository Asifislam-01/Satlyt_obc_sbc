ls
curl -4 ifconfig.me
ls
sudo apt update
sudo apt install samba samba-common-bin -y
chmod 777 /home/pi
sudo nano /etc/samba/smb.conf
sudo smbpasswd -a pi
sudo systemctl restart smbd
ls
echo "hello Asif" > hello.txt
ls
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
ls
cd satlyt
ls
npm install
ls
rmdir node_modules
ls
cd ..
ls
ls
curl -4 ifconfig.me
hostname -I
cat server.txt
ls
cat hello.txt
ls
cd satlyt_clean
npm install express
clear
ls
cat package.json
npm install
node server.js
cd ..
ls
docker-compose -f docker-compose-up.yml up -d
docker ps
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
ls
cd satlyt_clean
ls
cat server.js
node -v
npm -v
nc -z localhost 9999
echo "PING" | nc localhost 9999
ls
docker ps
docker stop 18dff4e7a58c
docker ps
echo "START_CONTAINER" | nc localhost 9999
echo "RUN_PAYLOAD" | nc localhost 9999
# Install docker-compose
sudo apt install docker-compose -y
# Test container start
echo "START_CONTAINER" | nc localhost 9999
echo "GET_CONTAINER_STATUS" | nc localhost 9999
# Test PING with timeout
timeout 5 nc localhost 9999 <<< "PING"
# Test container status with timeout
timeout 5 nc localhost 9999 <<< "GET_CONTAINER_STATUS"
clear
telnet localhost 9999
echo "PING" | nc -w 3 localhost 9999
echo "GET_CONTAINER_STATUS" | nc -w 3 localhost 9999
echo "PING" | nc -w 3 localhost 9999
ls
docker --version
docker compose version
cd satlyt_clean
docker-compose -f docker-compose-up.yml build
docker compose -f docker-compose-up.yml build
cd ..
# Build the container
docker compose -f docker-compose-up.yml build
docker compose -f docker-compose-up.yml up -d
docker ps
curl -X POST http://localhost:3000/RUN-MODEL
ls -la satlyt_clean/results/
docker logs satlyt-container
docker stats satlyt-container
docker imags
docker images
docker network ls
docker volume ls
docker port satlyt-container
docker ps
ls
curl -4 ifconfig.me
hostname I
hostname -I
cat gateway.py
clear
ls
chmod +x setup_virtual_serial.sh
./setup_virtual_serial.sh start
./setup_virtual_serial.sh stop
sudo ./setup_virtual_serial.sh start
./setup_virtual_serial.sh test
./setup_virtual_serial.sh status
./setup_virtual_serial.sh stop
netstat -tlnp | grep 9999
sudo netstat -tlnp | grep 9999
sudo ss -tlnp | grep 9999
sudo ps aux | grep socat
sudo nc -z localhost 9999
sudo apt install netcat-openbsd -y
sudo ps aux | grep socat
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
sudo ps aux | grep socat
sudo netstat -tlnp | grep 9999
# Test sending a PING command
echo "PING" | nc localhost 9999
sudo ps aux | grep socat
sudo netstat -tlnp | grep 9999
ls
clear
sudo ps aux | grep socat
python gateway.py
python3  gateway.py
sudo pip3 install pyserial
sudo apt update
sudo apt install -y python3-pip
pip3 --version
pip3 install pyserial
sudo pip3 install pyserial
sudo apt pip3 install pyserial
sudo apt install python3-serial -y
python3  gateway.py
clear
sudo ps aux | grep socat
python3 gateway.py
ls -la /dev/ttyVIRTUAL
ls -la /dev/pts/
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
ls -la /dev/ttyVIRTUAL
python3 gateway.py
sudo ps aux | grep socat
sudo netstat -tlnp | grep 9999
python3 gateway.py
ls -la /dev/ttyVIRTUAL
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
ls -la /dev/ttyVIRTUAL
python3 gateway.py
sudo ps aux | grep socat
ls -la /dev/ttyVIRTUAL
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
ls -la /dev/ttyVIRTUAL
python3 gateway.py
ls
echo "PING" | nc -w 3 localhost 9999
docker ps
ls
cat docker-compose-up.yml
docker ps
docker stop c6fbc0cec70a
docker ps
docker stop c6fbc0cec70a
docker ps 
docker ps
docker stop f063de2c3954
ls
docker ps
ls -la satlyt_clean/results/
docker images
sudo ps aux | grep socat
ls -la /dev/ttyVIRTUAL
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
ls -la /dev/ttyVIRTUAL
python3 gateway.py
echo "PING" | nc -w 3 localhost 9999
echo "GET_STATUS" | nc -w 3 localhost 9999
Received from OBC: 'PING'
Processing OBC command: PING
Sent to OBC: PONG
Received from OBC: 'RUN_PAYLOAD'
Processing OBC command: RUN_PAYLOAD
Calling RUN-MODEL API...
API Connection Error: HTTPConnectionPool(host='localhost', port=3000): Max retries exceeded with url: /RUN-MODEL (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f8fe5cf50>: Failed to establish a new connection: [Errno 111] Connection refused'))
Sent to OBC: API_ERROR
[1]+  Stopped                 python3 gateway.py
pi@raspberrypi:~ $ echo "PING" | nc -w 3 localhost 9999
PONG
pi@raspberrypi:~ $ echo "GET_STATUS" | nc -w 3 localhost 9999
API_ERROR
pi@raspberrypi:~ $ ls
ls
echo "PING" | nc -w 3 localhost 9999
echo "RUN_PAYLOAD" | nc -w 3 localhost 9999
ls -la /dev/ttyVIRTUAL
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh stART
./setup_virtual_serial.sh start
sudo netstat -tlnp | grep 9999
python3 gateway.py
ls
curl http://localhost:3000/MODEL-EXECUTION-STATUS
docker ps
hostname -I
ls -la /dev/ttyVIRTUAL
sudo px aux | grep socat
sudo ps aux | grep socat
ls -la /dev/ttyVIRTUAL
sudo nc -z localhost 9999
./setup_virtual_serial.sh status
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
ls -la /dev/ttyVIRTUAL
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
sudo ps aux | grep socat
sudo netstat -tlnp | grep 9999
python3 gateway.py
sudo ps aux | grep socat
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
sudo ps aux | grep socat
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
ls
cd satlyt_clean
npm run start
echo "PING" | nc -w 3 localhost 9999
echo "START_CONTAINER" | nc -w 3 localhost 9999
sudo netstat -tlnp | grep :3000
sudo pkill -f "node.*3000"
sudo netstat -tlnp | grep :3000
curl http://localhost:3000/MODEL-EXECUTION-STATUS
sudo kill 45748
sudo netstat -tlnp | grep :3000
cd ..
echo "START_CONTAINER" | nc -w 3 localhost 9999
sudo kill 45748
sudo netstat -tlnp | grep :3000
sudo kill -9 45748
sudo netstat -tlnp | grep :3000
docker ps
echo "START_CONTAINER" | nc -w 3 localhost 9999
docker ps
echo "GET_CONTAINER_STATUS" | nc -w 3 localhost 9999
docker ps
docker stats satlyt-container
docker ps
echo "GET_CONTAINER_STATUS" | nc -w 3 localhost 9999
docker ps 
echo "GET_CONTAINER_STATUS" | nc -w 3 localhost 9999
echo "GET_CONTAINER_STATUS" | nc -w 5 localhost 9999
docker stats satlyt-container
echo "RUN_PAYLOAD" | nc -w 3 localhost 9999
echo "GET_CONTAINER_STATUS" | nc -w 5 localhost 9999
echo "GET_CONTAINER_STATUS" | nc -w 10 localhost 9999
docker stats satlyt-container
docker ps
docker stats f063de2c3954
echo "SET_STATS:cpu=15.5,memory=512MiB,mem_percent=25.0,net_io=1.2MB/800KB,block_io=100KB/50KB" | nc -w 5 localhost 9999
docker stats f063de2c3954
echo "SET_STATS:cpu=15.5,memory=512MiB,mem_percent=25.0,net_io=1.2MB/800KB,block_io=100KB/50KB" | nc -w 5 localhost 9999
docker stats f063de2c3954
echo "GET_CONTAINER_STATUS" | nc -w 5 localhost 9999
echo "GET_CONTAINER_STATUS" | nc -w 15 localhost 9999
echo "PING" | nc -w 3 localhost 9999
python3 resource_manager.py set 0.5 512M
python3 resource_manager.py status
docker ps
docker stats 2d902f414bbd
python3 resource_manager.py set 0.5 512M
docker ps
docker stats bcd137775510
python3 resource_manager.py reset
docker ps
docker ps 
echo "STOP_CONTAINER" | nc -w 10 localhost 9999
docker ps
echo "PING" | nc -w 3 localhost 9999
docker ps
echo "START_CONTAINER" | nc -w 10 localhost 9999
docker ps
echo "SET_RESOURCE_LIMITS:cpu=0.5,memory=512M" | nc -w 10 localhost 9999
docker ps
docker stop 2a2357c5343c
docker ps
echo "START_CONTAINER" | nc -w 10 localhost 9999
docker ps
echo "SET_RESOURCE_LIMITS:cpu=0.5,memory=512M" | nc -w 10 localhost 9999
docker ps
docker stats cea95fb9a445
echo "GET_CONTAINER_STATUS" | nc -w 10 localhost 9999
# Check current limits using our resource manager
python3 resource_manager.py status
# Check the actual resource limits applied to the container
docker inspect satlyt-container --format='{{.HostConfig.CpuQuota}} {{.HostConfig.CpuPeriod}} {{.HostConfig.Memory}}'
# Reset to unlimited
echo "RESET_RESOURCE_LIMITS" | nc -w 10 localhost 9999
docker ps
python3 resource_manager.py set 0.5 512M
docker inspect satlyt-container --format='{{.HostConfig.CpuQuota}} {{.HostConfig.CpuPeriod}} {{.HostConfig.Memory}}'
# Test the updated resource manager
python3 resource_manager.py set 0.5 512M
docker ps
python3 resource_manager.py set 0.5 512M
# Check the actual container limits
docker inspect satlyt-container --format='{{.HostConfig.CpuQuota}} {{.HostConfig.CpuPeriod}} {{.HostConfig.Memory}}'
python3 resource_manager.py set 0.5 512M
docker inspect satlyt-container --format='{{.HostConfig.CpuQuota}} {{.HostConfig.CpuPeriod}} {{.HostConfig.Memory}}'
python3 resource_manager.py set 0.5 512M
docker inspect satlyt-container --format='{{.HostConfig.CpuQuota}} {{.HostConfig.CpuPeriod}} {{.HostConfig.Memory}}'
python3 resource_manager.py set 0.5 512M
echo "PING" | nc -w 3 localhost 9999
ls
cat resource_manager.py
sudo ps aux | grep socat
sudo netstat -tlnp | grep :3000
docker ps
docker stop 668f7d8c4975
docker ps 
docker ps
sudo ps aux | grep socat
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
ls
cat docker-compose-up.yml
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
./setup_virtual_serial.sh stop
./setup_virtual_serial.sh start
python3 gateway.py
echo "PING" | nc w -3 localhost 9999
echo "PING" | nc -w 3 localhost 9999
docker ps
echo "GET_CONTAINER_STATUS" | nc -w 3 localhost 9999
docker ps 
ls
echo "START_CONTAINER" | nc -w 3 localhost 9999
docker rm 668f7d8c4975af74cc84afe3d24ecb388a88171c96566dc0d7e97764a20da98e
docker ps
echo "START_CONTAINER" | nc -w 3 localhost 9999
docker ps 
docker stats b9095e77f7c8
echo "STOP_CONTAINER" | nc -w 3 localhost 9999
docker ps 
docker stats b9095e77f7c8
echo "RUN_PAYLOAD" | nc -w 3 localhost 9999
echo "PING" | nc -w 3 localhost 9999
echo "RUN_PAYLOAD" | nc -w 3 localhost 9999
docker ps
echo "START_CONTAINER" | nc -w 3 localhost 9999
docker ps
echo "START_CONTAINER" | nc -w 3 localhost 9999
echo "RUN_PAYLOAD" | nc -w 3 localhost 9999
docker ps
echo "GET_STATUS" | nc -w 3 localhost 9999
docker ps
docker stop 4b86e0aa3496
docker ps
echo "PING" | nc -w 3 localhost 9999
echo "START_CONTAINER" | nc -w 3 localhost 9999
echo "PING" | nc -w 3 localhost 9999
docker ps
echo "RUN_PAYLOAD" | nc -w 3 localhost 9999
echo "GET_STATUS" | nc -w 3 localhost 9999
docker logs satlyt-containe
docker ps
docker stop 4b86e0aa3496
echo "PING" | nc -w 3 localhost 9999
echo "START_CONTAINER" | nc -w 3 localhost 9999
echo "PING" | nc -w 3 localhost 9999
echo "GET_STATUS" | nc -w 3 localhost 9999
echo "RUN_PAYLOAD" | nc -w 3 localhost 9999
echo "GET_STATUS" | nc -w 3 localhost 9999
echo "GET_FILES" | nc -w 3 localhost 9999
echo "GET_STATUS" | nc -w 3 localhost 9999
docker ps
echo "GET_STATUS" | nc -w 3 localhost 9999
echo "GET_FILES" | nc -w 3 localhost 9999
echo "GET_STATUS" | nc -w 3 localhost 9999
docker ps
LS
ls
docker ps
ls
python3 resource_manager.py set 0.5 512M
docker ps 
ls
git init
cat > .gitignore << EOF
node_modules/
__pycache__/
*.pyc
.env
.DS_Store
*.log
EOF

ls
git add .
git commit -m "OBC_SBC_emulator_setup_1.0"
git config --global user.name
git config --global user.name Asif
git config --global user.email asif@catalyx.space
git commit -m "OBC_SBC_emulator_setup_1.0"
git remote add origin https://github.com/Catalyx-Space/Satlyt_obc_sbc.git
git branch
git remote -v
git push -u origin master
git remote -v
git remote add origin https://github.com/Asifislam-01/Satlyt_obc_sbc.git
git remote set-url origin https://github.com/Asifislam-01/Satlyt_obc_sbc.git
git remote -v
git branch 
git push -u origin master
