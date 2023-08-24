USING: accessors arrays assocs calendar calendar.format calendar.parser
combinators continuations destructors formatting fry grouping.extras imap
imap.private io.streams.duplex kernel math math.parser ranges
namespaces random sequences sets sorting uuid multiline
splitting strings system tools.test memoize combinators.smart ;
FROM: pcre => findall ;
IN: imap.tests

: random-ascii ( n -- str )
    [ CHAR: a CHAR: z [a..b] random ] "" replicate-as ;

: make-mail ( from -- mail )
    now timestamp>rfc822 swap 10000 random
    3array {
        "Date: %s"
        "From: %s"
        "Subject: afternoon meeting"
        "To: mooch@owatagu.siam.edu"
        "Message-Id: <%08d@Blurdybloop.COM>"
        "MIME-Version: 1.0"
        "Content-Type: TEXT/PLAIN; CHARSET=US-ASCII"
        ""
        "Hello Joe, do you think we can meet at 3:30 tomorrow?"
    } "\r\n" join vsprintf ;

: sample-mail ( -- mail )
    "Fred Foobar <foobar@Blurdybloop.COM>" make-mail ;

ERROR: no-imap-test-host ;

: get-test-host ( -- host )
    \ imap-settings get-global host>> [ no-imap-test-host ] unless* ;

: imap-test ( result quot -- )
    '[ \ imap-settings get-global _ with-imap-settings ] unit-test ; inline

: base-folder ( -- s )
    os name>> cpu name>> "-" glue ;

MEMO: my-uuid ( -- str )
    uuid1 ;

: test-folder ( s -- s )
    '[
        base-folder "/" my-uuid "/" _
    ] "" append-outputs-as ;


![[

{ t } [
    get-test-host <imap4ssl> [ duplex-stream? ] with-disposal
] unit-test

{ t } [
    get-test-host <imap4ssl> [ capabilities ] with-stream
    { "IMAP4rev1" "UNSELECT" "IDLE" "NAMESPACE" "QUOTA" } swap subset?
] unit-test

{ "NO" } [
    [ get-test-host <imap4ssl> [ "dont@exist.com" "foo" login ] with-stream ]
    [ ind>> ] recover
] unit-test

{ "BAD" } [
    [ get-test-host <imap4ssl> [ f f login ] with-stream ] [ ind>> ] recover
] unit-test

! Try to reset test folder before starting tests
{ } [
    [ "foo/bar/baz/日本語" test-folder delete-folder ] ignore-errors
    [ "foo/bar/baz/boo" test-folder delete-folder ] ignore-errors
    [ "foo/bar/baz" test-folder delete-folder ] ignore-errors
    [ "foo/bar" test-folder delete-folder ] ignore-errors
    [ "foo" test-folder delete-folder ] ignore-errors
    [ "örjan" test-folder delete-folder ] ignore-errors
    [ base-folder delete-folder ] ignore-errors
] imap-test


{ } [ \ imap-settings get-global [ ] with-imap-settings ] unit-test

! Newly created and then selected folder is empty.
{ 0 { } } [
    10 random-ascii
    [ create-folder ]
    [ select-folder ]
    [ delete-folder ] tri
    "ALL" "" search-mails
] imap-test

! Create delete select again.
{ 0 } [
    "örjan" test-folder
    [ create-folder ] [ select-folder ] [ delete-folder ] tri
] imap-test

! Test list folders
{ t } [
    10 random-ascii
    [ create-folder "*" list-folders length 0 > ] [ delete-folder ] bi
] imap-test

! Generate some mails for searching
{ t t f f } [
    10 random-ascii {
        [ create-folder ]
        [
            '[ _ "(\\Seen)" now sample-mail append-mail drop ]
            10 swap times
        ]
        [
            select-folder drop
            "ALL" "" search-mails
            5 sample "(RFC822)" fetch-mails
            [ [ string? ] all? ] [ length 5 = ] bi
            "SUBJECT" "afternoon" search-mails empty?
            "(SINCE \"01-Jan-2014\")" "" search-mails empty?
        ]
        [ delete-folder ]
    } cleave
] imap-test

! Stat folder
{ t } [
    10 random-ascii {
        [ create-folder ]
        [
            '[ _ "(\\Seen)" now sample-mail append-mail drop ]
            10 swap times
        ]
        [
            { "MESSAGES" "UNSEEN" } status-folder
            [ "MESSAGES" of 0 > ] [ "UNSEEN" of 0 >= ] bi and
        ]
        [ delete-folder ]
    } cleave
] imap-test

! Rename folder
{ } [
    "日本語" test-folder [ create-folder ] [
        "ascii-name" test-folder
        [ rename-folder ] [ delete-folder ] bi
    ] bi
] imap-test

! Create a folder hierarchy
{ t } [
    "foo/bar/baz/日本語" test-folder
    [ '[ _ delete-folder ] ignore-errors ]
    [
        "*" test-folder list-folders length
        swap create-folder
        "*" test-folder list-folders length 4 - =
    ]
    [ delete-folder ] tri
] imap-test

! A gmail compliant way of creating a folder hierarchy.
{ } [
    "foo/bar/baz/boo" test-folder "/" split
    { } [ suffix ] accumulate* [ "/" join ] map
    [ [ create-folder ] each ] [ [ delete-folder ] each ] bi
] imap-test

{ } [
    "örjan" test-folder {
        [ create-folder ]
        [ select-folder drop ]
        ! Append mail with a seen flag
        [ "(\\Seen)" now sample-mail append-mail drop ]
        ! And one without
        [ "" now sample-mail append-mail drop ]
        [ delete-folder ]
    } cleave
] imap-test

! Exercise store-mail
{ 5 } [
    "INBOX" select-folder drop "ALL" "" search-mails
    5 sample "+FLAGS" "(\\Recent)" store-mail length
] imap-test

! Internal date parsing
{ "Mon, 19 Aug 2013 23:16:36 GMT" } [
    "19-Aug-2013 23:16:36 +0000" internal-date>timestamp timestamp>rfc822
] unit-test

{ "19-Aug-2014 23:16:36 GMT" } [
    "Mon, 19 Aug 2014 23:16:36 GMT" rfc822>timestamp timestamp>internal-date
] unit-test

! Test parsing an INTERNALDATE from a real mail.
{ t } [
    "INBOX" select-folder drop
    "ALL" "" search-mails
    "(INTERNALDATE)" fetch-mails first
    "\"([^\"]+)\"" findall first second last
    internal-date>timestamp timestamp?
] imap-test

! Response parsing
{ { 8132 { "\\Seen" } } f } [
    "(FLAGS (\\Seen) UID 8132)" parse-store-mail-line
    ! Weird non-standard(?) response format gmail uses to indicate the
    ! previous mail flags. Just ignore it.
    "(UID 1234 FLAGS (\\Seen))" parse-store-mail-line
] unit-test

! Just an interesting verb to gmail thread mails. Wonder if you can
! avoid the double fetch-mails?
: threaded-mailbox ( uids -- threads )
    [
        "(X-GM-THRID)" fetch-mails [
            "\\d+" findall [ first last string>number
            ] map
        ] map
    ] [ "(BODY[HEADER.FIELDS (SUBJECT)])" fetch-mails ] bi zip
    [ first first ] [ sort-with ] [ group-by ] bi ;

]]
