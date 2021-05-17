FROM alpine:latest

USER root

RUN apk add --no-cache lego ca-certificates dcron tzdata

COPY ./client.sh /bin/client.sh
RUN chmod 775 /bin/client.sh

COPY ./lego /etc/cron.d/lego
RUN chmod 600 /etc/cron.d/lego

# Expose Output Folder
VOLUME /output /tmp/lego

ENTRYPOINT ["/bin/client.sh", "firstStart"]
