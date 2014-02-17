www
===

Haproxy and apache tomcat configurations with start-stop cshell scripts.

All servers are meant to be run as user, listening on non-root TCP ports.

iptables is configure to accepts port 80 and port 443. Port 80 is redirected
to 9080, while port 443 is redirected to 9443 (see iptables-save.txt).

The haproxy https frontend config includes basic authentication and is
configured for ssl via a cacert-private key merged file. tomcat and nodej
backends are configured for http. 
