! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
io.directories io.files io.files.info io.pathnames kernel
make peg.ebnf regexp regexp.combinators sequences strings system
unicode multiline ;
IN: globs

: not-path-separator ( -- sep )
    os windows? R/ [^\/\\]/ R/ [^\/]/ ? ; foldable

: wild-path-separator ( -- sep )
    os windows? R/ [^\/\\][\/\\]|[^\/\\]/ R/ [^\/][\/]|[^\/]/ ? ; foldable

EBNF: <glob> [=[

Character = "\\" .:c => [[ c 1string <literal> ]]
          | !(","|"}") . => [[ 1string <literal> ]]

RangeCharacter = !("]") .

Range = RangeCharacter:a "-" RangeCharacter:b => [[ a b <char-range> ]]
      | RangeCharacter => [[ 1string <literal> ]]

StartRange = .:a "-" RangeCharacter:b => [[ a b <char-range> ]]
           | . => [[ 1string <literal> ]]

Ranges = StartRange:s Range*:r => [[ r s prefix ]]

CharClass = "^"?:n Ranges:e => [[ e <or> n [ <not> ] when ]]

AlternationBody = Concatenation:c "," AlternationBody:a => [[ a c prefix ]]
                | Concatenation => [[ 1array ]]

Element = "**" => [[ wild-path-separator <zero-or-more> ]]
        | "*" => [[ not-path-separator <zero-or-more> ]]
        | "?" => [[ not-path-separator ]]
        | "[" CharClass:c "]" => [[ c ]]
        | "{" AlternationBody:b "}" => [[ b <or> ]]
        | Character

Concatenation = Element* => [[ <sequence> ]]

End = !(.)

Main = Concatenation End

]=]

: glob-matches? ( input glob -- ? )
    [ >case-fold ] bi@ <glob> matches? ;

: glob-pattern? ( string -- ? )
    [ "\\*?[{" member? ] any? ;

<PRIVATE

! TODO: simplify
! TODO: handle two more test cases
! TODO: make case-fold an option, off by default
! TODO: maybe make case-fold an option on regexp

DEFER: glob%

: glob-entries ( path -- entries )
    directory-entries [ name>> "." head? ] reject ;

: ?glob% ( root remaining entry -- )
    over empty? [
        2drop ,
    ] [
        directory? [ glob% ] [ 2drop ] if
    ] if ;

:: glob-wildcard% ( root globs -- )
    globs ?second :> next-glob
    next-glob dup pair? [ second ] [ drop f ] if :> next-glob-regexp

    root glob-entries [| entry |
        root entry name>> append-path
        {
            { [ next-glob not ] [ dup , ] }
            { [ next-glob empty? ] [ entry directory? [ dup , ] when ] }
            [
                next-glob-regexp [
                    entry name>> >case-fold next-glob-regexp matches?
                ] [
                    {
                        [ next-glob "**" = ]
                        [ entry name>> next-glob = ]
                    } 0||
                ] if [
                    globs 2 tail [
                         dup ,
                    ] [
                        entry directory? [
                            dupd glob%
                        ] [
                            drop
                        ] if
                    ] if-empty
                ] when
            ]
        } cond

        { [ entry directory? ] [ next-glob ] } 0&& [
            globs glob%
        ] [
            drop
        ] if
    ] each ;

:: glob-pattern% ( root globs -- )
    globs unclip second :> ( remaining glob )

    root glob-entries [| entry |
        entry name>> >case-fold glob matches? [
            root entry name>> append-path
            remaining entry ?glob%
        ] when
    ] each ;

:: glob-literal% ( root globs -- )
    globs unclip :> ( remaining glob )

    root glob append-path [
        remaining over file-info ?glob%
    ] when-file-exists ;

: glob% ( root globs -- )
    dup ?first {
        { f [ 2drop ] }
        { "**" [ glob-wildcard% ] }
        [ pair? [ glob-pattern% ] [ glob-literal% ] if ]
    } case ;

: split-glob ( glob -- path globs )
    { } [
        over glob-pattern?
    ] [
        [
            dup [ path-separator? ] find-last drop
            [ cut rest ] [ "" swap ] if*
        ] dip swap prefix
    ] while ;

: glob-path ( glob -- path globs )
    split-glob [
        dup { [ "**" = not ] [ glob-pattern? ] } 1&& [
            dup >case-fold <glob> 2array
        ] when
    ] map ;

PRIVATE>

: glob ( glob -- files )
    glob-path [
        [ 1array f swap ] when-empty glob%
    ] { } make ;
