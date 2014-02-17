www
===

haproxy and apache tomcat configurations and start-stop cshell scripts.
alls apps. are meant to be run as user, not root, listening on non-root
tcp ports.

iptables is configure to accept port 80 redirected to 9080, and port 443\
redirected to 9443.

the haproxy https frontend config includes basic authentication and is
configured for ssl via a cacert-private key merged file. tomcat and nodej
backends are configured for http. 
