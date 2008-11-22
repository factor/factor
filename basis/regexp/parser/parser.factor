! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators io io.streams.string
kernel math math.parser namespaces qualified sets
quotations sequences splitting symbols vectors math.order
unicode.categories strings regexp.backend regexp.utils
unicode.case words ;
IN: regexp.parser

FROM: math.ranges => [a,b] ;

MIXIN: node
TUPLE: concatenation seq ; INSTANCE: concatenation node
TUPLE: alternation seq ; INSTANCE: alternation node
TUPLE: kleene-star term ; INSTANCE: kleene-star node

! !!!!!!!!
TUPLE: possessive-question term ; INSTANCE: possessive-question node
TUPLE: possessive-kleene-star term ; INSTANCE: possessive-kleene-star node

! !!!!!!!!
TUPLE: reluctant-question term ; INSTANCE: reluctant-question node
TUPLE: reluctant-kleene-star term ; INSTANCE: reluctant-kleene-star node

TUPLE: negation term ; INSTANCE: negation node
TUPLE: constant char ; INSTANCE: constant node
TUPLE: range from to ; INSTANCE: range node

MIXIN: parentheses-group
TUPLE: lookahead term ; INSTANCE: lookahead node
INSTANCE: lookahead parentheses-group
TUPLE: lookbehind term ; INSTANCE: lookbehind node
INSTANCE: lookbehind parentheses-group
TUPLE: capture-group term ; INSTANCE: capture-group node
INSTANCE: capture-group parentheses-group
TUPLE: non-capture-group term ; INSTANCE: non-capture-group node
INSTANCE: non-capture-group parentheses-group
TUPLE: independent-group term ; INSTANCE: independent-group node ! atomic group
INSTANCE: independent-group parentheses-group
TUPLE: comment-group term ; INSTANCE: comment-group node
INSTANCE: comment-group parentheses-group

TUPLE: character-class-range from to ; INSTANCE: character-class-range node
SINGLETON: epsilon INSTANCE: epsilon node
SINGLETON: any-char INSTANCE: any-char node
SINGLETON: front-anchor INSTANCE: front-anchor node
SINGLETON: back-anchor INSTANCE: back-anchor node

TUPLE: option-on option ; INSTANCE: option-on node
TUPLE: option-off option ; INSTANCE: option-off node
SINGLETONS: unix-lines dotall multiline comments case-insensitive unicode-case reversed-regexp ;

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
: get-reversed-regexp ( -- ? ) reversed-regexp get-option ;

: <possessive-kleene-star> ( obj -- kleene ) possessive-kleene-star boa ;
: <reluctant-kleene-star> ( obj -- kleene ) reluctant-kleene-star boa ;
: <possessive-question> ( obj -- kleene ) possessive-question boa ;
: <reluctant-question> ( obj -- kleene ) reluctant-question boa ;

: <negation> ( obj -- negation ) negation boa ;
: <concatenation> ( seq -- concatenation )
    >vector get-reversed-regexp [ reverse ] when
    [ epsilon ] [ concatenation boa ] if-empty ;
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
        2dup <
        [ character-class-range boa ] [ 2drop unmatchable-class ] if
    ] if ;

ERROR: unmatched-parentheses ;

ERROR: bad-option ch ;

: option ( ch -- singleton )
    {
        { CHAR: i [ case-insensitive ] }
        { CHAR: d [ unix-lines ] }
        { CHAR: m [ multiline ] }
        { CHAR: n [ multiline ] }
        { CHAR: r [ reversed-regexp ] }
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

ERROR: bad-special-group string ;

DEFER: (parse-regexp)
: nested-parse-regexp ( token ? -- )
    [ push-stack (parse-regexp) pop-stack ] dip
    [ <negation> ] when pop-stack new swap >>term push-stack ;

! non-capturing groups
: (parse-special-group) ( -- )
    read1 {
        { [ dup CHAR: # = ] ! comment
            [ drop comment-group f nested-parse-regexp pop-stack drop ] }
        { [ dup CHAR: : = ]
            [ drop non-capture-group f nested-parse-regexp ] }
        { [ dup CHAR: = = ]
            [ drop lookahead f nested-parse-regexp ] }
        { [ dup CHAR: ! = ]
            [ drop lookahead t nested-parse-regexp ] }
        { [ dup CHAR: > = ]
            [ drop non-capture-group f nested-parse-regexp ] }
        { [ dup CHAR: < = peek1 CHAR: = = and ]
            [ drop drop1 lookbehind f nested-parse-regexp ] }
        { [ dup CHAR: < = peek1 CHAR: ! = and ]
            [ drop drop1 lookbehind t nested-parse-regexp ] }
        [
            ":)" read-until
            [ swap prefix ] dip
            {
                { CHAR: : [ parse-options non-capture-group f nested-parse-regexp ] }
                { CHAR: ) [ parse-options ] }
                [ drop bad-special-group ]
            } case
        ]
    } cond ;

: handle-left-parenthesis ( -- )
    peek1 CHAR: ? =
    [ drop1 (parse-special-group) ]
    [ capture-group f nested-parse-regexp ] if ;

: handle-dot ( -- ) any-char push-stack ;
: handle-pipe ( -- ) pipe push-stack ;
: (handle-star) ( obj -- kleene-star )
    peek1 {
        { CHAR: + [ drop1 <possessive-kleene-star> ] }
        { CHAR: ? [ drop1 <reluctant-kleene-star> ] }
        [ drop <kleene-star> ]
    } case ;
: handle-star ( -- ) stack pop (handle-star) push-stack ;
: handle-question ( -- )
    stack pop peek1 {
        { CHAR: + [ drop1 <possessive-question> ] }
        { CHAR: ? [ drop1 <reluctant-question> ] }
        [ drop epsilon 2array <alternation> ]
    } case push-stack ;
: handle-plus ( -- )
    stack pop dup (handle-star)
    2array <concatenation> push-stack ;

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

SINGLETON: beginning-of-input
SINGLETON: end-of-input

: newlines ( -- obj1 obj2 obj3 )
    CHAR: \r <constant>
    CHAR: \n <constant>
    2dup 2array <concatenation> ;

: beginning-of-line ( -- obj )
    beginning-of-input newlines 4array <alternation> lookbehind boa ;

: end-of-line ( -- obj )
    end-of-input newlines 4array <alternation> lookahead boa ;

: handle-front-anchor ( -- )
    get-multiline beginning-of-line beginning-of-input ? push-stack ;

: handle-back-anchor ( -- )
    get-multiline end-of-line end-of-input ? push-stack ;

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
    drop1
    [ epsilon ] [
        [ <constant> ] V{ } map-as
        first|concatenation
    ] if-empty ;

: parse-escaped ( -- obj )
    read1
    {
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

        ! { CHAR: 1 [ CHAR: 1 <constant> ] }
        ! { CHAR: 2 [ CHAR: 2 <constant> ] }
        ! { CHAR: 3 [ CHAR: 3 <constant> ] }
        ! { CHAR: 4 [ CHAR: 4 <constant> ] }
        ! { CHAR: 5 [ CHAR: 5 <constant> ] }
        ! { CHAR: 6 [ CHAR: 6 <constant> ] }
        ! { CHAR: 7 [ CHAR: 7 <constant> ] }
        ! { CHAR: 8 [ CHAR: 8 <constant> ] }
        ! { CHAR: 9 [ CHAR: 9 <constant> ] }

        { CHAR: Q [ parse-escaped-literals ] }
        [ <constant> ]
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
    { pipe } split
    [ first|concatenation ] map first|alternation ;

: handle-right-parenthesis ( -- )
    stack dup [ parentheses-group "members" word-prop member? ] find-last -rot cut rest
    [ [ push ] keep current-regexp get (>>stack) ]
    [ finish-regexp-parse push-stack ] bi* ;

: parse-regexp-token ( token -- ? )
    {
        { CHAR: ( [ handle-left-parenthesis t ] } ! handle (?..) at beginning?
        { CHAR: ) [ handle-right-parenthesis f ] }
        { CHAR: . [ handle-dot t ] }
        { CHAR: | [ handle-pipe t ] }
        { CHAR: ? [ handle-question t ] }
        { CHAR: * [ handle-star t ] }
        { CHAR: + [ handle-plus t ] }
        { CHAR: { [ handle-left-brace t ] }
        { CHAR: [ [ handle-left-bracket t ] }
        { CHAR: \ [ handle-escape t ] }
        [
            dup CHAR: $ = peek1 f = and [
                drop
                handle-back-anchor f
            ] [
                <constant> push-stack t
            ] if
        ]
    } case ;

: (parse-regexp) ( -- )
    read1 [ parse-regexp-token [ (parse-regexp) ] when ] when* ;

: parse-regexp-beginning ( -- )
    peek1 CHAR: ^ = [ drop1 handle-front-anchor ] when ;

: parse-regexp ( regexp -- )
    dup current-regexp [
        raw>> [
            <string-reader> [
                parse-regexp-beginning (parse-regexp)
            ] with-input-stream
        ] unless-empty
        current-regexp get
        stack finish-regexp-parse
            >>parse-tree drop
    ] with-variable ;
