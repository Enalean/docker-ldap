#!/bin/bash

set -ex

# Changing the open file descriptors limit, otherwise slapd memory
# consumption is crazy
# https://github.com/moby/moby/issues/8231
ulimit -n 1024

if [ ! -f /data/lib/ldap/DB_CONFIG ]; then
    if [ -z "$LDAP_ROOT_PASSWORD" -o -z "$LDAP_MANAGER_PASSWORD" ]; then
        echo "Need LDAP_ROOT_PASSWORD and LDAP_MANAGER_PASSWORD"
        exit
    fi

    cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
    chown ldap. /var/lib/ldap/DB_CONFIG

    /usr/sbin/slapd -h "ldap:/// ldaps:/// ldapi:///" -u ldap -d $DEBUG_LEVEL &
    slapd_pid=$!
    sleep 3

    ROOT_PWD=$(slappasswd -s $LDAP_ROOT_PASSWORD)
    # Use bash variable subsitution to escape special chars http://stackoverflow.com/a/14339705
    sed -i "s+%LDAP_ROOT_PASSWORD%+${ROOT_PWD//+/\\+}+" /root/manager.ldif
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/manager.ldif

    ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/cosine.ldif
    ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/nis.ldif
    ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/inetorgperson.ldif
    MANAGER_PWD=$(slappasswd -s $LDAP_MANAGER_PASSWORD)
    sed -i "s+%LDAP_MANAGER_PASSWORD%+${MANAGER_PWD//+/\\+}+" /root/domain.ldif
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/domain.ldif

    ldapadd -x -D cn=Manager,dc=tuleap,dc=local -w $LDAP_MANAGER_PASSWORD -f /root/base.ldif

    kill "$slapd_pid"
    wait "$slapd_pid"

    mkdir /data/lib /data/etc
    cp -ar /var/lib/ldap /data/lib
    cp -ar /etc/openldap /data/etc
fi

rm -rf /var/lib/ldap && ln -s /data/lib/ldap /var/lib/ldap
rm -rf /etc/openldap && ln -s /data/etc/openldap /etc/openldap

pushd /var/lib/ldap
db_recover -v -h .
db_upgrade -v -h . *.bdb
db_checkpoint -v -h . -1
chown -R ldap: .
popd
exec /usr/sbin/slapd -h "ldap:/// ldaps:/// ldapi:///" -u ldap -d $DEBUG_LEVEL
