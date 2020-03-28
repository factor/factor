! Copyright (C) 2019 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit kernel math modern modern.compiler
sequences splitting.monotonic strings words ;
IN: modern.manifest

MIXIN: token

TUPLE: uri
    uri
    vocab-root
    vocab
    section-path
    word ;


TUPLE: syntax-forms
    sections
    named-sections
    ucolons
    lcolons
    containers
    braces
    brackets
    parens
    ldecorators
    rdecorators

    named-section-arities
    ucolon-arities
    ;

: <syntax-forms> ( -- syntax-forms )
    syntax-forms new
        H{ } clone >>sections
        H{ } clone >>named-sections
        H{ } clone >>ucolons
        H{ } clone >>lcolons
        H{ } clone >>containers
        H{ } clone >>braces
        H{ } clone >>brackets
        H{ } clone >>parens
        H{ } clone >>ldecorators
        H{ } clone >>rdecorators

        H{ } clone >>named-section-arities
        H{ } clone >>ucolon-arities
    ; inline

ERROR: key-exists val key assoc existing-value ;
: checked-set-at ( val key assoc -- )
    2dup ?at [ key-exists ] [ drop set-at ] if ;

: add-section-form ( syntax-forms parser tag -- syntax-forms ) pick sections>> checked-set-at ;
: add-ucolon-form ( syntax-forms parser tag -- syntax-forms ) pick ucolons>> checked-set-at ;
: add-lcolon-form ( syntax-forms parser tag -- syntax-forms ) pick lcolons>> checked-set-at ;
: add-containers-form ( syntax-forms parser tag -- syntax-forms ) pick containers>> checked-set-at ;
: add-braces-form ( syntax-forms parser tag -- syntax-forms ) pick braces>> checked-set-at ;
: add-brackets-form ( syntax-forms parser tag -- syntax-forms ) pick brackets>> checked-set-at ;
: add-parens-form ( syntax-forms parser tag -- syntax-forms ) pick parens>> checked-set-at ;
: add-ldecorators-form ( syntax-forms parser tag -- syntax-forms ) pick ldecorators>> checked-set-at ;
: add-rdecorators-form ( syntax-forms parser tag -- syntax-forms ) pick rdecorators>> checked-set-at ;

: add-ucolon-arity ( syntax-forms parser tag -- syntax-forms ) pick ucolon-arities>> checked-set-at ;
: add-named-section-arity ( syntax-forms parser tag -- syntax-forms ) pick named-section-arities>> checked-set-at ;

: lookup-arity ( form syntax-forms -- n/f )
    over upper-colon? [
        [ first >string but-last ] [ ucolon-arities>> ] bi* at
    ] [
        2drop f
    ] if ;

: lookup-decorator ( name syntax-forms -- n/f )
    rdecorators>> at ;

! One syntax-forms per vocab-root
: core-syntax-forms ( -- obj )
    <syntax-forms>
        ! <PRIVATE
        "factor-section" "FACTOR" add-section-form
        "linux-section" "LINUX" add-section-form
        "macos-section" "MACOS" add-section-form
        "windows-section" "WINDOWS" add-section-form
        "unix-section" "UNIX" add-section-form
        "private-section" "PRIVATE" add-section-form

        "word" "" add-ucolon-form  ! : :: ::: ...
        ! "about" "ABOUT" add-ucolon-form
        "alias" "ALIAS" add-ucolon-form
        "broadcast" "BROADCAST" add-ucolon-form
        "builtin" "BUILTIN" add-ucolon-form
        "constructor" "C" add-ucolon-form
        "constant" "CONSTANT" add-ucolon-form
        "consult" "CONSULT" add-ucolon-form
        "defer" "DEFER" add-ucolon-form
        "error" "ERROR" add-ucolon-form
        "exclude" "EXCLUDE" add-ucolon-form
        "forget" "FORGET" add-ucolon-form
        "generic#" "GENERIC#" add-ucolon-form
        "generic" "GENERIC" add-ucolon-form
        "hints" "HINTS" add-ucolon-form
        "hook" "HOOK" add-ucolon-form
        "identity-memo" "IDENTITY-MEMO" add-ucolon-form
        "in" "IN" add-ucolon-form
        "initialized-symbol" "INITIALIZED-SYMBOL" add-ucolon-form
        "instance" "INSTANCE" add-ucolon-form
        "intersection" "INTERSECTION" add-ucolon-form
        "method" "M" add-ucolon-form
        "macro" "MACRO" add-ucolon-form
        "main" "MAIN" add-ucolon-form
        "math" "MATH" add-ucolon-form
        "memo" "MEMO" add-ucolon-form
        "mixin" "MIXIN" add-ucolon-form
        "predicate" "PREDICATE" add-ucolon-form
        "primitive" "PRIMITIVE" add-ucolon-form
        "protocol" "PROTOCOL" add-ucolon-form
        "qualified-with" "QUALIFIED-WITH" add-ucolon-form
        "qualified" "QUALIFIED" add-ucolon-form
        "rename" "RENAME" add-ucolon-form
        "shutdown-hook" "SHUTDOWN-HOOK" add-ucolon-form
        "singleton" "SINGLETON" add-ucolon-form
        "singletons" "SINGLETONS" add-ucolon-form
        "slot-protocol" "SLOT-PROTOCOL" add-ucolon-form
        "slot" "SLOT" add-ucolon-form
        "startup-hook" "STARTUP-HOOK" add-ucolon-form
        "symbol" "SYMBOL" add-ucolon-form
        "symbols" "SYMBOLS" add-ucolon-form
        "syntax" "SYNTAX" add-ucolon-form
        "tuple" "TUPLE" add-ucolon-form
        "typed" "TYPED" add-ucolon-form
        "union" "UNION" add-ucolon-form
        "unuse" "UNUSE" add-ucolon-form
        "use" "USE" add-ucolon-form
        "using" "USING" add-ucolon-form
        "variables-functor" "VARIABLES-FUNCTOR" add-ucolon-form

        "initial" "initial" add-lcolon-form
        "nan" "nan" add-lcolon-form
        "char" "char" add-lcolon-form
        "breakpoint" "b" add-lcolon-form

        "array-data" "" add-braces-form ! {
        "byte-array-data" "B" add-braces-form
        "byte-vector-data" "BV" add-braces-form
        "callstack-data" "CS" add-braces-form
        "complex-data" "C" add-braces-form
        "hashset-data" "HS" add-braces-form
        "hash-data" "H" add-braces-form
        "immutable-hash-data" "IH" add-braces-form
        "tuple-hash-data" "TH" add-braces-form
        "tuple-data" "T" add-braces-form
        "vector-data" "V" add-braces-form
        "wrapper-data" "W" add-braces-form
        "intersection" "intersection" add-braces-form
        "maybe" "maybe" add-braces-form
        "not" "not" add-braces-form
        "union" "union" add-braces-form

        "quotation" "" add-brackets-form ! [ ]
        "memoized-quotation" "MEMO" add-brackets-form
        "let" "let" add-brackets-form
        "binder-quotation" "|" add-brackets-form

        "stack-effect" "" add-parens-form ! ( )
        "call-paren" "call" add-parens-form ! call( )
        "execute-paren" "execute" add-parens-form ! execute( )

        "string" "" add-containers-form  ! "" [[ ]] [=[ ]=] ...
        "interpolate" "I" add-containers-form
        "string-buffer" "sbuf" add-containers-form
        "comment" "!" add-containers-form
        "comment" "#" add-containers-form
        "path" "path" add-containers-form

        "delimiter" "delimiter" add-rdecorators-form
        "deprecated" "deprecated" add-rdecorators-form
        "inline" "inline" add-rdecorators-form
        "recursive" "recursive" add-rdecorators-form
        "private" "private" add-rdecorators-form
        "final" "final" add-rdecorators-form
        "flushable" "flushable" add-rdecorators-form
        "foldable" "foldable" add-rdecorators-form

        2 "ALIAS" add-ucolon-arity
        1 "BUILTIN" add-ucolon-arity
        2 "C" add-ucolon-arity
        2 "CONSTANT" add-ucolon-arity
        1 "DEFER" add-ucolon-arity
        1 "FORGET" add-ucolon-arity
        3 "GENERIC#" add-ucolon-arity
        2 "GENERIC" add-ucolon-arity
        3 "HOOK" add-ucolon-arity
        1 "IN" add-ucolon-arity
        2 "INITIALIZED-SYMBOL" add-ucolon-arity
        2 "INSTANCE" add-ucolon-arity
        1 "MAIN" add-ucolon-arity
        2 "MATH" add-ucolon-arity
        1 "MIXIN" add-ucolon-arity
        2 "PRIMITIVE" add-ucolon-arity
        2 "QUALIFIED-WITH" add-ucolon-arity
        1 "QUALIFIED" add-ucolon-arity
        2 "RENAME" add-ucolon-arity
        2 "SHUTDOWN-HOOK" add-ucolon-arity
        1 "SINGLETON" add-ucolon-arity
        1 "SLOT" add-ucolon-arity
        2 "STARTUP-HOOK" add-ucolon-arity
        1 "SYMBOL" add-ucolon-arity
        1 "UNUSE" add-ucolon-arity
        1 "USE" add-ucolon-arity
    ;

: lookup-syntax ( string -- form ) ;

: ?glue-as ( seq1 seq2 glue exemplar -- seq )
    reach [
        glue-as
    ] [
        nip like nip
    ] if ; inline


ERROR: not-a-decorator obj ;

GENERIC#: apply-decorators2 1 ( seq syntax-forms -- seq' )

M: array apply-decorators2
    ! monotonoic-split doesn't iterate if only one item
    over length 1 = [
        '[ dup section? [ _ apply-decorators2 ] when ] map
    ] [
        dup '[
            nip dup slice? [
                >string _ rdecorators>> ?at [ not-a-decorator ] unless
            ] [
                dup section? [
                    [ _ apply-decorators2 ] change-payload drop f
                ] [
                    drop f
                ] if
            ] if
        ] monotonic-split
    ] if ;

M: section apply-decorators2
    '[ _ apply-decorators2 ] change-payload ;

! : apply-decorators ( seq syntax-forms -- seq' )
!    '[ [ nip dup slice? [ >string _ rdecorators>> at ] [ drop f ] if ] monotonic-split ] map-literals ;

: upper-colon>form ( seq -- form )
    [ first "syntax" lookup-word ] [ ] bi 2array ;

GENERIC: upper-colon>definitions ( form -- seq )

! M: \: upper-colon>definitions
!    second first >string ;

: form>definitions ( obj -- obj' )
    {
        { [ dup upper-colon? ] [ upper-colon>definitions ] }
        [ ]
    } cond ;


: loopn-index ( n quot -- )
    [ <iota> ] [ '[ @ not ] ] bi* find 2drop ; inline

: loopn ( n quot -- )
    [ drop ] prepose loopn-index ; inline


ERROR: undefined-find-nth m n seq quot ;

: check-trivial-find ( m n seq quot -- m n seq quot )
    pick 0 = [ undefined-find-nth ] when ; inline

: find-nth-from ( m n seq quot -- i/f elt/f )
    check-trivial-find [ f ] 3dip '[
        drop _ _ find-from [ dup [ 1 + ] when ] dip over
    ] loopn [ dup [ 1 - ] when ] dip ; inline

: find-nth ( n seq quot -- i/f elt/f )
    [ 0 ] 3dip find-nth-from ; inline


ERROR: combinator-nth-reached-end n seq quot ;

:: head-nth-match ( n seq quot -- seq' )
    n seq quot find-nth drop [
        [ seq ] dip 1 + head
    ] [
        n seq quot combinator-nth-reached-end
    ] if* ; inline

:: cut-nth-match ( n seq quot -- head tail )
    n seq quot find-nth drop [
        [ seq ] dip 1 + cut
    ] [
        n seq quot combinator-nth-reached-end
    ] if* ; inline

: multiline-comment? ( obj -- ? )
    { [ double-bracket? ] [ first "!" sequence= ] } 1&& ;

: any-comment? ( obj -- ? )
    { [ comment? ] [ multiline-comment? ] } 1|| ;

GENERIC#: fixup-arity 1 ( obj syntax-forms -- seq )

: change-upper-token-payload ( upper-colon quot -- upper-colon )
    dup '[
        dup length 2 = [ first2 _ call 2array ] [ first3 _ dip 3array ] if
    ] change-tokens ; inline

ERROR: closing-tag-required obj ;
M: upper-colon fixup-arity
    dupd lookup-arity [
        over tokens>> second [ any-comment? not ] cut-nth-match
        [ >>payload ] dip dup length '[ [ _ head* ] change-upper-token-payload ] dip swap prefix
        ! ! dup first " ;" >>closing-tag drop
    ] [
        ! dup closing-tag>> [ B closing-tag-required ] unless
        ! dup closing-tag>> [ " ;" >>closing-tag ] unless
    ] if* ;

M: section fixup-arity
    '[ [ _ fixup-arity ] map ] change-payload ;

M: array fixup-arity
    '[ _ fixup-arity ] map ;

M: object fixup-arity drop ;

: fixup-parse ( seq -- seq' )
    core-syntax-forms
    [ fixup-arity ] [ apply-decorators2 ] bi ;
