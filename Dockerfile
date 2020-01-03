FROM oracle/graalvm-ce:19.3.0.2-java11
MAINTAINER LolHens <pierrekisters@gmail.com>


ENV SBT_VERSION 1.3.6
ENV SBT_NAME sbt
ENV SBT_FILE $SBT_NAME-$SBT_VERSION.tgz
ENV SBT_URL https://sbt-downloads.cdnedge.bluemix.net/releases/v$SBT_VERSION/$SBT_FILE
ENV SBT_HOME /usr/local/sbt

ENV CLEANIMAGE_VERSION 2.0
ENV CLEANIMAGE_URL https://raw.githubusercontent.com/LolHens/docker-cleanimage/$CLEANIMAGE_VERSION/cleanimage

ENV JAVA_OPTS -Xmx2G


ADD ["$CLEANIMAGE_URL", "/usr/local/bin/"]
RUN chmod +x "/usr/local/bin/cleanimage"

RUN yum install -y \
      jq \
      perl \
 && gu install native-image \
 && cd /tmp \
 && curl -LO $SBT_URL \
 && tar -xf $SBT_FILE \
 && mv $SBT_NAME $SBT_HOME \
 && cleanimage

ENV PATH $PATH:$SBT_HOME/bin

RUN cd /tmp \
 && mkdir -p src/main/scala \
 && touch src/main/scala/init.scala \
 && sbt 'set scalaVersion := "2.12.10"' compile \
 && sbt 'set scalaVersion := "2.13.1"' compile \
 && cleanimage


WORKDIR /root

RUN sbt tasks
