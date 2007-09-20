! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: words
USING: arrays definitions graphs assocs kernel kernel.private
slots.private math namespaces sequences strings vectors sbufs
quotations assocs hashtables sorting math.parser words.private
vocabs ;

GENERIC: execute ( word -- )

M: word execute (execute) ;

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

! Used by the compiler
SYMBOL: changed-words

: word-changed? ( word -- ? )
    changed-words get [ key? ] [ drop f ] if* ;

: changed-word ( word -- )
    dup changed-words get [ set-at ] [ 2drop ] if* ;

: unchanged-word ( word -- )
    changed-words get [ delete-at ] [ drop ] if* ;

M: word <=>
    [ dup word-name swap word-vocabulary 2array ] compare ;

M: word definition drop f ;

PREDICATE: word undefined ( obj -- ? ) word-def not ;
M: undefined definer drop \ DEFER: f ;

PREDICATE: word compound  ( obj -- ? ) word-def quotation? ;

M: compound definer drop \ : \ ; ;

M: compound definition word-def ;

PREDICATE: word primitive ( obj -- ? ) word-def fixnum? ;
M: primitive definer drop \ PRIMITIVE: f ;

PREDICATE: word symbol    ( obj -- ? ) word-def t eq? ;
M: symbol definer drop \ SYMBOL: f ;

: word-prop ( word name -- value ) swap word-props at ;

: remove-word-prop ( word name -- )
    swap word-props delete-at ;

: set-word-prop ( word value name -- )
    over
    [ pick word-props ?set-at swap set-word-props ]
    [ nip remove-word-prop ] if ;

: reset-props ( word seq -- ) [ remove-word-prop ] curry* each ;

: lookup ( name vocab -- word ) vocab-words at ;

: target-word ( word -- target )
    dup word-name swap word-vocabulary lookup ;

SYMBOL: bootstrapping?

: if-bootstrapping ( true false -- )
    bootstrapping? get -rot if ; inline

: bootstrap-word ( word -- target )
    [ target-word ] [ ] if-bootstrapping ;

PREDICATE: word interned dup target-word eq? ;

GENERIC# (quot-uses) 1 ( obj assoc -- )

M: object (quot-uses) 2drop ;

M: interned (quot-uses) dupd set-at ;

: seq-uses ( seq assoc -- ) [ (quot-uses) ] curry each ;

M: array (quot-uses) seq-uses ;

M: callable (quot-uses) seq-uses ;

M: wrapper (quot-uses) >r wrapped r> (quot-uses) ;

: quot-uses ( quot -- assoc )
    global [ H{ } clone [ (quot-uses) ] keep ] bind ;

M: word uses ( word -- seq )
    word-def quot-uses keys ;

M: compound redefined* ( word -- )
    dup changed-word
    { "inferred-effect" "base-case" "no-effect" } reset-props ;

<PRIVATE

: definition-changed? ( word def -- ? )
    swap word-def = not ;

: define ( word def -- )
    2dup definition-changed? [
        over redefined
        over unxref
        over set-word-def
        dup update-xt
        dup word-vocabulary [
            dup changed-word dup xref
        ] when drop
    ] [
        2drop
    ] if ;

PRIVATE>

: define-symbol ( word -- ) t define ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] if ;

: define-compound ( word def -- ) [ ] like define ;

: define-declared ( word def effect -- )
    pick swap "declared-effect" set-word-prop
    define-compound ;

: make-inline ( word -- )
    t "inline" set-word-prop ;

: make-flushable ( word -- )
    t "flushable" set-word-prop ;

: make-foldable ( word -- )
    dup make-flushable t "foldable" set-word-prop ;

: define-inline ( word quot -- )
    dupd define-compound make-inline ;

: reset-word ( word -- )
    {
        "parsing" "inline" "foldable"
        "predicating"
        "reading" "writing"
        "constructing"
        "declared-effect" "constructor-quot" "delimiter"
    } reset-props ;

: reset-generic ( word -- )
    dup reset-word { "methods" "combination" } reset-props ;

: gensym ( -- word )
    "G:" \ gensym counter number>string append f <word> ;

: define-temp ( quot -- word )
    gensym [ swap define-compound ] keep ;

: reveal ( word -- )
    dup word-name over word-vocabulary vocab-words set-at ;

TUPLE: check-create name vocab ;

: check-create ( name vocab -- name vocab )
    2dup [ string? ] both? [
        \ check-create construct-boa throw
    ] unless ;

: create ( name vocab -- word )
    check-create 2dup lookup
    dup [ 2nip ] [ drop <word> dup reveal ] if ;

: constructor-word ( name vocab -- word )
    >r "<" swap ">" 3append r> create ;

: parsing? ( obj -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] if ;

: delimiter? ( obj -- ? )
    dup word? [ "delimiter" word-prop ] [ drop f ] if ;

! Definition protocol
M: word where "loc" word-prop ;

M: word set-where swap "loc" set-word-prop ;

GENERIC: (forget-word) ( word -- )

M: interned (forget-word)
    dup word-name swap word-vocabulary vocab-words delete-at ;

M: word (forget-word)
    drop ;

: rename-word ( word newname newvocab -- )
    pick (forget-word)
    pick set-word-vocabulary
    over set-word-name
    reveal ;

: forget-word ( word -- )
    dup f "methods" set-word-prop
    dup delete-xref
    dup unchanged-word
    (forget-word) ;

M: word forget forget-word ;

M: word hashcode*
    nip 1 slot { fixnum } declare ;

M: word literalize <wrapper> ;

: ?word-name dup word? [ word-name ] when ;

: xref-words ( -- ) all-words [ xref ] each ;
