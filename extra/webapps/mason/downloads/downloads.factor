! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions html.components html.forms
kernel webapps.mason.backend webapps.mason.version.data
webapps.mason.grids webapps.mason.utils ;
IN: webapps.mason.downloads

: stable-release ( version -- link )
    [ version>> ] [ announcement-url>> ] bi <simple-link> ;

: source-release ( version -- link )
    [ version>> ] [ source-path>> download-url ] bi <simple-link> ;

: <downloads-action> ( -- action )
    <page-action>
    [
        [
            package-grid "package-grid" set-value
            release-grid "release-grid" set-value

            latest-version
            [ stable-release "stable-release" set-value ]
            [ source-release "source-release" set-value ] bi
        ] with-mason-db
    ] >>init ;
