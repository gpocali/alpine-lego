FROM alpine:latest

USER root

RUN apk add --no-cache lego ca-certificates dcron tzdata

COPY ./client.sh /bin/client.sh
RUN chmod 775 /bin/client.sh

COPY ./lego /etc/crontabs/lego
RUN chmod 600 /etc/crontabs/lego

# Expose Output Folder
VOLUME /output /tmp/lego

ENTRYPOINT ["/bin/client.sh", "firstStart"]
