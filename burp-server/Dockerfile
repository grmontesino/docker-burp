ARG VERSION=latest
FROM grmontesino/burp-base:${VERSION}

EXPOSE 4971

COPY entrypoint.sh /usr/local/bin

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]

CMD ["/usr/sbin/burp", "-F", "-v", "-c", "/etc/burp/burp-server.conf"]
