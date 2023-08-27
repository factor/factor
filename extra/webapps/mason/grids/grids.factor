! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs db.tuples furnace.actions
furnace.utilities http.server.responses kernel sequences
splitting urls xml.syntax xml.writer webapps.mason.backend
webapps.mason.version.data webapps.mason.utils ;
IN: webapps.mason.grids

: render-grid-cell ( cpu os quot -- xml )
    call( cpu os -- url label )
    2dup and
    [ link [XML <td class="supported"><-></td> XML] ]
    [ 2drop [XML <td class="doesnotexist" /> XML] ]
    if ;

CONSTANT: oses
{
    { "windows" "Windows" }
    { "macosx" "Mac OS" }
    { "linux" "Linux" }
}

CONSTANT: cpus
{
    { "x86.32" "x86" }
    { "x86.64" "x86-64" }
}

: render-grid-header ( -- xml )
    oses values [ [XML <th scope="col"><-></th> XML] ] map ;

:: render-grid-row ( cpu quot -- xml )
    cpu second oses keys [| os | cpu os quot render-grid-cell ] map
    [XML <tr><th scope="row"><-></th><-></tr> XML] ;

:: render-grid ( quot -- xml )
    render-grid-header
    cpus [ quot render-grid-row ] map
    [XML
        <table class="downloads" cellspacing="0">
            <colgroup>
            <col style="width: 25%" />
            <col style="width: 25%" />
            <col style="width: 25%" />
            <col style="width: 25%" />
            </colgroup>
            <thead>
            <tr><th class="nobg">OS/CPU</th><-></tr>
            </thead>
            <tbody>
            <->
            </tbody>
        </table>
    XML] ;

: package-date ( filename -- date )
    "." split1 drop 16 tail* 6 head* ;

: package-grid-cell ( cpu os -- url label )
    builder new swap >>os swap >>cpu select-tuple [
        [ package-url ]
        [ last-release>> [ package-date ] [ "N/A" ] if* ] bi
    ] [ f f ] if* ;

: package-grid ( -- xml )
    [ package-grid-cell ] render-grid ;

: <package-grid-action> ( -- action )
    <action>
    [
        [
            package-grid xml>string
            <html-content>
        ] with-mason-db
    ] >>display ;

: release-version ( filename -- release )
    ".tar.gz" ?tail drop ".zip" ?tail drop ".dmg" ?tail drop
    "-" split1-last nip ;

: release-grid-cell ( cpu os -- url label )
    release new swap >>os swap >>cpu select-tuple [
        [ release-url ]
        [ last-release>> [ release-version ] [ "N/A" ] if* ] bi
    ] [ f f ] if* ;

: release-grid ( -- xml )
    [ release-grid-cell ] render-grid ;

: <release-grid-action> ( -- action )
    <action>
    [
        [
            release-grid xml>string
            <html-content>
        ] with-mason-db
    ] >>display ;
