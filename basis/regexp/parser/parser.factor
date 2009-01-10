! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators io io.streams.string
kernel math math.parser namespaces sets
quotations sequences splitting vectors math.order
strings regexp.backend regexp.utils
unicode.case unicode.categories words locals regexp.classes ;
IN: regexp.parser

FROM: math.ranges => [a,b] ;

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

SINGLETON: epsilon INSTANCE: epsilon node

TUPLE: option option on? ; INSTANCE: option node

SINGLETONS: unix-lines dotall multiline comments case-insensitive
unicode-case reversed-regexp ;

SINGLETONS: beginning-of-character-class end-of-character-class
left-parenthesis pipe caret dash ;

: push1 ( obj -- ) input-stream get stream>> push ;
: peek1 ( -- obj ) input-stream get stream>> [ f ] [ peek ] if-empty ;
: pop3 ( seq -- obj1 obj2 obj3 ) [ pop ] [ pop ] [ pop ] tri spin ;
: drop1 ( -- ) read1 drop ;

: stack ( -- obj ) current-regexp get stack>> ;
: change-whole-stack ( quot -- )
    current-regexp get
    [ stack>> swap call ] keep (>>stack) ; inline
: push-stack ( obj -- ) stack push ;
: pop-stack ( -- obj ) stack pop ;
: cut-out ( vector n -- vector' vector ) cut rest ;
ERROR: cut-stack-error ;
: cut-stack ( obj vector -- vector' vector )
    tuck last-index [ cut-stack-error ] unless* cut-out swap ;

: <possessive-kleene-star> ( obj -- kleene ) possessive-kleene-star boa ;
: <reluctant-kleene-star> ( obj -- kleene ) reluctant-kleene-star boa ;
: <possessive-question> ( obj -- kleene ) possessive-question boa ;
: <reluctant-question> ( obj -- kleene ) reluctant-question boa ;

: <negation> ( obj -- negation ) negation boa ;
: <concatenation> ( seq -- concatenation )
    >vector [ epsilon ] [ concatenation boa ] if-empty ;
: <alternation> ( seq -- alternation ) >vector alternation boa ;
: <capture-group> ( obj -- capture-group ) capture-group boa ;
: <kleene-star> ( obj -- kleene-star ) kleene-star boa ;
: <constant> ( obj -- constant ) constant boa ;

: first|concatenation ( seq -- first/concatenation )
    dup length 1 = [ first ] [ <concatenation> ] if ;

: first|alternation ( seq -- first/alternation )
    dup length 1 = [ first ] [ <alternation> ] if ;

: <character-class-range> ( from to -- obj )
    2dup <
    [ character-class-range boa ] [ 2drop unmatchable-class ] if ;

ERROR: unmatched-parentheses ;

ERROR: unknown-regexp-option option ;

: ch>option ( ch -- singleton )
    {
        { CHAR: i [ case-insensitive ] }
        { CHAR: d [ unix-lines ] }
        { CHAR: m [ multiline ] }
        { CHAR: n [ multiline ] }
        { CHAR: r [ reversed-regexp ] }
        { CHAR: s [ dotall ] }
        { CHAR: u [ unicode-case ] }
        { CHAR: x [ comments ] }
        [ unknown-regexp-option ]
    } case ;

: option>ch ( option -- string )
    {
        { case-insensitive [ CHAR: i ] }
        { multiline [ CHAR: m ] }
        { reversed-regexp [ CHAR: r ] }
        { dotall [ CHAR: s ] }
        [ unknown-regexp-option ]
    } case ;

: toggle-option ( ch ? -- ) 
    [ ch>option ] dip option boa push-stack ;

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
    [ 2dup [ [ 0 < [ invalid-range ] when ] when* ] bi@ ] dip
    [
        2dup and [ from-m-to-n ]
        [ [ nip at-most-n ] [ at-least-n ] if* ] if
    ] [ drop 0 max exactly-n ] if ;

: handle-front-anchor ( -- ) beginning-of-line push-stack ;
: handle-back-anchor ( -- ) end-of-line push-stack ;

ERROR: bad-character-class obj ;
ERROR: expected-posix-class ;

: parse-posix-class ( -- obj )
    read1 CHAR: { = [ expected-posix-class ] unless
    "}" read-until [ bad-character-class ] unless
    {
        { "Lower" [ letter-class ] }
        { "Upper" [ LETTER-class ] }
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

: parse-til-E ( -- obj )
    "\\E" read-until [ bad-escaped-literals ] unless ;
    
:: (parse-escaped-literals) ( quot: ( obj -- obj' ) -- obj )
    parse-til-E
    drop1
    [ epsilon ] [
        quot call [ <constant> ] V{ } map-as
        first|concatenation
    ] if-empty ; inline

: parse-escaped-literals ( -- obj )
    [ ] (parse-escaped-literals) ;

: lower-case-literals ( -- obj )
    [ >lower ] (parse-escaped-literals) ;

: upper-case-literals ( -- obj )
    [ >upper ] (parse-escaped-literals) ;

: parse-escaped ( -- obj )
    read1
    {
        { CHAR: t [ CHAR: \t <constant> ] }
        { CHAR: n [ CHAR: \n <constant> ] }
        { CHAR: r [ CHAR: \r <constant> ] }
        { CHAR: f [ HEX: c <constant> ] }
        { CHAR: a [ HEX: 7 <constant> ] }
        { CHAR: e [ HEX: 1b <constant> ] }

        { CHAR: w [ c-identifier-class ] }
        { CHAR: W [ c-identifier-class <negation> ] }
        { CHAR: s [ java-blank-class ] }
        { CHAR: S [ java-blank-class <negation> ] }
        { CHAR: d [ digit-class ] }
        { CHAR: D [ digit-class <negation> ] }

        { CHAR: p [ parse-posix-class ] }
        { CHAR: P [ parse-posix-class <negation> ] }
        { CHAR: x [ parse-short-hex <constant> ] }
        { CHAR: u [ parse-long-hex <constant> ] }
        { CHAR: 0 [ parse-octal <constant> ] }
        { CHAR: c [ parse-control-character ] }

        { CHAR: Q [ parse-escaped-literals ] }

        ! { CHAR: b [ word-boundary-class ] }
        ! { CHAR: B [ word-boundary-class <negation> ] }
        ! { CHAR: A [ handle-beginning-of-input ] }
        ! { CHAR: z [ handle-end-of-input ] }

        ! { CHAR: Z [ handle-end-of-input ] } ! plus a final terminator

        ! m//g mode
        ! { CHAR: G [ end of previous match ] }

        ! Group capture
        ! { CHAR: 1 [ CHAR: 1 <constant> ] }
        ! { CHAR: 2 [ CHAR: 2 <constant> ] }
        ! { CHAR: 3 [ CHAR: 3 <constant> ] }
        ! { CHAR: 4 [ CHAR: 4 <constant> ] }
        ! { CHAR: 5 [ CHAR: 5 <constant> ] }
        ! { CHAR: 6 [ CHAR: 6 <constant> ] }
        ! { CHAR: 7 [ CHAR: 7 <constant> ] }
        ! { CHAR: 8 [ CHAR: 8 <constant> ] }
        ! { CHAR: 9 [ CHAR: 9 <constant> ] }

        ! Perl extensions
        ! can't do \l and \u because \u is already a 4-hex
        { CHAR: L [ lower-case-literals ] }
        { CHAR: U [ upper-case-literals ] }

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

: push-constant ( ch -- ) <constant> push-stack ;

: parse-character-class-second ( -- )
    read1 {
        { CHAR: [ [ CHAR: [ push-constant ] }
        { CHAR: ] [ CHAR: ] push-constant ] }
        { CHAR: - [ CHAR: - push-constant ] }
        [ push1 ]
    } case ;

: parse-character-class-first ( -- )
    read1 {
        { CHAR: ^ [ caret push-stack parse-character-class-second ] }
        { CHAR: [ [ CHAR: [ push-constant ] }
        { CHAR: ] [ CHAR: ] push-constant ] }
        { CHAR: - [ CHAR: - push-constant ] }
        [ push1 ]
    } case ;

: handle-left-bracket ( -- )
    beginning-of-character-class push-stack
    parse-character-class-first (parse-character-class) ;

: finish-regexp-parse ( stack -- obj )
    { pipe } split
    [ first|concatenation ] map first|alternation ;

: handle-right-parenthesis ( -- )
    stack dup [ parentheses-group "members" word-prop member? ] find-last
    -rot cut rest
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
            dup CHAR: $ = peek1 f = and
            [ drop handle-back-anchor f ]
            [ push-constant t ] if
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
        current-regexp get [ finish-regexp-parse ] change-stack
        dup stack>> >>parse-tree drop
    ] with-variable ;
