! Copyright (C) 2020 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs byte-arrays combinators
io.encodings.string io.encodings.utf8 kernel lexer linked-assocs
literals locals make math math.order math.parser multiline
namespaces peg.ebnf present prettyprint.backend
prettyprint.custom prettyprint.sections regexp sbufs sequences
sequences.extras sequences.generalizations sets sorting
splitting strings strings.parser urls urls.encoding
urls.encoding.private urls.private ;

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
    [ N < ] partition members natural-sort ;

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

:: decode-digit ( ch -- digit )
    {
        { [ ch CHAR: A CHAR: Z between? ] [ ch CHAR: A - ] }
        { [ ch CHAR: 0 CHAR: 9 between? ] [ ch CHAR: 0 26 - - ] }
        [ ch invalid-digit ]
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

: idna> ( punycode -- str )
    "." split [
        "xn--" ?head [ punycode> ] when
    ] map "." join ;

: >idna ( str -- punycode )
    "." split [
        dup [ N < ] all? [
            >punycode "xn--" prepend
        ] unless
    ] map "." join ;

TUPLE: irl < url ;

: <irl> ( -- irl ) irl new ;

GENERIC: >irl ( obj -- irl )

M: f >irl drop <irl> ;

<PRIVATE

: irl-decode ( str -- str' )
    "" like R/ (%[a-fA-F0-9]{2})+/ [ url-decode ] re-replace-with ;

: iquery-decode ( str -- decoded )
    "+" split "%20" join irl-decode ;

: iquery>assoc ( query -- assoc )
    dup [
        "&;" split <linked-hash> [
            [
                [ "=" split1 [ dup [ iquery-decode ] when ] bi@ swap ] dip
                add-query-param
            ] curry each
        ] keep
    ] when ;

: assoc>iquery ( assoc -- str )
    [
        [
            [
                dup array? [ 1array ] unless
                [ "=" glue , ] with each
            ] [ , ] if*
        ] assoc-each
    ] { } make "&" join ;

! RFC 3987
EBNF: parse-irl [=[

protocol = [a-zA-Z0-9.+-]+ => [[ irl-decode ]]
username = [^/:@#?]+       => [[ irl-decode ]]
password = [^/:@#?]+       => [[ irl-decode ]]
path     = [^#?]+          => [[ irl-decode ]]
query    = [^#]+           => [[ iquery>assoc ]]
anchor   = .+              => [[ irl-decode ]]
hostname = [^/#?:]+        => [[ irl-decode ]]
port     = [^/#?]+         => [[ url-decode parse-port ]]

auth     = username (":"~ password)? "@"~
host     = hostname (":"~ port)?

url      = (protocol ":"~)?
           ("//"~ auth? host?)?
           path?
           ("?"~ query)?
           ("#"~ anchor)?

]=]

: unparse-ihost-part ( url -- )
    {
        [ unparse-username-password ]
        [ host>> % ]
        [ url-port [ ":" % # ] when* ]
        [ path>> "/" head? [ "/" % ] unless ]
    } cleave ;

: unparse-iauthority ( url -- )
    dup host>> [ "//" % unparse-ihost-part ] [ drop ] if ;

M: irl present
    [
        {
            [ unparse-protocol ]
            [ unparse-iauthority ]
            [ path>> % ]
            [ query>> dup assoc-empty? [ drop ] [ "?" % assoc>iquery % ] if ]
            [ anchor>> [ "#" % present % ] when* ]
        } cleave
    ] "" make ;

PRIVATE>

M: string >irl
    [ <irl> ] dip parse-irl 5 firstn {
        [ >lower >>protocol ]
        [
            [
                [ first [ first2 [ >>username ] [ >>password ] bi* ] when* ]
                [ second [ first2 [ >>host ] [ >>port ] bi* ] when* ] bi
            ] when*
        ]
        [ >>path ]
        [ >>query ]
        [ >>anchor ]
    } spread dup host>> [ [ "/" or ] change-path ] when ;

M: irl >url
    [ <url> ] dip {
        [ protocol>> >>protocol ]
        [ username>> >>username ]
        [ password>> >>password ]
        [ host>> [ >idna ] [ f ] if* >>host ]
        [ port>> >>port ]
        [ path>> >>path ]
        [ query>> >>query ]
        [ anchor>> >>anchor ]
    } cleave ;

M: url >irl
    [ <irl> ] dip {
        [ protocol>> >>protocol ]
        [ username>> >>username ]
        [ password>> >>password ]
        [ host>> [ idna> ] [ f ] if* >>host ]
        [ port>> >>port ]
        [ path>> >>path ]
        [ query>> >>query ]
        [ anchor>> >>anchor ]
    } cleave ;

SYNTAX: IRL" lexer get skip-blank parse-string >irl suffix! ;

M: irl pprint*
    \ IRL" record-vocab
    dup present "IRL\" " "\"" pprint-string ;
