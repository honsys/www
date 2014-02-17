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
  source env.csh
else
  echo need env.csh ...
  exit
endif
#
echo $cwd
setenv NODE_PATH ${NODE_PATH}':'$cwd/epad/src/node_modules':'$cwd/cesium/node_modules':'$cwd/cloud9/node_modules
echo "NODE_PATH == $NODE_PATH"
set epadapp = $cwd/epad/bin/run.sh
set epadlog = $cwd/log/epad.log
#
set cesiumapp = $cwd/cesium/Apps/server.js
set cesiumlog = $cwd/log/cesium.log
#
set cloud9app = "$cwd/cloud9/bin/cloud9.sh -w $cwd/sandbox"
set cloud9log = $cwd/log/cloud9.log
#
#set nideapp = "nide -b"
#set nidelog = $cwd/log/nide.log
echo '--------------------------------------------------'
set opt = envshow
if ( $1 != "" ) set opt = "$1"
#
if ( "$opt" == "envshow" ) exit
#
pkill tail >& /dev/null
if ( "$opt" == "stop" ) then
  echo shutting down any current haproxy, nodejs, and tomcat runtime and PRESERVING all logs 
  echo '--------------------------------------------------'
  $TOMCAT_HOME/bin/shutdown.sh
  pkill node
  exit
endif
if ( "$opt" == "restart" ) then
  echo shutting down current nodejs runtime and restarting (but not haproxy) and PRESERVING all logs 
  echo '--------------------------------------------------'
  pkill node ; touch $epadlog
  if ( -e $epadapp ) then
    pushd $cwd/epad
    $epadapp >>& $epadlog &
    popd
  endif
#  if ( -e $cwd/sandbox ) then
#    pushd $cwd/sandbox
#    nide -b >>& $nidelog &
#    popd
#  endif
  if ( -e $cwd/cloud9 ) then
    pushd $cwd/cloud9
    $cloud9app >>& $cloud9log &
    popd
  exit
  endif
  if ( -e $cwd/cesium ) then
    pushd $cwd/cesium
    $cesiumapp >>& $cesiumlog &
    popd
  exit
  endif
endif
if ( "$opt" != "start" ) then
  echo unsupported option -- did you mean '"www.csh [stop] or [re]start"?'
  exit
endif
# ok, assume start
echo shutting down any current nodejs, runtimes, REMOVING logs, and starting all nodejs servers
echo '--------------------------------------------------'
pkill node ; rm -f $epadlog $nidelog >& /dev/null ; touch $epadlog $nidelog
if ( -e $cwd/cesium ) then
  pushd $cwd/cesium
  $cesiumapp >>& $cesiumlog &
  popd
  sleep 1 ; tail -f $cesiumlog &
else
  echo no cesium
endif
if ( -e $cwd/cloud9 ) then
  pushd $cwd/cloud9
  $cloud9app >>& $cloud9log &
# give node a sec. to startup
  popd
  sleep 1 ; tail -f $cloud9log &
else
  echo no cloud9
endif
#if ( -e $cwd/sandbox ) then
#  pushd $cwd/sandbox
#  nide -b >>& $nidelog &
# give node a sec. to startup
#  popd
#  sleep 1 ; tail -f $nidelog &
#else
#  echo no nide
#endif
if ( -e $epadapp ) then
  pushd $cwd/epad
  $epadapp >>& $epadlog &
# give node a sec. to startup
  popd
  sleep 1
  tail -f $epadlog &
else
  echo no epad found -- $epadapp
endif
echo "$started"
