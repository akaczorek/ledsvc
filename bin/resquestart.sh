#!/bin/bash
cd /root/ledsvc && bundle exec rake resque:work RAILS_ENV=production BACKGROUND=yes QUEUE=* PIDFILE=/var/run/resque.pid
