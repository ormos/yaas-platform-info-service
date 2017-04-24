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

Embargo download:
~~~~
curl --Header 'X-Access-Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoiU0FQLUh5YnJpcyIsInN1YiI6ImVtYmFyZ28gZGF0YSBhY2Nlc3MiLCJpc3MiOiJ5YWFzLmlvIiwiYXVkIjoiWWFhUyIsImV4cCI6MTUyMjU0MDc5OX0.CK35W8orpm1_LItvfWcn1sj4xF97Z0ZKP9CynJ32SDs' http://localhost:8089/embargo >embargo.mmdb
~~~~

Embargo Access Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoiU0FQLUh5YnJpcyIsInN1YiI6ImVtYmFyZ28gZGF0YSBhY2Nlc3MiLCJpc3MiOiJ5YWFzLmlvIiwiYXVkIjoiWWFhUyIsImV4cCI6MTUyMjU0MDc5OX0.CK35W8orpm1_LItvfWcn1sj4xF97Z0ZKP9CynJ32SDs

