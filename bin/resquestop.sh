#!/bin/bash
kill -9 $(cat /var/run/resque.pid) && rm -f /var/run/resque.pid
