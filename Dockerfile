FROM python:3.8-alpine

ARG AD_VERSION=${AD_VERSION:-4.0.5}
ARG USERID=${USERID:-1000}
ARG GROUPID=${GROUPID:-1000}
ARG WORKDIR=${WORKDIR:-/usr/src/app}

# API Port
EXPOSE 5050

WORKDIR ${WORKDIR}

#Create user
RUN addgroup -S -g ${GROUPID} ad\
  && adduser -S -G ad -u ${USERID} ad 
#RUN mkdir ${WORKDIR}\
RUN chown ad:ad ${WORKDIR}

#Fix permissions
RUN mkdir /conf && chown -R ad:ad /conf
RUN mkdir /certs && chown -R ad:ad /certs

# Mountpoints for configuration & certificates
VOLUME /conf
VOLUME /certs

# Install dependencies
RUN apk add --no-cache gcc libffi-dev openssl-dev musl-dev tzdata curl 

# Install additional packages for rhasspy
RUN apk add --no-cache ffmpeg lame flac vorbis-tools
 

# Copy appdaemon into image
RUN wget https://github.com/AppDaemon/appdaemon/archive/${AD_VERSION}.zip -O appdaemon.zip
RUN unzip appdaemon.zip \ 
    && mv appdaemon-${AD_VERSION}/* . \
    && rm -rf appdaemon-${AD_VERSION} \
    && rm appdaemon.zip \
    && pip install --no-cache-dir .

RUN chmod +x ${WORKDIR}/dockerStart.sh

USER ${USERID}
ENTRYPOINT ["./dockerStart.sh"]
#ENTRYPOINT ["sleep","200"]

