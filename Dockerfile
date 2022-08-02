FROM ghcr.io/graalvm/graalvm-ce:ol8-java11-22.2.0
MAINTAINER lhns <pierrekisters@gmail.com>


ENV SBT_VERSION 1.7.1
ENV SBT_NAME sbt
ENV SBT_FILE $SBT_NAME-$SBT_VERSION.tgz
ENV SBT_URL https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/$SBT_FILE
ENV SBT_HOME /usr/local/sbt

ENV GOJQ_VERSION v0.12.7
ENV GOJQ_FILE gojq_${GOJQ_VERSION}_linux_amd64
ENV GOJQ_URL https://github.com/itchyny/gojq/releases/download/$GOJQ_VERSION/${GOJQ_FILE}.tar.gz

ENV CLEANIMAGE_VERSION 2.0
ENV CLEANIMAGE_URL https://raw.githubusercontent.com/lhns/docker-cleanimage/$CLEANIMAGE_VERSION/cleanimage


ADD ["$CLEANIMAGE_URL", "/usr/local/bin/"]
RUN chmod +x "/usr/local/bin/cleanimage"

RUN microdnf install \
      git \
      perl \
 && curl -sSfL -- "$GOJQ_URL" | tar -xzf - \
 && mv "$GOJQ_FILE/gojq" /usr/bin/jq \
 && rm -Rf "$GOJQ_FILE" \
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
 && sbt 'set scalaVersion := "2.12.15"' compile \
 && sbt 'set scalaVersion := "2.13.8"' compile \
 && cleanimage


WORKDIR /root

RUN sbt tasks
