! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions kernel kernel.private
slots.private math namespaces sequences strings vectors sbufs
quotations assocs hashtables sorting vocabs math.order sets
words.private ;
IN: words

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

M: word execute (execute) ;

M: word ?execute execute( -- value ) ; inline

M: word <=>
    [ [ name>> ] [ vocabulary>> ] bi 2array ] compare ;

M: word definer drop \ : \ ; ;

M: word definition def>> ;

: word-prop ( word name -- value ) swap props>> at ;

: remove-word-prop ( word name -- ) swap props>> delete-at ;

: set-word-prop ( word value name -- )
    over
    [ pick props>> ?set-at >>props drop ]
    [ nip remove-word-prop ] if ;

: reset-props ( word seq -- ) [ remove-word-prop ] with each ;

<PRIVATE

: caller ( callstack -- word ) callstack>array <reversed> third ;

PRIVATE>

TUPLE: undefined word ;
: undefined ( -- * ) callstack caller \ undefined boa throw ;

: undefined-def ( -- quot )
    #! 'f' inhibits tail call optimization in non-optimizing
    #! compiler, ensuring that we can pull out the caller word
    #! above.
    [ undefined f ] ;

PREDICATE: deferred < word ( obj -- ? ) def>> undefined-def = ;
M: deferred definer drop \ DEFER: f ;
M: deferred definition drop f ;

PREDICATE: primitive < word ( obj -- ? ) "primitive" word-prop ;
M: primitive definer drop \ PRIMITIVE: f ;
M: primitive definition drop f ;

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
    dup "forgotten" word-prop [ drop f ] [ vocabulary>> >boolean ] if ;

: inline? ( word -- ? ) "inline" word-prop ; inline

GENERIC: subwords ( word -- seq )

M: word subwords drop f ;

: define ( word def -- )
    over changed-definition [ ] like >>def drop ;

: changed-effect ( word -- )
    [ dup changed-effects get set-in-unit ]
    [ dup primitive? [ drop ] [ changed-definition ] if ] bi ;

: set-stack-effect ( effect word -- )
    2dup "declared-effect" word-prop = [ 2drop ] [
        [ nip changed-effect ]
        [ nip subwords [ changed-effect ] each ]
        [ swap "declared-effect" set-word-prop ]
        2tri
    ] if ;

: define-declared ( word def effect -- )
    [ nip swap set-stack-effect ] [ drop define ] 3bi ;

: make-deprecated ( word -- )
    t "deprecated" set-word-prop ;

ERROR: cannot-be-inline word ;

GENERIC: make-inline ( word -- )

M: word make-inline
    dup inline? [ drop ] [
        [ t "inline" set-word-prop ]
        [ changed-effect ]
        bi
    ] if ;

: make-recursive ( word -- )
    t "recursive" set-word-prop ;

: make-flushable ( word -- )
    t "flushable" set-word-prop ;

: make-foldable ( word -- )
    dup make-flushable t "foldable" set-word-prop ;

: define-inline ( word def effect -- )
    [ define-declared ] [ 2drop make-inline ] 3bi ;

GENERIC: flushable? ( word -- ? )

M: word flushable? "flushable" word-prop ;

GENERIC: reset-word ( word -- )

M: word reset-word
    dup flushable? [ dup changed-conditionally ] when
    {
        "unannotated-def" "parsing" "inline" "recursive"
        "foldable" "flushable" "reading" "writing" "reader"
        "writer" "delimiter" "deprecated"
    } reset-props ;

: reset-generic ( word -- )
    [ subwords forget-all ]
    [ reset-word ]
    [
        f >>pic-def
        f >>pic-tail-def
        {
            "methods"
            "combination"
            "default-method"
            "engines"
            "decision-tree"
        } reset-props
    ] tri ;

: <word> ( name vocab -- word )
    2dup [ hashcode ] bi@ bitxor >fixnum (word) dup new-word ;

: <uninterned-word> ( name -- word )
    f \ <uninterned-word> counter >fixnum (word)
    new-words get [ dup new-word ] when ;

: gensym ( -- word )
    "( gensym )" <uninterned-word> ;

: define-temp ( quot effect -- word )
    [ gensym dup ] 2dip define-declared ;

: reveal ( word -- )
    dup [ name>> ] [ vocabulary>> ] bi dup vocab-words
    [ ] [ no-vocab ] ?if
    set-at ;

ERROR: bad-create name vocab ;

: check-create ( name vocab -- name vocab )
    2dup [ string? ] [ [ string? ] [ vocab? ] bi or ] bi* and
    [ bad-create ] unless ;

: create ( name vocab -- word )
    check-create 2dup lookup
    dup [ 2nip ] [
        drop
        vocab-name <word>
        dup reveal
        dup changed-definition
    ] if ;

: constructor-word ( name vocab -- word )
    [ "<" ">" surround ] dip create ;

PREDICATE: parsing-word < word "parsing" word-prop ;

M: parsing-word definer drop \ SYNTAX: \ ; ;

: define-syntax ( word quot -- )
    [ drop ] [ define ] 2bi t "parsing" set-word-prop ;

: delimiter? ( obj -- ? )
    dup word? [ "delimiter" word-prop ] [ drop f ] if ;

: deprecated? ( obj -- ? )
    dup word? [ "deprecated" word-prop ] [ drop f ] if ;

! Definition protocol
M: word where "loc" word-prop ;

M: word set-where swap "loc" set-word-prop ;

M: word forget*
    dup "forgotten" word-prop [ drop ] [
        [ [ name>> ] [ vocabulary>> vocab-words ] bi delete-at ]
        [ t "forgotten" set-word-prop ]
        bi
    ] if ;

M: word hashcode*
    nip 1 slot { fixnum } declare ; inline foldable

M: word literalize <wrapper> ;

INSTANCE: word definition
