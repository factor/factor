
USING: kernel sequences splitting io.files io.encodings.utf8 random newfx ;

IN: dns.misc

: resolv-conf-servers ( -- seq )
  "/etc/resolv.conf" utf8 file-lines
  [ " " split ] map
  [ 1st "nameserver" = ] filter
  [ 2nd ] map ;

: resolv-conf-server ( -- ip ) resolv-conf-servers random ;