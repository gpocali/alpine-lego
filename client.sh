#!/bin/ash
## LEGO CA Certificate Request

# TZ SET - Requires tzdata package
if [[ "$TZ" == "" ]]; then
    echo timezone not defined using ENV 'TZ', using UTC.
    TIMEZONE=UTC
else
    if [ -e /usr/share/zoneinfo/$TZ ]; then
        echo Using timezone: $TZ
        TIMEZONE=$TZ
    else
        echo Invalid timezone defined in input.conf file, using UTC.
        TIMEZONE=UTC
    fi
fi
cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo $TIMEZONE >  /etc/timezone

if [ ! -e /tmp/lego ]; then
    mkdir /tmp/lego
fi
if [[ "$1" == "firstStart" ]]; then
    echo -n $(date) - First Start... | tee -a /tmp/legoLog
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

if [ ! -e /ca_cert/cert ]; then
    mkdir /ca_cert/cert
fi

echo $(date) - Starting... | tee -a /tmp/legoLog
domain=$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}')
certServer=$CERT_SERVER
email=$EMAIL
if [[ "$1" != "firstStart" ]]; then
    lego -s "$certServer" -a -m "$email" --path /ca_cert/cert -d "$domain" --tls --http-timeout 10 renew | tee -a /tmp/legoLog
else
    echo $(date) - Attempting first time registration...
    lego -s "$certServer" -a -m "$email" --path /ca_cert/cert -d "$domain" --tls --http --http-timeout 10 run | tee -a /tmp/legoLog
fi
cat /ca_cert/cert/certificates/$domain.crt > /output/$OUTPUT_FILE
cat /ca_cert/cert/certificates/$domain.key >> /output/$OUTPUT_FILE
echo -e "$(date) - Finished...\n\n" | tee -a /tmp/legoLog

if [[ "$1" == "firstStart" ]]; then
    crond -b -c /etc/crontabs -L /tmp/legoLog
    echo "######## Starting Log Monitor ##########"
    tail -f /tmp/legoLog
fi

exit 0