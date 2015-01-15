# Dockerfile to build a ldap server for DEVELOPMENT #
# None of the following is meant for production, esp. from a security pov #

# Inspired from
# http://docs.adaptivecomputing.com/viewpoint/hpc/Content/topics/1-setup/installSetup/settingUpOpenLDAPOnCentos6.htm

## Use the official docker centos distribution ##
FROM centos:centos6

## Get some karma ##
MAINTAINER Manuel Vacelet, manuel.vacelet@enalean.com

# Update to last version
RUN yum -y update && yum -y install openldap-servers openldap-clients; yum clean all

# Default password is Welcome0 
RUN echo 'olcRootPW: {SSHA}pa84PIkgQ48nqq6gg19ER2Z3LAoMFE3Z' >> '/etc/openldap/slapd.d/cn=config/olcDatabase={2}bdb.ldif' && \
    echo "olcAccess: {0}to attrs=userPassword by self write by dn.base=\"cn=Manager,dc=tuleap,dc=local\" write by anonymous auth by * none" >> '/etc/openldap/slapd.d/cn=config/olcDatabase={2}bdb.ldif' && \
    echo "olcAccess: {1}to * by dn.base=\"cn=Manager,dc=tuleap,dc=local\" write by self write by * read" >> '/etc/openldap/slapd.d/cn=config/olcDatabase={2}bdb.ldif' && \
    sed -i 's/dc=my-domain,dc=com/dc=tuleap,dc=local/' '/etc/openldap/slapd.d/cn=config/olcDatabase={2}bdb.ldif' && \
    sed -i 's/dc=my-domain,dc=com/dc=tuleap,dc=local/' '/etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif'

COPY . /root

RUN service slapd start && sleep 3 && ldapadd -f /root/base.ldif -D cn=Manager,dc=tuleap,dc=local -w welcome0

EXPOSE 389

VOLUME [ "/data" ]

CMD ["/root/run.sh"]
