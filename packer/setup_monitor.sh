#!/bin/bash -ex

sudo mkdir -p /apps/prometheus-2.2.0-rc.1.linux-amd64/data/
sudo chown -R ec2-user:ec2-user /apps
cd /apps/

#mount data dir
sudo ls -l /dev
sudo mkfs -t ext4 /dev/xvdb
#sudo mkdir /apps/prometheus-2.2.0-rc.1.linux-amd64/data/
sudo mount /dev/xvdb /apps/prometheus-2.2.0-rc.1.linux-amd64/data/
echo "/dev/xvdb      /apps/prometheus-2.2.0-rc.1.linux-amd64/data/   ext4    defaults,nofail " | sudo tee --append /etc/fstab > /dev/null
sudo chown -R ec2-user:ec2-user /apps

curl -LO "https://github.com/prometheus/prometheus/releases/download/v2.2.0-rc.1/prometheus-2.2.0-rc.1.linux-amd64.tar.gz"
curl -LO "https://github.com/prometheus/alertmanager/releases/download/v0.14.0/alertmanager-0.14.0.linux-amd64.tar.gz"
curl -LO "https://github.com/prometheus/blackbox_exporter/releases/download/v0.12.0/blackbox_exporter-0.12.0.linux-amd64.tar.gz"

tar -xvf prometheus-2.2.0-rc.1.linux-amd64.tar.gz
tar -xvf alertmanager-0.14.0.linux-amd64.tar.gz
tar -xvf blackbox_exporter-0.12.0.linux-amd64.tar.gz 
rm -rf prometheus-2.2.0-rc.1.linux-amd64.tar.gz
rm -rf alertmanager-0.14.0.linux-amd64.tar.gz
rm -rf blackbox_exporter-0.12.0.linux-amd64.tar.gz

mkdir -p /apps/prometheus-2.2.0-rc.1.linux-amd64/rules
cp /tmp/rules/* /apps/prometheus-2.2.0-rc.1.linux-amd64/rules
cp /tmp/prometheus.yml /apps/prometheus-2.2.0-rc.1.linux-amd64/
cp /tmp/alertmanager.* /apps/alertmanager-0.14.0.linux-amd64/
cp /tmp/blackbox.yml /apps/blackbox_exporter-0.12.0.linux-amd64/

sudo cp /tmp/prometheus.service /usr/lib/systemd/system/prometheus.service

sudo systemctl enable prometheus.service
sudo systemctl start prometheus.service

sudo cp /tmp/alertmanager.service /usr/lib/systemd/system/alertmanager.service

sudo systemctl enable alertmanager.service
sudo systemctl start alertmanager.service

sudo cp /tmp/blackbox-exporter.service /usr/lib/systemd/system/blackbox-exporter.service

sudo systemctl enable blackbox-exporter.service
sudo systemctl start blackbox-exporter.service
