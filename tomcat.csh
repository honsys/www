#!/bin/csh -f
# while much of the apache-tomcat/config content
# is portable, each host must have its own unige keystore file.
# generated via:
# $JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA -keystore ./.keystore
#
# also be sure to double-check these env items for properly set sym-links!
# and this version version is currently only runnable from the specific www directory
#
set cwd = `pwd` ; echo $cwd
set www = $cwd:t:r # ; echo $www ala $cwd
set opt = "start"
if ( $1 != "" ) set opt = "$1"
if ( "$www" != "www" ) then
  echo this should be a www directory name, not $cwd
  exit
endif
if ( -e env.csh ) then
  source env.csh "$2"
else
  echo need env.csh ...
  exit
endif
#
pkill tail >& /dev/null
echo '--------------------------------------------------'
if ( "$opt" == "stop" ) then
  echo shutting down tomcat runtime and PRESERVING all logs 
  $TOMCAT_HOME/bin/shutdown.sh
# pkill java
  exit
endif
if ( "$opt" == "start" ) then
  echo \(re\)start tomcat runtime and REMOVING all logs 
  $TOMCAT_HOME/bin/shutdown.sh >& /dev/null
  \mkdir -p $TOMCAT_HOME/logs >& /dev/null
  \rm -rf $TOMCAT_HOME/logs/*
endif
if ( "$opt" != "restart" ) then
  echo unsupported option -- did you mean '"www.csh [stop] or [re]start"?'
  exit
endif
# ok, assume restart
echo restarting tomcat runtime and PRESERVING all logs 
$TOMCAT_HOME/bin/shutdown.sh >& /dev/null
#pkill java
\mv $TOMCAT_HOME/logs/catalina.out $TOMCAT_HOME/logs/${jdat}catalina.out
$TOMCAT_HOME/bin/startup.sh >& /dev/null
set started = `grep -n 'INFO: Server startup' $TOMCAT_HOME/logs/catalina.out`
while ( "$started" == "" )
  echo ... sleeping until tomcat catalina log indicates successful startup ...
  sleep 5
  set started = `grep -n 'INFO: Server startup' $TOMCAT_HOME/logs/catalina.out`
end
echo "$started"
echo ok tomcat catalina is up ... start haproxy ...

