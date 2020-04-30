#!/bin/bash

# 8084：http1.0/1.1；8085：https；9500：代理到本机备用
docker stop n3 && rm -rf logs/*.log && docker rm n3
docker run -itd --name n3 -p 8084:80 -p 8085:443 -p 9500:9500 --network=mybridge \
	--privileged=true \
	-v /etc/timezone:/etc/localtime \
	-v /home/wwwroot/cluster/ngx_lua_waf/conf:/usr/local/openresty/nginx/conf \
	-v /home/wwwroot/cluster/ngx_lua_waf/logs:/usr/local/openresty/nginx/logs \
	-v /home/wwwroot/cluster/html:/usr/local/openresty/nginx/html \
	openresty/openresty:stretch
