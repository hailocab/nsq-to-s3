FROM alpine:3.1
MAINTAINER goller@gmail.com <goller@gmail.com>

RUN apk add --update bash git openssh-client && rm -rf /var/cache/apk/*

CMD ["/bin/nsq-to-s3"]

ADD bin/nsq-to-s3-linux /bin/nsq-to-s3
