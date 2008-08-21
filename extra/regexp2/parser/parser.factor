! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators io io.streams.string
kernel math math.parser multi-methods namespaces qualified sets
quotations sequences sequences.lib splitting symbols vectors
dlists math.order combinators.lib unicode.categories strings
sequences.lib regexp2.backend regexp2.utils unicode.case ;
IN: regexp2.parser

FROM: math.ranges => [a,b] ;

MIXIN: node
TUPLE: concatenation seq ; INSTANCE: concatenation node
TUPLE: alternation seq ; INSTANCE: alternation node
TUPLE: kleene-star term ; INSTANCE: kleene-star node
TUPLE: question term ; INSTANCE: question node
TUPLE: negation term ; INSTANCE: negation node
TUPLE: constant char ; INSTANCE: constant node
TUPLE: range from to ; INSTANCE: range node
TUPLE: lookahead term ; INSTANCE: lookahead node
TUPLE: lookbehind term ; INSTANCE: lookbehind node
TUPLE: capture-group term ; INSTANCE: capture-group node
TUPLE: non-capture-group term ; INSTANCE: non-capture-group node
TUPLE: independent-group term ; INSTANCE: independent-group node
TUPLE: character-class-range from to ; INSTANCE: character-class-range node
SINGLETON: epsilon INSTANCE: epsilon node
SINGLETON: any-char INSTANCE: any-char node
SINGLETON: front-anchor INSTANCE: front-anchor node
SINGLETON: back-anchor INSTANCE: back-anchor node

TUPLE: option-on option ; INSTANCE: option-on node
TUPLE: option-off option ; INSTANCE: option-off node
SINGLETONS: unix-lines dotall multiline comments case-insensitive unicode-case ;

SINGLETONS: letter-class LETTER-class Letter-class digit-class
alpha-class non-newline-blank-class
ascii-class punctuation-class java-printable-class blank-class
control-character-class hex-digit-class java-blank-class c-identifier-class
unmatchable-class ;

SINGLETONS: beginning-of-group end-of-group
beginning-of-character-class end-of-character-class
left-parenthesis pipe caret dash ;

: get-option ( option -- ? ) current-regexp get options>> at ;
: get-unix-lines ( -- ? ) unix-lines get-option ;
: get-dotall ( -- ? ) dotall get-option ;
: get-multiline ( -- ? ) multiline get-option ;
: get-comments ( -- ? ) comments get-option ;
: get-case-insensitive ( -- ? ) case-insensitive get-option ;
: get-unicode-case ( -- ? ) unicode-case get-option ;

: <negation> ( obj -- negation ) negation boa ;
: <concatenation> ( seq -- concatenation ) >vector concatenation boa ;
: <alternation> ( seq -- alternation ) >vector alternation boa ;
: <capture-group> ( obj -- capture-group ) capture-group boa ;
: <kleene-star> ( obj -- kleene-star ) kleene-star boa ;
: <constant> ( obj -- constant )
    dup Letter? get-case-insensitive and [
        [ ch>lower constant boa ]
        [ ch>upper constant boa ] bi 2array <alternation>
    ] [
        constant boa
    ] if ;

: first|concatenation ( seq -- first/concatenation )
    dup length 1 = [ first ] [ <concatenation> ] if ;

: first|alternation ( seq -- first/alternation )
    dup length 1 = [ first ] [ <alternation> ] if ;

: <character-class-range> ( from to -- obj )
    2dup [ Letter? ] bi@ or get-case-insensitive and [
        [ [ ch>lower ] bi@ character-class-range boa ]
        [ [ ch>upper ] bi@ character-class-range boa ] 2bi
        2array [ [ from>> ] [ to>> ] bi < ] filter
        [ unmatchable-class ] [ first|alternation ] if-empty
    ] [
        dup [ from>> ] [ to>> ] bi <
        [ character-class-range boa ] [ 2drop unmatchable-class ] if
    ] if ;

ERROR: unmatched-parentheses ;

: make-positive-lookahead ( string -- )
    lookahead boa push-stack ;

: make-negative-lookahead ( string -- )
    <negation> lookahead boa push-stack ;

: make-independent-group ( string -- )
    #! no backtracking
    independent-group boa push-stack ;

: make-positive-lookbehind ( string -- )
    lookbehind boa push-stack ;

: make-negative-lookbehind ( string -- )
    <negation> lookbehind boa push-stack ;

DEFER: nested-parse-regexp
: make-non-capturing-group ( string -- )
    non-capture-group boa push-stack ;

ERROR: bad-option ch ;

: option ( ch -- singleton )
    {
        { CHAR: i [ case-insensitive ] }
        { CHAR: d [ unix-lines ] }
        { CHAR: m [ multiline ] }
        { CHAR: s [ dotall ] }
        { CHAR: u [ unicode-case ] }
        { CHAR: x [ comments ] }
        [ bad-option ]
    } case ;

: option-on ( option -- ) current-regexp get options>> conjoin ;
: option-off ( option -- ) current-regexp get options>> delete-at ;

: toggle-option ( ch ? -- ) [ option ] dip [ option-on ] [ option-off ] if ;
: (parse-options) ( string ? -- ) [ toggle-option ] curry each ;

: parse-options ( string -- )
    "-" split1 [ t (parse-options) ] [ f (parse-options) ] bi* ;

DEFER: (parse-regexp)
: parse-special-group ( -- )
    beginning-of-group push-stack
    (parse-regexp) pop-stack make-non-capturing-group ;

ERROR: bad-special-group string ;

: (parse-special-group) ( -- )
    read1 {
        { [ dup CHAR: : = ]
            [ drop nested-parse-regexp pop-stack make-non-capturing-group ] }
        { [ dup CHAR: = = ]
            [ drop nested-parse-regexp pop-stack make-positive-lookahead ] }
        { [ dup CHAR: = = ]
            [ drop nested-parse-regexp pop-stack make-negative-lookahead ] }
        { [ dup CHAR: > = ]
            [ drop nested-parse-regexp pop-stack make-independent-group ] }
        { [ dup CHAR: < = peek1 CHAR: = = and ]
            [ drop read1 drop nested-parse-regexp pop-stack make-positive-lookbehind ] }
        { [ dup CHAR: < = peek1 CHAR: ! = and ]
            [ drop read1 drop nested-parse-regexp pop-stack make-negative-lookbehind ] }
        [
            ":)" read-until
            [ swap prefix ] dip
            {
                { CHAR: : [ parse-options parse-special-group ] }
                { CHAR: ) [ parse-options ] }
                [ drop bad-special-group ]
            } case
        ]
    } cond ;

: handle-left-parenthesis ( -- )
    peek1 CHAR: ? =
    [ read1 drop (parse-special-group) ]
    [ nested-parse-regexp ] if ;

: handle-dot ( -- ) any-char push-stack ;
: handle-pipe ( -- ) pipe push-stack ;
: handle-star ( -- ) stack pop <kleene-star> push-stack ;
: handle-question ( -- )
    stack pop epsilon 2array <alternation> push-stack ;
: handle-plus ( -- )
    stack pop dup <kleene-star> 2array <concatenation> push-stack ;

ERROR: unmatched-brace ;
: parse-repetition ( -- start finish ? )
    "}" read-until [ unmatched-brace ] unless
    [ "," split1 [ string>number ] bi@ ]
    [ CHAR: , swap index >boolean ] bi ;

: replicate/concatenate ( n obj -- obj' )
    over zero? [ 2drop epsilon ]
    [ <repetition> first|concatenation ] if ;

: exactly-n ( n -- )
    stack pop replicate/concatenate push-stack ;

: at-least-n ( n -- )
    stack pop
    [ replicate/concatenate ] keep
    <kleene-star> 2array <concatenation> push-stack ;

: at-most-n ( n -- )
    1+
    stack pop
    [ replicate/concatenate ] curry map <alternation> push-stack ;

: from-m-to-n ( m n -- )
    [a,b]
    stack pop
    [ replicate/concatenate ] curry map
    <alternation> push-stack ;

ERROR: invalid-range a b ;

: handle-left-brace ( -- )
    parse-repetition
    >r 2dup [ [ 0 < [ invalid-range ] when ] when* ] bi@ r>
    [
        2dup and [ from-m-to-n ]
        [ [ nip at-most-n ] [ at-least-n ] if* ] if
    ] [ drop 0 max exactly-n ] if ;

: handle-front-anchor ( -- ) front-anchor push-stack ;
: handle-back-anchor ( -- ) back-anchor push-stack ;

ERROR: bad-character-class obj ;
ERROR: expected-posix-class ;

: parse-posix-class ( -- obj )
    read1 CHAR: { = [ expected-posix-class ] unless
    "}" read-until [ bad-character-class ] unless
    {
        { "Lower" [ get-case-insensitive Letter-class letter-class ? ] }
        { "Upper" [ get-case-insensitive Letter-class LETTER-class ? ] }
        { "Alpha" [ Letter-class ] }
        { "ASCII" [ ascii-class ] }
        { "Digit" [ digit-class ] }
        { "Alnum" [ alpha-class ] }
        { "Punct" [ punctuation-class ] }
        { "Graph" [ java-printable-class ] }
        { "Print" [ java-printable-class ] }
        { "Blank" [ non-newline-blank-class ] }
        { "Cntrl" [ control-character-class ] }
        { "XDigit" [ hex-digit-class ] }
        { "Space" [ java-blank-class ] }
        ! TODO: unicode-character-class, fallthrough in unicode is bad-char-clss
        [ bad-character-class ]
    } case ;

: parse-octal ( -- n ) 3 read oct> check-octal ;
: parse-short-hex ( -- n ) 2 read hex> check-hex ;
: parse-long-hex ( -- n ) 6 read hex> check-hex ;
: parse-control-character ( -- n ) read1 ;

ERROR: bad-escaped-literals seq ;
: parse-escaped-literals ( -- obj )
    "\\E" read-until [ bad-escaped-literals ] unless
    read1 drop
    [ epsilon ] [
        [ <constant> ] V{ } map-as
        first|concatenation
    ] if-empty ;

: parse-escaped ( -- obj )
    read1
    {
        { CHAR: \ [ CHAR: \ <constant> ] }
        { CHAR: . [ CHAR: . <constant> ] }
        { CHAR: t [ CHAR: \t <constant> ] }
        { CHAR: n [ CHAR: \n <constant> ] }
        { CHAR: r [ CHAR: \r <constant> ] }
        { CHAR: f [ HEX: c <constant> ] }
        { CHAR: a [ HEX: 7 <constant> ] }
        { CHAR: e [ HEX: 1b <constant> ] }

        { CHAR: d [ digit-class ] }
        { CHAR: D [ digit-class <negation> ] }
        { CHAR: s [ java-blank-class ] }
        { CHAR: S [ java-blank-class <negation> ] }
        { CHAR: w [ c-identifier-class ] }
        { CHAR: W [ c-identifier-class <negation> ] }

        { CHAR: p [ parse-posix-class ] }
        { CHAR: P [ parse-posix-class <negation> ] }
        { CHAR: x [ parse-short-hex <constant> ] }
        { CHAR: u [ parse-long-hex <constant> ] }
        { CHAR: 0 [ parse-octal <constant> ] }
        { CHAR: c [ parse-control-character ] }

        ! { CHAR: b [ handle-word-boundary ] }
        ! { CHAR: B [ handle-word-boundary <negation> ] }
        ! { CHAR: A [ handle-beginning-of-input ] }
        ! { CHAR: G [ end of previous match ] }
        ! { CHAR: Z [ handle-end-of-input ] }
        ! { CHAR: z [ handle-end-of-input ] } ! except for terminator

        { CHAR: Q [ parse-escaped-literals ] }
    } case ;

: handle-escape ( -- ) parse-escaped push-stack ;

: handle-dash ( vector -- vector' )
    H{ { dash CHAR: - } } substitute ;

: character-class>alternation ( seq -- alternation )
    [ dup number? [ <constant> ] when ] map first|alternation ;

: handle-caret ( vector -- vector' )
    dup [ length 2 >= ] [ first caret eq? ] bi and [
        rest-slice character-class>alternation <negation>
    ] [
        character-class>alternation
    ] if ;

: make-character-class ( -- character-class )
    [ beginning-of-character-class swap cut-stack ] change-whole-stack
    handle-dash handle-caret ;

: apply-dash ( -- )
    stack [ pop3 nip <character-class-range> ] keep push ;

: apply-dash? ( -- ? )
    stack dup length 3 >=
    [ [ length 2 - ] keep nth dash eq? ] [ drop f ] if ;

ERROR: empty-negated-character-class ;
DEFER: handle-left-bracket
: (parse-character-class) ( -- )
    read1 [ empty-negated-character-class ] unless* {
        { CHAR: [ [ handle-left-bracket t ] }
        { CHAR: ] [ make-character-class push-stack f ] }
        { CHAR: - [ dash push-stack t ] }
        { CHAR: \ [ parse-escaped push-stack t ] }
        [ push-stack apply-dash? [ apply-dash ] when t ]
    } case
    [ (parse-character-class) ] when ;

: parse-character-class-second ( -- )
    read1 {
        { CHAR: [ [ CHAR: [ <constant> push-stack ] }
        { CHAR: ] [ CHAR: ] <constant> push-stack ] }
        { CHAR: - [ CHAR: - <constant> push-stack ] }
        [ push1 ]
    } case ;

: parse-character-class-first ( -- )
    read1 {
        { CHAR: ^ [ caret push-stack parse-character-class-second ] }
        { CHAR: [ [ CHAR: [ <constant> push-stack ] }
        { CHAR: ] [ CHAR: ] <constant> push-stack ] }
        { CHAR: - [ CHAR: - <constant> push-stack ] }
        [ push1 ]
    } case ;

: handle-left-bracket ( -- )
    beginning-of-character-class push-stack
    parse-character-class-first (parse-character-class) ;

: finish-regexp-parse ( stack -- obj )
    dup length {
        { 1 [ first ] }
        [
            drop { pipe } split
            [ first|concatenation ] map first|alternation
        ]
    } case ;

: handle-right-parenthesis ( -- )
    stack beginning-of-group over last-index cut rest
    [ current-regexp get swap >>stack drop ]
    [ finish-regexp-parse <capture-group> push-stack ] bi* ;

: nested-parse-regexp ( -- )
    beginning-of-group push-stack (parse-regexp) ;

: ((parse-regexp)) ( token -- )
    {
        { CHAR: . [ handle-dot ] }
        { CHAR: ( [ handle-left-parenthesis ] }
        { CHAR: ) [ handle-right-parenthesis ] }
        { CHAR: | [ handle-pipe ] }
        { CHAR: ? [ handle-question ] }
        { CHAR: * [ handle-star ] }
        { CHAR: + [ handle-plus ] }
        { CHAR: { [ handle-left-brace ] }
        { CHAR: [ [ handle-left-bracket ] }
        { CHAR: ^ [ handle-front-anchor ] }
        { CHAR: $ [ handle-back-anchor ] }
        { CHAR: \ [ handle-escape ] }
        [ <constant> push-stack ]
    } case ;

: (parse-regexp) ( -- )
    read1 [ ((parse-regexp)) (parse-regexp) ] when* ;

: parse-regexp ( regexp -- )
    dup current-regexp [
        raw>> [
            <string-reader> [ (parse-regexp) ] with-input-stream
        ] unless-empty
        current-regexp get
        stack finish-regexp-parse
            >>parse-tree drop
    ] with-variable ;
