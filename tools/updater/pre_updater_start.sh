#!/bin/bash

PROJPATH=/usr/local/open_dnsdb
MKDIR=/bin/mkdir
CP=/bin/cp
CHMOD=/bin/chmod


$MKDIR $PROJPATH/tmp/var/bind -p &>/dev/null
$MKDIR $PROJPATH/tmp/etc -p  &>/dev/null

if [ ! -f "/sbin/mkrdns" ]; then
  $CP $PROJPATH/tools/updater/mkrdns /sbin/
  $CHMOD +x /sbin/mkrdns
fi
