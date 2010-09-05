! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel mason.server furnace.actions
html.forms sequences xml.syntax webapps.mason.utils ;
IN: webapps.mason.downloads

: crashed-builder-list ( -- xml )
    crashed-builders [
        [ package-url ] [ [ os>> ] [ cpu>> ] bi "/" glue ] bi
        [XML <li><a href=<->><-></a></li> XML]
    ] map
    [XML <ul><-></ul> XML] ;

: <dashboard-action> ( -- action )
    <page-action>
    [
        [
            crashed-builder-list "crashed" set-value
        ] with-mason-db
    ] >>init ;
