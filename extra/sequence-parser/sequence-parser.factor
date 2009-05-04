! Copyright (C) 2005, 2009 Daniel Ehrenberg, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math kernel sequences accessors fry circular
unicode.case unicode.categories locals combinators.short-circuit
make combinators io splitting math.parser math.ranges
generalizations sorting.functor math.order sorting.slots ;
IN: sequence-parser

TUPLE: sequence-parser sequence n ;

: <sequence-parser> ( sequence -- sequence-parser )
    sequence-parser new
        swap >>sequence
        0 >>n ;

:: with-sequence-parser ( sequence-parser quot -- seq/f )
    sequence-parser n>> :> n
    sequence-parser quot call [
        n sequence-parser (>>n) f
    ] unless* ; inline

: offset  ( sequence-parser offset -- char/f )
    swap
    [ n>> + ] [ sequence>> ?nth ] bi ; inline

: current ( sequence-parser -- char/f ) 0 offset ; inline

: previous ( sequence-parser -- char/f ) -1 offset ; inline

: peek-next ( sequence-parser -- char/f ) 1 offset ; inline

: advance ( sequence-parser -- sequence-parser )
    [ 1 + ] change-n ; inline

: advance* ( sequence-parser -- )
    advance drop ; inline

: get+increment ( sequence-parser -- char/f )
    [ current ] [ advance drop ] bi ; inline

:: skip-until ( sequence-parser quot: ( obj -- ? ) -- )
    sequence-parser current [
        sequence-parser quot call
        [ sequence-parser advance quot skip-until ] unless
    ] when ; inline recursive

: sequence-parse-end? ( sequence-parser -- ? ) current not ;

: take-until ( sequence-parser quot: ( obj -- ? ) -- sequence/f )
    over sequence-parse-end? [
        2drop f
    ] [
        [ drop n>> ]
        [ skip-until ]
        [ drop [ n>> ] [ sequence>> ] bi ] 2tri subseq f like
    ] if ; inline

: take-while ( sequence-parser quot: ( obj -- ? ) -- sequence/f )
    [ not ] compose take-until ; inline

: <safe-slice> ( from to seq -- slice/f )
    3dup {
        [ 2drop 0 < ]
        [ [ drop ] 2dip length > ]
        [ drop > ]
    } 3|| [ 3drop f ] [ slice boa ] if ; inline

:: take-sequence ( sequence-parser sequence -- obj/f )
    sequence-parser [ n>> dup sequence length + ] [ sequence>> ] bi
    <safe-slice> sequence sequence= [
        sequence
        sequence-parser [ sequence length + ] change-n drop
    ] [
        f
    ] if ;

: take-sequence* ( sequence-parser sequence -- )
    take-sequence drop ;

:: take-until-sequence ( sequence-parser sequence -- sequence'/f )
    sequence-parser n>> :> saved
    sequence length <growing-circular> :> growing
    sequence-parser
    [
        current growing push-growing-circular
        sequence growing sequence=
    ] take-until :> found
    growing sequence sequence= [
        found dup length
        growing length 1- - head
        sequence-parser [ growing length - 1 + ] change-n drop
        ! sequence-parser advance drop
    ] [
        saved sequence-parser (>>n)
        f
    ] if ;

:: take-until-sequence* ( sequence-parser sequence -- sequence'/f )
    sequence-parser sequence take-until-sequence :> out
    out [
        sequence-parser [ sequence length + ] change-n drop
    ] when out ;

: skip-whitespace ( sequence-parser -- sequence-parser )
    [ [ current blank? not ] take-until drop ] keep ;

: skip-whitespace-eol ( sequence-parser -- sequence-parser )
    [ [ current " \t\r" member? not ] take-until drop ] keep ;

: take-c-comment ( sequence-parser -- seq/f )
    [
        dup "/*" take-sequence [
            "*/" take-until-sequence*
        ] [
            drop f
        ] if
    ] with-sequence-parser ;

: take-c++-comment ( sequence-parser -- seq/f )
    [
        dup "//" take-sequence [
            [
                [
                    { [ current CHAR: \n = ] [ sequence-parse-end? ] } 1||
                ] take-until
            ] [
                advance drop
            ] bi
        ] [
            drop f
        ] if
    ] with-sequence-parser ;

: skip-whitespace/comments ( sequence-parser -- sequence-parser )
    skip-whitespace-eol
    {
        { [ dup take-c-comment ] [ skip-whitespace/comments ] }
        { [ dup take-c++-comment ] [ skip-whitespace/comments ] }
        [ ]
    } cond ;

: take-define-identifier ( sequence-parser -- string )
    skip-whitespace/comments
    [ current { [ blank? ] [ CHAR: ( = ] } 1|| ] take-until ;

: take-rest-slice ( sequence-parser -- sequence/f )
    [ sequence>> ] [ n>> ] bi
    2dup [ length ] dip < [ 2drop f ] [ tail-slice ] if ; inline

: take-rest ( sequence-parser -- sequence )
    [ take-rest-slice ] [ sequence>> like ] bi ;

: take-until-object ( sequence-parser obj -- sequence )
    '[ current _ = ] take-until ;

: parse-sequence ( sequence quot -- )
    [ <sequence-parser> ] dip call ; inline

:: take-quoted-string ( sequence-parser escape-char quote-char -- string )
    sequence-parser n>> :> start-n
    sequence-parser advance
    [
        {
            [ { [ previous escape-char = ] [ current quote-char = ] } 1&& ]
            [ current quote-char = not ]
        } 1||
    ] take-while :> string
    sequence-parser current quote-char = [
        sequence-parser advance* string
    ] [
        start-n sequence-parser (>>n) f
    ] if ;

: (take-token) ( sequence-parser -- string )
    skip-whitespace [ current { [ blank? ] [ f = ] } 1|| ] take-until ;

:: take-token* ( sequence-parser escape-char quote-char -- string/f )
    sequence-parser skip-whitespace
    dup current {
        { quote-char [ escape-char quote-char take-quoted-string ] }
        { f [ drop f ] }
        [ drop (take-token) ]
    } case ;

: take-token ( sequence-parser -- string/f )
    CHAR: \ CHAR: " take-token* ;

: take-integer ( sequence-parser -- n/f )
    [ current digit? ] take-while ;

:: take-n ( sequence-parser n -- seq/f )
    n sequence-parser [ n>> + ] [ sequence>> length ] bi > [
        f
    ] [
        sequence-parser n>> dup n + sequence-parser sequence>> subseq
        sequence-parser [ n + ] change-n drop
    ] if ;

: c-identifier-begin? ( ch -- ? )
    CHAR: a CHAR: z [a,b]
    CHAR: A CHAR: Z [a,b]
    { CHAR: _ } 3append member? ;

: c-identifier-ch? ( ch -- ? )
    CHAR: a CHAR: z [a,b]
    CHAR: A CHAR: Z [a,b]
    CHAR: 0 CHAR: 9 [a,b]
    { CHAR: _ } 4 nappend member? ;

: (take-c-identifier) ( sequence-parser -- string/f )
    dup current c-identifier-begin? [
        [ current c-identifier-ch? ] take-while
    ] [
        drop f
    ] if ;

: take-c-identifier ( sequence-parser -- string/f )
    [ (take-c-identifier) ] with-sequence-parser ;

<< "length" [ length ] define-sorting >>

: sort-tokens ( seq -- seq' )
    { length>=< <=> } sort-by ;

: take-first-matching ( sequence-parser seq -- seq )
    swap
    '[ _ [ swap take-sequence ] with-sequence-parser ] find nip ;


: take-longest ( sequence-parser seq -- seq )
    sort-tokens take-first-matching ;

: take-c-integer ( sequence-parser -- string/f )
    [
        dup take-integer [
            swap
            { "ull" "uLL" "Ull" "ULL" "ll" "LL" "l" "L" "u" "U" }
            take-longest [ append ] when*
        ] [
            drop f
        ] if*
    ] with-sequence-parser ;

CONSTANT: c-punctuators
    {
        "[" "]" "(" ")" "{" "}" "." "->"
        "++" "--" "&" "*" "+" "-" "~" "!"
        "/" "%" "<<" ">>" "<" ">" "<=" ">=" "==" "!=" "^" "|" "&&" "||"
        "?" ":" ";" "..."
        "=" "*=" "/=" "%=" "+=" "-=" "<<=" ">>=" "&=" "^=" "|="
        "," "#" "##"
        "<:" ":>" "<%" "%>" "%:" "%:%:"
    }

: take-c-punctuator ( sequence-parser -- string/f )
    c-punctuators take-longest ;

: write-full ( sequence-parser -- ) sequence>> write ;
: write-rest ( sequence-parser -- ) take-rest write ;
