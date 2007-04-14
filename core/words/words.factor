! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions graphs assocs kernel kernel.private
slots.private math namespaces sequences strings vectors sbufs
quotations assocs hashtables sorting math.parser words.private
vocabs combinators ;
IN: words

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

GENERIC: execute ( word -- )

M: word execute (execute) ;

M: word <=>
    [ dup word-name swap word-vocabulary 2array ] compare ;

M: word definer drop \ : \ ; ;

M: word definition word-def ;

ERROR: undefined ;

PREDICATE: deferred < word ( obj -- ? )
    word-def [ undefined ] = ;
M: deferred definer drop \ DEFER: f ;
M: deferred definition drop f ;

PREDICATE: symbol < word ( obj -- ? )
    dup <wrapper> 1array swap word-def sequence= ;
M: symbol definer drop \ SYMBOL: f ;
M: symbol definition drop f ;

PREDICATE: primitive < word ( obj -- ? )
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

: reset-props ( word seq -- ) [ remove-word-prop ] with each ;

: lookup ( name vocab -- word ) vocab-words at ;

: target-word ( word -- target )
    dup word-name swap word-vocabulary lookup ;

SYMBOL: bootstrapping?

: if-bootstrapping ( true false -- )
    bootstrapping? get -rot if ; inline

: bootstrap-word ( word -- target )
    [ target-word ] [ ] if-bootstrapping ;

: crossref? ( word -- ? )
    {
        { [ dup "forgotten" word-prop ] [ f ] }
        { [ dup "method-generic" word-prop ] [ t ] }
        { [ dup word-vocabulary ] [ t ] }
        { [ t ] [ f ] }
    } cond nip ;

GENERIC# (quot-uses) 1 ( obj assoc -- )

M: object (quot-uses) 2drop ;

M: word (quot-uses)
    >r dup crossref? [ dup r> set-at ] [ r> 2drop ] if ;

: seq-uses ( seq assoc -- ) [ (quot-uses) ] curry each ;

M: array (quot-uses) seq-uses ;

M: callable (quot-uses) seq-uses ;

M: wrapper (quot-uses) >r wrapped r> (quot-uses) ;

: quot-uses ( quot -- assoc )
    global [ H{ } clone [ (quot-uses) ] keep ] bind ;

M: word uses ( word -- seq )
    word-def quot-uses keys ;

SYMBOL: compiled-crossref

compiled-crossref global [ H{ } assoc-like ] change-at

: compiled-xref ( word dependencies -- )
    [ drop crossref? ] assoc-subset
    2dup "compiled-uses" set-word-prop
    compiled-crossref get add-vertex* ;

: compiled-unxref ( word -- )
    dup "compiled-uses" word-prop
    compiled-crossref get remove-vertex* ;

: delete-compiled-xref ( word -- )
    dup compiled-unxref
    compiled-crossref get delete-at ;

SYMBOL: +inlined+
SYMBOL: +called+

: compiled-usage ( word -- assoc )
    compiled-crossref get at ;

: compiled-usages ( words -- seq )
    [ [ dup ] H{ } map>assoc dup ] keep [
        compiled-usage [ nip +inlined+ eq? ] assoc-subset update
    ] with each keys ;

M: word redefined* ( word -- )
    { "inferred-effect" "no-effect" } reset-props ;

SYMBOL: changed-words

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
    dup crossref? [ dup xref ] when drop ;

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
        "parsing" "inline" "foldable" "flushable"
        "predicating"
        "reading" "writing"
        "constructing"
        "declared-effect" "constructor-quot" "delimiter"
    } reset-props ;

GENERIC: subwords ( word -- seq )

M: word subwords drop f ;

: reset-generic ( word -- )
    dup subwords [ forget ] each
    dup reset-word
    { "methods" "combination" "default-method" } reset-props ;

: gensym ( -- word )
    "G:" \ gensym counter number>string append f <word> ;

: define-temp ( quot -- word )
    gensym dup rot define ;

: reveal ( word -- )
    dup word-name over word-vocabulary dup vocab-words
    [ ] [ no-vocab ] ?if
    set-at ;

ERROR: bad-create name vocab ;

: check-create ( name vocab -- name vocab )
    2dup [ string? ] both?
    [ bad-create ] unless ;

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

GENERIC: forget-word ( word -- )

: (forget-word) ( word -- )
    dup "forgotten" word-prop [
        dup delete-xref
        dup delete-compiled-xref
        dup word-name over word-vocabulary vocab-words delete-at
        dup t "forgotten" set-word-prop
    ] unless drop ;

M: word forget-word (forget-word) ;

M: word forget* forget-word ;

M: word hashcode*
    nip 1 slot { fixnum } declare ;

M: word literalize <wrapper> ;

: ?word-name dup word? [ word-name ] when ;

: xref-words ( -- ) all-words [ xref ] each ;
