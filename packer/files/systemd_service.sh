#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Error! User name is not specified."
    exit 1
else
    user=$1
fi

cat <<EOF > puma.service
[Unit]
Description=PumaServer
After=mongod.service
Requires=mongod.service

[Service]
Type=simple
PIDFile=/home/${user}/reddit/service.pid
WorkingDirectory=/home/${user}/reddit

User=${user}
Group=${user}

OOMScoreAdjust=-100

ExecStart=/usr/local/bin/puma

Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo cp puma.service /etc/systemd/system/puma.service

sudo systemctl start puma.service
sudo systemctl enable puma.service
sudo systemctl status puma.service
