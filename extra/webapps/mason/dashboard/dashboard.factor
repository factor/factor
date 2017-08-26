! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel furnace.actions html.forms
sequences sorting xml.syntax webapps.mason.backend
webapps.mason.utils ;
IN: webapps.mason.downloads

CONSTANT: CRASHED
XML-CHUNK[[ <span style="background-color: yellow;">CRASHED</span> ]]

CONSTANT: BROKEN
XML-CHUNK[[ <span style="background-color: red; color: white;">BROKEN</span> ]]

: builder-status ( builder -- status/f )
    {
        { [ dup crashed? ] [ drop CRASHED ] }
        { [ dup broken? ] [ drop BROKEN ] }
        [ drop f ]
    } cond ;

: builder-list ( seq -- xml )
    [ os/cpu ] sort-with
    [
        [ report-url ] [ os/cpu ] [ builder-status ] tri
        XML-CHUNK[[ <li><a href=<->><-></a> <-></li> ]]
    ] map
    [ XML-CHUNK[[ <p>No machines.</p> ]] ]
    [ XML-CHUNK[[ <ul><-></ul> ]] ]
    if-empty ;

: <dashboard-action> ( -- action )
    <page-action>
    [
        [
            all-builders builder-list
            "builders" set-value
        ] with-mason-db
    ] >>init ;
