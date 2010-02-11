! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions html.forms kernel
mason.platform mason.report sequences webapps.mason
webapps.mason.utils ;
IN: webapps.mason.release

: releases-url ( builder -- url )
    [ os>> ] [ cpu>> ] bi (platform)
    "http://downloads.factorcode.org/releases/" prepend ;

: release-link ( builder -- xml )
    [ releases-url ] [ last-release>> ] bi [ "/" glue ] keep link ;

: <download-release-action> ( -- action )
    <page-action>
    [
        validate-os/cpu
        "os" value "cpu" value (platform) "platform" set-value
        current-release
        [ release-link "release" set-value ]
        [ release-git-id>> git-link "git-id" set-value ]
        [ requirements "requirements" set-value ]
        tri
    ] >>init ;
