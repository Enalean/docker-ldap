Dockerfile to have an LDAP server for development
=================================================

Inspired from a [Centos 6 LDAP tutorial](http://docs.adaptivecomputing.com/viewpoint/hpc/Content/topics/1-setup/installSetup/settingUpOpenLDAPOnCentos6.htm)

How to use it
=============

Basically just bind a port to your host

    docker run -p 389:389 enalean/ldap-dev

Then you should be able to issue some ldap command from your host (you might need to install some ldap client tools):

    $> ldapadd -f bob.ldif -x -D 'cn=Manager,dc=tuleap,dc=local' -w welcome0
    adding new entry "cn=Bob Jones,ou=people,dc=tuleap,dc=local"

    $> ldapsearch -x -h 172.17.0.47 -LLL -b 'dc=tuleap,dc=local' 'cn=bob*'
    dn: cn=Bob Jones,ou=people,dc=tuleap,dc=local
    cn: Bob Jones
    sn: Jones
    objectClass: inetOrgPerson
    uid: bjones

Data persistence
================

There is a volume for /data:

    docker run -p 389:389 -d /srv/docker/ldap:/data enalean/ldap-dev
