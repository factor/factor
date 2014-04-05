USING: accessors arrays assocs calendar calendar.format calendar.format.macros
formatting fry grouping io io.crlf io.encodings.ascii io.encodings.binary
io.encodings.string io.encodings.utf7 io.encodings.utf8 io.sockets
io.sockets.secure io.streams.duplex io.streams.string kernel math math.parser
sequences splitting strings ;
QUALIFIED: pcre
IN: imap

ERROR: imap4-error ind data ;

CONSTANT: IMAP4_PORT     143
CONSTANT: IMAP4_SSL_PORT 993

! Converts a timestamp to the format imap4 expects.
: timestamp>internal-date ( timestamp -- str )
    [

        {
            DD "-" MONTH "-" YYYY " "
            hh ":" mm ":" ss " "
            [ gmt-offset>> write-gmt-offset ]
        } formatted
    ] with-string-writer ;

: internal-date>timestamp ( str -- timestamp )
    [
        ! Date, month, year.
        "-" read-token checked-number
        "-" read-token month-abbreviations index 1 +
        read-sp checked-number -rot swap
        ! Hour, minute second and gmt offset.
        read-hms " " expect readln parse-rfc822-gmt-offset <timestamp>
    ] with-string-reader  ;

<PRIVATE

: >utf7imap4 ( str -- str' )
    utf7imap4 encode >string ;

: comma-list ( numbers -- str )
    [ number>string ] map "," join ;

: check-status ( ind data -- )
    over "OK" = not [ imap4-error ] [ 2drop ] if ;

: read-response-chunk ( stop-expr -- item ? )
    read-?crlf ascii decode swap dupd pcre:findall
    [
        dup "^.*{(\\d+)}$" pcre:findall
        [
            dup "^\\* (\\d+) [A-Z-]+ (.*)$" pcre:findall
            [ ] [ nip first third second ] if-empty
        ]
        [
            ! Literal item to read, such as message body.
            nip first second second string>number read ascii decode
            read-?crlf drop
        ] if-empty t
    ]
    [ nip first 1 tail values f ] if-empty ;

: read-response ( tag -- lines )
    "^%s (BAD|NO|OK) (.*)$" sprintf
    '[ _ read-response-chunk [ suffix ] dip ] { } swap loop
    unclip-last first2 [ check-status ] keep suffix ;

: write-command ( command literal tag -- )
    -rot [
        [ "%s %s\r\n" sprintf ] [ length "%s %s {%d}\r\n" sprintf ] if-empty
        ascii encode write flush
    ] keep [
        read-?crlf drop "\r\n" append write flush
    ] unless-empty ;

: command-response ( command literal -- obj )
    "ABCD" [ write-command ] [ read-response ] bi ;

! Special parsing
: parse-items ( seq -- items )
    first " " split 2 tail ;

: parse-list-folders ( str -- folder )
    "\\* LIST \\(([^\\)]+)\\) \"([^\"]+)\" \"([^\"]+)\"" pcre:findall
    first 1 tail values [ utf7imap4 decode ] map ;

: parse-select-folder ( seq -- count )
    [ "\\* (\\d+) EXISTS" pcre:findall ] map harvest
    [ f ] [ first first last last string>number ] if-empty ;

! Returns uid if the server supports the UIDPLUS extension.
: parse-append-mail ( seq -- uid/f )
    [ "\\[APPENDUID (\\d+) \\d+\\]" pcre:findall ] map harvest
    [ f ] [ first first last last string>number ] if-empty ;

: parse-status ( seq -- assoc )
    first "\\* STATUS \"[^\"]+\" \\(([^\\)]+)\\)" pcre:findall first last last
    " " split 2 group [ string>number ] assoc-map ;

: parse-store-mail ( seq -- assoc )
    but-last [
        "\\(FLAGS \\(([^\\)]+)\\) UID (\\d+)\\)" pcre:findall
        first 1 tail values first2 [ " " split ] dip string>number swap 2array
    ] map ;

PRIVATE>

! Constructor
: <imap4ssl> ( host -- imap4 )
    IMAP4_SSL_PORT <inet> <secure> binary <client> drop
    ! Read the useless welcome message.
    dup [ "\\*" read-response drop ] with-stream* ;

! IMAP commands
: capabilities ( -- caps )
    "CAPABILITY" "" command-response parse-items ;

: login ( username password -- caps )
    "LOGIN %s \"%s\"" sprintf "" command-response parse-items ;

! Folder management
: list-folders ( directory -- folders )
    "LIST \"%s\" *" sprintf "" command-response
    but-last [ parse-list-folders ] map ;

: select-folder ( mailbox -- count )
    >utf7imap4 "SELECT \"%s\"" sprintf "" command-response
    parse-select-folder ;

: create-folder ( mailbox -- )
    >utf7imap4 "CREATE \"%s\"" sprintf "" command-response
    drop ;

: delete-folder ( mailbox -- )
    >utf7imap4 "DELETE \"%s\"" sprintf "" command-response
    drop ;

: rename-folder ( old-name new-name -- )
    [ >utf7imap4 ] bi@ "RENAME \"%s\" \"%s\"" sprintf "" command-response
    drop ;

: status-folder ( mailbox keys -- assoc )
    [ >utf7imap4 ] dip " " join "STATUS \"%s\" (%s)" sprintf
    "" command-response parse-status ;

: close-folder ( -- )
    "CLOSE" "" command-response drop ;

! Mail management
: search-mails ( data-spec str -- uids )
    [ "UID SEARCH CHARSET UTF-8 %s" sprintf ] dip utf8 encode
    command-response parse-items [ string>number ] map ;

: fetch-mails ( uids data-spec -- texts )
    [ comma-list ] dip "UID FETCH %s %s" sprintf "" command-response but-last ;

: copy-mails ( uids mailbox -- )
    [ comma-list ] dip >utf7imap4 "UID COPY %s \"%s\"" sprintf ""
    command-response drop ;

: append-mail ( mailbox flags date-time mail -- uid/f )
    [
        [ >utf7imap4 ]
        [ [ "" ] [ " " append ] if-empty ]
        [ timestamp>internal-date ] tri*
        "APPEND \"%s\" %s\"%s\"" sprintf
    ] dip utf8 encode command-response parse-append-mail ;

: store-mail ( uids command flags -- mail-flags )
    [ comma-list ] 2dip "UID STORE %s %s %s" sprintf "" command-response
    parse-store-mail ;

! High level API

: with-imap ( host email password quot -- )
    [ <imap4ssl> ] 3dip '[ _ _ login drop @ ] with-stream ; inline

TUPLE: imap-settings host email password ;

: <imap-settings> ( host email password -- obj )
    imap-settings new
        swap >>password
        swap >>email
        swap >>host ; inline
    
: with-imap-settings ( imap-settings quot -- )
    [ [ host>> ] [ email>> ] [ password>> ] tri ] dip with-imap ; inline
