FROM eclipse-temurin:8-jdk

ENV OPENMQ_VERSION 4.5.2
ENV OPENMQ_ARCHIVE openmq4_5_2-binary-Linux_X86.zip

RUN apt-get update && \
    apt-get install -y zip

ADD /config/config.properties /usr/local/openmq/MessageQueue4_5/var/mq/instances/imqbroker/props/config.properties

RUN useradd -d /home/openmq -u 1001 -s /bin/bash openmq && \
    chown -R openmq:openmq /usr/local/openmq

#    mkdir -p /usr/local/openmq && \

USER openmq
RUN cd /usr/local/openmq/MessageQueue4_5 && \
    curl -v -o $OPENMQ_ARCHIVE https://download.oracle.com/mq/open-mq/$OPENMQ_VERSION/latest/$OPENMQ_ARCHIVE && \
    unzip $OPENMQ_ARCHIVE


# portmapper & broker
EXPOSE 7676
# jms service
EXPOSE 7677
# ssljms service
#EXPOSE 7678
# admin service
EXPOSE 7679
# ssladmin service
#EXPOSE 7680

CMD ["/usr/local/openmq/MessageQueue4_5/mq/bin/imqbrokerd", "-vmargs", "-Xss228m"]

