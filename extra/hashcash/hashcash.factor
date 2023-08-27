! Copyright (C) 2009 Diego Martinelli.
! Copyright (C) 2023 Zoltán Kéri.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays calendar calendar.format
calendar.parser checksums checksums.openssl classes.tuple
combinators combinators.short-circuit.smart formatting grouping
io io.encodings.ascii io.encodings.string io.streams.string
kernel literals make math math.functions math.parser namespaces
parser present prettyprint quotations random random.passwords
ranges sequences sequences.deep splitting strings typed words ;
IN: hashcash

<PRIVATE

: lastn-digits ( n digits -- string )
    [ number>string ] dip [ 48 pad-head ] keep tail* ;

: read-yymmdd ( -- y m d )
    read-00 now start-of-millennium year>> + read-00 read-00 ;

TYPED: yymmdd-gmt>timestamp ( yymmdd: string -- timestamp )
    [ read-yymmdd <date-gmt> ] with-string-reader ;

TYPED: timestamp>yymmdd ( timestamp -- yymmdd: string )
    [ year>> 2 lastn-digits ]
    [ month>> pad-00 ]
    [ day>> pad-00 ] tri 3append ;

TYPED: now-gmt-yymmdd ( -- yymmdd: string )
    now-gmt timestamp>yymmdd ;

TYPED: yymmdd-gmt-diff ( yymmdd: string yymmdd: string -- days )
    [ yymmdd-gmt>timestamp ] bi@ time- duration>days ;

TYPED: on-or-before-today? ( yymmdd: string -- x ? )
    now-gmt-yymmdd swap yymmdd-gmt-diff dup 0 >= ;

PRIVATE>

TUPLE: hashcash version bits date resource ext salt suffix ;

: <hashcash> ( -- tuple )
    hashcash new
    1 >>version
    20 >>bits
    now-gmt-yymmdd >>date
    8 ascii-password >>salt ;

M: hashcash string>>
    tuple-slots [ present ] map ":" join ;

<PRIVATE

: sha1-checksum ( str -- bytes )
    ascii encode openssl-sha1 checksum-bytes ; inline

: set-suffix ( tuple guess -- tuple )
    >hex >>suffix ;

: get-bits ( bytes -- str )
    [ >bin 8 CHAR: 0 pad-head ] { } map-as concat ;

: checksummed-bits ( tuple -- relevant-bits )
    dup string>> sha1-checksum
    swap bits>> 8 / ceiling head get-bits ;

: all-char-zero? ( seq -- ? )
    [ CHAR: 0 = ] all? ; inline

: valid-guess? ( checksum tuple -- ? )
    bits>> head all-char-zero? ;

: (mint) ( tuple counter -- tuple )
    2dup set-suffix checksummed-bits pick
    valid-guess? [ drop ] [ 1 + (mint) ] if ;

PRIVATE>

: mint* ( tuple -- stamp )
    0 (mint) string>> ;

: mint ( resource -- stamp )
    <hashcash>
    swap >>resource
    mint* ;

<PRIVATE

! NOTE: Recommended expiry time is 28 days.
INITIALIZED-SYMBOL: expiry-days [ 28 ]

PRIVATE>

TYPED: valid-date? ( yymmdd: string -- ? )
    on-or-before-today? [ expiry-days get <= ] [ drop f ] if ;

: valid-stamp? ( stamp -- ? )
    dup ":" split [ sha1-checksum get-bits ] dip [ 1 3 ] dip subseq first2
    valid-date? [ string>number head all-char-zero? ] [ 2drop f ] if ;
