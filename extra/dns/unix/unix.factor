! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs dns io.encodings.utf8 io.files kernel
math.statistics sequences splitting system unicode.categories ;
IN: dns.unix

: load-resolve.conf ( -- seq )
    "/etc/resolv.conf" utf8 file-lines
    [ [ blank? ] trim ] map
    [ "#" head? not ] filter
    [ [ " " split1 swap ] dip push-at ] sequence>hashtable "nameserver" swap at ;

M: unix initial-dns-servers load-resolve.conf ;