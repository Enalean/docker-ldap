# Dockerfile to build a ldap server for DEVELOPMENT #
# None of the following is meant for production, esp. from a security pov #

## Use the official docker centos distribution ##
FROM centos:centos6

## Get some karma ##
MAINTAINER Manuel Vacelet, manuel.vacelet@enalean.com

# See possible debug levels in man page (loglevel): http://linux.die.net/man/5/slapd.conf
ENV DEBUG_LEVEL=256
EXPOSE 389
VOLUME [ "/data" ]

# Update to last version

RUN yum -y update && \
    yum -y install openldap-servers openldap-clients && \
    yum clean all

COPY . /root

# Default passwords are welcome0
# RootDnpassword is welcome0
# Manager password is welcome1
# Generated with slappasswd 

RUN service slapd start && \
    sleep 3 && \
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/manager.ldif && \
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/domain.ldif && \
    ldapadd -x -D cn=Manager,dc=tuleap,dc=local -w welcome1 -f /root/base.ldif

CMD ["/root/run.sh"]
