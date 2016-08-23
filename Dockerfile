###### grafana images
FROM qnib/alpn-jdk8

ENV MAVEN_VERSION="3.3.9" \
    M2_HOME=/usr/lib/mvn

RUN apk add --update wget \
 && wget -qO - "http://ftp.unicamp.br/pub/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | tar xfz - -C /opt/ \
 && mv "/opt/apache-maven-$MAVEN_VERSION" "$M2_HOME" \
 && ln -s "$M2_HOME/bin/mvn" /usr/bin/mvn \
 && curl -Lso /tmp/master.zip  https://github.com/DeemOpen/zkui/archive/master.zip \
 && cd /opt/ \
 && unzip /tmp/master.zip \
 && mv /opt/zkui-master /opt/zkui \
 && apk del wget \
 && cd /opt/zkui && mvn clean install \
 && rm -rf /tmp/* /var/cache/apk/* /usr/lib/mvn 
ADD etc/supervisord.d/zkui.ini \
    etc/supervisord.d/zkui-update.ini \
    /etc/supervisord.d/
ADD etc/consul.d/zkui.json /etc/consul.d/
ADD etc/consul-templates/zkui.conf.ctmpl /etc/consul-templates/
ADD opt/qnib/zkui/bin/start_zookeeper-update.sh /opt/qnib/zkui/bin/
RUN echo "grep zkSer /opt/zkui/config.cfg" >> /root/.bash_history
ENV ZKUI_ADMIN_PW=admin \
    ZKUI_USER_PW=user \
    ZKUI_PORT=9090
ADD opt/qnib/zkui/bin/healthcheck.sh /opt/qnib/zkui/bin/
HEALTHCHECK --interval=2s --retries=300 --timeout=1s \
 CMD /opt/qnib/zkui/bin/healthcheck.sh
