! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.threads continuations kernel
locals math math.functions math.order random threads ;
IN: backoff

! All delays are in milliseconds. Policies are separate from counters so
! callers can share a policy while keeping independent attempt numbers.
GENERIC: backoff-delay ( attempt policy -- milliseconds )

TUPLE: constant-backoff delay ;
C: <constant-backoff> constant-backoff

TUPLE: linear-backoff min max step ;
C: <linear-backoff> linear-backoff

TUPLE: exponential-backoff min max factor jitter? ;
C: <exponential-backoff> exponential-backoff

: <default-backoff> ( -- policy )
    100 10000 2 f <exponential-backoff> ;

M: constant-backoff backoff-delay nip delay>> ;

M:: linear-backoff backoff-delay ( attempt policy -- milliseconds )
    policy min>> attempt policy step>> * + policy max>> min ;

M:: exponential-backoff backoff-delay ( attempt policy -- milliseconds )
    policy min>> :> lo
    policy max>> :> hi
    policy factor>> :> factor
    ! Compare logarithms first: do not build enormous powers after capping.
    lo zero? [ 0 ] [
        lo hi >= [ hi ] [
            factor 1 = [ lo ] [
                attempt hi >float lo / log factor log / >=
                [ hi ] [ lo factor >float attempt ^ * hi min ] if
            ] if
        ] if
    ] if :> delay
    policy jitter?>> [
        lo hi min :> floor
        delay floor - 1.0 random * floor +
    ] [ delay ] if ;

TUPLE: backoff { attempts integer initial: 0 } policy ;

: <backoff> ( policy -- backoff ) backoff new swap >>policy ;

: reset-backoff ( backoff -- ) 0 >>attempts drop ;

: next-backoff ( backoff -- milliseconds )
    dup [ attempts>> ] [ policy>> ] bi backoff-delay
    swap [ 1 + ] change-attempts drop ;

ERROR: invalid-retry-count count ;

:: retry-backoff-with ( quot: ( -- result ) retry?: ( error -- ? ) wait: ( milliseconds -- ) policy retries -- result )
    retries integer? [ retries 0 >= ] [ f ] if
    [ ] [ retries invalid-retry-count ] if
    policy <backoff> :> counter
    f :> result!
    [
        [ quot call result! t ] [
            dup retry? call counter attempts>> retries < and [
                drop counter next-backoff wait call f
            ] [ rethrow ] if
        ] recover
    ] [ ] until
    result ; inline

:: retry-backoff ( quot: ( -- result ) policy retries -- result )
    quot [ drop t ] [ milliseconds sleep ] policy retries
    retry-backoff-with ; inline
