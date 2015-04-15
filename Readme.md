Dockerfile to have an LDAP server for development
=================================================

Inspired from a [Centos 6 LDAP tutorial](http://www.server-world.info/en/note?os=CentOS_6&p=ldap) and [SSL tutorial](http://www.server-world.info/en/note?os=CentOS_6&p=ldap&f=3)

How to use it
=============

Basically just bind a port to your host

    docker run -p 389:389 enalean/ldap-dev

Then you should be able to issue some ldap command from your host (you might need to install some ldap client tools):
    
    $> cd docker-ldap-dev

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

To keep your data between reboots of your LDAP server, there is a volume for /data:

    $> docker run --name=ldap-data -v /data busybox true
    $> $EDITOR .env
    LDAP_ROOT_PASSWORD=you very secure password for root
    LDAP_MANAGER_PASSWORD=as secure but for manager
    $> docker run --rm --volumes-from ldap-data --env-file=.env enalean/ldap
    $> rm .env

Then, just regular run:

    $> docker run --volumes-from ldap-data enalean/ldap

SSL
===

docker run -ti --volumes-from ldap-data enalean/ldap bash
./root/run.sh &

cd /etc/pki/tls/certs
make server.key
openssl rsa -in server.key -out server.key
make server.csr
openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650

cp /etc/pki/tls/certs/server.key /etc/pki/tls/certs/server.crt /etc/pki/tls/certs/ca-bundle.crt /etc/openldap/certs/
chown ldap. /etc/openldap/certs/server.key /etc/openldap/certs/server.crt /etc/openldap/certs/ca-bundle.crt

ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/ssl.ldif

pkill -INT slapd


References and links
====================

* http://www.bradchen.com/blog/2012/08/openldap-tls-issue
* http://www.server-world.info/en/note?os=CentOS_6&p=ldap&f=3
* http://www.server-world.info/en/note?os=CentOS_6&p=ldap
