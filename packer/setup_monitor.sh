#!/bin/bash -ex

sudo mkdir -p /apps/
sudo chown -R ec2-user:ec2-user /apps
cd /apps/

curl -LO "https://github.com/prometheus/prometheus/releases/download/v2.2.0-rc.1/prometheus-2.2.0-rc.1.linux-amd64.tar.gz"
curl -LO "https://github.com/prometheus/alertmanager/releases/download/v0.14.0/alertmanager-0.14.0.linux-amd64.tar.gz"
tar -xvf prometheus-2.2.0-rc.1.linux-amd64.tar.gz
tar -xvf alertmanager-0.14.0.linux-amd64.tar.gz 
rm -rf prometheus-2.2.0-rc.1.linux-amd64.tar.gz
rm -rf alertmanager-0.14.0.linux-amd64.tar.gz

mkdir -p /apps/prometheus-2.2.0-rc.1.linux-amd64/rules
cp /tmp/rules/* /apps/prometheus-2.2.0-rc.1.linux-amd64/rules
cp /tmp/prometheus.yml /apps/prometheus-2.2.0-rc.1.linux-amd64/
cp /tmp/alertmanager.* /apps/alertmanager-0.14.0.linux-amd64/

sudo cp /tmp/prometheus.service /usr/lib/systemd/system/prometheus.service

sudo systemctl enable prometheus.service
sudo systemctl start prometheus.service

sudo cp /tmp/alertmanager.service /usr/lib/systemd/system/alertmanager.service

sudo systemctl enable alertmanager.service
sudo systemctl start alertmanager.service
