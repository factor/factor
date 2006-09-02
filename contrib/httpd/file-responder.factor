! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: file-responder
USING: calendar embedded errors html httpd io kernel math namespaces parser
sequences strings hashtables ;

: serving-path ( filename -- filename )
    [ "" ] unless* "doc-root" get swap append ;

: file-http-date ( filename -- string )
  #! Return the date in HTTP Date format (see RFC 2616).
  #! Returns false if no time information available for the file.
  stat [ fourth unix>gmt timestamp>http-string ] [ f ] if* ;

: file-response ( filename mime-type length -- )
    [
        number>string "Content-Length" set
        "Content-Type" set
        file-http-date [ "Last-Modified" set ] when*
        now timestamp>http-string "Date" set
    ] make-hash "200 OK" response terpri ;

: last-modified-matches? ( filename -- bool )
  file-http-date [
    "If-Modified-Since" "header" get hash = 
  ] [
    f
  ] if* ;

: not-modified-response ( -- )
    [
        now timestamp>http-string "Date" set
    ] make-hash "304 Not Modified" response terpri ;  

: serve-static ( filename mime-type -- )
    over last-modified-matches? [
      drop not-modified-response
    ] [
      dupd pick file-length file-response "method" get "head" = [
          drop
      ] [
          <file-reader> stdio get stream-copy
      ] if 
    ] if ;

SYMBOL: page

: run-page ( filename -- )
    dup
    [ [ dup page set run-embedded-file ] with-scope ] try
    drop ;

: include-page ( filename -- )
    "doc-root" get swap path+ run-page ;

: serve-file ( filename -- )
    dup mime-type dup "application/x-factor-server-page" =
    [ drop serving-html run-page ] [ serve-static ] if ;

: list-directory ( directory -- )
    serving-html
     "method" get "head" = [
        drop
    ] [
        "request" get [ dup log-message directory. ] simple-html-document
    ] if ;

: find-index ( filename -- path )
    { "index.html" "index.fhtml" }
    [ dupd path+ exists? ] find nip
    dup [ path+ ] [ nip ] if ;

: serve-directory ( filename -- )
    dup "/" tail? [
        dup find-index
        [ serve-file ] [ list-directory ] ?if
    ] [
        drop directory-no/
    ] if ;

: serve-object ( filename -- )
    dup directory? [ serve-directory ] [ serve-file ] if ;

: file-responder ( -- )
    "doc-root" get [
        "argument" get serving-path dup exists? [
            serve-object
        ] [
            drop "404 not found" httpd-error
        ] if
    ] [
        "404 doc-root not set" httpd-error
    ] if ;
