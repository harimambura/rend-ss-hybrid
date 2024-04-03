#!/bin/bash

if [[ -z "${VER}" ]]; then
  VER="latest"
fi
echo ${VER}

if [[ -z "${PORT}" ]]; then
  PORT=443
fi
echo ${PORT}

if [[ -z "${PASSWORD}" ]]; then
  PASSWORD="5c301bb8-6c77-41a0-a606-4ba11bbab084"
fi
echo ${PASSWORD}

if [[ -z "${ENCRYPT}" ]]; then
  ENCRYPT="chacha20-ietf-poly1305"
fi

if [[ -z "${X_Path}" ]]; then
  X_Path="/s233"
fi
echo ${X_Path}



if [ "$VER" = "latest" ]; then
  V_VER=`wget --no-check-certificate -qO- "https://api.github.com/repos/teddysun/xray-plugin/releases/latest" | sed -n -r -e 's/.*"tag_name".+?"([vV0-9\.]+?)".*/\1/p'`
  [[ -z "${V_VER}" ]] && V_VER="v1.8.4"
else
  V_VER="v$VER"
fi

mkdir /xraybin
cd /xraybin
XRAY_URL="https://github.com/teddysun/xray-plugin/releases/download/${V_VER}/xray-plugin-linux-amd64-${V_VER}.tar.gz"
wget --no-check-certificate ${XRAY_URL}
tar -zxvf xray-plugin-linux-amd64-$V_VER.tar.gz
rm -rf xray-plugin-linux-amd64-$V_VER.tar.gz
mv xray-plugin_linux_amd64 /xx-plugin
rm -rf /xraybin

sed -e "/^#/d"\
    -e "s/\${PORT}/${PORT}/g"\
    -e "s|\${X_Path}|${X_Path}|g"\
    -e "$s"\
    /conf/nginx_ss.conf > /etc/nginx/http.d/ss.conf
echo /etc/nginx/http.d/ss.conf
cat /etc/nginx/http.d/ss.conf


plugin=$(echo -n "xray;path=${X_Path};host=${AppName}.onrender.com;tls" | sed -e 's/\//%2F/g' -e 's/=/%3D/g' -e 's/;/%3B/g')
ss="ss://$(echo -n ${ENCRYPT}:${PASSWORD} | base64 -w 0)@${AppName}.onrender.com:443?plugin=${plugin}" 
echo ${ss}

echo 'RUN SS SERVER'
go-shadowsocks2 -s "ss://AEAD_CHACHA20_POLY1305:${PASSWORD}@:2333" -plugin xx-plugin -plugin-opts "server;loglevel=none" -udp=false >> /dev/null

rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
