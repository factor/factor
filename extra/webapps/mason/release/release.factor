! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions html.forms io.pathnames kernel
mason.platform mason.report sequences webapps.mason
webapps.mason.backend webapps.mason.utils ;
IN: webapps.mason.release

: release-link ( builder -- xml )
    last-release>> [ download-url ] [ file-name ] bi link ;

: <download-release-action> ( -- action )
    <page-action>
    [
        [
            validate-os/cpu
            "os" value "cpu" value (platform) "platform" set-value
            current-release [
                [ release-link "release" set-value ]
                [ release-git-id>> git-link "git-id" set-value ]
                [ requirements "requirements" set-value ]
                tri
            ] when*
        ] with-mason-db
    ] >>init ;
