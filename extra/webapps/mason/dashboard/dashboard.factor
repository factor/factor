! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators furnace.actions
grouping.extras html.forms kernel mason.report math.order
sequences sorting sorting.specification webapps.mason.backend
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
    { { host-name>> <=> } { os>> <=> } { cpu>> <=> } } sort-with-spec
    [ host-name>> ] group-by
    [
        first2
        [
            [ os/cpu ] [ current-git-id>> git-link ] [ status>> ] tri
            [XML <tr><td><-></td><td><-></td><td><-></td></tr> XML]
        ] map
        [XML <li><-><table><-></table></li> XML]
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
