#!/bin/csh -f
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
if ( ! -e nodejs ) then
  echo need nodejs directory -- presumably containing latest versions of cesium, cloud9,and etherpad
  exit
endif
set cwd = `pwd`
echo "------------------------ $cwd -----------------------------"
#
unsetenv NODE_PATH
setenv NODE_PATH /usr/local/lib/node_modules':'$cwd/epad/src/node_modules':'$cwd/cesium/node_modules':'$cwd/cloud9/node_modules
echo "NODE_PATH == $NODE_PATH"
set epadapp = $cwd/nodejs/epad/bin/run.sh
set epadlog = $cwd/log/epad.log
#
set cesiumapp = $cwd/nodejs/cesium/Apps/server.js
set cesiumlog = $cwd/log/cesium.log
#
set cloud9app = "$cwd/nodejs/cloud9/bin/cloud9.sh -w $cwd/sandbox"
set cloud9log = $cwd/log/cloud9.log
#
set nideapp = "nide -b"
set nidelog = $cwd/log/nide.log
#
if ( ! -e $cwd/log ) \mkdir -p $cwd/log
#
set opt = stop
if ( $1 != "" ) set opt = "$1"
echo "------------------------ $opt -----------------------------"
pkill tail
#pgrep node
\ps -ef | grep 'node /' | grep -v grep
if ( $? == 0 ) then
  echo shut down any/all current nodejs runtime 
  pkill node
endif
#
if ( "$opt" == "stop" ) then
  echo PRESERVING all logs 
  exit
endif
if ( "$opt" == "start" ) then
  echo REMOVING all logs 
  rm -f $epadlog >& /dev/null 
  rm -f $cloud9log >& /dev/null 
  rm -f $cesiumlog >& /dev/null 
  set opt = restart
endif
echo "------------------------ $opt -----------------------------"
if ( "$opt" != "restart" ) then
  echo unsupported option -- did you mean '"nodejs.csh [stop] or [re]start"?'
  exit
endif
# ok [re]start all nodejs servers
echo starting all nodejs servers
touch $epadlog $cloud9log $cesiumlog
pushd nodejs
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
if ( -e $epadapp ) then
  rm -f $epadlog >& /dev/null ; touch $epadlog
  pushd $cwd/epad
  $epadapp >>& $epadlog &
# give node a sec. to startup
  popd
  sleep 1 ; tail -f $epadlog &
else
  echo no epad found -- $epadapp
endif
#if ( -e $cwd/sandbox ) then
# rm -f $nidelog >& /dev/null ; touch $nidelog
# pushd $cwd/sandbox
# nide -b >>& $nidelog &
# give node a sec. to startup
# popd
# sleep 1 ; tail -f $nidelog &
#else
# echo no nide
#endif
popd # back to www
