# alpine-lego
 Lego SSL Certificate Utility on Alpine Linux
 
## Purpose
 This docker is designed to obtain a valid ACME SSL certificate using Lego
 
## Environmental Variables
- CERT_SERVER - The URL of the ACME certificate server
- EMAIL       - Registration email address for the domain
- OUTPUT_FILE - Name of the file to output

## Output Volumes and Ports
- /output   - The output location of the issued certificate as a PEM file
 -- This contains the server certificate and private key in the output file
- /ca_cert - CA Certificate for the ACME server and Lego Persistent Directory
 
## Unraid Specific Settings
```vi /etc/rc.d/rc.nginx```

```			#
            # Redirect http requests to https
            #
            listen $IPV4:$PORT default_server;
            listen [$IPV6]:$PORT default_server;
            location ^~ /.well-known/ {
                try_files   /$request_uri =404;
            }
            return 302 $ORIGIN\$request_uri;
```
		
```			#
            # deny access to any hidden file (beginning with a .period)
            #
            location ~ /\.(?!well-known).* { <----
                return 404;
            }
```

```/etc/rc.d/rc.nginx reload```

### Certificate Location
```/boot/config/ssl/certs/certificate_bundle.pem```