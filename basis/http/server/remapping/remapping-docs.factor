USING: help.markup help.syntax ;
IN: http.server.remapping

HELP: port-remapping
{ $var-description "An assoc mapping port numbers that the HTTP server listens on to external port numbers presented to the user." } ;

ARTICLE: "http.server.remapping" "HTTP server port remapping"
"On Unix systems, non-root processes cannot bind to sockets on port numbers under 1024. Since running an HTTP server as root is a potential security risk, a typical setup runs an HTTP server under an ordinary user account, set up to listen on a higher port number such as 8080. Then, the HTTP port is redirected to 8080. On Linux, this might be done using commands such as the following:"
{ $code
    "echo 1 > /proc/sys/net/ipv4/ip_forward"
    "iptables -t nat -F"
    "iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j DNAT --to :8443"
    "iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j DNAT --to :8080"
}
"However, the HTTP server is unaware of the forwarding, and still believes that it is listening on port 8080 and 8443, respectively. This can be a problem if a responder wishes to redirect the user to a secure page; they will be sent to port 8443 and not 443 as one would expect."
$nl
"The " { $vocab-link "http.server.remapping" } " vocabulary defines a variable which may store an assoc of port mappings:"
{ $subsections port-remapping }
"For example, with the above setup, we would set it as follows:"
{ $code
    "{ { 8080 80 } { 8443 443 } } port-remapping set-global"
} ;

ABOUT: "http.server.remapping"
