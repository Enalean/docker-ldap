#!/bin/bash

set -e

if [ ! -d /data/ldap ]; then
    mv /var/lib/ldap /data
else 
    rm -rf /var/lib/ldap
fi

ln -s /data/ldap /var/lib/ldap

exec /usr/sbin/slapd -h ldap:/// ldaps:/// ldapi:/// -u ldap -d $DEBUG_LEVEL
