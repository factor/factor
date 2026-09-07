! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.units grouping kernel
locals math namespaces regexp regexp.ast regexp.classes
regexp.compiler regexp.negation regexp.nfa regexp.transition-tables
sequences sets strings vectors ;
IN: regexp.captures

TUPLE: regexp-match { groups read-only } { names read-only } ;

ERROR: duplicate-capture-name name ;
ERROR: unknown-capture-group group ;
ERROR: inconsistent-capture-match ;

<PRIVATE

TUPLE: numbered-capture < capture-group index ;
TUPLE: capturing-lookahead < lookahead ;
TUPLE: capturing-lookbehind < lookbehind ;
TUPLE: capture-save index ;
TUPLE: capture-test quot ;
TUPLE: capture-assertion table detector reverse? ;
TUPLE: capture-branch quot yes no ;
TUPLE: capture-edge label targets ;
TUPLE: capture-thread pc registers ;
TUPLE: capture-code table count names ;

SYMBOLS: capture-number capture-names captures-enabled? recording-captures? ;

! Number before expanding repetitions, in opening-parenthesis order.
GENERIC: number-captures ( ast -- ast' )
M: object number-captures ;

M:: capture-group number-captures ( ast -- ast' )
    capture-number get first 1 + :> index
    index 0 capture-number get set-nth
    ast name>> :> name
    name [
        name capture-names get key? [ name duplicate-capture-name ] when
        index name capture-names get set-at
    ] when
    ast term>> number-captures
    captures-enabled? get
    [ name index numbered-capture boa ] when ;

M: concatenation number-captures
    [ first>> number-captures ] [ second>> number-captures ] bi
    concatenation boa ;
M: alternation number-captures
    [ first>> number-captures ] [ second>> number-captures ] bi
    alternation boa ;
M: star number-captures term>> number-captures <star> ;
M: repeated number-captures
    [ term>> number-captures ] [ times>> ] bi <repeated> ;
M: with-options number-captures
    [ tree>> number-captures ] [ options>> ] bi <with-options> ;
M: tagged-epsilon number-captures tag>> number-captures <tagged-epsilon> ;
M: lookahead number-captures
    term>> number-captures captures-enabled? get
    [ capturing-lookahead boa ] [ <lookahead> ] if ;
M: lookbehind number-captures
    term>> number-captures captures-enabled? get
    [ capturing-lookbehind boa ] [ <lookbehind> ] if ;
M: negation number-captures
    f captures-enabled? [ term>> number-captures <negation> ] with-variable ;
M: not-class number-captures
    f captures-enabled? [ class>> number-captures <not-class> ] with-variable ;

M:: numbered-capture nfa-node ( ast -- start end )
    recording-captures? get [
        ast index>> 2 * capture-save boa <tagged-epsilon> nfa-node :> ( s0 s1 )
        ast term>> nfa-node :> ( s2 s3 )
        ast index>> 2 * 1 + capture-save boa <tagged-epsilon> nfa-node :> ( s4 s5 )
        s1 s2 epsilon-transition
        s3 s4 epsilon-transition
        s0 s5
    ] [ ast term>> nfa-node ] if ;

GENERIC: capture-question>quot ( question -- quot )
M: object capture-question>quot question>quot ;
M: not-class capture-question>quot
    class>> capture-question>quot '[ @ not ] ;

DEFER: prepare-capture-table
DEFER: run-captures

:: compile-capture-assertion ( ast reverse? -- assertion )
    ast lookaround-options :> tree
    f recording-captures? [
        reverse? [
            tree { reversed-regexp } f <options> <with-options>
            ast>dfa dfa>reverse-word
        ] [ tree ast>dfa dfa>word ] if
    ] with-variable :> detector
    tree construct-nfa prepare-capture-table detector reverse?
    capture-assertion boa ;

M: capturing-lookahead modify-class
    recording-captures? get
    [ term>> f compile-capture-assertion ] [ call-next-method ] if ;
M: capturing-lookbehind modify-class
    recording-captures? get
    [ term>> t compile-capture-assertion ] [ call-next-method ] if ;

GENERIC: prepare-capture-label ( label -- label' )
M: object prepare-capture-label ;
M: tagged-epsilon prepare-capture-label
    tag>> {
        { [ dup capture-save? ] [ ] }
        { [ dup capture-assertion? ] [ ] }
        [ capture-question>quot capture-test boa ]
    } cond ;

: prepare-capture-target ( target -- target' )
    dup condition? [
        [ question>> capture-question>quot ]
        [ yes>> prepare-capture-target ]
        [ no>> prepare-capture-target ] tri capture-branch boa
    ] when ;

: prepare-capture-table ( table -- table' )
    [
        [
            >alist [ first2
                [ prepare-capture-label ]
                [ [ prepare-capture-target ] map ] bi*
                capture-edge boa
            ] map
        ] assoc-map
    ] change-transitions
    [ prepare-capture-target ] change-start-state ;

:: <capture-code> ( regexp -- code )
    [
        { 0 } clone capture-number namespaces:set
        H{ } clone capture-names namespaces:set
        t captures-enabled? namespaces:set
        t recording-captures? namespaces:set
        f backwards? namespaces:set
        f shortest? namespaces:set
        regexp parse-tree>> number-captures
        regexp options>> clone
            [ reversed-regexp swap remove ] change-on
            <with-options>
        construct-nfa prepare-capture-table
        capture-number get first capture-names get capture-code boa
    ] with-scope ;

: ensure-capture-code ( regexp -- code )
    dup capture-program>> [ nip ] [
        dup [ <capture-code> ] with-compilation-unit
        [ >>capture-program drop ] keep
    ] if* ;

:: push-capture-targets ( targets registers work -- )
    targets <reversed> [ registers capture-thread boa work push ] each ;

:: save-capture ( registers index position -- registers' )
    registers clone [ position index rot set-nth ] keep ;

:: assert-captures ( registers assertion position string -- registers/f )
    assertion reverse?>> :> reverse?
    position reverse? [ 1 - ] when string f
    assertion detector>> execute( index string regexp -- end/f )
    [| end |
        reverse? [ end 1 + position ] [ position end ] if
        string assertion table>> registers run-captures
    ] [ f ] if* ;

! A closure visits each state at most once. The work stack follows the
! first alternative and the repeating branch first; lower-priority
! histories reaching the same state can never affect future acceptance.
:: capture-closure ( seeds position string table -- ready )
    seeds reverse >vector :> work
    HS{ } clone :> seen
    V{ } clone :> ready
    [ work empty? not ] [
        work pop :> thread
        thread pc>> :> pc
        thread registers>> :> registers
        pc {
            { [ dup capture-branch? ] [
                position string pc quot>> call( index string -- ? )
                pc yes>> pc no>> ? registers capture-thread boa work push
                drop
            ] }
            { [ dup capture-edge? ] [
                drop pc label>> :> label
                label {
                    { [ dup capture-save? ] [
                        index>> registers swap position save-capture
                        pc targets>> swap work push-capture-targets
                    ] }
                    { [ dup capture-test? ] [
                        quot>> position string rot call( index string -- ? )
                        [ pc targets>> registers work push-capture-targets ] when
                    ] }
                    { [ dup capture-assertion? ] [
                        registers swap position string assert-captures
                        [ pc targets>> swap work push-capture-targets ] when*
                    ] }
                    [ drop thread ready push ]
                } cond
            ] }
            [
                seen ?adjoin [
                    pc table final-states>> in?
                    [ f registers capture-thread boa ready push ] when
                    pc table transitions>> at <reversed>
                    [ registers capture-thread boa work push ] each
                ] when
            ]
        } cond
    ] while
    ready ;

:: advance-captures ( ready ch -- seeds )
    V{ } clone :> seeds
    ready [| thread |
        thread pc>> [| edge |
            ch edge label>> class-member? [
                edge targets>> [ thread registers>> capture-thread boa seeds push ] each
            ] when
        ] when*
    ] each
    seeds ;

:: run-captures ( start end string table registers -- registers/f )
    table start-state>> registers capture-thread boa 1vector :> seeds!
    start :> position!
    f :> result!
    [ position end <= seeds empty? not and ] [
        seeds position string table capture-closure :> ready
        position end = [
            ready [ pc>> not ] find nip
            [ registers>> result! ] when*
            V{ } clone seeds!
        ] [
            ready position string nth advance-captures seeds!
        ] if
        position 1 + position!
    ] while
    result ;

:: capture-result ( start end string code -- match )
    code count>> 1 + 2 * f <array> :> registers
    start 0 registers set-nth
    end 1 registers set-nth
    start end string code table>> registers run-captures
    [
        2 group [ first2
            over [ string <slice> ] [ 2drop f ] if
        ] map code names>> regexp-match boa
    ] [ inconsistent-capture-match ] if* ;

PRIVATE>

:: first-match-with-captures ( string regexp -- match/f )
    regexp ensure-capture-code :> code
    string regexp first-match
    [ >slice< code capture-result ] [ f ] if* ;

:: all-matches-with-captures ( string regexp -- matches )
    regexp ensure-capture-code :> code
    string regexp [ code capture-result ] map-matches ;

:: capture ( group match -- slice/f )
    group string? [
        group match names>> at [ group unknown-capture-group ] unless*
    ] [ group ] if :> index
    index integer? [ index 0 >= index match groups>> length < and ] [ f ] if
    [ index match groups>> nth ] [ group unknown-capture-group ] if ;
