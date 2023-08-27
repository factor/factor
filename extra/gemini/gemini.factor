! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs colors combinators
combinators.short-circuit continuations images.loader
images.loader.private images.viewer io io.encodings.ascii
io.encodings.binary io.encodings.latin1 io.encodings.string
io.encodings.utf8 io.pathnames io.sockets io.sockets.secure
io.styles kernel make math namespaces present sequences
sequences.extras splitting urls wrap.strings ;

IN: gemini

! Project Gemini
! "Speculative specification"
! v0.14.3, November 29, 2020

! https://gemini.circumlunar.space/docs/specification.gmi

! URL" gemini://gemini.circumlunar.space"

ERROR: too-many-redirects ;

SYMBOL: max-redirects
max-redirects [ 5 ] initialize

<PRIVATE

CONSTANT: STATUS-CATEGORIES H{
    { 10 "Input" }
    { 20 "Success" }
    { 30 "Redirect" }
    { 40 "Temporary Failure" }
    { 50 "Permanent Failure" }
    { 60 "Client Certificate Required" }
}

CONSTANT: STATUS-CODES H{
    { 10 "Input" }
    { 11 "Sensitive Input" }
    { 20 "Success" }
    { 30 "Redirect - Temporary" }
    { 31 "Redirect - Permanent" }
    { 40 "Temporary Failure" }
    { 41 "Server Unavailable" }
    { 42 "CGI Error" }
    { 43 "Proxy Error" }
    { 44 "Slow Down" }
    { 50 "Permanent Failure" }
    { 51 "Not Found" }
    { 52 "Gone" }
    { 53 "Proxy Request Refused" }
    { 59 "Bad Request" }
    { 60 "Client Certificate Requested" }
    { 61 "Certificate Not Authorized" }
    { 62 "Certificate Not Valid" }
}

: read-body ( -- body )
    [ 1024 read ] loop>array concat ;

ERROR: invalid-status value ;

: check-status ( status -- status )
    dup length 1 > [ invalid-status ] unless ;

: ?read-body ( status -- body/f )
    check-status ?first CHAR: 2 = [ read-body ] [ f ] if ;

: read-response ( -- status meta body/f )
    readln utf8 decode "\r" ?tail drop [ blank? ] split1-when over ?read-body ;

: send-request ( url -- )
    present utf8 encode write B{ CHAR: \r CHAR: \n } write flush ;

: gemini-addr ( url -- addr )
    [ host>> ] [ port>> 1965 or ] bi <inet> ;

: gemini-tls ( -- )
    ! XXX: Implement Trust-On-First-Use
    [ send-secure-handshake ] [ certificate-verify-error? ] ignore-error ;

SYMBOL: redirects

DEFER: gemini-request

: gemini-redirect ( status meta body/f -- status' meta' body'/f )
    redirects inc
    redirects get max-redirects get < [
        ! XXX: detect cross-protocol redirects
        ! XXX: detect redirect to same link
        drop nip gemini-request
    ] [ too-many-redirects ] if ;

: ?gemini-redirect ( status meta body/f -- status' meta' body'/f )
    pick ?first CHAR: 3 = [ gemini-redirect ] when ;

: gemini-request ( url -- status meta body/f )
    >url dup gemini-addr binary [
        gemini-tls
        send-request
        read-response
    ] with-client ?gemini-redirect ;

PRIVATE>

: gemini ( url -- status meta body/f )
    0 redirects [ gemini-request ] with-variable ;

ERROR: unsupported-charset charset ;

<PRIVATE

CONSTANT: gemini-encodings H{
    { "iso-8859-1" latin1 }
    { "utf-8" utf8 }
    { "us-ascii" ascii }
}

: gemini-meta ( meta -- headers )
    ";" split [ [ blank? ] trim "=" split1 [ >lower ] dip ] H{ } map>assoc ;

: gemini-charset ( text-mime -- charset )
    gemini-meta "charset" of [
        >lower gemini-encodings ?at
        [ unsupported-charset ] unless
    ] [ utf8 ] if* ;

PRIVATE>

DEFER: gemtext.

: gemini. ( url -- )
    >url dup gemini [ drop ] 2dip swap {
        { [ "text/" ?head ] [ gemini-charset decode gemtext. ] }
        { [ "image/" ?head ] [ (image-class) load-image* image. drop ] }
        [ 3drop ]
    } cond ;

<PRIVATE

:: gemini-link ( link-text base-url -- text url )
    link-text
    [ blank? ] trim-head
    [ blank? ] split1-when
    [ blank? ] trim-head [ dup ] when-empty swap >url
    dup protocol>> [
        base-url clone f >>query f >>anchor swap derive-url
    ] unless ;

: gemini-link. ( link-text base-url -- )
    gemini-link [
        presented ,,
        COLOR: blue foreground ,,
    ] H{ } make format nl ;

:: gemini-pad ( text n -- text' )
    ! XXX: break on dashes and soft-hyphens
    text n [ over length over > ] [
        dup pick [ blank? ] find-last-from drop
        dup [ 2dup - n >= [ drop f ] when ] when
        [ nip ] [ [ cut " " glue ] keep ] if* n + 1 +
    ] while drop ;

: gemini-quoted. ( text -- )
    74 gemini-pad 74 wrap-lines [ "> " write print ] each ;

: gemini-text. ( text -- )
    76 gemini-pad 76 wrap-string print ;

SYMBOL: pre

CONSTANT: h1-style H{ { font-size 16 } { font-style bold } }
CONSTANT: h2-style H{ { font-size 14 } { font-style bold } }
CONSTANT: h3-style H{ { font-size 12 } { font-style bold } }
CONSTANT: text-style H{ { font-size 12 } { font-style plain } }

:: gemini-line. ( base-url line -- )
    line {
        { [ "```" ?head ] [ drop pre toggle ] }
        { [ pre get ] [ print ] }
        { [ "=>" ?head ] [ base-url gemini-link. ] }
        { [ "> " ?head ] [ gemini-quoted. ] }
        { [ "* " ?head ] [ "• " write gemini-text. ] }
        { [ "### " ?head ] [ h3-style [ gemini-text. ] with-style ] }
        { [ "## " ?head ] [ h2-style [ gemini-text. ] with-style ] }
        { [ "# " ?head ] [ h1-style [ gemini-text. ] with-style ] }
        [ text-style [ gemini-text. ] with-style ]
    } cond ;

PRIVATE>

: gemtext. ( base-url body -- )
    f pre [ split-lines [ gemini-line. ] with each ] with-variable ;
