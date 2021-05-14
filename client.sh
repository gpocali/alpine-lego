#!/bin/ash
## LEGO CA Certificate Request

if [ ! -e /tmp/lego ]; then
    mkdir /tmp/lego
fi
ng=0
if [[ "$CERT_SERVER" == "" ]]; then
    echo Enter the Certificate Server Address in variable CERT_SERVER
    ng=1
fi
if [[ "$EMAIL" == "" ]]; then
    echo Enter the registration email in variable EMAIL
    ng=1
fi
if [ $ng -eq 1 ]; then
    echo Unsatisfied configuration files.  Cannot update certificates
    exit 0
fi

if [[ "$CA_CERT" != "" ]]; then
    echo "$CA_CERT" > /usr/local/share/ca-certificates/root_ca.crt
    update-ca-certificates
else
    echo CA Certificate must be set in variable CA_CERT
    exit 0
fi

domain=$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}')
certServer=$CERT_SERVER
email=$EMAIL
lego -s "$certServer" -a -m "$email" --path /tmp/cert -d "$domain" --http.webroot "/tmp/lego" --http.port 1085 --http --tls --http-timeout 10 renew || \
lego -s "$certServer" -a -m "$email" --path /tmp/cert -d "$domain" --http.webroot "/tmp/lego" --http.port 1085 --http --tls --http-timeout 10 run
cat /tmp/cert/certificates/$domain.crt > /output/tower_unraid_bundle.pem
cat /tmp/cert/certificates/$domain.key >> /output/tower_unraid_bundle.pem
# Unraid: /boot/config/ssl/certs/tower_unraid_bundle.pem

if [[ $1 == "firstStart" ]]; then
    echo -n $(date) - First Start...
    crond -b -l 8 -c /etc/crontabs
fi

exit 0
