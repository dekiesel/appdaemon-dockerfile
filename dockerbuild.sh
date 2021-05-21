AD_VERSION=4.0.8
docker build --build-arg USERID=1000\
             --build-arg GROUPID=1000\
             --build-arg AD_VERSION=${AD_VERSION}\
             --tag appdaemon:${AD_VERSION}_1 .
