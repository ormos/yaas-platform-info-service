
ngx.header.content_type = 'application/octet-stream'
ngx.header['Content-Disposition'] = 'filename="embargo.mmdb"'
ngx.exec('/data/geoip/Embargo-Networks.mmdb')
