# FROM alpine:latest
FROM cygmris/alpine:latest

MAINTAINER cygmris <chrisheng86@gmail.com>

# apk mirror
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# RUN apk --update --no-cache \ 
#         --virtual earth2 \
#         ADD git \
#             vim

RUN apk add --update --no-cache \
            --virtual build-deps \
            gcc

RUN apk add --update --no-cache \
            bind \
            #for rndc
            bind-tools
        
RUN apk add --update --no-cache \
            python3 \
            python3-dev \
            musl-dev
            # supervisor

# for mkrdns
RUN sed -i 's/v3.9/edge/g' /etc/apk/repositories&& \
    apk add --update -u perl


ADD docker/conf/supervisord.conf /etc/supervisord.conf

#pip mirror
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 install supervisor

           
RUN pip3 install virtualenv

RUN rndc-confgen -a && \
    chmod 660 /etc/bind/rndc.key


RUN mkdir -p /usr/local/open_dnsdb && \
    mkdir -p /var/log/open_dnsdb && \
    mkdir -p /etc/supervisor/conf.d
COPY docker/conf/supervisor.conf.d/*.conf /etc/supervisor/conf.d/


ADD . /usr/local/open_dnsdb
ADD docker/conf/named.conf /etc/bind/named.conf 

# RUN git clone https://github.com/cygmris/open_dnsdb.git /usr/local/open_dnsdb

ADD docker/start.sh /start.sh
RUN chmod 755 /start.sh

WORKDIR /usr/local/open_dnsdb

ENV FLASK_APP=dnsdb_command.py
ENV FLASK_ENV=beta

RUN python3 tools/install_venv.py -p /usr/bin/python3.6 && \
    source .venv/bin/activate && \
    tools/with_venv.sh python setup.py install&& \
    flask deploy

# permission issue is the last thing to deal with. 
RUN addgroup -g 505 bind &&\
    adduser -h /etc/bind -D -u 505 -g bind -G bind -s /sbin/nologin bind &&\
    chgrp -R bind /etc/bind /var/bind /var/run/named /var/bind/dyn /var/bind/pri /var/bind/sec
RUN chmod +x tools/updater/pre_updater_start.sh &&\
    tools/updater/pre_updater_start.sh


VOLUME "/usr/local/open_dnsdb"

EXPOSE 53 9001 9000

#CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
CMD ["/start.sh"]

