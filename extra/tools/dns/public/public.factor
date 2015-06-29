! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.dns ;
IN: tools.dns.public

CONSTANT: google-dns-servers { "8.8.8.8" "8.8.4.4" }
: google-host ( domain -- ) [ google-dns-servers ] dip dns-host ;

CONSTANT: dnsvantage-dns-servers {
    "156.154.70.1"
    "156.154.71.1"
}
: dnsvantage-host ( domain -- ) [ dnsvantage-dns-servers ] dip dns-host ;


CONSTANT: opendns-dns-servers { "208.67.222.222" "208.67.220.220" }
: opendns-host ( domain -- ) [ opendns-dns-servers ] dip dns-host ;

CONSTANT: norton-dns-servers { "198.153.192.1" "198.153.194.1" }
: norton-host ( domain -- ) [ norton-dns-servers ] dip dns-host ;

CONSTANT: verizon-dns-servers {
    "4.2.2.1"
    "4.2.2.2"
    "4.2.2.3"
    "4.2.2.4"
    "4.2.2.5"
    "4.2.2.6"
}
: verizon-host ( domain -- ) [ verizon-dns-servers ] dip dns-host ;
