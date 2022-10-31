ARG VERSION=latest
FROM grmontesino/burp-base:${VERSION}

EXPOSE 5000

# Configure the deadsnake ppa for python 3.9
RUN apt-get update && apt-get install --no-install-recommends -y \
		ca-certificates \
		gnupg \
	&& gpg --keyserver keyserver.ubuntu.com --recv F23C5A6CF475977595C89F51BA6932366A755776 \
	&& gpg --export F23C5A6CF475977595C89F51BA6932366A755776 > /etc/apt/keyrings/deadsnakes.gpg \
	&& rm -rf ~/.gnupg \
	&& echo "deb [signed-by=/etc/apt/keyrings/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" \
		> /etc/apt/sources.list.d/ppa-deadsnakes.list \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install --no-install-recommends -y \
	curl \
	libffi-dev \
	libssl-dev \
	python3.9-dev \
	python3.9-distutils \
	&& rm -rf /var/lib/apt/lists/*

RUN curl https://bootstrap.pypa.io/get-pip.py | python3.9 && \
	python3.9 -m pip install burp-ui~=0.6.6 jinja2~=3.0.0 itsdangerous~=2.0.1 ldap3~=2.9 && \
	cp /usr/local/share/burpui/etc/burpui.sample.cfg /etc/burp/burpui.cfg && \
	rm /etc/burp/burp-server.conf

COPY entrypoint.sh /usr/local/bin

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]

CMD ["burp-ui", "--", "-h", "0.0.0.0"]
