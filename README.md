# alpine-lego
 Lego SSL Certificate Utility on Alpine Linux
 
## Purpose
 This docker is designed to obtain a valid ACME SSL certificate using Lego
 
## Environmental Variables
- CERT_SERVER - The URL of the ACME certificate server
- EMAIL       - Registration email address for the domain
- CA_CERT     - CA certificate used to validate the CA server communications

## Output Volumes and Ports
- Port 1885 - Used to validate the host from the CA server
- /output   - The output location of the issued certificate as a PEM file
 -- This contains the server certificate and private key in the output file
 
