! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors dns resolv-conf system ;
IN: dns.unix

M: unix initial-dns-servers
    default-resolv.conf nameserver>> ;
