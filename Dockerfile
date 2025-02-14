# Build stage
FROM eclipse-temurin:8-jdk AS builder

ENV OPENMQ_VERSION=4.5.2 \
    OPENMQ_ARCHIVE=openmq4_5_2-binary-Linux_X86.zip

WORKDIR /build

# Download and extract OpenMQ in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip && \
    curl -v -o $OPENMQ_ARCHIVE https://download.oracle.com/mq/open-mq/$OPENMQ_VERSION/latest/$OPENMQ_ARCHIVE && \
    unzip $OPENMQ_ARCHIVE -d MessageQueue4_5 && \
    rm $OPENMQ_ARCHIVE && \
    apt-get purge -y curl unzip && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Runtime stage
FROM eclipse-temurin:8 

ENV OPENMQ_HOME=/usr/local/openmq/MessageQueue4_5

# Create user early to leverage layer caching
RUN apt-get update && \
    apt-get install -y --no-install-recommends net-tools && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r openmq && \
    useradd -r -g openmq -d /home/openmq -s /bin/bash openmq && \
    mkdir -p ${OPENMQ_HOME} && \
    mkdir -p /home/openmq && \
    chown -R openmq:openmq /home/openmq ${OPENMQ_HOME}

# Copy only necessary files from builder
COPY --from=builder --chown=openmq:openmq /build/MessageQueue4_5 ${OPENMQ_HOME}

# Add config file
COPY --chown=openmq:openmq /config/config.properties ${OPENMQ_HOME}/var/mq/instances/imqbroker/props/config.properties

USER openmq
WORKDIR ${OPENMQ_HOME}

# Group all EXPOSE commands together
EXPOSE 7676 7677 7679
# ssljms service
#EXPOSE 7678
# ssladmin service
#EXPOSE 7680

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD netstat -an | grep 7676 || exit 1

CMD ["mq/bin/imqbrokerd", "-vmargs", "-Xss228m"]