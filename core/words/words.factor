! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: words
USING: arrays definitions graphs assocs kernel kernel.private
slots.private math namespaces sequences strings vectors sbufs
quotations assocs hashtables sorting math.parser words.private
vocabs ;

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

GENERIC: execute ( word -- )

M: word execute (execute) ;

M: word <=>
    [ dup word-name swap word-vocabulary 2array ] compare ;

M: word definer drop \ : \ ; ;

M: word definition word-def ;

TUPLE: undefined ;

: undefined ( -- * ) \ undefined construct-empty throw ;

PREDICATE: word deferred ( obj -- ? )
    word-def [ undefined ] = ;
M: deferred definer drop \ DEFER: f ;
M: deferred definition drop f ;

PREDICATE: word symbol ( obj -- ? )
    dup <wrapper> 1array swap word-def sequence= ;
M: symbol definer drop \ SYMBOL: f ;
M: symbol definition drop f ;

PREDICATE: word primitive ( obj -- ? )
    word-def [ do-primitive ] tail? ;
M: primitive definer drop \ PRIMITIVE: f ;
M: primitive definition drop f ;

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

M: word redefined* ( word -- )
    { "inferred-effect" "base-case" "no-effect" } reset-props ;

SYMBOL: changed-words

TUPLE: no-compilation-unit word ;

: no-compilation-unit ( word -- * )
    \ no-compilation-unit construct-boa throw ;

: changed-word ( word -- )
    dup changed-words get
    [ no-compilation-unit ] unless*
    set-at ;

: define ( word def -- )
    [ ] like
    over unxref
    over redefined
    over set-word-def
    dup changed-word
    dup word-vocabulary [ dup xref ] when drop ;

: define-declared ( word def effect -- )
    pick swap "declared-effect" set-word-prop
    define ;

: make-inline ( word -- )
    t "inline" set-word-prop ;

: make-flushable ( word -- )
    t "flushable" set-word-prop ;

: make-foldable ( word -- )
    dup make-flushable t "foldable" set-word-prop ;

: define-inline ( word quot -- )
    dupd define make-inline ;

: define-symbol ( word -- )
    dup [ ] curry define-inline ;

: reset-word ( word -- )
    {
        "unannotated-def"
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
    gensym dup rot define ;

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
    dup delete-xref
    (forget-word) ;

M: word forget forget-word ;

M: word hashcode*
    nip 1 slot { fixnum } declare ;

M: word literalize <wrapper> ;

: ?word-name dup word? [ word-name ] when ;

: xref-words ( -- ) all-words [ xref ] each ;
