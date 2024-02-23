# Dockerfile to build a ldap server for DEVELOPMENT #
# None of the following is meant for production, esp. from a security pov #

FROM rockylinux:9

# See possible debug levels in man page (loglevel): http://linux.die.net/man/5/slapd.conf
ENV DEBUG_LEVEL=256
EXPOSE 389 636
VOLUME [ "/data" ]

# Update to last version

RUN dnf install -y epel-release && dnf -y install openldap-servers openldap-clients libdb-utils && \
    dnf clean all

COPY . /root

CMD ["/root/run.sh"]
