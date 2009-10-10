! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators db db.tuples furnace.actions
http.server.responses http.server.dispatchers kernel mason.platform
mason.notify.server mason.report math.order sequences sorting
splitting xml.syntax xml.writer io.pathnames io.encodings.utf8
io.files present validators html.forms furnace.db urls ;
FROM: assocs => at keys values ;
IN: webapps.mason

TUPLE: mason-app < dispatcher ;

: link ( url label -- xml )
    [XML <a href=<->><-></a> XML] ;

: download-link ( builder label -- xml )
    [
        [ URL" http://builds.factorcode.org/download" ] dip
        [ os>> "os" set-query-param ]
        [ cpu>> "cpu" set-query-param ] bi
    ] dip link ;

: download-grid-cell ( cpu os -- xml )
    builder new swap >>os swap >>cpu select-tuple [
        dup last-release>> dup
        [ "." split1 drop 16 tail* 6 head* download-link ] [ 2drop f ] if
        [XML <td class="supported"><div class="bigdiv"><-></div></td> XML]
    ] [
        [XML <td class="doesnotexist" /> XML]
    ] if* ;

CONSTANT: oses
{
    { "winnt" "Windows" }
    { "macosx" "Mac OS X" }
    { "linux" "Linux" }
    { "freebsd" "FreeBSD" }
    { "netbsd" "NetBSD" }
    { "openbsd" "OpenBSD" }
}

CONSTANT: cpus
{
    { "x86.32" "x86" }
    { "x86.64" "x86-64" }
    { "ppc" "PowerPC" }
}

: download-grid ( -- xml )
    oses
    [ values [ [XML <th align='center' scope='col'><-></th> XML] ] map ]
    [
        keys
        cpus [
            [ nip second ] [ first ] 2bi [
                swap download-grid-cell
            ] curry map
            [XML <tr><th align='center' scope='row'><-></th><-></tr> XML]
        ] with map
    ] bi
    [XML
        <table id="downloads" cellspacing="0">
            <tr><th class="nobg">OS/CPU</th><-></tr>
            <->
        </table>
    XML] ;

: <download-grid-action> ( -- action )
    <action>
    [ download-grid xml>string "text/html" <content> ] >>display ;

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

: git-link ( id -- link )
    [ "http://github.com/slavapestov/factor/commit/" prepend ] keep
    [XML <a href=<->><-></a> XML] ;

: building ( builder string -- xml )
    swap current-git-id>> git-link
    [XML <-> for <-> XML] ;

: status-string ( builder -- string )
    dup status>> {
        { +dirty+ [ drop "Dirty" ] }
        { +clean+ [ drop "Clean" ] }
        { +error+ [ drop "Error" ] }
        { +starting+ [ "Starting build" building ] }
        { +make-vm+ [ "Compiling VM" building ] }
        { +boot+ [ "Bootstrapping" building ] }
        { +test+ [ "Testing" building ] }
        [ 2drop "Unknown" ]
    } case ;

: current-status ( builder -- xml )
    [ status-string ]
    [ current-timestamp>> present " (as of " ")" surround ] bi
    2array ;

: build-status ( git-id timestamp -- xml )
    over [ [ git-link ] [ present ] bi* " (built on " ")" surround 2array ] [ 2drop f ] if ;

: binaries-url ( builder -- url )
    [ os>> ] [ cpu>> ] bi (platform) "http://downloads.factorcode.org/" prepend ;

: latest-binary-link ( builder -- xml )
    [ binaries-url ] [ last-release>> ] bi [ "/" glue ] keep link ;

: binaries-link ( builder -- link )
    binaries-url dup link ;

: clean-image-url ( builder -- url )
    [ os>> ] [ cpu>> ] bi (platform) "http://factorcode.org/images/clean/" prepend ;

: clean-image-link ( builder -- link )
    clean-image-url dup link ;

: report-link ( builder -- xml )
    [ URL" report" ] dip
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    [XML <a href=<->>Latest build report</a> XML] ;

: requirements ( builder -- xml )
    [
        os>> {
            { "winnt" "Windows XP, Windows Vista or Windows 7" }
            { "macosx" "Mac OS X 10.5 Leopard" }
            { "linux" "Ubuntu Linux 9.04 (other distributions may also work)" }
            { "freebsd" "FreeBSD 7.1" }
            { "netbsd" "NetBSD 5.0" }
            { "openbsd" "OpenBSD 4.4" }
        } at
    ] [
        dup cpu>> "x86.32" = [
            os>> {
                { [ dup { "winnt" "linux" "freebsd"  "netbsd" } member? ] [ drop "Intel Pentium 4, Core Duo, or other x86 chip with SSE2 support. Note that 32-bit Athlon XP processors do not support SSE2." ] }
                { [ dup { "openbsd" } member? ] [ drop "Intel Pentium Pro or better" ] }
                { [ t ] [ drop f ] }
            } cond
        ] [ drop f ] if
    ] bi
    2array sift [ [XML <li><-></li> XML] ] map [XML <ul><-></ul> XML] ;

: last-build-status ( builder -- xml )
    [ last-git-id>> ] [ last-timestamp>> ] bi build-status ;

: clean-build-status ( builder -- xml )
    [ clean-git-id>> ] [ clean-timestamp>> ] bi build-status ;

: <download-binary-action> ( -- action )
    <page-action>
    [
        validate-os/cpu
        "os" value "cpu" value (platform) "platform" set-value
        current-builder {
            [ latest-binary-link "package" set-value ]
            [ release-git-id>> git-link "git-id" set-value ]
            [ requirements "requirements" set-value ]
            [ host-name>> "host-name" set-value ]
            [ current-status "status" set-value ]
            [ last-build-status "last-build" set-value ]
            [ clean-build-status "last-clean-build" set-value ]
            [ binaries-link "binaries" set-value ]
            [ clean-image-link "clean-images" set-value ]
            [ report-link "last-report" set-value ]
        } cleave
    ] >>init
    { mason-app "download" } >>template ;

: <mason-app> ( -- dispatcher )
    mason-app new-dispatcher
    <build-report-action> "report" add-responder
    <download-binary-action> "download" add-responder
    <download-grid-action> "grid" add-responder
    mason-db <db-persistence> ;

