ARG VERSION=latest
FROM grmontesino/burp-base:${VERSION}

EXPOSE 5000

RUN apt-get update && apt-get install --no-install-recommends -y \
	libffi-dev \
	libssl-dev \
	python3-dev \
	python3-pip \
	&& rm -rf /var/lib/apt/lists/*

RUN pip install burp-ui~=0.6.0 jinja2~=3.0.0 itsdangerous~=2.0.1 ldap3~=2.9 && \
	cp /usr/local/share/burpui/etc/burpui.sample.cfg /etc/burp/burpui.cfg && \
	rm /etc/burp/burp-server.conf

COPY entrypoint.sh /usr/local/bin

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]

CMD ["burp-ui", "--", "-h", "0.0.0.0"]
