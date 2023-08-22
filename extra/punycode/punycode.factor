! Copyright (C) 2020 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii byte-arrays combinators kernel literals
math math.order sbufs sequences sequences.extras sets sorting
splitting urls ;

IN: punycode

<PRIVATE

<<
CONSTANT: BASE   36
CONSTANT: TMIN   1
CONSTANT: TMAX   26
CONSTANT: SKEW   38
CONSTANT: DAMP   700
CONSTANT: BIAS   72
CONSTANT: N      128
CONSTANT: DIGITS $[ "abcdefghijklmnopqrstuvwxyz0123456789" >byte-array ]
>>

: threshold ( j bias -- T )
    [ BASE * ] [ - ] bi* TMIN TMAX clamp ;

:: adapt ( delta! #chars first? -- bias )
    delta first? DAMP 2 ? /i delta!
    delta dup #chars /i + delta!
    0 [ delta $[ BASE TMIN - TMAX * 2 /i ] > ] [
        delta $[ BASE TMIN - ] /i delta!
        BASE +
    ] while BASE delta * delta SKEW + /i + ;

: segregate ( str -- base extended )
    [ N < ] partition members sort ;

:: find-pos ( str ch i pos -- i' pos' )
    i pos 1 + str [
        ch <=> {
            { +eq+ [ 1 + t ] }
            { +lt+ [ 1 + f ] }
            [ drop f ]
        } case
    ] find-from drop [ drop -1 -1 ] unless* ;

:: insertion-unsort ( str extended -- deltas )
    V{ } clone :> accum
    N :> oldch!
    -1 :> oldi!
    extended [| ch |
        -1 :> i!
        -1 :> pos!
        str [ ch < ] count :> curlen
        curlen 1 + ch oldch - * :> delta!
        [
            str ch i pos find-pos pos! i!
            i -1 = [
                f
            ] [
                i oldi - delta + delta!
                delta 1 - accum push
                i oldi!
                0 delta!
                t
            ] if
        ] loop
        ch oldch!
    ] each accum ;

:: encode-delta ( delta! bias -- seq )
    SBUF" " clone :> accum
    0 :> j!
    [
        j 1 + j!
        j bias threshold :> T
        delta T < [
            f
            delta
        ] [
            t
            delta T - BASE T - /mod T + swap delta!
        ] if DIGITS nth accum push
    ] loop accum ;

:: encode-deltas ( baselen deltas -- seq )
    SBUF" " clone :> accum
    BIAS :> bias!
    deltas [| delta i |
        delta bias encode-delta accum push-all
        delta baselen i + 1 + i 0 = adapt bias!
    ] each-index accum ;

PRIVATE>

:: >punycode ( str -- punicode )
    str segregate :> ( base extended )
    str extended insertion-unsort :> deltas
    base length deltas encode-deltas
    base [ "-" rot 3append ] unless-empty "" like ;

<PRIVATE

ERROR: invalid-digit char ;

: decode-digit ( ch -- digit )
    {
        { [ dup LETTER? ] [ CHAR: A - ] }
        { [ dup digit? ] [ CHAR: 0 26 - - ] }
        [ invalid-digit ]
    } cond ;

:: decode-delta ( extended extpos! bias -- extpos' delta )
    0 :> delta!
    1 :> w!
    0 :> j!
    [
        j 1 + j!
        j bias threshold :> T
        extpos extended nth decode-digit :> digit
        extpos 1 + extpos!
        digit w * delta + delta!
        BASE T - w * w!
        digit T >=
    ] loop extpos delta ;

ERROR: invalid-character char ;

:: insertion-sort ( base extended -- base )
    N :> ch!
    -1 :> pos!
    BIAS :> bias!
    0 :> extpos!
    extended length :> extlen
    [ extpos extlen < ] [
        extended extpos bias decode-delta :> ( newpos delta )
        delta 1 + pos + pos!
        pos base length 1 + /mod pos! ch + ch!
        ch 0x10FFFF > [ ch invalid-character ] when
        ch pos base insert-nth!
        delta base length extpos 0 = adapt bias!
        newpos extpos!
    ] while base ;

PRIVATE>

: punycode> ( punycode -- str )
    CHAR: - over last-index [
        ! FIXME: assert all non-basic code-points
        [ head >sbuf ] [ 1 + tail ] 2bi >upper
    ] [
        SBUF" " clone swap >upper
    ] if* insertion-sort "" like ;

GENERIC: idna> ( punycode -- obj )

M: object idna>
    "." split [
        "xn--" ?head [ punycode> ] when
    ] map "." join ;

M: url idna> [ idna> ] change-host ;

GENERIC: >idna ( obj -- punycode )

M: object >idna
    "." split [
        dup [ N < ] all? [
            >punycode "xn--" prepend
        ] unless
    ] map "." join ;

M: url >idna [ >idna ] change-host ;
