! Copyright (C) 2009 Diego Martinelli.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays calendar calendar.format 
checksums checksums.openssl classes.tuple 
fry kernel make math math.functions math.parser math.ranges 
present random sequences splitting strings syntax ;
IN: hashcash

! Hashcash implementation
! Reference materials listed below:
! 
! http://hashcash.org
! http://en.wikipedia.org/wiki/Hashcash
! http://www.ibm.com/developerworks/linux/library/l-hashcash.html?ca=dgr-lnxw01HashCash
! 
! And the reference implementation (in python):
! http://www.gnosis.cx/download/gnosis/util/hashcash.py

<PRIVATE

! Return a string with today's date in the form YYMMDD
: get-date ( -- str )
    now [ year>> 100 mod pad-00 ] 
        [ month>> pad-00 ] 
        [ day>> pad-00 ] tri 3append ;

! Random salt is formed by ascii characters
! between 33 and 126
: available-chars ( -- seq )
    33 126 [a,b] [ CHAR: : = not ] filter ;

PRIVATE>

! Generate a 'length' long random salt
: salt ( length -- salted )
    available-chars '[ _ random ] "" replicate-as ;

TUPLE: hashcash version bits date resource ext salt suffix ;

: <hashcash> ( -- tuple )
    hashcash new
        1 >>version
        20 >>bits
        get-date >>date
        8 salt >>salt ;

M: hashcash string>> 
    tuple-slots [ present ] map ":" join ;

<PRIVATE

: sha1-checksum ( str -- bytes )
    openssl-sha1 checksum-bytes ; inline

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
    valid-guess? [ drop ] [ 1+ (mint) ] if ;

PRIVATE>

: mint* ( tuple -- stamp )
    0 (mint) string>> ;

: mint ( resource -- stamp )
    <hashcash>
        swap >>resource
    mint* ;

! One might wanna add check based on the date,
! passing a 'good-until' duration param
: check-stamp ( stamp -- ? )
    dup ":" split [ sha1-checksum get-bits ] dip
    second string>number head all-char-zero? ;

