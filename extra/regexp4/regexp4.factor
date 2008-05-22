! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators kernel math
sequences namespaces locals combinators.lib state-tables
math.parser state-parser sets dlists unicode.categories
math.order quotations shuffle math.ranges splitting
symbols fry parser math.ranges inspector strings ;
IN: regexp4

SYMBOLS: eps start-state final-state beginning-of-text
end-of-text left-parenthesis alternation left-bracket
caret dash ampersand colon ;

SYMBOL: runtime-epsilon

TUPLE: regexp raw parentheses-count bracket-count
state stack nfa new-states dfa minimized-dfa
dot-matches-newlines? capture-group captured-groups ;

TUPLE: capture-group n range ;

ERROR: parentheses-underflow ;
ERROR: unbalanced-parentheses ;
ERROR: unbalanced-brackets ;

: push-stack ( regexp token -- ) swap stack>> push ;
: push-all-stack ( regexp seq -- ) swap stack>> push-all ;
: next-state ( regexp -- n ) [ 1+ ] change-state state>> ;

: check-parentheses-underflow ( regexp -- )
    parentheses-count>> 0 < [ parentheses-underflow ] when ;

: check-unbalanced-parentheses ( regexp -- )
    parentheses-count>> 0 > [ unbalanced-parentheses ] when ;

:: (apply-alternation) ( stack regexp -- )
    [let | s2 [ stack peek first ]
           s3 [ stack pop second ]
           s0 [ stack peek alternation = [ stack pop* ] when stack peek first ]
           s1 [ stack pop second ]
           s4 [ regexp next-state ]
           s5 [ regexp next-state ]
           table [ regexp nfa>> ] |
        s5 table add-row
        s4 eps s0 <entry> table add-entry
        s4 eps s2 <entry> table add-entry
        s1 eps s5 <entry> table add-entry
        s3 eps s5 <entry> table add-entry
        s1 table final-states>> delete-at
        s3 table final-states>> delete-at
        t s5 table final-states>> set-at
        s4 s5 2array stack push ] ;

: apply-alternation ( regexp -- )
    [ stack>> ] [ (apply-alternation) ] bi ;

: apply-alternation? ( stack -- ? )
    dup length dup 3 <
    [ 2drop f ] [ 2 - swap nth alternation = ] if ;

:: (apply-concatenation) ( stack regexp -- )
    [let* |
            s2 [ stack peek first ]
            s3 [ stack pop second ]
            s0 [ stack peek first ]
            s1 [ stack pop second ]
            table [ regexp nfa>> ] |
        s1 eps s2 <entry> table set-entry
        s1 table final-states>> delete-at
        s3 table add-row
        s0 s3 2array stack push ] ;

: apply-concatenation ( regexp -- )
    [ stack>> ] [ (apply-concatenation) ] bi ;

: apply-concatenation? ( seq -- ? )
    dup length dup 2 <
    [ 2drop f ] [ 2 - swap nth array? ] if ;

: apply-loop ( seq regexp -- seq regexp )
    over length 1 > [
        2dup over apply-alternation?
        [ (apply-alternation) ] [ (apply-concatenation) ] if apply-loop
    ] when ;

: cut-out ( vector n -- vector' vector ) cut rest ;

: cut-stack ( obj vector -- vector' vector )
    tuck last-index cut-out swap ;
    
: apply-til-last ( regexp token -- )
    swap [ cut-stack ] change-stack
    apply-loop stack>> push-all ;

: concatenation-loop ( regexp -- )
    dup stack>> dup apply-concatenation?
    [ over (apply-concatenation) concatenation-loop ] [ 2drop ] if ;

:: apply-kleene-closure ( regexp -- )
    [let* | stack [ regexp stack>> ]
            s0 [ stack peek first ]
            s1 [ stack pop second ]
            s2 [ regexp next-state ]
            s3 [ regexp next-state ]
            table [ regexp nfa>> ] |
        s1 table final-states>> delete-at
        t s3 table final-states>> set-at
        s3 table add-row
        s1 eps s0 <entry> table add-entry
        s2 eps s0 <entry> table add-entry
        s2 eps s3 <entry> table add-entry
        s1 eps s3 <entry> table add-entry
        s2 s3 2array stack push ] ;

: add-numbers ( n obj -- obj )
    2dup [ number? ] bi@ and
    [ + ] [ dup sequence? [ [ + ] with map ] [ nip ] if ] if ;

: increment-columns ( n assoc -- )
    dup [ >r swap >r add-numbers r> r> set-at ] curry with* assoc-each ;

:: copy-state-rows ( regexp range -- )
    [let* | len [ range range-length ]
            offset [ regexp state>> range range-min - 1+ ]
            state [ regexp [ len + ] change-state ] |
        regexp nfa>> rows>>
        [ drop range member? ] assoc-filter
        [
            [ offset + ] dip
            [ offset swap add-numbers ] assoc-map
        ] assoc-map
        regexp nfa>> [ assoc-union ] change-rows drop
        range [ range-min ] [ range-max ] bi [ offset + ] bi@ 2array
        regexp stack>> push ] ;

: last-state ( regexp -- range )
    stack>> peek first2 [a,b] ;

: set-last-state-final ( ? regexp -- )
    [ stack>> peek second ] [ nfa>> final-states>> ] bi set-at ;

: apply-plus-closure ( regexp -- )
    [ dup last-state copy-state-rows ]
    [ apply-kleene-closure ]
    [ apply-concatenation ] tri ;

: apply-question-closure ( regexp -- )
    [ stack>> peek first2 eps swap <entry> ] [ nfa>> add-entry ] bi ;

: with0 ( obj n quot -- n quot' ) swapd curry ; inline

: copy-state ( regexp state n -- )
    [ copy-state-rows ] with0 with0 times ;

:: (exactly-n) ( regexp state n -- )
    regexp state n copy-state
    t regexp set-last-state-final ;

: exactly-n ( regexp n -- )
    >r dup last-state r> 1- (exactly-n) ;

: exactly-n-concatenated ( regexp state n -- )
    [ (exactly-n) ] 3keep
    nip 1- [ apply-concatenation ] with0 times ;

:: at-least-n ( regexp n -- )
    [let | state [ regexp stack>> pop first2 [a,b] ] |
        regexp state n copy-state
        state regexp stack>> push
        regexp apply-kleene-closure ] ; 

: pop-last ( regexp -- range )
    stack>> pop first2 [a,b] ;

:: at-most-n ( regexp n -- )
    [let | state [ regexp pop-last ] |
        regexp state n [ 1+ exactly-n-concatenated ] with with each
        regexp n 1- [ apply-alternation ] with0 times
        regexp apply-question-closure ] ;

:: from-m-to-n ( regexp m n -- )
    [let | state [ regexp pop-last ] |
        regexp state
        m n [a,b] [ exactly-n-concatenated ] with with each
        regexp n m - [ apply-alternation ] with0 times ] ;

: apply-brace-closure ( regexp from/f to/f comma? -- )
    [
        2dup and
        [ from-m-to-n ]
        [ [ nip at-most-n ] [ at-least-n ] if* ] if
    ] [ drop exactly-n ] if ;

:: push-single-nfa ( regexp obj -- )
    [let | s0 [ regexp next-state ]
           s1 [ regexp next-state ]
           stack [ regexp stack>> ]
           table [ regexp nfa>> ] |
        s0 obj s1 <entry> table set-entry
        s1 table add-row
        t s1 table final-states>> set-at
        s0 s1 2array stack push ] ;

: set-start-state ( regexp -- )
    dup stack>> dup empty? [
        2drop
    ] [
        [ nfa>> ] [ pop first ] bi* >>start-state drop
    ] if ;

: ascii? ( n -- ? ) 0 HEX: 7f between? ;
: octal-digit? ( n -- ? ) CHAR: 0 CHAR: 7 between? ;
: decimal-digit? ( n -- ? ) CHAR: 0 CHAR: 9 between? ;

: hex-digit? ( n -- ? )
    [
        [ dup decimal-digit? ]
        [ dup CHAR: a CHAR: f between? ]
        [ dup CHAR: A CHAR: F between? ]
    ] || nip ;

: control-char? ( n -- ? )
    [
        [ dup 0 HEX: 1f between? ]
        [ dup HEX: 7f = ]
    ] || nip ;

: punct? ( n -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

: c-identifier-char? ( ch -- ? ) 
    [ [ dup alpha? ] [ dup CHAR: _ = ] ] || nip ;

: java-blank? ( n -- ? )
    {   
        CHAR: \s CHAR: \t CHAR: \n
        HEX: b HEX: 7 CHAR: \r
    } member? ;

: java-printable? ( n -- ? )
    [ [ dup alpha? ] [ dup punct? ] ] || nip ;

ERROR: bad-character-class obj ;

: parse-posix-class ( -- quot )
    next
    CHAR: { expect
    [ get-char CHAR: } = ] take-until
    {
        { "Lower" [ [ letter? ] ] }
        { "Upper" [ [ LETTER? ] ] }
        { "ASCII" [ [ ascii? ] ] }
        { "Alpha" [ [ Letter? ] ] }
        { "Digit" [ [ digit? ] ] }
        { "Alnum" [ [ alpha? ] ] }
        { "Punct" [ [ punct? ] ] }
        { "Graph" [ [ java-printable? ] ] }
        { "Print" [ [ java-printable? ] ] }
        { "Blank" [ [ " \t" member? ] ] }
        { "Cntrl" [ [ control-char? ] ] }
        { "XDigit" [ [ hex-digit? ] ] }
        { "Space" [ [ java-blank? ] ] }
        ! TODO: unicode-character-class, fallthrough in unicode is bad-char-clss
        [ bad-character-class ]
    } case ;

ERROR: bad-octal number ;

: parse-octal ( -- n )
    next get-char drop
    3 take oct>
    dup 255 > [ bad-octal ] when ;

ERROR: bad-hex number ;

: parse-short-hex ( -- n )
    next 2 take hex>
    dup number? [ bad-hex ] unless ;

: parse-long-hex ( -- n )
    next 6 take hex>
    dup number? [ bad-hex ] unless ;

: parse-control-character ( -- n )
    next get-char ;

: dot-construction ( regexp -- )
    [ CHAR: \n = not ] push-single-nfa ;

: front-anchor-construction ( regexp -- )
    drop ;

: back-anchor-construction  ( regexp -- )
    drop ;

: parse-brace ( -- from/f to/f comma? )
    next
    [ get-char CHAR: } = ] take-until
    "," split1 [ [ string>number ] bi@ ] keep >boolean ;

TUPLE: character-class members ;
TUPLE: character-class-range from to ;
TUPLE: negated-character-class < character-class ;
TUPLE: negated-character-class-range < character-class-range ;
TUPLE: intersection-class < character-class ;
TUPLE: negated-intersection-class < intersection-class ;

GENERIC: character-class-contains? ( obj character-class -- ? )

: parse-escaped-until ( -- seq )
    [ get-char CHAR: \ = get-next CHAR: E = and ] take-until
    next ;

: character-class-predicate ( seq -- quot )
    boa '[ , character-class-contains? ] ;

ERROR: unmatched-escape-sequence ;

: (parse-escaped) ( regexp ? ch -- obj )
    {
        { CHAR: \ [ [ CHAR: \ = ] ] }
        { CHAR: t [ [ CHAR: \t = ] ] }
        { CHAR: n [ [ CHAR: \n = ] ] }
        { CHAR: r [ [ CHAR: \r = ] ] }
        { CHAR: f [ [ HEX: c = ] ] }
        { CHAR: a [ [ HEX: 7 = ] ] }
        { CHAR: e [ [ HEX: 1b = ] ] }

        { CHAR: d [ [ digit? ] ] }
        { CHAR: D [ [ digit? not ] ] }
        { CHAR: s [ [ java-blank? ] ] }
        { CHAR: S [ [ java-blank? not ] ] }
        { CHAR: w [ [ c-identifier-char? ] ] }
        { CHAR: W [ [ c-identifier-char? not ] ] }

        { CHAR: p [ parse-posix-class ] }
        { CHAR: P [ parse-posix-class [ not ] compose ] }
        { CHAR: x [ parse-short-hex ] }
        { CHAR: u [ parse-long-hex ] }
        { CHAR: 0 [ parse-octal ] }
        { CHAR: c [ parse-control-character ] }

        ! { CHAR: Q [ next parse-escaped-until ] }
        ! { CHAR: E [ unmatched-escape-sequence ] }

        ! { CHAR: b [ ] } ! a word boundary
        ! { CHAR: B [ ] } ! a non-word boundary
        ! { CHAR: A [ ] } ! beginning of input
        ! { CHAR: G [ ] } ! end of previous match
        ! { CHAR: Z [ ] } ! end of input but for the final terminator, if any
        ! { CHAR: z [ ] } ! end of the input
        [ ]
    } case ;

: parse-escaped ( regexp -- )
    next get-char (parse-escaped) push-single-nfa ;

: handle-dash ( vector -- vector )
    [ dup dash eq? [ drop CHAR: - ] when ] map ;

M: object character-class-contains? ( obj1 obj2 -- ? )
    = ;

M: callable character-class-contains? ( obj1 callable -- ? )
    call ;

M: character-class character-class-contains? ( obj cc -- ? )
    members>> [ character-class-contains? ] with find drop >boolean ;

M: negated-character-class character-class-contains? ( obj cc -- ? )
    call-next-method not ;

M: character-class-range character-class-contains? ( obj cc -- ? )
    [ from>> ] [ to>> ] bi between?  ;

M: negated-character-class-range character-class-contains? ( obj cc -- ? )
    call-next-method not ;

M: intersection-class character-class-contains? ( obj cc -- ? )
    members>> [ character-class-contains? not ] with find drop not ;

M: negated-intersection-class character-class-contains? ( obj cc -- ? )
    call-next-method not ;

ERROR: unmatched-negated-character-class class ;

: handle-caret ( obj -- seq class )
    dup [ length 2 >= ] [ first caret eq? ] bi and [ 
        rest negated-character-class
    ] [
        character-class
    ] if ;

: make-character-class ( regexp -- )
    left-bracket over stack>> cut-stack
    pick (>>stack)
    handle-dash handle-caret
    character-class-predicate push-single-nfa ;

: apply-dash ( regexp -- )
    stack>> dup [ pop ] [ pop* ] [ pop ] tri
    swap character-class-range boa swap push ;

: apply-dash? ( regexp -- ? )
    stack>> dup length 3 >=
    [ [ length 2 - ] keep nth dash eq? ] [ drop f ] if ;

DEFER: parse-character-class
: (parse-character-class) ( regexp -- )
    [
        next get-char
        {
            { CHAR: [ [
                [ 1+ ] change-bracket-count dup left-bracket push-stack
                parse-character-class
            ] }
            { CHAR: ] [
                [ 1- ] change-bracket-count
                make-character-class
            ] }
            { CHAR: - [ dash push-stack ] }
            ! { CHAR: & [ ampersand push-stack ] }
            ! { CHAR: : [ semicolon push-stack ] }
            { CHAR: \ [ next get-char (parse-escaped) push-stack ] }
            { f [ unbalanced-brackets ] }
            [ dupd push-stack dup apply-dash? [ apply-dash ] [ drop ] if ]
        } case
    ] [
        dup bracket-count>> 0 >
        [ (parse-character-class) ] [ drop ] if
    ] bi ;

: parse-character-class-second ( regexp -- )
    get-next
    {
        { CHAR: [ [ CHAR: [ push-stack next ] }
        { CHAR: ] [ CHAR: ] push-stack next ] }
        { CHAR: - [ CHAR: - push-stack next ] }
        [ 2drop ]
    } case ;

: parse-character-class-first ( regexp -- )
    get-next
    {
        { CHAR: ^ [ caret dupd push-stack next parse-character-class-second ] }
        { CHAR: [ [ CHAR: [ push-stack next ] }
        { CHAR: ] [ CHAR: ] push-stack next ] }
        { CHAR: - [ CHAR: - push-stack next ] }
        [ 2drop ]
    } case ;

: parse-character-class ( regexp -- )
    [ parse-character-class-first ] [ (parse-character-class) ] bi ;

ERROR: unsupported-token token ;
: parse-token ( regexp token -- )
    dup {
        { CHAR: ^ [ drop front-anchor-construction ] }
        { CHAR: $ [ drop back-anchor-construction ] }
        { CHAR: \ [ drop parse-escaped ] }
        { CHAR: | [ drop dup concatenation-loop alternation push-stack ] }
        { CHAR: ( [ drop [ 1+ ] change-parentheses-count left-parenthesis push-stack ] }
        { CHAR: ) [ drop [ 1- ] change-parentheses-count left-parenthesis apply-til-last ] }
        { CHAR: * [ drop apply-kleene-closure ] }
        { CHAR: + [ drop apply-plus-closure ] }
        { CHAR: ? [ drop apply-question-closure ] }
        { CHAR: { [ drop parse-brace apply-brace-closure ] }
        { CHAR: [ [
            drop
            dup left-bracket push-stack
            [ 1+ ] change-bracket-count parse-character-class
        ] }
        ! { CHAR: } [ drop drop "brace" ] }
        ! { CHAR: ? [ drop ] }
        { CHAR: . [ drop dot-construction ] }
        { beginning-of-text [ push-stack ] }
        { end-of-text [
            drop {
                [ check-unbalanced-parentheses ]
                [ concatenation-loop ]
                [ beginning-of-text apply-til-last ]
                [ set-start-state ]
            } cleave
        ] }
        [ drop push-single-nfa ]
    } case ;

: (parse-raw-regexp) ( regexp -- )
    get-char [ dupd parse-token next (parse-raw-regexp) ] [ drop ] if* ;

: parse-raw-regexp ( regexp -- )
    [ beginning-of-text parse-token ]
    [
        dup raw>> dup empty? [
            2drop
        ] [
            [ (parse-raw-regexp) ] string-parse
        ] if
    ]
    [ end-of-text parse-token ] tri ;

:: find-delta ( states obj table -- keys )
    obj states [
        table get-row at
        [ dup integer? [ 1array ] when unique ] [ H{ } ] if*
    ] with map H{ } clone [ assoc-union ] reduce keys ;

:: (find-closure) ( states obj assoc table -- keys )
    [let | size [ assoc assoc-size ] |
        assoc states unique assoc-union
        dup assoc-size size > [
            obj states [
                table get-row at* [
                    dup integer? [ 1array ] when
                    obj rot table (find-closure)
                ] [
                    drop
                ] if
            ] with each
        ] when ] ;

: find-closure ( states obj table -- states )
    >r H{ } r> (find-closure) keys ;

: find-epsilon-closure ( states table -- states )
    >r eps H{ } r> (find-closure) keys ;

: filter-special-transition ( vec -- vec' )
    [ drop eps = not ] assoc-filter ;

: initialize-subset-construction ( regexp -- )
    <vector-table> >>dfa
    [
        nfa>> [ start-state>> 1array ] keep
        find-epsilon-closure 1dlist
    ] [
        swap >>new-states drop
    ] [
        [ dfa>> ] [ nfa>> ] bi
        columns>> filter-special-transition >>columns drop
    ] tri ;

:: (subset-construction) ( regexp -- )
    [let* | nfa [ regexp nfa>> ]
           dfa [ regexp dfa>> ]
           new-states [ regexp new-states>> ]
           columns [ dfa columns>> keys ] |
        
        new-states dlist-empty? [
            new-states pop-front
            dup dfa add-row
            columns [
                2dup nfa [ find-delta ] [ find-epsilon-closure ] bi
                dup [ dfa rows>> key? ] [ empty? ] bi or [
                    dup new-states push-back
                ] unless
                dup empty? [ 3drop ] [ <entry> dfa set-entry ] if
            ] with each
            regexp (subset-construction)
        ] unless ] ;

: set-start/final-states ( regexp -- )
    dup [ nfa>> start-state>> ]
    [ dfa>> rows>> keys [ member? ] with filter first ] bi
    >r dup dfa>> r> >>start-state drop

    dup [ nfa>> final-states>> ] [ dfa>> rows>> ] bi
    [ keys ] bi@
    [ intersect empty? not ] with filter
    >r dfa>> r> >>final-states drop ;

: subset-construction ( regexp -- )
    [ initialize-subset-construction ]
    [ (subset-construction) ]
    [ set-start/final-states ] tri ;

: <regexp> ( raw -- obj )
    regexp new
        swap >>raw
        0 >>parentheses-count
        0 >>bracket-count
        -1 >>state
        V{ } clone >>stack 
        <vector-table> >>nfa
        dup [ parse-raw-regexp ] [ subset-construction ] bi ;

! Literal syntax for regexps
: parse-options ( string -- ? )
    #! Lame
    {
        { "" [ f ] }
        { "i" [ t ] }
    } case ;

: parse-regexp ( accum end -- accum )
    lexer get dup skip-blank
    [ [ index-from dup 1+ swap ] 2keep swapd subseq swap ] change-lexer-column
    ! lexer get dup still-parsing-line?
    ! [ (parse-token) parse-options ] [ drop f ] if
    <regexp> parsed ;

: R! CHAR: ! parse-regexp ; parsing
: R" CHAR: " parse-regexp ; parsing
: R# CHAR: # parse-regexp ; parsing
: R' CHAR: ' parse-regexp ; parsing
: R( CHAR: ) parse-regexp ; parsing
: R/ CHAR: / parse-regexp ; parsing
: R@ CHAR: @ parse-regexp ; parsing
: R[ CHAR: ] parse-regexp ; parsing
: R` CHAR: ` parse-regexp ; parsing
: R{ CHAR: } parse-regexp ; parsing
: R| CHAR: | parse-regexp ; parsing

TUPLE: dfa-traverser
    dfa
    last-state current-state
    text
    start-index current-index
    matches ;

: <dfa-traverser> ( text dfa -- match )
    dfa>>
    dfa-traverser new
        swap [ start-state>> >>current-state ] keep
        >>dfa
        swap >>text
        0 >>start-index
        0 >>current-index
        V{ } clone >>matches ;

: final-state? ( dfa-traverser -- ? )
    [ current-state>> ] [ dfa>> final-states>> ] bi
    member? ;

: text-finished? ( dfa-traverser -- ? )
    [ current-index>> ] [ text>> length ] bi >= ;

: save-final-state ( dfa-straverser -- )
    [ current-index>> ] [ matches>> ] bi push ;

: match-done? ( dfa-traverser -- ? )
    dup final-state? [
        dup save-final-state
    ] when text-finished? ;

: increment-state ( dfa-traverser state -- dfa-traverser )
    >r [ 1+ ] change-current-index
    dup current-state>> >>last-state r>
    >>current-state ;

: match-transition ( obj hash -- state/f )
    2dup keys [ callable? ] filter predicates
    [ swap at nip ] [ at ] if* ;

: do-match ( dfa-traverser -- dfa-traverser )
    dup match-done? [
        dup {
            [ current-index>> ]
            [ text>> ]
            [ current-state>> ]
            [ dfa>> rows>> ]
        } cleave
        at >r nth r> match-transition [
            increment-state do-match
        ] when*
    ] unless ;

: return-match ( dfa-traverser -- interval/f )
    dup matches>> empty? [
        drop f
    ] [
        [ start-index>> ] [ matches>> peek ] bi 1 <range>
    ] if ;

: match ( string regexp -- pair )
    <dfa-traverser> do-match return-match ;

: matches? ( string regexp -- ? )
    dupd match [ [ length ] [ range-length 1- ] bi* = ] [ drop f ] if* ;

: match-head ( string regexp -- end )
    match length>> 1- ;

! character classes
! TUPLE: range-class from to ;
! TUPLE: or-class left right ;

! (?:a|b)*  <- does not capture
! (a|b)*\1  <- group captured
! doesn't advance the current position:
! (?=abba)  positive lookahead  matches abbaaa but not abaaa
! (?!abba)  negative lookahead  matches ababa but not abbaa
! look behind.   "lookaround"

! : $ ( n -- obj ) groups get nth ;
! [
    ! groups bound to scope here
! ] [
    ! error or something
! ] if-match
! match in a string with  .*foo.*
