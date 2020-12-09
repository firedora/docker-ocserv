FROM centos:8

RUN yum install -y epel-release && \
    yum install -y ocserv && \
    yum install -y iptables

ADD ./ocuser /usr/local/bin
RUN chmod a+x /usr/local/bin/ocuser

COPY ocserv.conf /etc/ocserv/ocserv.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 443
CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"]
