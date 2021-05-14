#!/bin/ash
## LEGO CA Certificate Request

if [ ! -e /tmp/lego ]; then
    mkdir /tmp/lego
fi
if [[ $1 == "firstStart" ]]; then
    echo -n $(date) - First Start... | tee -a /tmp/legoLog
    crond -b -l 8 -c /etc/crontabs
fi
ng=0
if [[ "$CERT_SERVER" == "" ]]; then
    echo Enter the Certificate Server Address in variable CERT_SERVER | tee -a /tmp/legoLog
    ng=1
fi
if [[ "$EMAIL" == "" ]]; then
    echo Enter the registration email in variable EMAIL | tee -a /tmp/legoLog
    ng=1
fi
if [[ "$OUTPUT_FILE" == "" ]]; then
    echo Enter the output file name in variable OUTPUT_FILE | tee -a /tmp/legoLog
    ng=1
fi
if [ $ng -eq 1 ]; then
    echo Unsatisfied configuration files.  Cannot update certificates | tee -a /tmp/legoLog
    exit 0
fi

if [ -e /ca_cert/ca.crt ]; then
    cp -f /ca_cert/ca.crt /usr/local/share/ca-certificates/root_ca.crt
    update-ca-certificates
else
    echo CA Certificate must be located at /ca_cert/ca.crt.
    exit 0
fi

echo $(date) - Starting... | tee -a /tmp/legoLog
domain=$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}')
certServer=$CERT_SERVER
email=$EMAIL
if [[ $1 != "firstStart" ]]; then
    lego -s "$certServer" -a -m "$email" --path /tmp/cert -d "$domain" --http.webroot "/tmp/lego" --http.port 1085 --http --tls --http-timeout 10 renew | tee -a /tmp/legoLog
else
    echo $(date) - Attempting first time registration...
    lego -s "$certServer" -a -m "$email" --path /tmp/cert -d "$domain" --http.webroot "/tmp/lego" --http.port 1085 --http --tls --http-timeout 10 run | tee -a /tmp/legoLog
fi
cat /tmp/cert/certificates/$domain.crt > /output/$OUTPUT_FILE
cat /tmp/cert/certificates/$domain.key >> /output/$OUTPUT_FILE
echo -e "$(date) - Finished...\n\n" | tee -a /tmp/legoLog

tail -f /tmp/legoLog

exit 0
