# syntax=docker/dockerfile:1
FROM docker:cli

RUN apk add --no-cache busybox bash

COPY crontab /etc/crontabs/root

CMD ["crond", "-f", "-L", "/dev/stdout"]
