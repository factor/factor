! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions html.forms
http.server.responses mason.server mason.server.release
validators ;
IN: webapps.mason.make-release

: <make-release-action> ( -- action )
    <page-action>
    [ { { "version" [ v-one-line ] } } validate-params ] >>validate
    [
        [
            "version" value do-release
            "OK" "text/html" <content>
        ] with-mason-db
    ] >>submit ;
