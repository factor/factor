! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See https://factorcode.org/license.txt for BSD license.
!
! Examples of using channels
USING: kernel threads channels math sequences ;
IN: channels.examples

: (counter) ( channel n -- )
    [ swap to ] 2keep 1 + (counter) ;

: counter ( channel -- )
    2 (counter) ;

: counter-test ( -- n1 n2 n3 )
    <channel> dup [ counter ] curry "Counter" spawn drop
    [ from ] keep [ from ] keep from ;

: filter ( send prime recv -- )
    ! Receives numbers from the 'send' channel,
    ! filters out all those divisible by 'prime',
    ! and sends to the 'recv' channel.
    [
        from swap dupd mod zero? not [ swap to ] [ 2drop ] if
    ] 3keep filter ;

:: (sieve) ( prime c -- )
    c from :> p
    <channel> :> newc
    p prime to
    [ newc p c filter ] "Filter" spawn drop
    prime newc (sieve) ;

: sieve ( prime -- )
    ! Send prime numbers to 'prime' channel
    <channel> dup [ counter ] curry "Counter" spawn drop
    (sieve) ;

: sieve-test ( -- seq )
    <channel> dup [ sieve ] curry "Sieve" spawn drop
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
