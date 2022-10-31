FROM ubuntu:jammy

RUN apt-get update && apt-get install --no-install-recommends -y \
	burp \
	openssl \
	tini \
	tzdata \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm /etc/burp/clientconfdir/testclient

VOLUME /etc/burp/tls

COPY entrypoint-utils.sh /usr/local/bin
