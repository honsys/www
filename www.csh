#!/bin/csh -f
# while much of the apache-tomcat/config content
# is portable, each host must have its own unige keystore file.
# generated via:
# $JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA -keystore ./.keystore
#
# also be sure to double-check these env items for properly set sym-links!
# and this version version is currently only runnable from the specific www directory
#
set opt = "pro"
if ( $1 != "" ) set opt = "$1"
set cwd = `pwd`
set www = $cwd:t:r
#echo $www ala $cwd
if ( "$www" != "www" ) then
  echo this should be a www directory name, not $cwd
  exit
endif
if ( -e env.csh ) then
  source env.csh clear "$opt"
else
  echo need env.csh ...
  exit
endif
set opt = "start"
if ( $2 != "" ) set opt = "$2"
#
echo $cwd
if ( ! -e ./log ) \mkdir -p ./log
set proxylog = $cwd/log/haproxy.log
echo '--------------------------------------------------'
#
pkill tail >& /dev/null
if ( "$opt" == "stop" ) then
  echo shutting down any current haproxy, nodejs, and tomcat runtime and PRESERVING all logs 
  echo '--------------------------------------------------'
  source nodejs.csh "$opt"
  source tomcat.csh "$opt"
  pkill haproxy
  exit
endif
if ( "$opt" == "restart" ) then
  echo shutting down any current nodejs and tomcat runtime (but not haproxy) and PRESERVING all logs 
  echo '--------------------------------------------------'
  source nodejs.csh "$opt"
  source tomcat.csh "$opt"
  exit
endif
if ( "$opt" != "start" ) then
  echo unsupported option -- did you mean '"www.csh [rc or pro] and [stop] or [[re]start]"?'
  exit
endif
# ok, assume start
echo start all services, after hutting down any current haproxy, nodejs, and tomcat runtime and REMOVING all logs 
echo '--------------------------------------------------'
pkill haproxy
source nodejs.csh "$opt"
source tomcat.csh "$opt"
echo ok tomcat catalina is up ... start haproxy ...
#
set haproxyconf "-f haproxy_globaldefaults.conf haproxy_frontend_auth.conf -f haproxy_stats.conf -f haproxy_nodejsbackends.conf -f haproxy_tomcatbackends.conf"
#
haproxy -V -db -d ${haproxyconf} >>& $proxylog &
echo "haproxy started and logging to $proxylog" ; sleep 2 ; tail -f $proxylog &

