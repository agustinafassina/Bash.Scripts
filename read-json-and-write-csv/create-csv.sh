#!/usr/bin/bash
sudo apt-get install -y jq

cat data.json | jq -r '
  [.[] | {
    region: .region,
    name: .name,
    ip: .publicIpAddress,
    size: .size,
    status: .status,
    security_group: (.securityGroups[0]?.groupName // "N/A"),
    platform: .plataformDetails
  }] | (["region", "name", "ip", "size", "status", "security_group", "platform"] | @csv),
     (.[] | [.region, .name, .ip, .size, .status, .security_group, .platform] | @csv)
  ' > aws_device.csv