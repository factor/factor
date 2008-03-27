! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences vectors classes classes.algebra
combinators arrays words assocs parser namespaces definitions
prettyprint prettyprint.backend quotations arrays.lib
debugger io compiler.units kernel.private effects ;
IN: multi-methods

GENERIC: generic-prologue ( combination -- quot )

GENERIC: method-prologue ( combination -- quot )

: maximal-element ( seq quot -- n elt )
    dupd [
        swapd [ call 0 < ] 2curry subset empty?
    ] 2curry find [ "Topological sort failed" throw ] unless* ;
    inline

: topological-sort ( seq quot -- newseq )
    >r >vector [ dup empty? not ] r>
    [ dupd maximal-element >r over delete-nth r> ] curry
    [ ] unfold nip ; inline

: classes< ( seq1 seq2 -- -1/0/1 )
    [
        {
            { [ 2dup eq? ] [ 0 ] }
            { [ 2dup [ class< ] 2keep swap class< and ] [ 0 ] }
            { [ 2dup class< ] [ -1 ] }
            { [ 2dup swap class< ] [ 1 ] }
            { [ t ] [ 0 ] }
        } cond 2nip
    ] 2map [ zero? not ] find nip 0 or ;

: picker ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
        [ 1- picker [ >r ] swap [ r> swap ] 3append ]
    } case ;

: (multi-predicate) ( class picker -- quot )
    swap "predicate" word-prop append ;

: multi-predicate ( classes -- quot )
    dup length <reversed>
    [ picker 2array ] 2map
    [ drop object eq? not ] assoc-subset
    dup empty? [ drop [ t ] ] [
        [ (multi-predicate) ] { } assoc>map
        unclip [ swap [ f ] \ if 3array append [ ] like ] reduce
    ] if ;

: methods ( word -- alist )
    "multi-methods" word-prop >alist ;

: make-method-def ( quot classes generic -- quot )
    [
        swap [ declare ] curry %
        "multi-combination" word-prop method-prologue %
        %
    ] [ ] make ;

TUPLE: method word def classes generic loc ;

PREDICATE: method-body < word
    "multi-method" word-prop >boolean ;

M: method-body stack-effect
    "multi-method" word-prop method-generic stack-effect ;

: method-word-name ( classes generic -- string )
    [
        word-name %
        "-(" % [ "," % ] [ word-name % ] interleave ")" %
    ] "" make ;

: <method-word> ( quot classes generic -- word )
    #! We xref here because the "multi-method" word-prop isn't
    #! set yet so crossref? yields f.
    [ make-method-def ] 2keep
    method-word-name f <word>
    dup rot define
    dup xref ;

: <method> ( quot classes generic -- method )
    [ <method-word> ] 3keep f \ method construct-boa
    dup method-word over "multi-method" set-word-prop ;

TUPLE: no-method arguments generic ;

: no-method ( argument-count generic -- * )
    >r narray r> \ no-method construct-boa throw ; inline

: argument-count ( methods -- n )
    dup assoc-empty? [ drop 0 ] [
        keys [ length ] map supremum
    ] if ;

: multi-dispatch-quot ( methods generic -- quot )
    >r [
        [
            >r multi-predicate r> method-word 1quotation
        ] assoc-map
    ] keep argument-count
    r> [ no-method ] 2curry
    swap reverse alist>quot ;

: congruify-methods ( alist -- alist' )
    dup argument-count [
        swap >r object pad-left [ \ f or ] map r>
    ] curry assoc-map ;

: sorted-methods ( alist -- alist' )
    [ [ first ] 2apply classes< ] topological-sort ;

: niceify-method [ dup \ f eq? [ drop f ] when ] map ;

M: no-method error.
    "Type check error" print
    nl
    "Generic word " write dup no-method-generic pprint
    " does not have a method applicable to inputs:" print
    dup no-method-arguments short.
    nl
    "Inputs have signature:" print
    dup no-method-arguments [ class ] map niceify-method .
    nl
    "Defined methods in topological order: " print
    no-method-generic
    methods congruify-methods sorted-methods keys
    [ niceify-method ] map stack. ;

TUPLE: standard-combination ;

M: standard-combination method-prologue drop [ ] ;

M: standard-combination generic-prologue drop [ ] ;

: make-generic ( generic -- quot )
    dup "multi-combination" word-prop generic-prologue swap
    [ methods congruify-methods sorted-methods ] keep
    multi-dispatch-quot append ;

TUPLE: hook-combination var ;

M: hook-combination method-prologue
    drop [ drop ] ;

M: hook-combination generic-prologue
    hook-combination-var [ get ] curry ;

: update-generic ( word -- )
    dup make-generic define ;

: define-generic ( word combination -- )
    over "multi-combination" word-prop over = [
        2drop
    ] [
        dupd "multi-combination" set-word-prop
        dup H{ } clone "multi-methods" set-word-prop
        update-generic
    ] if ;

: define-standard-generic ( word -- )
    T{ standard-combination } define-generic ;

: GENERIC:
    CREATE define-standard-generic ; parsing

: define-hook-generic ( word var -- )
    hook-combination construct-boa define-generic ;

: HOOK:
    CREATE scan-word define-hook-generic ; parsing

: method ( classes word -- method )
    "multi-methods" word-prop at ;

: with-methods ( word quot -- )
    over >r >r "multi-methods" word-prop
    r> call r> update-generic ; inline

: define-method ( quot classes generic -- )
    >r [ bootstrap-word ] map r>
    [ <method> ] 2keep
    [ set-at ] with-methods ;

: forget-method ( classes generic -- )
    [ delete-at ] with-methods ;

: method>spec ( method -- spec )
    dup method-classes swap method-generic add* ;

: parse-method ( -- quot classes generic )
    parse-definition dup 2 tail over second rot first ;

: METHOD:
    location
    >r parse-method [ define-method ] 2keep add* r>
    remember-definition ; parsing

! For compatibility
: M:
    scan-word 1array scan-word parse-definition
    -rot define-method ; parsing

! Definition protocol. We qualify core generics here
USE: qualified
QUALIFIED: syntax

PREDICATE: generic < word
    "multi-combination" word-prop >boolean ;

PREDICATE: standard-generic < word
    "multi-combination" word-prop standard-combination? ;

PREDICATE: hook-generic < word
    "multi-combination" word-prop hook-combination? ;

syntax:M: standard-generic definer drop \ GENERIC: f ;

syntax:M: standard-generic definition drop f ;

syntax:M: hook-generic definer drop \ HOOK: f ;

syntax:M: hook-generic definition drop f ;

syntax:M: hook-generic synopsis*
    dup definer.
    dup seeing-word
    dup pprint-word
    dup "multi-combination" word-prop
    hook-combination-var pprint-word stack-effect. ;

PREDICATE: method-spec < array
    unclip generic? >r [ class? ] all? r> and ;

syntax:M: method-spec where
    dup unclip method [ method-loc ] [ second where ] ?if ;

syntax:M: method-spec set-where
    unclip method set-method-loc ;

syntax:M: method-spec definer
    drop \ METHOD: \ ; ;

syntax:M: method-spec definition
    unclip method dup [ method-def ] when ;

syntax:M: method-spec synopsis*
    dup definer.
    unclip pprint* pprint* ;

syntax:M: method-spec forget*
    unclip forget-method ;
