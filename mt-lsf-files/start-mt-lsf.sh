cd /home/vcap
tar -xvzf app/mt-lsf-files/mt-logstash-forwarder.tgz

echo "CF_APP_NAME is ${CF_APP_NAME}"
mkdir -p /home/vcap/mt-logstash-forwarder/etc
cp /home/vcap/app/mt-lsf-files/cf-lsf-template.conf /home/vcap/mt-logstash-forwarder/etc/cf-lsf-${CF_APP_NAME}.conf
sed -i "s/REPLACE_CF_APP_NAME/${CF_APP_NAME}/g" /home/vcap/mt-logstash-forwarder/etc/cf-lsf-${CF_APP_NAME}.conf

if [[ "${JSON_LOGS}" == "true" ]]; then
  sed -i "s/REPLACE_JSON_BOOLEAN/true/g" /home/vcap/mt-logstash-forwarder/etc/cf-lsf-${CF_APP_NAME}.conf
else
  sed -i "s/REPLACE_JSON_BOOLEAN/false/g" /home/vcap/mt-logstash-forwarder/etc/cf-lsf-${CF_APP_NAME}.conf
fi

# start logrotate
/home/vcap/app/mt-lsf-files/rotate_logs.sh &

# Now kick off mt-logstash-forwarder
if [[ "$USE_LSF" == "true" ]]; then
  /home/vcap/mt-logstash-forwarder/bin/mt-logstash-forwarder -config /home/vcap/mt-logstash-forwarder/etc -spool-size 100 -load-vcap true > /home/vcap/mt-logstash-forwarder/mt-lsf.log 2>&1 &
fi
