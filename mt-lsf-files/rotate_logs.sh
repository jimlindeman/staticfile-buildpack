#!/bin/bash
########################################################################
# (c) Copyright 2015, 2016 IBM Corp. Licensed Materials - Property of IBM.
########################################################################

ROTATION_CHECK_PERIOD=600  # 10 minutes

function log() {
  echo "$(date -u '+%Y-%m-%d %T,000') INFO $1" >>/home/vcap/${CF_APP_NAME}-rotate.log
}

echo "Generating logrotate configuration"
cat >/home/vcap/${CF_APP_NAME}-rotate.conf <<EOF
/home/vcap/${CF_APP_NAME}-rotate.log {
  size 1M
  rotate 0
}
/home/vcap/mt-logstash-forwarder/mt-lsf.log {
  size 10M
  rotate 5
}
/home/vcap/app/nginx/logs/access.log {
  size 50M
  rotate 5
  daily
}
/home/vcap/app/nginx/logs/error.log {
  size 50M
  rotate 5
  daily
}
EOF

while [ true ]; do
  log "Sleeping for $ROTATION_CHECK_PERIOD seconds before next log rotation check."
  sleep $ROTATION_CHECK_PERIOD
  log "Rotate logs if needed with logrotate"
  log_rotate_output=`/home/vcap/logrotate --verbose -s /home/vcap/rotate-statusfile /home/vcap/${CF_APP_NAME}-rotate.conf 2>&1`
  echo "$log_rotate_output" >>/home/vcap/${CF_APP_NAME}-rotate.log
done
