! Copyright (C) 2021 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii colors.constants continuations io
io.encodings.utf8 io.sockets io.sockets.secure io.styles kernel
make present sequences sequences.extras splitting urls
wrap.strings ;

IN: gemini

! Project Gemini
! "Speculative specification"
! v0.14.3, November 29, 2020

! https://gemini.circumlunar.space/docs/specification.gmi

! URL" gemini://gemini.circumlunar.space"

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
    [ readln ] loop>array ;

: ?read-body ( status -- body/f )
    ?first CHAR: 2 = [ read-body ] [ f ] if ;

: read-response ( -- status meta body/f )
    readln [ blank? ] split1-when over ?read-body ;

: send-request ( url -- )
    present write "\r\n" write flush ;

: gemini-addr ( url -- addr )
    [ host>> ] [ port>> 1965 or ] bi <inet> ;

: gemini-tls ( -- )
    ! XXX: Implement Trust-On-First-Use
    [ send-secure-handshake ] [ certificate-verify-error? ] ignore-error ;

PRIVATE>

: gemini ( url -- status meta body/f )
    dup gemini-addr utf8 [
        gemini-tls
        send-request
        read-response
    ] with-client ;

:: gemini. ( url -- )
    url gemini 2nip [
        "=> " ?head [
            [ blank? ] trim-head
            [ blank? ] split1-when
            [ blank? ] trim [ dup ] when-empty swap
            "://" over subseq? [
                >url
            ] [
                url clone swap >>path f >>query f >>anchor
            ] if [
                presented ,,
                COLOR: blue foreground ,,
            ] H{ } make format nl
        ] [
            60 wrap-string print
        ] if
    ] each ;

! "gemtext"

! Text Lines
! 
! ... each line is a paragraph
! ... each blank line is a vertical space
! 
! 
! Link Lines
! 
! =>[<whitespace>]<URL>[<whitespace><USER-FRIENDLY LINK NAME>]<CR><LF>
! 
! Preformatted toggle lines
! 
! ```
! 
! Heading Lines
! 
! # 
! ##
! ###
! 
! Unordered list lines
! 
! * 
!
! Quote lines
! 
! >
! >
