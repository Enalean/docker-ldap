#!/bin/bash

if [ ! -d /data/ldap ]; then
    mv /var/lib/ldap /data
else 
    rm -rf /var/lib/ldap
fi

ln -s /data/ldap /var/lib/ldap

exec /usr/sbin/slapd -u ldap -d 3
