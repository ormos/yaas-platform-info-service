# YaaS Platform Info Service

Deployment
~~~~
docker build -t elvido/yaas-platform-info-service:latest .
docker run -p 8089:80 elvido/yaas-platform-info-service

docker push elvido/yaas-platform-info-service
cf push -f ypi-xxx-manifest.yml --docker-image elvido/yaas-platform-info-service:1.x
~~~~

Smoke tests:
~~~~
xdg-open https://api.eu.yaas.io/hybris/ypi/v1/regions
xdg-open https://api.stage.yaas.io/hybris/ypi/v1/markets
xdg-open https://api.yaas.io/hybris/ypi/v1/info?ip=123.45.67.89
xdg-open https://api.yaas.io/hybris/ypi/v1/networks
xdg-open https://api.yaas.io/hybris/ypi/v1/email/john.smith@objectmail.com
~~~~

Endpoints:
~~~~
EU API      : https://api.eu-central.cf.yaas.io
US API      : https://api.us-east.cf.yaas.io
STAGE API   : https://api.us-east.stage.cf.yaas.io
~~~~

Examples commands:
~~~~
cf login -a https://api.us-east.stage.cf.yaas.io -u r.hofmann@sap.com ; cf push -f ypi-stage-manifest.yml --docker-image elvido/yaas-platform-info-service:1.13.1
cf login -a https://api.eu-central.cf.yaas.io -u r.hofmann@sap.com ; cf push -f ypi-prod-manifest.yml --docker-image elvido/yaas-platform-info-service:1.13.1
~~~~

Embargo download:
~~~~
curl --Header 'X-Access-Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoiU0FQLUh5YnJpcyIsInN1YiI6ImVtYmFyZ28gZGF0YSBhY2Nlc3MiLCJpc3MiOiJ5YWFzLmlvIiwiYXVkIjoiWWFhUyIsImV4cCI6MTUyMjU0MDc5OX0.CK35W8orpm1_LItvfWcn1sj4xF97Z0ZKP9CynJ32SDs' http://localhost:8089/embargo >embargo.mmdb
~~~~

Embargo Access Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoiU0FQLUh5YnJpcyIsInN1YiI6ImVtYmFyZ28gZGF0YSBhY2Nlc3MiLCJpc3MiOiJ5YWFzLmlvIiwiYXVkIjoiWWFhUyIsImV4cCI6MTUyMjU0MDc5OX0.CK35W8orpm1_LItvfWcn1sj4xF97Z0ZKP9CynJ32SDs
