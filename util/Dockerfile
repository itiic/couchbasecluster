FROM alpine:latest

RUN set -ex && apk add --no-cache bash openssh-client ca-certificates jq curl

COPY ./setup.sh /setup.sh
RUN chmod 755 /setup.sh

CMD ["/setup.sh"]
