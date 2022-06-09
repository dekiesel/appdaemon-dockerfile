#AD_VERSION=4.0.8
AD_VERSION=4.2.1
PYTHON_VERSION=3.9.13-buster
docker build --build-arg USERID=1000\
             --build-arg GROUPID=1000\
             --build-arg AD_VERSION=${AD_VERSION}\
             --build-arg PYTHON_VERSION=${PYTHON_VERSION}\
             --tag appdaemon:${AD_VERSION}_1 .
