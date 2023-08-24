! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii kernel sequences tr ;
IN: soundex

<PRIVATE

TR: soundex-digits
    "AEHIOUWYBFPVCGJKQSXZDTLMNR"
    "AEHIOUWY111122222222334556" ;

: remove-duplicates ( seq -- seq' )
    ! Remove _consecutive_ duplicates (unlike prune which removes
    ! all duplicates).
    f swap [ [ = ] keep swap ] reject nip ;

: pad-4 ( seq -- seq' ) "000" append 4 head ;

: remove-hw ( seq -- seq' )
    unclip [ [ "HW" member? ] reject ] [ prefix ] bi* ;

: remove-aeiouy ( seq -- seq' )
    unclip [ [ "AEIOUY" member? ] reject ] [ prefix ] bi* ;

: ?replace-first ( seq first -- seq )
    over first digit? [ over set-first ] [ drop ] if ;

PRIVATE>

: soundex ( string -- soundex )
    >upper [ LETTER? ] filter [
        remove-hw
        soundex-digits
        remove-duplicates
        remove-aeiouy
    ] keep first ?replace-first pad-4 ;
