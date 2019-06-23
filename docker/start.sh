#!/bin/bash

# cd /usr/local/open_dnsdb && \
# pip3 install \

if [ -d /usr/local/open_dnsdb/.venv ]
then
    echo "pass"
else
    cd /usr/local/open_dnsdb
    python3 tools/install_venv.py -p /usr/bin/python3.6
    pip3 install -r requirements.txt
    source .venv/bin/activate
    tools/with_venv.sh python setup.py install
fi

exec /usr/bin/supervisord -n -c /etc/supervisord.conf

# exec /usr/sbin/named -c /etc/bind/named.conf -u bind -g
# flask import-zone-records --zone_dir /var/bind --zone_group fdMaster --user test
# flask import-named-conf --group_name fdMaster --file_path /etc/bind/named.conf
