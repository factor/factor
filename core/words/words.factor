! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs definitions hashtables kernel
kernel.private math math.order namespaces quotations sequences
slots.private strings vocabs ;
IN: words

BUILTIN: word
{ hashcode fixnum initial: 0 } name vocabulary
{ def quotation initial: [ ] } props pic-def pic-tail-def
{ sub-primitive read-only } ;

PRIMITIVE: word-code ( word -- start end )
PRIMITIVE: word-optimized? ( word -- ? )

<PRIVATE
PRIMITIVE: (word) ( name vocab hashcode -- word )
PRIVATE>

: last-word ( -- word ) \ last-word get-global ;

: set-last-word ( word -- ) \ last-word set-global ;

M: word execute (execute) ;

M: word <=> [ [ name>> ] [ vocabulary>> ] bi 2array ] compare ;

M: word definer drop \ : \ ; ;

M: word definition def>> ;

: word-prop ( word name -- value ) swap props>> at ;

: remove-word-prop ( word name -- ) swap props>> delete-at ;

: remove-word-props ( word seq -- )
    swap props>> [ delete-at ] curry each ;

: set-word-prop ( word value name -- )
    over
    [ pick props>> ?set-at >>props drop ]
    [ nip remove-word-prop ] if ;

: change-word-prop ( ..a word prop quot: ( ..a value -- ..b newvalue ) -- ..b )
    [ swap props>> ] dip change-at ; inline

<PRIVATE

: caller ( callstack -- word )
    callstack>array first ;

PRIVATE>

TUPLE: undefined-word word ;

: undefined ( -- * ) get-callstack caller undefined-word boa throw ;

: undefined-def ( -- quot )
    ! 'f' inhibits tail call optimization in non-optimizing
    ! compiler, ensuring that we can pull out the caller word
    ! above.
    [ undefined f ] ;

PREDICATE: deferred < word def>> undefined-def = ;
M: deferred definer drop \ DEFER: f ;
M: deferred definition drop f ;

PREDICATE: primitive < word "primitive" word-prop ;
M: primitive definer drop \ PRIMITIVE: f ;
M: primitive definition drop f ;

ERROR: invalid-primitive vocabulary word effect ;
: ensure-primitive ( vocabulary word effect -- )
    3dup
    [ drop vocabulary>> = ]
    [ drop nip primitive? ]
    [ [ nip "declared-effect" word-prop ] dip = ] 3tri and and
    [ 3drop ] [ invalid-primitive ] if ;

: lookup-word ( name vocab -- word ) vocab-words-assoc at ;

: target-word ( word -- target )
    [ name>> ] [ vocabulary>> ] bi lookup-word ;

SYMBOL: bootstrapping?

: if-bootstrapping ( true false -- )
    [ bootstrapping? get ] 2dip if ; inline

: bootstrap-word ( word -- target )
    [ target-word ] [ ] if-bootstrapping ;

GENERIC: crossref? ( word -- ? )

M: word crossref?
    dup "forgotten" word-prop [ drop f ] [ vocabulary>> >boolean ] if ;

GENERIC: subwords ( word -- seq )

M: word subwords drop f ;

GENERIC: parent-word ( word -- word/f )

M: word parent-word drop f ;

: define ( word def -- )
    over changed-definition [ ] like >>def drop ;

: changed-effect ( word -- )
    [ changed-effects get add-to-unit ]
    [ dup primitive? [ drop ] [ changed-definition ] if ] bi ;

: set-stack-effect ( word effect -- )
    2dup [ "declared-effect" word-prop ] dip =
    [ 2drop ] [
        [ drop changed-effect ]
        [ drop subwords [ changed-effect ] each ]
        [ "declared-effect" set-word-prop ]
        2tri
    ] if ;

: define-declared ( word def effect -- )
    [ nip set-stack-effect ] [ drop define ] 3bi ;

: make-deprecated ( word -- )
    t "deprecated" set-word-prop ;

: word-prop? ( obj string -- ? )
    over word? [ word-prop ] [ 2drop f ] if ; inline

: inline? ( obj -- ? ) "inline" word-prop? ; inline

: recursive? ( obj -- ? ) "recursive" word-prop? ; inline

: inline-recursive? ( obj -- ? )
    dup inline? [ recursive? ] [ drop f ] if ; inline

ERROR: cannot-be-inline word ;

GENERIC: make-inline ( word -- )

M: word make-inline
    dup inline? [ drop ] [
        [ t "inline" set-word-prop ]
        [ changed-effect ]
        bi
    ] if ;

: define-inline ( word def effect -- )
    [ define-declared ] [ 2drop make-inline ] 3bi ;

: make-recursive ( word -- )
    t "recursive" set-word-prop ;

GENERIC: flushable? ( word -- ? )

M: word flushable?
    [ "flushable" word-prop ]
    [ parent-word dup [ flushable? ] when ] bi or ;

: make-flushable ( word -- )
    t "flushable" set-word-prop ;

GENERIC: foldable? ( word -- ? )

M: word foldable?
    [ "foldable" word-prop ]
    [ parent-word dup [ foldable? ] when ] bi or ;

: make-foldable ( word -- )
    [ make-flushable ]
    [ t "foldable" set-word-prop ] bi ;

GENERIC: reset-word ( word -- )

M: word reset-word
    dup flushable? [ dup changed-conditionally ] when
    {
        "unannotated-def" "parsing" "inline" "recursive"
        "foldable" "flushable" "reading" "writing" "reader"
        "writer" "delimiter" "deprecated"
    } remove-word-props ;

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
        } remove-word-props
    ] tri ;

: <word> ( name vocab -- word )
    over hashcode over hashcode hash-combine >fixnum (word) dup new-word ;

PREDICATE: uninterned-word < word vocabulary>> not ;

: <uninterned-word> ( name -- word )
    f \ <uninterned-word> counter >fixnum (word)
    new-words get [ dup new-word ] when ;

: gensym ( -- word )
    "( gensym )" <uninterned-word> ;

: define-temp ( quot effect -- word )
    [ gensym dup ] 2dip define-declared ;

: reveal ( word -- )
    dup [ name>> ] [ vocabulary>> ] bi
    [ vocab-words-assoc ] [ no-vocab ] ?unless set-at ;

ERROR: bad-create name vocab ;

: check-create ( name vocab -- name vocab )
    2dup [ string? ] [ [ string? ] [ vocab? ] bi or ] bi* and
    [ bad-create ] unless ;

: create-word ( name vocab -- word )
    check-create 2dup lookup-word
    [ 2nip ] [
        vocab-name <word>
        dup reveal
        dup changed-definition
    ] if* ;

PREDICATE: parsing-word < word "parsing" word-prop ;

M: parsing-word definer drop \ SYNTAX: \ ; ;

: define-syntax ( word quot -- )
    [ drop ] [ define ] 2bi t "parsing" set-word-prop ;

: delimiter? ( obj -- ? ) "delimiter" word-prop? ;

: deprecated? ( obj -- ? ) "deprecated" word-prop? ;

! Definition protocol
M: word where "loc" word-prop ;

M: word set-where swap "loc" set-word-prop ;

M: word forget*
    dup "forgotten" word-prop [ drop ] [
        [ subwords forget-all ]
        [ [ name>> ] [ vocabulary>> vocab-words-assoc ] bi delete-at ]
        [ t "forgotten" set-word-prop ]
        tri
    ] if ;

! Can be foldable because the hashcode itself is immutable
M: word hashcode*
    nip 1 slot { fixnum } declare ; inline foldable

M: word literalize <wrapper> ;

INSTANCE: word definition-mixin
