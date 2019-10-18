! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel make mason.config mason.platform
mason.release.archive namespaces sequences ;
IN: mason.version.files

: release-directory ( string version -- string )
    [ "releases/" % % "/" % % ] "" make ;

: remote-directory ( string -- string' )
    [ upload-directory get ] dip "/" glue ;

: remote ( string version -- string )
    remote-directory swap "/" glue ;

: platform ( builder -- string )
    [ os>> ] [ cpu>> ] bi (platform) ;

: binary-package-name ( builder -- string )
    [ [ platform % "/" % ] [ last-release>> % ] bi ] "" make
    remote-directory ;

: binary-release-name ( version builder -- string )
    [
        [
            [ "factor-" % platform % "-" % % ]
            [ os>> extension % ]
            bi
        ] "" make
    ] [ drop ] 2bi release-directory ;

: remote-binary-release-name ( version builder -- string )
    [ binary-release-name ] [ drop ] 2bi remote ;

: source-release-name ( version -- string )
    [ "factor-src-" ".zip" surround ] keep release-directory ;

: remote-source-release-name ( version -- string )
    [ source-release-name ] keep remote ;
