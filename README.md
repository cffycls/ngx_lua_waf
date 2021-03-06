# ngx_lua_waf 限流防火墙使用


[2020.01.05 13:18]  
1、生成证书、搭建http服务;  

[2019.12.24 12:34]  
1、dvwa安装;  
2、sqlite3安装;  
3、sqlmap安装;  

[2020.04.30 22:21]  
完善页面访问测试;  

phpMyAdmin后台页面访问测试
====

1、getClientIp()函数报错，简化
----
```markdown
vim conf/waf/init.lua:

function getClientIp()
    return ngx.var.remote_addr or ""
end
```

2、phpmyadmin页面访问测试
----
- http://192.168.1.111:8084/phpMyAdmin/index.php ERROR：403
```markdown
vim conf/waf/wafconf/url:

(phpmyadmin|jmx-console|jmxinvokerservlet)
    -> (jmx-console|jmxinvokerservlet)
```  
刷新OK。 
- http://192.168.1.111:8084/phpMyAdmin/ajax.php ERROR：404[跳转单页可访问]  
  
查看拦截 /home/wwwroot/cluster/ngx_lua_waf/logs/error.log 检查是 limiting requests 方面的问题。  

```markdown
vim conf/nginx.conf:

burst=30
rate=10r/s
```  
重启nginx刷新OK。 
- https://192.168.1.111:8085/phpMyAdmin/lint.php ERROR：403[跳转单页可访问]  
  
查看拦截无log，检查post传参。  

```markdown
Form Data:
    sql_query: SELECT * FROM `user` WHERE 1

备份并修改： conf/waf/wafconf/post，去除sql相关拦截
```  
重启nginx刷新OK。 
```markdown
添加IP到白名单，并还原post：
vim conf/waf/config.lua，ipWhitelist添加 192.168.1.100
```  
重启nginx刷新OK。 

3、其它问题
----
- 变量 $cfg['TempDir'] （/var/www/html/phpMyAdmin/tmp/）无法访问
```markdown
vim ../html/phpMyAdmin/libraries/vendor_config.php:

define('TEMP_DIR', '/temp/'); //sys_get_temp_dir()
```
- 需要一个短语密码

新版本的PhpMyAdmin 增强了安全性，需要在配置文件设置一个短语密码。
```markdown
vim ../html/phpMyAdmin/config.sample.inc.php:
vim ../html/phpMyAdmin/libraries/config.default.php:

$cfg['blowfish_secret'] = 'abpqrstuvwxyzabcdefgh.phpmyadmin'; //随意的字符,够32位即可
vim ../html/phpMyAdmin/libraries/config.default.php 792: $cfg['LoginCookieValidity'] = 604800; //3600*24*7=604800
php.ini: session.gc_maxlifetime = 604800
```
- Fatal error: Uncaught Error: Failed to create(read) session ID: redis

/var/www/html/phpMyAdmin/libraries/classes/Session.php on line 58 --  
刷新几次就好，但偶然仍会出现。为了防止session固定、XSS跨站脚本攻击， 不活跃后强制刷新时会主动刷新，只在 远程存储session时生成才会异常。
```markdown
session_regenerate_id(true) //58行： 更换session_id

http://192.168.1.111:8084/s.php //单独测试见: ../html/s.php
Redis not available while creating session_id ...
一直刷新，可能会报不同的错误: 无、notice、Fatal error，是PHP的bug

注释掉： /var/www/html/phpMyAdmin/libraries/classes/Session.php 的58行即可。
```