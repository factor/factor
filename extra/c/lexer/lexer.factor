! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit kernel
math.order ranges sequences sequences.generalizations
sequences.parser sorting unicode ;
IN: c.lexer

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
        sequence-parser advance drop string
    ] [
        start-n sequence-parser n<< f
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
    CHAR: \ CHAR: \" take-token* ;

: c-identifier-begin? ( ch -- ? )
    CHAR: a CHAR: z [a..b]
    CHAR: A CHAR: Z [a..b]
    { CHAR: _ } 3append member? ;

: c-identifier-ch? ( ch -- ? )
    CHAR: a CHAR: z [a..b]
    CHAR: A CHAR: Z [a..b]
    CHAR: 0 CHAR: 9 [a..b]
    { CHAR: _ } 4 nappend member? ;

: (take-c-identifier) ( sequence-parser -- string/f )
    dup current c-identifier-begin? [
        [ current c-identifier-ch? ] take-while
    ] [
        drop f
    ] if ;

: take-c-identifier ( sequence-parser -- string/f )
    [ (take-c-identifier) ] with-sequence-parser ;

: sort-tokens ( seq -- seq' ) [ length ] inv-sort-by ;

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
