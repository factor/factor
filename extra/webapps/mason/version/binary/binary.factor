! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel make sequences webapps.mason.version.common
webapps.mason.version.files ;
IN: webapps.mason.version.binary

: binary-release-command ( version builder -- command )
    [
        "cp " %
        [ nip binary-package-name % " " % ]
        [ remote-binary-release-name % ]
        2bi
    ] "" make ;

: binary-release-script ( version builders -- string )
    [ binary-release-command ] with map "\n" join ;

: do-binary-release ( version builders -- )
    "Copying binary releases to release directory..." print flush
    binary-release-script execute-on-server ;
