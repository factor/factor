! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions html.forms
http.server.responses validators webapps.mason.backend
webapps.mason.version ;
IN: webapps.mason.make-release

: <make-release-action> ( -- action )
    <action>
    [
        {
            { "version" [ v-one-line ] }
            { "announcement-url" [ v-url ] }
        } validate-params
    ] >>validate
    [
        [
            "version" value "announcement-url" value do-release
            "OK" <text-content>
        ] with-mason-db
    ] >>submit ;
