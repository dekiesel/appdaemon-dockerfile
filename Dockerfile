FROM python:3.8-alpine

# Environment vars we can configure against
# But these are optional, so we won't define them now
#ENV HA_URL http://hass:8123
#ENV HA_KEY secret_key
#ENV DASH_URL http://hass:5050
#ENV EXTRA_CMD -D DEBUG
ARG AD_VERSION=${AD_VERSION:-4.0.5}
ARG USERID=${USERID:-1000}
ARG GROUPID=${GROUPID:-1000}
ARG WORKDIR=${WORKDIR:-/usr/src/app}

# API Port
EXPOSE 5050

#RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
# Install dependencies
RUN apk add --no-cache gcc libffi-dev openssl-dev musl-dev tzdata 

# Install additional packages
RUN apk add --no-cache curl
RUN apk add --no-cache ffmpeg lame flac vorbis-tools
 
#Create user
RUN addgroup -S -g ${GROUPID} ad\
  && adduser -S -G ad -u ${USERID} ad 
RUN mkdir ${WORKDIR}\
    && chown ad:ad ${WORKDIR}

WORKDIR ${WORKDIR}
# Copy appdaemon into image
RUN wget https://github.com/AppDaemon/appdaemon/archive/${AD_VERSION}.zip -O appdaemon.zip
RUN unzip appdaemon.zip \ 
    && mv appdaemon-${AD_VERSION}/* . \
    && rm -rf appdaemon-${AD_VERSION} \
    && rm appdaemon.zip \
    && pip install --no-cache-dir .

#Fix permissions
RUN mkdir /conf && chown -R ad:ad /conf
RUN mkdir /certs && chown -R ad:ad /certs
RUN chmod +x ${WORKDIR}/dockerStart.sh

# Mountpoints for configuration & certificates
VOLUME /conf
VOLUME /certs
USER ${USERID}
ENTRYPOINT ["./dockerStart.sh"]
#ENTRYPOINT ["sleep","200"]

