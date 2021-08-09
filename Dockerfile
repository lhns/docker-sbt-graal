FROM ghcr.io/graalvm/graalvm-ce:ol8-java11-21.2.0
MAINTAINER LolHens <pierrekisters@gmail.com>


ENV SBT_VERSION 1.5.5
ENV SBT_NAME sbt
ENV SBT_FILE $SBT_NAME-$SBT_VERSION.tgz
ENV SBT_URL https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/$SBT_FILE
ENV SBT_HOME /usr/local/sbt

ENV JQ_REF a17dd32
ENV JQ_URL https://github.com/LolHens/jq-buildenv/releases/download/$JQ_REF/jq

ENV CLEANIMAGE_VERSION 2.0
ENV CLEANIMAGE_URL https://raw.githubusercontent.com/LolHens/docker-cleanimage/$CLEANIMAGE_VERSION/cleanimage

ENV JAVA_OPTS -Xmx2G


ADD ["$CLEANIMAGE_URL", "/usr/local/bin/"]
RUN chmod +x "/usr/local/bin/cleanimage"

RUN microdnf install \
      perl \
 && curl -SsfL "$JQ_URL" -o /usr/bin/jq \
 && chmod +x /usr/bin/jq \
 && gu install native-image \
 && gu install nodejs \
 && cd /tmp \
 && curl -SsfLO "$SBT_URL" \
 && tar -xf "$SBT_FILE" \
 && mv "$SBT_NAME" "$SBT_HOME" \
 && cleanimage

ENV PATH $PATH:$SBT_HOME/bin

RUN cd /tmp \
 && mkdir -p src/main/scala \
 && touch src/main/scala/init.scala \
 && sbt 'set scalaVersion := "2.12.14"' compile \
 && sbt 'set scalaVersion := "2.13.6"' compile \
 && cleanimage


WORKDIR /root

RUN sbt tasks
