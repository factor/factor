! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel furnace.actions html.forms
sequences sorting xml.syntax webapps.mason.backend
webapps.mason.utils ;
IN: webapps.mason.downloads

CONSTANT: OFFLINE
[XML <span style="background-color: khaki;">OFFLINE</span> XML]

CONSTANT: BROKEN
[XML <span style="background-color: red; color: white;">BROKEN</span> XML]

: builder-status ( builder -- status/f )
    {
        { [ dup offline? ] [ drop OFFLINE ] }
        { [ dup broken? ] [ drop BROKEN ] }
        [ drop f ]
    } cond ;

: builder-list ( seq -- xml )
    [ os/cpu ] sort-by
    [
        [ report-url ] [ os/cpu ] [ builder-status ] tri
        [XML <li><a href=<->><-></a> <-></li> XML]
    ] map
    [ [XML <p>No machines.</p> XML] ]
    [ [XML <ul><-></ul> XML] ]
    if-empty ;

: <dashboard-action> ( -- action )
    <page-action>
    [
        [
            all-builders builder-list
            "builders" set-value
        ] with-mason-db
    ] >>init ;
