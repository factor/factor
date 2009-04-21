! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions graphs assocs kernel
kernel.private slots.private math namespaces sequences strings
vectors sbufs quotations assocs hashtables sorting words.private
vocabs math.order sets ;
IN: words

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

M: word execute (execute) ;

M: word ?execute execute( -- value ) ;

M: word <=>
    [ [ name>> ] [ vocabulary>> ] bi 2array ] compare ;

M: word definer drop \ : \ ; ;

M: word definition def>> ;

ERROR: undefined ;

PREDICATE: deferred < word ( obj -- ? )
    def>> [ undefined ] = ;
M: deferred definer drop \ DEFER: f ;
M: deferred definition drop f ;

PREDICATE: primitive < word ( obj -- ? )
    [ def>> [ do-primitive ] tail? ]
    [ sub-primitive>> >boolean ]
    bi or ;
M: primitive definer drop \ PRIMITIVE: f ;
M: primitive definition drop f ;

: word-prop ( word name -- value ) swap props>> at ;

: remove-word-prop ( word name -- ) swap props>> delete-at ;

: set-word-prop ( word value name -- )
    over
    [ pick props>> ?set-at >>props drop ]
    [ nip remove-word-prop ] if ;

: reset-props ( word seq -- ) [ remove-word-prop ] with each ;

: lookup ( name vocab -- word ) vocab-words at ;

: target-word ( word -- target )
    [ name>> ] [ vocabulary>> ] bi lookup ;

SYMBOL: bootstrapping?

: if-bootstrapping ( true false -- )
    [ bootstrapping? get ] 2dip if ; inline

: bootstrap-word ( word -- target )
    [ target-word ] [ ] if-bootstrapping ;

GENERIC: crossref? ( word -- ? )

M: word crossref?
    dup "forgotten" word-prop [
        drop f
    ] [
        vocabulary>> >boolean
    ] if ;

GENERIC# (quot-uses) 1 ( obj assoc -- )

M: object (quot-uses) 2drop ;

M: word (quot-uses) over crossref? [ conjoin ] [ 2drop ] if ;

: seq-uses ( seq assoc -- ) [ (quot-uses) ] curry each ;

M: array (quot-uses) seq-uses ;

M: hashtable (quot-uses) [ >alist ] dip seq-uses ;

M: callable (quot-uses) seq-uses ;

M: wrapper (quot-uses) [ wrapped>> ] dip (quot-uses) ;

: quot-uses ( quot -- assoc )
    global [ H{ } clone [ (quot-uses) ] keep ] bind ;

M: word uses ( word -- seq )
    def>> quot-uses keys ;

SYMBOL: compiled-crossref

compiled-crossref [ H{ } clone ] initialize

SYMBOL: compiled-generic-crossref

compiled-generic-crossref [ H{ } clone ] initialize

: (compiled-xref) ( word dependencies word-prop variable -- )
    [ [ set-word-prop ] curry ]
    [ [ get add-vertex* ] curry ]
    bi* 2bi ;

: compiled-xref ( word dependencies generic-dependencies -- )
    [ [ drop crossref? ] { } assoc-filter-as f like ] bi@
    [ "compiled-uses" compiled-crossref (compiled-xref) ]
    [ "compiled-generic-uses" compiled-generic-crossref (compiled-xref) ]
    bi-curry* bi ;

: (compiled-unxref) ( word word-prop variable -- )
    [ [ [ dupd word-prop ] dip get remove-vertex* ] 2curry ]
    [ drop [ remove-word-prop ] curry ]
    2bi bi ;

: compiled-unxref ( word -- )
    [ "compiled-uses" compiled-crossref (compiled-unxref) ]
    [ "compiled-generic-uses" compiled-generic-crossref (compiled-unxref) ]
    bi ;

: delete-compiled-xref ( word -- )
    [ compiled-unxref ]
    [ compiled-crossref get delete-at ]
    [ compiled-generic-crossref get delete-at ]
    tri ;

: inline? ( word -- ? ) "inline" word-prop ; inline

GENERIC: subwords ( word -- seq )

M: word subwords drop f ;

<PRIVATE

SYMBOL: visited

CONSTANT: reset-on-redefine { "inferred-effect" "cannot-infer" }

: relevant-callers ( word -- seq )
    crossref get at keys
    [ word? ] filter
    [
        [ reset-on-redefine [ word-prop ] with any? ]
        [ inline? ]
        bi or
    ] filter ;

: (redefined) ( word -- )
    dup visited get key? [ drop ] [
        [ reset-on-redefine reset-props ]
        [ visited get conjoin ]
        [
            [ relevant-callers [ (redefined) ] each ]
            [ subwords [ (redefined) ] each ]
            bi
        ] tri
    ] if ;

PRIVATE>

: redefined ( word -- )
    [ H{ } clone visited [ (redefined) ] with-variable ]
    [ changed-definition ]
    bi ;

: define ( word def -- )
    [ ] like
    over unxref
    over redefined
    >>def
    dup crossref? [ dup xref ] when drop ;

: set-stack-effect ( effect word -- )
    2dup "declared-effect" word-prop = [ 2drop ] [
        swap
        [ drop changed-effect ]
        [ "declared-effect" set-word-prop ]
        [ drop dup primitive? [ drop ] [ redefined ] if ]
        2tri
    ] if ;

: define-declared ( word def effect -- )
    [ nip swap set-stack-effect ] [ drop define ] 3bi ;

: make-inline ( word -- )
    t "inline" set-word-prop ;

: make-recursive ( word -- )
    t "recursive" set-word-prop ;

: make-flushable ( word -- )
    t "flushable" set-word-prop ;

: make-foldable ( word -- )
    dup make-flushable t "foldable" set-word-prop ;

: define-inline ( word def effect -- )
    [ define-declared ] [ 2drop make-inline ] 3bi ;

GENERIC: reset-word ( word -- )

M: word reset-word
    {
        "unannotated-def" "parsing" "inline" "recursive"
        "foldable" "flushable" "reading" "writing" "reader"
        "writer" "delimiter"
    } reset-props ;

: reset-generic ( word -- )
    [ subwords forget-all ]
    [ reset-word ]
    [ { "methods" "combination" "default-method" } reset-props ]
    tri ;

: gensym ( -- word )
    "( gensym )" f <word> ;

: define-temp ( quot effect -- word )
    [ gensym dup ] 2dip define-declared ;

: reveal ( word -- )
    dup [ name>> ] [ vocabulary>> ] bi dup vocab-words
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
    [ "<" ">" surround ] dip create ;

PREDICATE: parsing-word < word "parsing" word-prop ;

M: parsing-word definer drop \ SYNTAX: \ ; ;

: define-syntax ( word quot -- )
    [ drop ] [ define ] 2bi t "parsing" set-word-prop ;

: delimiter? ( obj -- ? )
    dup word? [ "delimiter" word-prop ] [ drop f ] if ;

! Definition protocol
M: word where "loc" word-prop ;

M: word set-where swap "loc" set-word-prop ;

M: word forget*
    dup "forgotten" word-prop [ drop ] [
        [ delete-xref ]
        [ [ name>> ] [ vocabulary>> vocab-words ] bi delete-at ]
        [ t "forgotten" set-word-prop ]
        tri
    ] if ;

M: word hashcode*
    nip 1 slot { fixnum } declare ; foldable

M: word literalize <wrapper> ;

: xref-words ( -- ) all-words [ xref ] each ;

INSTANCE: word definition