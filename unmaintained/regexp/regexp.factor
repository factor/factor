USING: arrays errors generic assocs io kernel math
memoize namespaces kernel sequences strings tables
vectors ;
USE: interpreter
USE: prettyprint
USE: test

IN: regexp-internals

SYMBOL: trans-table
SYMBOL: eps
SYMBOL: start-state
SYMBOL: final-state

SYMBOL: paren-count
SYMBOL: currentstate
SYMBOL: stack

SYMBOL: bot
SYMBOL: eot
SYMBOL: alternation
SYMBOL: lparen
SYMBOL: rparen

: regexp-init ( -- )
    0 paren-count set
    -1 currentstate set
    V{ } clone stack set
    <vector-table> final-state over add-column trans-table set ;

: paren-underflow? ( -- )
    paren-count get 0 < [ "too many rparen" throw ] when ;

: unbalanced-paren? ( -- )
    paren-count get 0 > [ "neesds closing paren" throw ] when ;

: inc-paren-count ( -- )
    paren-count [ 1+ ] change ;

: dec-paren-count ( -- )
    paren-count [ 1- ] change paren-underflow? ;

: push-stack ( n -- ) stack get push ;
: next-state ( -- n )
    currentstate [ 1+ ] change currentstate get ;
: current-state ( -- n ) currentstate get ;

: set-trans-table ( row col data -- )
    <entry> trans-table get set-value ;

: add-trans-table ( row col data -- )
    <entry> trans-table get add-value ;

: data-stack-slice ( token -- seq )
    stack get reverse [ index ] keep cut reverse dup pop* stack set reverse ;

: find-start-state ( table -- n )
    start-state t rot find-by-column first ;

: find-final-state ( table -- n )
    final-state t rot find-by-column first ;

: final-state? ( row table -- ? )
    get-row final-state swap key? ;

: switch-rows ( r1 r2 -- )
    [ 2array [ trans-table get get-row ] each ] 2keep
    2array [ trans-table get set-row ] each ;

: set-table-prop ( prop s table -- )
    pick over add-column table-rows
    [
        pick rot member? [
            pick t swap rot set-at
        ] [
            drop
        ] if
    ] assoc-each 2drop ;

: add-numbers ( n obj -- obj )
    dup sequence? [ 
        [ + ] map-with
    ] [
        dup number? [ + ] [ nip ] if
    ] if ;

: increment-cols ( n row -- )
    ! n row
    dup [ >r pick r> add-numbers swap pick set-at ] assoc-each 2drop ;

: complex-count ( c -- ci-cr+1 )
    >rect swap - 1+ ;

: copy-rows ( c1 -- )
    #! copy rows to the bottom with a new row-name c1_range higher
    [ complex-count ] keep trans-table get table-rows ! 2 C{ 0 1 } rows
    [ drop [ over real >= ] keep pick imaginary <= and ] assoc-subset nip
    [ clone [ >r over r> increment-cols ] keep swap pick + trans-table get set-row ] assoc-each ! 2
    currentstate get 1+ dup pick + 1- rect> push-stack
    currentstate [ + ] change ;


! s1 final f ! s1 eps s2 ! output s0,s3
: apply-concat ( seq -- )
    ! "Concat: " write dup .
    dup pop over pop swap
    over imaginary final-state f set-trans-table
    2dup >r imaginary eps r> real add-trans-table
    >r real r> imaginary rect> swap push ; 

! swap 0, 4 so 0 is incoming
! ! s1 final f ! s3 final f ! s4 e s0 ! s4 e s2 ! s1 e s5 ! s3 e s5
! ! s5 final t ! s4,s5 push

SYMBOL: saved-state
: apply-alternation ( seq -- )
    ! "Alternation: " print
    dup pop over pop* over pop swap
    next-state trans-table get add-row
    >r >rect >r saved-state set current-state r> rect> r> 
    ! 4,1 2,3
    over real saved-state get trans-table get swap-rows
    saved-state get start-state t set-trans-table
    over real start-state f set-trans-table
    over imaginary final-state f set-trans-table
    dup imaginary final-state f set-trans-table
    over real saved-state get eps rot add-trans-table
    dup real saved-state get eps rot add-trans-table
    imaginary eps next-state add-trans-table
    imaginary eps current-state add-trans-table
    current-state final-state t set-trans-table
    saved-state get current-state rect> swap push ;

! s1 final f ! s1 e s0 ! s2 e s0 ! s2 e s3 ! s1 e s3 ! s3 final t
: apply-kleene-closure ( -- )
    ! "Apply kleene closure" print
    stack get pop
    next-state trans-table get add-row
    >rect >r [ saved-state set ] keep current-state 
        [ trans-table get swap-rows ] keep r> rect>

    dup imaginary final-state f set-trans-table
    dup imaginary eps pick real add-trans-table
    saved-state get eps pick real add-trans-table
    saved-state get eps next-state add-trans-table
    imaginary eps current-state add-trans-table
    current-state final-state t add-trans-table
    saved-state get current-state rect> push-stack ;

: apply-plus-closure ( -- )
    ! "Apply plus closure" print
    stack get peek copy-rows
    apply-kleene-closure stack get apply-concat ;

: apply-alternation? ( seq -- ? )
    dup length dup 3 < [
        2drop f
    ] [
        2 - swap nth alternation =
    ] if ; 

: apply-concat? ( seq -- ? )
    dup length dup 2 < [
        2drop f
    ] [
        2 - swap nth complex?
    ] if ;

: (apply) ( slice -- slice )
    dup length 1 > [
        {
            { [ dup apply-alternation? ]
                [ [ apply-alternation ] keep (apply) ] }
            { [ dup apply-concat? ]
                [ [ apply-concat ] keep (apply) ] }
        } cond
    ] when ;

: apply-til-last ( tokens -- slice )
    data-stack-slice (apply) ;

: maybe-concat ( -- )
    stack get apply-concat? [ stack get apply-concat ] when ;

: maybe-concat-loop ( -- )
    stack get length maybe-concat stack get length > [
        maybe-concat-loop
    ] when ;

: create-nontoken-nfa ( tok -- )
    next-state swap next-state <entry>
    [ trans-table get set-value ] keep
    entry-value final-state t set-trans-table
    current-state [ 1- ] keep rect> push-stack ;

! stack gets:  alternation C{ 0 1 }
: apply-question-closure ( -- )
    alternation push-stack
    eps create-nontoken-nfa stack get apply-alternation ;

! {2}  exactly twice,  {2,} 2 or more,  {2,4} exactly 2,3,4 times
! : apply-bracket-closure ( c1 -- )
    ! ;
SYMBOL: character-class
SYMBOL: brace
SYMBOL: escaped-character
SYMBOL: octal
SYMBOL: hex
SYMBOL: control
SYMBOL: posix

: addto-character-class ( char -- )
    ;

: make-escaped ( char -- )
    {
        ! TODO: POSIX character classes (US-ASCII only)
        ! TODO: Classes for Unicode blocks and categories

        ! { CHAR: { [ ] } ! left brace
        { CHAR: \\ [ ] } ! backaslash

        { CHAR: 0 [ ] } ! octal \0n \0nn \0mnn (0 <= m <= 3, 0 <= n <= 7)
        { CHAR: x [ ] } ! \xhh
        { CHAR: u [ ] } ! \uhhhh
        { CHAR: t [ ] } ! tab \u0009
        { CHAR: n [ ] } ! newline \u000a
        { CHAR: r [ ] } ! carriage-return \u000d
        { CHAR: f [ ] } ! form-feed \u000c
        { CHAR: a [ ] } ! alert (bell) \u0007
        { CHAR: e [ ] } ! escape \u001b
        { CHAR: c [ ] } ! control character corresoding to X in \cX

        { CHAR: d [ ] } ! [0-9]
        { CHAR: D [ ] } ! [^0-9]
        { CHAR: s [ ] } ! [ \t\n\x0B\f\r]
        { CHAR: S [ ] } ! [^\s]
        { CHAR: w [ ] } ! [a-zA-Z_0-9]
        { CHAR: W [ ] } ! [^\w]

        { CHAR: b [ ] } ! a word boundary
        { CHAR: B [ ] } ! a non-word boundary
        { CHAR: A [ ] } ! the beginning of input
        { CHAR: G [ ] } ! the end of the previous match
        { CHAR: Z [ ] } ! the end of the input but for the
                        ! final terminator, if any
        { CHAR: z [ ] } ! the end of the input
    } case ;

: handle-character-class ( char -- )
    {
        { [ \ escaped-character get ] [ make-escaped \ escaped-character off ] }
        { [ dup CHAR: ] = ] [ \ character-class off ] }
        { [ t ] [ addto-character-class ] }
    } cond ;

: parse-token ( char -- )
    {
        ! { [ \ character-class get ] [ ] }
        ! { [ \ escaped-character get ] [ ] }
        ! { [ dup CHAR: [ = ] [ \ character-class on ] }
        ! { [ dup CHAR: \\ = ] [ drop \ escaped-character on ] }

        ! { [ dup CHAR: ^ = ] [ ] }
        ! { [ dup CHAR: $ = ] [ ] }
        ! { [ dup CHAR: { = ] [ ] }
        ! { [ dup CHAR: } = ] [ ] }

        { [ dup CHAR: | = ]
            [ drop maybe-concat-loop alternation push-stack ] }
        { [ dup CHAR: * = ]
            [ drop apply-kleene-closure ] }
        { [ dup CHAR: + = ]
            [ drop apply-plus-closure ] }
        { [ dup CHAR: ? = ]
            [ drop apply-question-closure ] }

        { [ dup CHAR: ( = ]
            [ drop inc-paren-count lparen push-stack ] }
        { [ dup CHAR: ) = ]
            [
                drop dec-paren-count lparen apply-til-last
                stack get push-all
            ] } ! apply


        { [ dup bot = ] [ push-stack ] }
        { [ dup eot = ]
            [
                drop unbalanced-paren? maybe-concat-loop bot apply-til-last
                dup length 1 = [
                    pop real start-state t set-trans-table
                ] [
                    drop
                ] if
            ] }
        { [ t ] [ create-nontoken-nfa ] }
    } cond ;

: cut-at-index ( i string ch -- i subseq )
    -rot [ index* ] 2keep >r >r [ 1+ ] keep r> swap r> subseq ;

: parse-character-class ( index string -- new-index obj )
    2dup >r 1+ r> nth CHAR: ] = [ >r 1+ r> ] when
    cut-at-index ;

: (parse-regexp) ( str -- )
    dup length [
        2dup swap character-class get [
            parse-character-class
            "CHARACTER CLASS: " write .
            character-class off
            nip ! adjust index
        ] [
            nth parse-token
        ] if
    ] repeat ;

: parse-regexp ( str -- )
    bot parse-token
    ! [ "parsing: " write dup ch>string . parse-token ] each
    [ parse-token ] each
    ! (parse-regexp)
    eot parse-token ;

: push-all-diff ( seq seq -- diff )
    [ swap seq-diff ] 2keep push-all ;

: prune-sort ( vec -- vec )
    prune natural-sort >vector ;

SYMBOL: ttable
SYMBOL: transition
SYMBOL: check-list
SYMBOL: initial-check-list
SYMBOL: result

: init-find ( data state table -- )
    ttable set
    dup sequence? [ clone >vector ] [ V{ } clone [ push ] keep ] if
    [ check-list set ] keep clone initial-check-list set
    V{ } clone result set
    transition set ;

: (find-next-state) ( -- )
    check-list get [
        [
            ttable get get-row transition get swap at*
                [ dup sequence? [ % ] [ , ] if ] [ drop ] if
        ] each
    ] { } make
    result get push-all-diff
    check-list set
    result get prune-sort result set ;

: (find-next-state-recursive) ( -- )
    check-list get empty? [ (find-next-state) (find-next-state-recursive) ] unless ;

: find-epsilon-closure ( state table -- vec )
    eps -rot init-find
    (find-next-state-recursive) result get initial-check-list get append natural-sort ;

: find-next-state ( data state table -- vec )
    find-epsilon-closure check-list set
    V{ } clone result set transition set
    (find-next-state) result get ttable get find-epsilon-closure ;

: filter-cols ( vec -- vec )
    #! remove info columns state-state, eps, final
    clone start-state over delete-at eps over delete-at
    final-state over delete-at ;

SYMBOL: old-table
SYMBOL: new-table
SYMBOL: todo-states
SYMBOL: transitions

: init-nfa>dfa ( table -- )
    <vector-table> new-table set
    [ table-columns clone filter-cols keys transitions set ] keep
    dup [ find-start-state ] keep find-epsilon-closure
    V{ } clone [ push ] keep todo-states set
    old-table set ;

: create-row ( state table -- )
    2dup row-exists?
    [ 2drop ] [ [ add-row ] 2keep drop todo-states get push ] if ;

: (nfa>dfa) ( -- )
    todo-states get dup empty? [
        pop transitions get [
            2dup swap old-table get find-next-state
            dup empty? [
                3drop
            ] [
                dup new-table get create-row
                <entry> new-table get set-value
            ] if
        ] each-with 
    ] unless* todo-states get empty? [ (nfa>dfa) ] unless ;

: nfa>dfa ( table -- table )
    init-nfa>dfa
    (nfa>dfa)
    start-state old-table get find-start-state
    new-table get set-table-prop
    final-state old-table get find-final-state
    new-table get [ set-table-prop ] keep ;

SYMBOL: regexp
SYMBOL: text
SYMBOL: matches
SYMBOL: partial-matches
TUPLE: partial-match index row count ;
! a state is a vector
! state is a key in a hashtable. the value is a hashtable of transition states

: save-partial-match ( index row -- )
    1 <partial-match> dup partial-match-index
    \ partial-matches get set-at ;

: inc-partial-match ( partial-match -- )
    [ partial-match-count 1+ ] keep set-partial-match-count ;

: check-final-state ( partial-match -- )
    dup partial-match-row regexp get final-state? [
        clone dup partial-match-index matches get set-at
    ] [
        drop
    ] if ;

: check-trivial-match ( row regexp -- )
    dupd final-state? [
        >r 0 r> 0 <partial-match>
        0 matches get set-at
    ] [
        drop
    ] if ;

: update-partial-match ( char partial-match -- )
    tuck partial-match-row regexp get get-row at* [
        over set-partial-match-row
        inc-partial-match
    ] [
        drop
        partial-match-index partial-matches get delete-at
    ] if ;

: regexp-step ( index char start-state -- )
    ! check partial-matches
    over \ partial-matches get
    [ nip update-partial-match ] assoc-each-with

    ! check new match
    at* [
        save-partial-match
    ] [
        2drop
    ] if
    partial-matches get values [ check-final-state ] each ;

: regexp-match ( text regexp -- seq )
    #! text is the haystack
    #! regexp is a table describing the needle
    H{ } clone \ matches set
    H{ } clone \ partial-matches set
    dup regexp set
    >r dup text set r>
    [ find-start-state ] keep
    2dup check-trivial-match
    get-row
    swap [ length ] keep
    [ pick regexp-step ] 2each drop
    matches get values [
        [ partial-match-index ] keep
        partial-match-count dupd + text get <slice>
    ] map ;

IN: regexp
MEMO: make-regexp ( str -- table )
    [
        regexp-init
        parse-regexp
        trans-table get nfa>dfa
    ] with-scope ;

! TODO: make compatible with
! http://java.sun.com/j2se/1.4.2/docs/api/java/util/regex/Pattern.html

! Greedy
! Match the longest possible string, default
! a+

! Reluctant
! Match on shortest possible string
! / in vi does this (find next)
! a+?

! Possessive
! Match only when the entire text string matches
! a++
