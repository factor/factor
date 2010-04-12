! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions html.forms kernel
mason.platform mason.report mason.server sequences webapps.mason
webapps.mason.utils io.pathnames ;
IN: webapps.mason.release

: release-link ( builder -- xml )
    last-release>> [ download-url ] [ file-name ] bi link ;

: <download-release-action> ( -- action )
    <page-action>
    [
        [
            validate-os/cpu
            "os" value "cpu" value (platform) "platform" set-value
            current-release
            [ release-link "release" set-value ]
            [ release-git-id>> git-link "git-id" set-value ]
            [ requirements "requirements" set-value ]
            tri
        ] with-mason-db
    ] >>init ;
