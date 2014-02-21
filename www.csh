#!/bin/csh -f
# while much of the apache-tomcat/config content
# is portable, each host must have its own unige keystore file.
# generated via:
# $JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA -keystore ./.keystore
#
# also be sure to double-check these env items for properly set sym-links!
# and this version version is currently only runnable from the specific www directory
#
set cwd = `pwd`
set www = $cwd:t:r
#echo $www ala $cwd
if ( "$www" != "www" ) then
  echo this should be a www directory name, not $cwd
  exit
endif
if ( -e env.csh ) then
  source env.csh clear
else
  echo need env.csh ...
  exit
endif
#
echo $cwd
set opt = "start"
if ( "$1" != "" ) set opt = "$1"
set tomcat = tomcat7.csh
if ( "$2" == "rc" || "$2" == "8" ) set tomcat "tomcat8.csh"
echo "------------------------- $opt -------------------------"
#
pkill tail >& /dev/null
if ( "$opt" == "stop" ) then
  echo shutting down any current haproxy, nodejs, and tomcat runtime and PRESERVING all logs 
  echo '--------------------------------------------------'
  pkill haproxy
  source $tomcat "$opt"
  source nodejs.csh "$opt"
  pkill java # make sure tomcat stops and also stop apollo mom
  exit # all done
endif
echo "------------------------- $opt -------------------------"
if ( "$opt" == "restart" ) then
  echo shutting down any current nodejs and tomcat runtime \(but not haproxy\) and PRESERVING all logs 
  echo '--------------------------------------------------'
  source $tomcat stop
  source nodejs.csh stop
  pkill java # make sure tomcat stops and also stop apollo mom
  set opt = start # proceed to startup
endif
echo "------------------------- $opt -------------------------"
if ( "$opt" != "start" ) then
  echo unsupported option -- did you mean '"www.csh [stop] or [[re]start]"?'
  exit
endif
# ok, assume start
pwd
echo start all services -- haproxy, nodejs, and tomcat runtimes 
echo '--------------------------------------------------'
source nodejs.csh "$opt"
source $tomcat "$opt"
echo ok tomcat catalina\(s\) is\(are\) up ... start apollo mom
#
if ( ! -e ./log ) \mkdir -p ./log
set momlog = $cwd/log/apollo.log
#
${WWW_HOME}/mom/broker/bin/apollo-broker run >>& $momlog &
echo ok apollo mom up
#
set proxylog = $cwd/log/haproxy.log
pgrep haproxy
if ( $? != 0 ) then
  echo start haproxy ...
  cat haproxy_globaldefaults.conf haproxy_frontend_auth.conf haproxy_stats.conf haproxy_nodejsbackends.conf haproxy_jeebackends.conf > haproxy.conf
#
  haproxy -V -db -d -f haproxy.conf >>& $proxylog &
  sleep 1
  echo "haproxy started and logging to $proxylog" 
endif
tail -f $momlog &
tail -f $proxylog &

