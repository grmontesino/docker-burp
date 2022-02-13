ARG VERSION=latest
FROM grmontesino/burp-base:${VERSION}

RUN apt-get update && apt-get install --no-install-recommends -y \
        cron \
	&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin

COPY cron-burp /etc/cron.d

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]

CMD ["/usr/sbin/cron", "-f"]
