FROM openjdk:8
MAINTAINER Jesse Schlüter (jesse@helix360.de)

ENV SUBSONIC_VERSION 6.1.6
ENV PORT 8080
ENV CONTEXT_PATH /

LABEL version="$SUBSONIC_VERSION"
LABEL description="Subsonic media streamer"

RUN apt-get update && apt-get -y install ffmpeg lame && apt-get clean && rm -fr /var/lib/apt/lists
RUN adduser --system --home /opt/subsonic --uid 999 --gid 33 subsonic
RUN mkdir -p /opt/data/transcode /opt/music /opt/playlist/ /opt/podcast/ && \
    chown -R subsonic /opt/data /opt/playlist/ /opt/podcast/
RUN ln -s /usr/bin/lame /opt/data/transcode/ && \
    ln -s /usr/bin/ffmpeg /opt/data/transcode/
RUN wget -O- --quiet "http://downloads.sourceforge.net/project/subsonic/subsonic/$SUBSONIC_VERSION/subsonic-$SUBSONIC_VERSION-standalone.tar.gz" | tar zxv -C /opt/subsonic

VOLUME /opt/music/
VOLUME /opt/data/
VOLUME /opt/playlist/
VOLUME /opt/podcast/

EXPOSE $PORT

WORKDIR /opt/subsonic

USER subsonic
CMD java -Xmx150m \
  -Dsubsonic.home=/opt/data \
  -Dsubsonic.port=$PORT \
  -Dsubsonic.httpsPort=0 \
  -Dsubsonic.contextPath=$CONTEXT_PATH \
  -Dsubsonic.defaultMusicFolder=/opt/music/ \
  -Dsubsonic.defaultPodcastFolder=/opt/podcast/ \
  -Dsubsonic.defaultPlaylistFolder=/opt/playlist/ \
  -Djava.awt.headless=true \
  -verbose:gc \
  -jar subsonic-booter-jar-with-dependencies.jar
