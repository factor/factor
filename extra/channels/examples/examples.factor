! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Examples of using channels
USING: kernel concurrency channels math namespaces locals
sequences ;
IN: channels.examples

: (counter) ( channel n -- )
    [ swap to ] 2keep 1+ (counter) ;
    
: counter ( channel -- )
    2 (counter) ;    

: counter-test ( -- n1 n2 n3 )
    <channel> [ counter ] spawn drop 
    [ from ] keep [ from ] keep from ;

: filter ( send prime recv -- )
    #! Receives numbers from the 'send' channel,
    #! filters out all those divisible by 'prime',
    #! and sends to the 'recv' channel.
    [
        from swap dupd mod zero? not [ swap to ] [ 2drop ] if     
    ] 3keep filter ;

:: (sieve) | prime c |
    [let | p [ c from ] 
           newc [ <channel> ] |
        p prime to
        [ newc p c filter ] spawn drop
        prime newc (sieve)
    ] ;

: sieve ( prime -- ) 
    #! Send prime numbers to 'prime' channel
    <channel> [ counter ] spawn drop
    (sieve) ;

: sieve-test ( -- seq )
    <channel> [ sieve ] spawn drop
    V{ } clone swap 
    [ from swap push ] 2keep
    [ from swap push ] 2keep
    [ from swap push ] 2keep
    [ from swap push ] 2keep
    [ from swap push ] 2keep
    [ from swap push ] 2keep
    [ from swap push ] 2keep
    [ from swap push ] 2keep
    drop ;
