! Copyright (C) 2007, 2008 Chris Double.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs classes combinators
combinators.short-circuit compiler.units effects.parser kernel
literals make math math.order memoize namespaces quotations
sequences sets splitting strings unicode vectors vocabs.loader
words ;

IN: peg

TUPLE: parse-result remaining ast ;
TUPLE: parse-error position got messages ;
TUPLE: parser peg compiled id ;

M: parser equal? { [ [ class-of ] same? ] [ [ id>> ] same? ] } 2&& ;
M: parser hashcode* id>> hashcode* ;

C: <parse-result> parse-result
C: <parse-error>  parse-error

GENERIC: parser-quot ( peg -- quot )

SYMBOL: ignore
SYMBOL: fail

<PRIVATE

SYMBOL: error-stack

: merge-overlapping-errors ( a b -- c )
    dupd [ messages>> ] bi@ union [ [ position>> ] [ got>> ] bi ] dip
    <parse-error> ;

: (merge-errors) ( a b -- c )
    {
        { [ over position>> not ] [ nip ] }
        { [ dup  position>> not ] [ drop ] }
        [
            2dup [ position>> ] compare {
                { +lt+ [ nip ] }
                { +gt+ [ drop ] }
                { +eq+ [ merge-overlapping-errors ] }
            } case
        ]
    } cond ;

: merge-errors ( -- )
    error-stack get dup length 1 > [
        [ pop ] [ pop swap (merge-errors) ] [ ] tri push
    ] [
        drop
    ] if ;

: add-error ( position got message -- )
    <parse-error> error-stack get push ;

: packrat ( id -- cache )
    ! The packrat cache is a mapping of parser-id->cache.
    ! For each parser it maps to a cache holding a mapping
    ! of position->result. The packrat cache therefore keeps
    ! track of all parses that have occurred at each position
    ! of the input string and the results obtained from that
    ! parser.
    \ packrat get [ drop H{ } clone ] cache ;

SYMBOL: pos
SYMBOL: input
SYMBOL: lrstack

: heads ( -- cache )
    ! A mapping from position->peg-head. It maps a
    ! position in the input string being parsed to
    ! the head of the left recursion which is currently
    ! being grown. It is 'f' at any position where
    ! left recursion growth is not underway.
    \ heads get ;

: peg-cache ( -- cache )
    ! Holds a hashtable mapping a peg tuple to
    ! the parser tuple for that peg. The parser tuple
    ! holds a unique id and the compiled form of that peg.
    \ peg-cache get-global [
        H{ } clone dup \ peg-cache set-global
    ] unless* ;

: reset-pegs ( -- )
    H{ } clone \ peg-cache set-global ;

reset-pegs

: next-id ( -- n )
    ! Return the next unique id for a parser
    \ next-id counter ;

: wrap-peg ( peg -- parser )
    ! Wrap a parser tuple around the peg object.
    ! Look for an existing parser tuple for that
    ! peg object.
    peg-cache [ f next-id parser boa ] cache ;

! An entry in the table of memoized parse results
! ast = an AST produced from the parse
!       or the symbol 'fail'
!       or a left-recursion object
! pos = the position in the input string of this entry
TUPLE: memo-entry ans pos ;

TUPLE: left-recursion seed rule-id head next ;

TUPLE: peg-head rule-id involved-set eval-set ;

: rule-id ( word -- id )
    ! A rule is the parser compiled down to a word. It has
    ! a "peg-id" property containing the id of the original parser.
    "peg-id" word-prop ;

: input-slice ( -- slice )
    ! Return a slice of the input from the current parse position
    input get pos get tail-slice ;

: input-from ( input -- n )
    ! Return the index from the original string that the
    ! input slice is based on.
    dup slice? [ from>> ] [ drop 0 ] if ;

: process-rule-result ( p result -- result )
    [
        nip [ ast>> ] [ remaining>> ] bi input-from pos namespaces:set
    ] [
        pos namespaces:set fail
    ] if* ;

: eval-rule ( rule -- ast )
    ! Evaluate a rule, return an ast resulting from it.
    ! Return fail if the rule failed. The rule has
    ! stack effect ( -- parse-result )
    pos get swap execute( -- parse-result ) process-rule-result ; inline

: memo ( pos id -- memo-entry )
    ! Return the result from the memo cache.
    packrat at ;

: set-memo ( memo-entry pos id -- )
    ! Store an entry in the cache
    packrat set-at ;

: update-m ( ast m -- )
    swap >>ans pos get >>pos drop ;

: stop-growth? ( ast m -- ? )
    [ fail = pos get ] dip pos>> <= or ;

: setup-growth ( h p -- )
    pos namespaces:set dup involved-set>> clone >>eval-set drop ;

: (grow-lr) ( h p r: ( -- result ) m -- )
    [ [ setup-growth ] 2keep ] 2dip
    [ dup eval-rule ] dip swap
        dup pick stop-growth? [
        5drop
    ] [
        over update-m
        (grow-lr)
    ] if ; inline recursive

: grow-lr ( h p r m -- ast )
    [ [ heads set-at ] 2keep ] 2dip
    pick over [ (grow-lr) ] 2dip
    swap heads delete-at
    dup pos>> pos namespaces:set ans>>
    ; inline

:: (setup-lr) ( l s -- )
    s [
        s left-recursion? [ s throw ] unless
        s head>> l head>> eq? [
            l head>> s head<<
            l head>> [ s rule-id>> suffix ] change-involved-set drop
            l s next>> (setup-lr)
        ] unless
    ] when ;

:: setup-lr ( r l -- )
    l head>> [
        r rule-id V{ } clone V{ } clone peg-head boa l head<<
    ] unless
    l lrstack get (setup-lr) ;

:: lr-answer ( r p m -- ast )
    m ans>> head>> :> h
    h rule-id>> r rule-id eq? [
        m ans>> seed>> m ans<<
        m ans>> fail = [
            fail
        ] [
            h p r m grow-lr
        ] if
    ] [
        m ans>> seed>>
    ] if ; inline

:: recall ( r p -- memo-entry )
    p r rule-id memo :> m
    p heads at :> h
    h [
        m r rule-id h involved-set>> h rule-id>> suffix member? not and [
            fail p memo-entry boa
        ] [
            r rule-id h eval-set>> member? [
                h [ r rule-id swap remove ] change-eval-set drop
                r eval-rule
                m update-m
                m
            ] [
                m
            ] if
        ] if
    ] [
        m
    ] if ; inline

:: apply-non-memo-rule ( r p -- ast )
    fail r rule-id f lrstack get left-recursion boa :> lr
    lr lrstack namespaces:set lr p memo-entry boa dup p r rule-id set-memo :> m
    r eval-rule :> ans
    lrstack get next>> lrstack namespaces:set
    pos get m pos<<
    lr head>> [
        m ans>> left-recursion? [
            ans lr seed<<
            r p m lr-answer
        ] [ ans ] if
    ] [
        ans m ans<<
        ans
    ] if ; inline

: apply-memo-rule ( r m -- ast )
    [ ans>> ] [ pos>> ] bi pos namespaces:set
    dup left-recursion? [
        [ setup-lr ] keep seed>>
    ] [
        nip
    ] if ;

: apply-rule ( r p -- ast )
    2dup recall [
        nip apply-memo-rule
    ] [
        apply-non-memo-rule
    ] if* ; inline

: with-packrat ( input quot -- result )
    ! Run the quotation with a packrat cache active.
    [
        swap input ,,
        0 pos ,,
        f lrstack ,,
        V{ } clone error-stack ,,
        H{ } clone \ heads ,,
        H{ } clone \ packrat ,,
    ] H{ } make swap with-variables ; inline

: process-parser-result ( result -- result )
    dup fail = [
        drop f
    ] [
        input-slice swap <parse-result>
    ] if ;

: execute-parser ( word -- result )
    pos get apply-rule process-parser-result ;

: preset-parser-word ( parser -- word parser )
    gensym tuck >>compiled ;

: define-parser-word ( word parser -- )
    ! Return the body of the word that is the compiled version
    ! of the parser.
    [ peg>> parser-quot ( -- result ) define-declared ]
    [ id>> "peg-id" set-word-prop ] 2bi ;

: compile-parser-word ( parser -- word )
    ! Look to see if the given parser has been compiled.
    ! If not, compile it to a temporary word, cache it,
    ! and return it. Otherwise return the existing one.
    ! Circular parsers are supported by getting the word
    ! name and storing it in the cache, before compiling,
    ! so it is picked up when re-entered.
    dup compiled>> [
        nip
    ] [
        preset-parser-word dupd define-parser-word
    ] if* ;

: execute-parser-quot ( parser -- quot )
    compile-parser-word '[ _ execute-parser ] ;

: execute-parsers-quots ( parsers -- quots )
    [ execute-parser-quot ] map dup rest-slice
    [ '[ @ merge-errors ] ] map! drop ;

SYMBOL: delayed

: fixup-delayed ( -- )
    ! Work through all delayed parsers and recompile their
    ! words to have the correct bodies.
    delayed get [
        call( -- parser ) execute-parser-quot ( -- result ) define-declared
    ] assoc-each ;

: compile-parser ( parser -- word )
    [
        H{ } clone delayed [
            compile-parser-word fixup-delayed
        ] with-variable
    ] with-compilation-unit ;

: perform-parse ( input word -- result )
    swap [
        execute-parser [
            error-stack get ?first [ throw ] [
                pos get input get f <parse-error> throw
            ] if*
        ] unless*
    ] with-packrat ;

PRIVATE>

: (parse) ( input parser -- result )
    compile-parser perform-parse ;

: parse ( input parser -- ast )
    (parse) ast>> ;

ERROR: unable-to-fully-parse remaining ;

ERROR: could-not-parse ;

: check-parse-result ( result -- result )
    [
        dup remaining>> [ blank? ] trim [
            unable-to-fully-parse
        ] unless-empty
    ] [
        could-not-parse
    ] if* ;

: parse-fully ( input parser -- ast )
    (parse) check-parse-result ast>> ;

<PRIVATE

TUPLE: token-parser symbol ;

: parse-token ( input string -- result )
    ! Parse the string, returning a parse result
    [ ?head-slice ] 1guard [
        <parse-result>
    ] [
        [ seq>> pos get swap ] dip "'" "'" surround 1vector add-error f
    ] if ;

M: token-parser parser-quot
    symbol>> '[ input-slice _ parse-token ] ;

TUPLE: satisfy-parser quot ;

:: parse-satisfy ( input quot -- result/f )
    input [ f ] [
        unclip-slice dup quot call [
            <parse-result>
        ] [
            2drop f
        ] if
    ] if-empty ; inline

M: satisfy-parser parser-quot
    quot>> '[ input-slice _ parse-satisfy ] ;

TUPLE: range-parser min max ;

:: parse-range ( input min max -- result/f )
    input [ f ] [
        dup first min max between? [
            unclip-slice <parse-result>
        ] [
            drop f
        ] if
    ] if-empty ;

M: range-parser parser-quot
    [ min>> ] [ max>> ] bi '[ input-slice _ _ parse-range ] ;

TUPLE: seq-parser parsers ;

: calc-seq-result ( prev-result current-result -- next-result )
    [
        [ remaining>> >>remaining ] [ ast>> ] bi
        dup ignore = [ drop ] [ over ast>> push ] if
    ] [
        drop f
    ] if* ;

: parse-seq-element ( result quot -- result )
    '[ @ calc-seq-result ] [ f ] if* ; inline

M: seq-parser parser-quot
    parsers>> execute-parsers-quots
    [ '[ _ parse-seq-element ] ] map
    '[ input-slice V{ } clone <parse-result> _ 1&& ] ;

TUPLE: choice-parser parsers ;

M: choice-parser parser-quot
    parsers>> execute-parsers-quots '[ _ 0|| ] ;

TUPLE: repeat0-parser parser ;

: repeat-loop ( quot: ( -- result/f ) result -- result )
    over call [
        [ remaining>> >>remaining ] [ ast>> ] bi
        over ast>> push repeat-loop
    ] [
        nip
    ] if* ; inline recursive

M: repeat0-parser parser-quot
    parser>> execute-parser-quot '[
        input-slice V{ } clone <parse-result> _ swap repeat-loop
    ] ;

TUPLE: repeat1-parser parser ;

: repeat1-empty-check ( result -- result )
    [ dup ast>> empty? [ drop f ] when ] [ f ] if* ;

M: repeat1-parser parser-quot
    parser>> execute-parser-quot '[
        input-slice V{ } clone <parse-result> _ swap repeat-loop
        repeat1-empty-check
    ] ;

TUPLE: optional-parser parser ;

: check-optional ( result -- result )
    [ input-slice f <parse-result> ] unless* ;

M: optional-parser parser-quot
    parser>> execute-parser-quot '[ @ check-optional ] ;

TUPLE: semantic-parser parser quot ;

: check-semantic ( result quot -- result )
    dupd '[ dup ast>> @ and* ] when ; inline

M: semantic-parser parser-quot
    [ parser>> execute-parser-quot ] [ quot>> ] bi
    '[ @ _ check-semantic ] ;

TUPLE: ensure-parser parser ;

: check-ensure ( old-input result -- result )
    [ ignore <parse-result> ] [ drop f ] if ;

M: ensure-parser parser-quot
    parser>> execute-parser-quot '[ input-slice @ check-ensure ] ;

TUPLE: ensure-not-parser parser ;

: check-ensure-not ( old-input result -- result )
    [ drop f ] [ ignore <parse-result> ] if ;

M: ensure-not-parser parser-quot
    parser>> execute-parser-quot '[ input-slice @ check-ensure-not ] ;

TUPLE: action-parser parser quot ;

: check-action ( result quot -- result )
    dupd '[ [ _ call( ast -- ast ) ] change-ast ] when ;

M: action-parser parser-quot
    [ parser>> execute-parser-quot ] [ quot>> ] bi
    '[ @ _ check-action ] ;

TUPLE: sp-parser parser ;

M: sp-parser parser-quot
    parser>> execute-parser-quot '[
        input-slice [ blank? ] trim-head-slice input-from pos namespaces:set @
    ] ;

TUPLE: delay-parser quot ;

M: delay-parser parser-quot
    ! For efficiency we memoize the quotation.
    ! This way it is run only once and the
    ! parser constructed once at run time.
    quot>> gensym [ delayed get set-at ] keep 1quotation ;

TUPLE: box-parser quot ;

M: box-parser parser-quot
    ! Calls the quotation at compile time
    ! to produce the parser to be compiled.
    ! This differs from 'delay' which calls
    ! it at run time.
    quot>> call( -- parser ) execute-parser-quot ;

PRIVATE>

: token ( string -- parser )
    token-parser boa wrap-peg ;

: satisfy ( quot -- parser )
    satisfy-parser boa wrap-peg ;

: range ( min max -- parser )
    range-parser boa wrap-peg ;

: seq ( seq -- parser )
    seq-parser boa wrap-peg ;

: 2seq ( parser1 parser2 -- parser )
    2array seq ;

: 3seq ( parser1 parser2 parser3 -- parser )
    3array seq ;

: 4seq ( parser1 parser2 parser3 parser4 -- parser )
    4array seq ;

: seq* ( quot -- parser )
    { } make seq ; inline

: choice ( seq -- parser )
    choice-parser boa wrap-peg ;

: 2choice ( parser1 parser2 -- parser )
    2array choice ;

: 3choice ( parser1 parser2 parser3 -- parser )
    3array choice ;

: 4choice ( parser1 parser2 parser3 parser4 -- parser )
    4array choice ;

: choice* ( quot -- parser )
    { } make choice ; inline

: repeat0 ( parser -- parser )
    repeat0-parser boa wrap-peg ;

: repeat1 ( parser -- parser )
    repeat1-parser boa wrap-peg ;

: optional ( parser -- parser )
    optional-parser boa wrap-peg ;

: semantic ( parser quot -- parser )
    semantic-parser boa wrap-peg ;

: ensure ( parser -- parser )
    ensure-parser boa wrap-peg ;

: ensure-not ( parser -- parser )
    ensure-not-parser boa wrap-peg ;

: action ( parser quot -- parser )
    action-parser boa wrap-peg ;

: sp ( parser -- parser )
    sp-parser boa wrap-peg ;

: hide ( parser -- parser )
    [ drop ignore ] action ;

: delay ( quot -- parser )
    delay-parser boa wrap-peg ;

: box ( quot -- parser )
    ! because a box has its quotation run at compile time
    ! it must always have a new parser wrapper created,
    ! not a cached one. This is because the same box,
    ! compiled twice can have a different compiled word
    ! due to running at compile time.
    ! Why the [ ] action at the end? Box parsers don't get
    ! memoized during parsing due to all box parsers being
    ! unique. This breaks left recursion detection during the
    ! parse. The action adds an indirection with a parser type
    ! that gets memoized and fixes this. Need to rethink how
    ! to fix boxes so this isn't needed...
    box-parser boa f next-id parser boa [ ] action ;

SYNTAX: PARTIAL-PEG:
    (:) '[
        [
            _
            _ call( -- parser ) compile-parser
            '[ _ perform-parse ast>> ]
            _ define-declared
        ] with-compilation-unit
    ] append! ;

SYNTAX: PEG:
    (:) '[
        [
            _
            _ call( -- parser ) compile-parser
            '[ _ perform-parse check-parse-result ast>> ]
            _ define-declared
        ] with-compilation-unit
    ] append! ;

{ "debugger" "peg" } "peg.debugger" require-when
