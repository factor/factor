! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators db db.tuples furnace.actions
http.server.responses kernel mason.platform mason.notify.server
math.order sequences sorting splitting xml.syntax xml.writer
io.pathnames io.encodings.utf8 io.files ;
IN: webapps.mason

: log-file ( -- path ) home "mason.log" append-path ;

: recent-events ( -- xml )
    log-file utf8 file-lines 10 short tail* "\n" join [XML <pre><-></pre> XML] ;

: git-link ( id -- link )
    [ "http://github.com/slavapestov/factor/commit/" prepend ] keep
    [XML <a href=<->><-></a> XML] ;

: building ( builder string -- xml )
    swap current-git-id>> git-link
    [XML <-> for <-> XML] ;

: current-status ( builder -- xml )
    dup status>> {
        { "dirty" [ drop "Dirty" ] }
        { "clean" [ drop "Clean" ] }
        { "starting" [ "Starting" building ] }
        { "make-vm" [ "Compiling VM" building ] }
        { "boot" [ "Bootstrapping" building ] }
        { "test" [ "Testing" building ] }
        [ 2drop "Unknown" ]
    } case ;

: binaries-link ( builder -- link )
    [ os>> ] [ cpu>> ] bi (platform) "http://downloads.factorcode.org/" prepend
    dup [XML <a href=<->><-></a> XML] ;

: clean-image-link ( builder -- link )
    [ os>> ] [ cpu>> ] bi (platform) "http://factorcode.org/images/clean/" prepend
    dup [XML <a href=<->><-></a> XML] ;

: machine-table ( builder -- xml )
    {
        [ os>> ]
        [ cpu>> ]
        [ host-name>> "." split1 drop ]
        [ current-status ]
        [ last-git-id>> dup [ git-link ] when ]
        [ clean-git-id>> dup [ git-link ] when ]
        [ binaries-link ]
        [ clean-image-link ]
    } cleave
    [XML
    <h2><-> / <-></h2>
    <table border="1">
    <tr><td>Host name:</td><td><-></td></tr>
    <tr><td>Current status:</td><td><-></td></tr>
    <tr><td>Last build:</td><td><-></td></tr>
    <tr><td>Last clean build:</td><td><-></td></tr>
    <tr><td>Binaries:</td><td><-></td></tr>
    <tr><td>Clean images:</td><td><-></td></tr>
    </table>
    XML] ;

: machine-report ( -- xml )
    builder new select-tuples
    [ [ [ os>> ] [ cpu>> ] bi 2array ] compare ] sort
    [ machine-table ] map ;

: build-farm-report ( -- xml )
    recent-events
    machine-report
    [XML
    <html>
    <head><title>Factor build farm</title></head>
    <body><h1>Recent events</h1><-> <h1>Machine status</h1><-></body>
    </html>
    XML] ;

: <build-farm-report-action> ( -- action )
    <action>
        [
            mason-db [ build-farm-report xml>string ] with-db
            "text/html" <content>
        ] >>display ;