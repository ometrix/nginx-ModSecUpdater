#!/bin/bash

# Define el error a buscar
strError='[emerg] module "/etc/nginx/modules/ngx_http_modsecurity_module.so" version'

# Captura el estado actual del sistema
strCap=$(nginx -t 2>&1 | grep -o '\[emerg\] module \"/etc/nginx/modules/ngx_http_modsecurity_module.so\" version' )

# Captura el estado del sistema
strOK=$(nginx -t 2>&1 | grep -o ok )

# Compara el estado actual con el estado de error
if [[ "$strError" == "$strCap" ]]; then

	# Define la version nueva en el sistema
	nginxv=$(nginx -v 2>&1 | sed 's/[^0-9].[^0-9]//g')

	# Carpeta donde se encuentra el codigo del modulo ModSecurity
	cd /opt || exit

	# Descarga la version del sistema de nginx
	sudo wget https://nginx.org/download/nginx-$nginxv.tar.gz

	tar zxvf nginx-$nginxv.tar.gz
	cd nginx-$nginxv || exit

	# Configura el modulo con los demas modulos de sistema
	./configure --add-dynamic-module=../ModSecurity-nginx --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -fdebug-prefix-map=/data/builder/debuild/nginx-$nginxv/debian/debuild-base/nginx-$nginxv=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'

	# Compila la nueva version
	sudo make modules

	# Copia la version nueva al directorio de moudulos de nginx
	cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules

	systemctl restart nginx

	str2doCheck=$(nginx -t 2>&1 | grep -o ok )

	#Chequea si tod0 esta correcto.
	if [[ "ok" = "$str2doCheck" ]]; then
		echo "Todo cool"
	else
		echo "Todo Nada Cool"
	fi
elif [[ "ok" = "$strOK" ]]; then
	echo "Todo cool"
else
	echo "Todo Nada Cool"
fi


