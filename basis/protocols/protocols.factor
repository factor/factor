! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel sequences ;
IN: protocols

: lookup-protocol ( string -- entry )
    {
        { "ftp"      [ { 21 f { "tcp" } } ] }
        { "git+ssh"  [ { 22 t { "tcp" } } ] }
        { "ssh"      [ { 22 t { "tcp" } } ] }
        { "telnet"   [ { 23 f { "tcp" } } ] }
        { "smtp"     [ { 25 f { "tcp" } } ] }
        { "dns"      [ { 53 f { "tcp" "udp" } } ] }
        { "gopher"   [ { 70 f { "tcp" } } ] }
        { "http"     [ { 80 f { "tcp" } } ] }
        { "www"      [ { 80 f { "tcp" } } ] }
        { "www-http" [ { 80 f { "tcp" } } ] }
        { "ws"       [ { 80 f { "tcp" } } ] }
        { "grpc"     [ { 80 f { "tcp" } } ] }
        { "pop3"     [ { 110 f { "tcp" } } ] }
        { "ntp"      [ { 123 f { "udp" } } ] }
        { "imap"     [ { 143 f { "tcp" } } ] }
        { "ldap"     [ { 389 f { "tcp" } } ] }
        { "https"    [ { 443 t { "tcp" } } ] }
        { "wss"      [ { 443 t { "tcp" } } ] }
        { "grpcs"    [ { 443 t { "tcp" } } ] }
        { "rtmps"    [ { 443 t { "tcp" } } ] }
        { "smtps"    [ { 465 t { "tcp" } } ] }
        { "ldaps"    [ { 636 t { "tcp" } } ] }
        { "ftps"     [ { 989 t { "tcp" } } ] }
        { "imaps"    [ { 993 t { "tcp" } } ] }
        { "pop3s"    [ { 995 t { "tcp" } } ] }
        { "mqtt"     [ { 1883 f { "tcp" } } ] }
        { "rtmp"     [ { 1935 f { "tcp" } } ] }
        { "sip"      [ { 5060 f { "udp" "tcp" } } ] }
        { "sips"     [ { 5061 t { "tcp" } } ] }
        { "xmpp"     [ { 5222 f { "tcp" } } ] }
        { "xmpps"    [ { 5223 t { "tcp" } } ] }
        { "irc"      [ { 6667 f { "tcp" } } ] }
        { "ircs"     [ { 6697 t { "tcp" } } ] }
        { "matrix"   [ { 8448 t { "tcp" } } ] }
        { "mqtts"    [ { 8883 t { "tcp" } } ] }
        { "git"      [ { 9418 f { "tcp" } } ] }
        [ drop { f f } ]
    } case ;

: lookup-protocol-port ( string -- port ) lookup-protocol first ;
: lookup-protocol-secure ( string -- ? ) lookup-protocol second ;
: lookup-protocol-protos ( string -- port ) lookup-protocol third ;
