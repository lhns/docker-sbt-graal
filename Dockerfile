FROM ghcr.io/graalvm/graalvm-community:22.0.0
MAINTAINER lhns <pierrekisters@gmail.com>

ENV SBT_VERSION 1.9.8
ENV SBT_NAME sbt
ENV SBT_FILE $SBT_NAME-$SBT_VERSION.tgz
ENV SBT_URL https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/$SBT_FILE
ENV SBT_HOME /usr/local/sbt

ENV JQ_VERSION 1.7.1
ENV JQ_URL https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64

ENV CLEANIMAGE_VERSION 2.0
ENV CLEANIMAGE_URL https://raw.githubusercontent.com/lhns/docker-cleanimage/$CLEANIMAGE_VERSION/cleanimage

ADD ["$CLEANIMAGE_URL", "/usr/bin/"]
RUN chmod +x "/usr/bin/cleanimage"

RUN microdnf install git nodejs perl \
 && curl -sSfLo /usr/bin/jq -- "$JQ_URL" \
 && chmod +x /usr/bin/jq \
 && cd /tmp \
 && curl -sSfLO -- "$SBT_URL" \
 && tar -xf "$SBT_FILE" \
 && mv "$SBT_NAME" "$SBT_HOME" \
 && cleanimage

ENV PATH $PATH:$SBT_HOME/bin

RUN cd /tmp \
 && mkdir -p src/main/scala \
 && touch src/main/scala/init.scala \
 && sbt 'set scalaVersion := "2.12.18"' compile \
 && sbt 'set scalaVersion := "2.13.12"' compile \
 && sbt 'set scalaVersion := "3.3.1"' compile \
 && cleanimage

WORKDIR /root

RUN sbt tasks
