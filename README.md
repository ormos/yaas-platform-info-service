# YaaS Platform Info Service

~~~~
docker build -t elvido/yaas-platform-info-service:latest .
docker run -p 8089:80 elvido/yaas-platform-info-service

docker push elvido/yaas-platform-info-service
cf push -f ypi-xxx-manifest.yml --docker-image elvido/yaas-platform-info-service:1.x

xdg-open https://api.eu.yaas.io/xtra/ypis/v1/regions
xdg-open https://api.eu.yaas.io/xtra/ypis/v1/markets
~~~~

EU API      : https://api.eu-central.cf.yaas.io
US API      : https://api.us-east.cf.yaas.io
STAGE API   : https://api.us-east.stage.cf.yaas.io
