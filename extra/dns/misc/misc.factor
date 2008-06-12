
USING: kernel combinators sequences splitting math 
       io.files io.encodings.utf8 random newfx dns.util ;

IN: dns.misc

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: resolv-conf-servers ( -- seq )
  "/etc/resolv.conf" utf8 file-lines
  [ " " split ] map
  [ 1st "nameserver" = ] filter
  [ 2nd ] map ;

: resolv-conf-server ( -- ip ) resolv-conf-servers random ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cdr-name ( name -- name ) dup CHAR: . index 1+ tail ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: domain-has-name? ( domain name -- ? )
    {
      { [ 2dup =       ] [ 2drop t ] }
      { [ 2dup longer? ] [ 2drop f ] }
      { [ t            ] [ cdr-name domain-has-name? ] }
    }
  cond ;

: name-in-domain? ( name domain -- ? ) swap domain-has-name? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

