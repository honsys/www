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
set opt = "start" # or stop or restart
if ( "$1" != "" ) set opt = "$1"
#
pkill tail >& /dev/null
echo "------------------------- $opt -------------------------"
if ( "$opt" == "stop" ) then
  echo shutting down tomcat runtimes \(production and release candidate\) and PRESERVING all logs 
  env CATALINA_BASE=${CATALINA} ${CATALINA}/bin/shutdown.sh >& /dev/null
# env CATALINA_BASE=${RCCATALINA} ${RCCATALINA}/bin/shutdown.sh >& /dev/null
# pkill java
  exit
endif
if ( "$opt" != "start" && "$opt" != "restart" ) then
  echo unsupported option -- did you mean '"tomcat.csh [stop or [re]start]"?'
  exit
endif
if ( "$opt" == "start" ) then
  echo REMOVING all logs and start tomcat runtimes \(production and release candidate\)
  env CATALINA_BASE=${CATALINA} ${CATALINA}/bin/shutdown.sh >& /dev/null
  env CATALINA_BASE=${RCCATALINA} ${RCCATALINA}/bin/shutdown.sh >& /dev/null
  \mkdir -p ${CATALINA}/logs ${RCCATALINA}/logs >& /dev/null
  \rm -rf ${CATALINA}/logs/* ${RCCATALINA}/logs/* >& /dev/null
else # restart indicated ...
  echo restarting tomcat runtime and PRESERVING all logs 
endif
env CATALINA_BASE=${CATALINA} ${CATALINA}/bin/shutdown.sh >& /dev/null
env CATALINA_BASE=${RCCATALINA} ${RCCATALINA}/bin/shutdown.sh >& /dev/null
#pkill java
\mv ${CATALINA}/logs/catalina.out ${CATALINA}/logs/${jdat}catalina.out
env CATALINA_BASE=${CATALINA} ${CATALINA}/bin/startup.sh >& /dev/null
set started = `grep -n 'INFO: Server startup' $CATALINA/logs/catalina.out`
\mv ${RCCATALINA}/logs/catalina.out ${RCCATALINA}/logs/${jdat}catalina.out
env CATALINA_BASE=${RCCATALINA} ${RCCATALINA}/bin/startup.sh >& /dev/null
set rcstarted = `grep -n 'INFO: Server startup' $RCCATALINA/logs/catalina.out`
while ( "$started" == "" && "$rcstarted" == "" )
  echo ... sleeping until tomcat catalina log indicates successful startup ...
  sleep 5
  set started = `grep -n 'INFO: Server startup' $CATALINA/logs/catalina.out`
#  set rcstarted = `grep -n 'INFO: Server startup' $RCCATALINA/logs/catalina.out`
end
echo "$started and $rcstarted" 
echo ok tomcat catalina\(s\) up ... start haproxy ...

