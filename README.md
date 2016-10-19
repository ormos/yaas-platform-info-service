# YaaS Platform Info Service

~~~~
docker build -t elvido/yaas-platform-info-service:latest .
docker run -p 8089:80 elvido/yaas-platform-info-service

docker push elvido/yaas-platform-info-service
cf push yaas-platform-info-service --docker-image elvido/yaas-platform-info-service:1.2 --health-check-type none

xdg-open https://api.eu.yaas.io/xtra/ypis/v1/regions
xdg-open https://api.eu.yaas.io/xtra/ypis/v1/markets
~~~~

EU API      : https://api.eu-central.cf.yaas.io
US API      : https://api.us-east.cf.yaas.io
STAGE API   : https://api.us-east.stage.cf.yaas.io
