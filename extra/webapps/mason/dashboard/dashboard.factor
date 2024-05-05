! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators furnace.actions grouping.extras
html.forms kernel sequences sorting webapps.mason.backend
webapps.mason.utils xml.syntax ;
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

: machine-list ( builders -- xml )
    [ host-name>> ] sort-by [ host-name>> ] group-by
    [
        first2
        [ os/cpu ] sort-by
        [
            os/cpu
            [XML <li><-></li> XML]
        ] map
        [XML <li><-><ul><-></ul></li> XML]
    ] map
    [ [XML <p>No machines.</p> XML] ]
    [ [XML <ul><-></ul> XML] ]
    if-empty ;

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
            all-builders
            [ machine-list "machines" set-value ]
            [ builder-list "builders" set-value ] bi
        ] with-mason-db
    ] >>init ;
