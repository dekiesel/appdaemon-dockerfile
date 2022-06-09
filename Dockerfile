#FROM python:3.8-alpine
ARG PYTHON_VERSION=${PYTHON_VERSION:-3.8.11-buster}
FROM python:${PYTHON_VERSION}

ARG AD_VERSION=${AD_VERSION:-4.0.5}
ARG USERID=${USERID:-1000}
ARG GROUPID=${GROUPID:-1000}
ARG WORKDIR=${WORKDIR:-/usr/src/app}

# API Port
EXPOSE 5050

WORKDIR ${WORKDIR}

#Create user
#RUN addgroup -S -g ${GROUPID} ad\
#  && adduser -S -G ad -u ${USERID} ad 
RUN groupadd -g ${GROUPID} ad
RUN useradd --gid ${GROUPID} --uid ${USERID} ad
#RUN usermod -u ${GROUPID} ad
#RUN usermod -a -G ${GROUPID} ad

#RUN mkdir ${WORKDIR}\
RUN chown ad:ad ${WORKDIR}

#Fix permissions
RUN mkdir /conf && chown -R ad:ad /conf
RUN mkdir /certs && chown -R ad:ad /certs

# Mountpoints for configuration & certificates
VOLUME /conf
VOLUME /certs

# Install dependencies
#RUN apt-get update && rm -rf /var/lib/apt/lists/*
RUN apt-get update 

#RUN apt-get install -y gcc libffi-dev libssl-dev musl-dev tzdata curl 
RUN apt-get install -y gcc libffi-dev libssl-dev tzdata curl musl-dev

# Install additional packages for rhasspy
RUN apt-get install -y ffmpeg lame flac vorbis-tools
#cryptography dependencies
RUN apt-get install -y build-essential libssl-dev libffi-dev
RUN apt-get clean
#as long as we are running on raspberry pi: use these prebuilt wheels to cut down on build time
RUN echo [global] > /etc/pip.conf; echo extra-index-url=https://www.piwheels.org/simple >> /etc/pip.conf
RUN python3 -m pip install --upgrade pip setuptools wheel
 

# Copy appdaemon into image
RUN wget https://github.com/AppDaemon/appdaemon/archive/${AD_VERSION}.zip -O appdaemon.zip
RUN unzip appdaemon.zip \ 
    && mv appdaemon-${AD_VERSION}/* . \
    && rm -rf appdaemon-${AD_VERSION} \
    && rm appdaemon.zip \
    && pip install --no-cache-dir .
#    && pip install .

RUN chmod +x ${WORKDIR}/dockerStart.sh

USER ${USERID}
ENTRYPOINT ["./dockerStart.sh"]
#ENTRYPOINT ["sleep","200"]

