! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel mason.server furnace.actions
html.forms sequences xml.syntax webapps.mason.utils ;
IN: webapps.mason.downloads

: builder-list ( seq -- xml )
    [
        [ package-url ] [ [ os>> ] [ cpu>> ] bi "/" glue ] bi
        [XML <li><a href=<->><-></a></li> XML]
    ] map
    [ [XML <p>No machines.</p> XML] ]
    [ [XML <ul><-></ul> XML] ]
    if-empty ;

: <dashboard-action> ( -- action )
    <page-action>
    [
        [
            funny-builders
            [ builder-list ] tri@
            [ "crashed" set-value ]
            [ "broken" set-value ]
            [ "limbo" set-value ] tri*
        ] with-mason-db
    ] >>init ;
