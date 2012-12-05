! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel furnace.actions html.forms sequences
xml.syntax webapps.mason.backend webapps.mason.utils ;
IN: webapps.mason.downloads

: builder-list ( seq -- xml )
    [
        [ report-url ] [ os/cpu ] bi
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
            [ builder-list ] bi@
            [ "crashed" set-value ]
            [ "broken" set-value ] bi*
        ] with-mason-db
    ] >>init ;
