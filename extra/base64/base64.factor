USING: kernel math sequences namespaces io.binary splitting
 strings hashtables ;
IN: base64

<PRIVATE

: count-end ( seq quot -- count )
    >r [ length ] keep r> find-last drop dup [ - 1- ] [ 2drop 0 ] if ;

: ch>base64 ( ch -- ch )
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" nth ;

: base64>ch ( ch -- ch )
    {
        f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f
        f f f f f f f f f f 62 f f f 63 52 53 54 55 56 57 58 59 60 61 f f
        f 0 f f f 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
        22 23 24 25 f f f f f f 26 27 28 29 30 31 32 33 34 35 36 37 38 39
        40 41 42 43 44 45 46 47 48 49 50 51
    } nth ;

: encode3 ( seq -- seq )
    be> 4 [ 3 swap - -6 * shift HEX: 3f bitand ch>base64 ] curry* map ;

: decode4 ( str -- str )
    [ base64>ch ] map 0 [ swap 6 shift bitor ] reduce 3 >be ;

: >base64-rem ( str -- str )
    [ 3 0 pad-right encode3 ] keep length 1+ head 4 CHAR: = pad-right ;

PRIVATE>

: >base64 ( seq -- base64 )
    #! cut string into two pieces, convert 3 bytes at a time
    #! pad string with = when not enough bits
    dup length dup 3 mod - cut swap
    [
        3 group [ encode3 % ] each
        dup empty? [ drop ] [ >base64-rem % ] if
    ] "" make ;

: base64> ( base64 -- str )
    #! input length must be a multiple of 4
    [
        [ 4 group [ decode4 % ] each ] keep [ CHAR: = = not ] count-end 
    ] SBUF" " make swap [ dup pop* ] times >string ;

