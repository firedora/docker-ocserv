FROM centos:8

RUN yum install epel-release && \
    yum install ocserv && \
    yum install iptables

COPY entrypoint.sh /entrypoint.sh
COPY ocserv.conf /etc/ocserv/ocserv.conf
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 443
CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"]
