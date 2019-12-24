#!/bin/bash

docker stop n3 && docker rm n3 
docker run -itd --name n3 -p 8084:80 --network=mybridge \
	--privileged=true \
	-v /home/wwwroot/cluster/ngx_lua_waf/conf:/usr/local/openresty/nginx/conf \
	-v /home/wwwroot/cluster/ngx_lua_waf/logs:/usr/local/openresty/nginx/logs \
	-v /home/wwwroot/cluster/html:/usr/local/openresty/nginx/html openresty/openresty:stretch
