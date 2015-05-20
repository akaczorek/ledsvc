#!/bin/bash
cd /root/ledsvc && /usr/local/bin/rackup --port 8080 --pid /var/run/ledsvc.pid --host 0.0.0.0 /root/ledsvc/config.ru -D
