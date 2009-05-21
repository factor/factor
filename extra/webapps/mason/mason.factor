! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators db db.tuples furnace.actions
http.server.responses http.server.dispatchers kernel mason.platform
mason.notify.server mason.report math.order sequences sorting
splitting xml.syntax xml.writer io.pathnames io.encodings.utf8
io.files present validators html.forms furnace.db assocs urls ;
IN: webapps.mason

TUPLE: mason-app < dispatcher ;

: validate-os/cpu ( -- )
    {
        { "os" [ v-one-line ] }
        { "cpu" [ v-one-line ] }
    } validate-params ;

: current-builder ( -- builder )
    builder new "os" value >>os "cpu" value >>cpu select-tuple ;

: <build-report-action> ( -- action )
    <action>
    [ validate-os/cpu ] >>init
    [ current-builder last-report>> "text/html" <content> ] >>display ;

: log-file ( -- path ) home "mason.log" append-path ;

: recent-events ( -- xml )
    log-file utf8 10 file-tail [XML <pre><-></pre> XML] ;

: git-link ( id -- link )
    [ "http://github.com/slavapestov/factor/commit/" prepend ] keep
    [XML <a href=<->><-></a> XML] ;

: building ( builder string -- xml )
    swap current-git-id>> git-link
    [XML <-> for <-> XML] ;

: current-status ( builder -- xml )
    [
        dup status>> {
            { +dirty+ [ drop "Dirty" ] }
            { +clean+ [ drop "Clean" ] }
            { +error+ [ drop "Error" ] }
            { +starting+ [ "Starting build" building ] }
            { +make-vm+ [ "Compiling VM" building ] }
            { +boot+ [ "Bootstrapping" building ] }
            { +test+ [ "Testing" building ] }
            [ 2drop "Unknown" ]
        } case
    ] [ current-timestamp>> present " (as of " ")" surround ] bi 2array ;

: build-status ( git-id timestamp -- xml )
    over [ [ git-link ] [ present ] bi* " (built on " ")" surround 2array ] [ 2drop f ] if ;

: binaries-url ( builder -- url )
    [ os>> ] [ cpu>> ] bi (platform) "http://downloads.factorcode.org/" prepend ;

: url-link ( url -- xml )
    dup [XML <a href=<->><-></a> XML] ;

: latest-binary-link ( builder -- xml )
    [ URL" download" ] dip
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    [XML <a href=<->>Latest download</a> XML] ;

: binaries-link ( builder -- link )
    binaries-url url-link ;

: clean-image-url ( builder -- url )
    [ os>> ] [ cpu>> ] bi (platform) "http://factorcode.org/images/clean/" prepend ;

: clean-image-link ( builder -- link )
    clean-image-url url-link ;

: report-link ( builder -- xml )
    [ URL" report" ] dip
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    [XML <a href=<->>Latest build report</a> XML] ;

: machine-table ( builder -- xml )
    {
        [ os>> ]
        [ cpu>> ]
        [ host-name>> "." split1 drop ]
        [ current-status ]
        [ [ last-git-id>> ] [ last-timestamp>> ] bi build-status ]
        [ [ clean-git-id>> ] [ clean-timestamp>> ] bi build-status ]
        [ binaries-link ]
        [ clean-image-link ]
        [ report-link ]
        [ latest-binary-link ]
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

    <-> | <->
    XML] ;

: machine-report ( -- xml )
    builder new select-tuples
    [ [ [ os>> ] [ cpu>> ] bi 2array ] compare ] sort
    [ machine-table ] map ;

: build-farm-summary ( -- xml )
    recent-events
    machine-report
    [XML
    <html>
    <head><title>Factor build farm</title></head>
    <body><h1>Recent events</h1><-> <h1>Machine status</h1><-></body>
    </html>
    XML] ;

: <summary-action> ( -- action )
    <action>
    [ build-farm-summary xml>string "text/html" <content> ] >>display ;

TUPLE: builder-link href title ;

C: <builder-link> builder-link

: requirements ( builder -- xml )
    [
        os>> {
            { "winnt" "Windows XP (also tested on Vista)" }
            { "macosx" "Mac OS X 10.5 Leopard" }
            { "linux" "Linux 2.6.16 with GLIBC 2.4" }
            { "freebsd" "FreeBSD 7.0" }
            { "netbsd" "NetBSD 4.0" }
            { "openbsd" "OpenBSD 4.2" }
        } at
    ] [
        dup cpu>> "x86-32" = [
            os>> {
                { [ dup { "winnt" "linux" } member? ] [ drop "Intel Pentium 4, Core Duo, or other x86 chip with SSE2 support. Note that 32-bit Athlon XP processors do not support SSE2." ] }
                { [ dup { "freebsd" "netbsd" "openbsd" } member? ] [ drop "Intel Pentium Pro or better" ] }
                { [ t ] [ drop f ] }
            } cond
        ] [ drop f ] if
    ] bi
    2array sift [ [XML <li><-></li> XML] ] map [XML <ul><-></ul> XML] ;

: <download-binary-action> ( -- action )
    <page-action>
    [
        validate-os/cpu
        "os" value "cpu" value (platform) "platform" set-value
        current-builder
        [ latest-binary-link "package" set-value ]
        [ release-git-id>> git-link "git-id" set-value ]
        [ requirements "requirements" set-value ]
        tri
    ] >>init
    { mason-app "download" } >>template ;

: <mason-app> ( -- dispatcher )
    mason-app new-dispatcher
    <summary-action> "" add-responder
    <build-report-action> "report" add-responder
    <download-binary-action> "download" add-responder
    mason-db <db-persistence> ;

