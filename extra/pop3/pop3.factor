! Copyright (C) 2009 Elie Chaftari.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators io io.crlf
io.encodings.utf8 io.sockets io.streams.duplex io.timeouts
kernel make math math.parser namespaces ranges sequences
splitting ;
IN: pop3

TUPLE: pop3-account
# host port timeout user pwd stream capa count list
uidls messages ;

: <pop3-account> ( -- pop3-account )
    pop3-account new
        110 >>port
        1 minutes >>timeout ;

: account ( -- pop3-account ) pop3-account get ;

TUPLE: message # uidl headers from to subject size ;

<PRIVATE

: stream ( -- duplex-stream ) account stream>> ;

: <message> ( -- message ) message new ; inline

TUPLE: raw-source top headers content ;

: <raw-source> ( -- raw-source ) raw-source new ; inline

: raw ( -- raw-source ) raw-source get ;

: set-read-timeout ( -- )
    stream [
        account timeout>> timeouts
    ] with-stream* ;

: get-ok ( -- )
    stream [
        readln dup "+OK" head? [ drop ] [ throw ] if
    ] with-stream* ;

: get-ok-and-total ( -- total )
    stream [
        readln dup "+OK" head? [
            split-words second string>number dup account count<<
        ] [ throw ] if
    ] with-stream* ;

: get-ok-and-uidl ( -- uidl )
    stream [
        readln dup "+OK" head? [
            split-words last
        ] [ throw ] if
    ] with-stream* ;

: command ( string -- ) write crlf flush get-ok ;

: command-and-total ( string -- total ) write crlf flush
    get-ok-and-total ;

: command-and-uidl ( string -- uidl ) write crlf flush
    get-ok-and-uidl ;

: associate-split ( seq -- assoc )
    [ " " split1 ] H{ } map>assoc ;

: split-map ( seq -- assoc )
    associate-split [ [ string>number ] dip ] assoc-map ;

: (readlns) ( -- )
    readln dup "." = [ , ] dip [ (readlns) ] unless ;

: readlns ( -- seq ) [ (readlns) ] { } make but-last ;

: (list) ( -- )
    stream [
        "LIST" command
        readlns account list<<
    ] with-stream* ;

: (uidls) ( -- )
    stream [
        "UIDL" command
        readlns account uidls<<
    ] with-stream* ;

PRIVATE>

: >user ( name -- )
    [ stream ] dip '[
        "USER " _ append command
    ] with-stream* ;

: >pwd ( password -- )
    [ stream ] dip '[
        "PASS " _ append command
    ] with-stream* ;

: connect ( pop3-account -- )
    [
        [ host>> ] [ port>> ] bi
        <inet> utf8 <client> drop
    ] 1guard >>stream
    {
        [ pop3-account set ]
        [ user>> [ >user ] when* ]
        [ pwd>> [ >pwd ] when* ]
    } cleave
    set-read-timeout
    get-ok ;

: capa ( -- array )
    stream [
        "CAPA" command
        readlns dup account capa<<
    ] with-stream* ;

: count ( -- n )
    stream [
        "STAT" command-and-total
    ] with-stream* ;

: list ( -- assoc )
    (list) account list>> split-map ;

: uidl ( message# -- uidl )
    [ stream ] dip '[
        "UIDL " _ number>string append command-and-uidl
    ] with-stream* ;

: uidls ( -- assoc )
    (uidls) account uidls>> split-map ;

: top ( message# #lines -- seq )
    <raw-source> raw-source set
    [ stream ] 2dip '[
        "TOP " _ number>string append " "
        append _ number>string append
        command
        readlns dup raw top<<
    ] with-stream* ;

: headers ( -- assoc )
    raw top>> {
        [
            [ dup "From:" head?
                [ raw [ swap suffix ] change-headers drop ]
                [ drop ] if
            ] each
        ]
        [
            [ dup "To:" head?
                [ raw [ swap suffix ] change-headers drop ]
                [ drop ] if
            ] each
        ]
        [
            [ dup "Subject:" head?
                [ raw [ swap suffix ] change-headers drop ]
                [ drop ] if
            ] each
        ]
    } cleave raw headers>> associate-split ;

: retrieve ( message# -- seq )
    [ stream ] dip '[
        "RETR " _ number>string append command
        readlns dup raw content<<
    ] with-stream* ;

: delete ( message# -- )
    [ stream ] dip '[
        "DELE " _ number>string append command
    ] with-stream* ;

: reset ( -- )
    stream [ "RSET" command ] with-stream* ;

: consolidate ( -- seq )
    count zero? [ "No mail for account." ] [
        1 account count>> [a..b] [
            {
                [ 0 top drop ]
                [ <message> swap >># ]
                [ uidls at >>uidl ]
                [ list at >>size ]
            } cleave
            "From:" headers at >>from
            "To:" headers at >>to
            "Subject:" headers at >>subject
            account [ swap suffix ] change-messages drop
        ] each account messages>>
    ] if ;

: close ( -- )
    stream [ "QUIT" command ] with-stream ;
