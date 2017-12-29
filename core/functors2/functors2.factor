! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs classes classes.parser
combinators effects.parser generalizations interpolate
io.streams.string kernel lexer make math.parser namespaces
parser quotations sequences sequences.generalizations strings
vocabs.generated vocabs.parser words splitting combinators.short-circuit ;
QUALIFIED: sets
IN: functors2

<<
ERROR: not-all-unique seq ;

: ensure-unique ( seq -- seq )
    dup sets:all-unique? [ not-all-unique ] unless ; inline

: effect-in>drop-variables ( effect -- quot )
    in>> ensure-unique
    [ '[ dup word? [ name>> ] when _ dup array? [ first ] when set ] ] map
    '[ _ spread ] ; inline

: make-in-drop-variables ( def effect -- def effect )
    [
        effect-in>drop-variables swap
        '[ [ @ @ ] with-scope ]
    ] keep ;
>>

: functor-definer-word-name ( word -- string )
    dup word? [ name>> ] when >lower "define-" prepend ;

: functor-syntax-word-name ( word -- string )
    dup word? [ name>> ] when >upper ":" append ;

: functor-word-name ( word -- string )
    dup word? [ name>> ] when "-functor" append ;

: functor-instantiated-vocab-name ( functor-word parameters -- string )
    dupd
    '[
        ! box-functor:functors:box:float:1827917291
        _ dup word? [ vocabulary>> ] when %
        ":functors:" %
        _ dup word? [ name>> ] when % ! functor name, e.g. box
        ":" %
        _ hashcode number>string % ! narray for all the template parameters
    ] "" make ;

: functor-inline-vocab-name ( functor-word parameters -- string )
    drop
    '[
        ! box-functor:functors:box:float:1827917291
        _ dup word? [ vocabulary>> ] when %
    ] "" make ;

: prepend-input-vocabs-generated ( word def effect -- word def effect )
    [ 2drop ]
    [
        ! make FROM: vocab => word ; for each input argument
        nip in>> length
        [
            dup dup '[ [ [ _ ] _ ndip _ narray functor-instantiated-vocab-name ] _ nkeep ]
        ] [
            [
                [
                    dup { [ word? ] } 1|| [
                        [ dup word? [ vocabulary>> ] [ drop current-vocab name>> ] if ] [ dup word? [ name>> ] when ] bi
                        " => " glue "FROM: " " ;\n" surround
                    ] [
                        drop ""
                    ] if
                ]
            ] replicate
        ] [ ] tri dup
        ! Make the FROM: list and keep the input arguments
        '[ [ @ _ spread _ narray "\n" join dupd [ "IN: " prepend ] dip "\n" glue ] _ nkeep ]
    ] [
        [ drop ] 2dip
        ! append the IN: and the FROM: quot generator and the functor code
        [
            append
            '[ @ over '[ _ <string-reader> _ parse-stream call( -- ) ] generate-vocab use-vocab ]
        ] dip
    ] 3tri ;

: prepend-input-vocabs-inline ( word def effect -- word def effect )
    [ 2drop ]
    [
        ! make FROM: vocab => word ; for each input argument
        nip in>> length
        [
            dup dup '[ [ [ _ ] _ ndip _ narray 2drop current-vocab name>> ] _ nkeep ]
        ] [
            [
                [
                    ! dup { [ word? ] [ string? ] } 1|| [
                    dup { [ word? ] } 1|| [
                        [ dup word? [ vocabulary>> ] [ drop current-vocab name>> ] if ] [ dup word? [ name>> ] when ] bi
                        " => " glue "FROM: " " ;\n" surround
                    ] [
                        drop ""
                    ] if
                ]
            ] replicate
        ] [ ] tri dup
        ! Make the FROM: list and keep the input arguments
        '[ [ @ _ spread _ narray "\n" join dupd [ "IN: " prepend ] dip "\n" glue ] _ nkeep ]
    ] [
        [ drop ] 2dip
        ! append the IN: and the FROM: quot generator and the functor code
        [
            append
            '[
                ! parse-stream forgets the previous vocab if same name
                @ over '[
                    _ _ drop string-lines parse-lines
                    call( -- ) ! call the top-level code returned from parse-lines
                ] nip call ! generate-vocab use-vocab
            ]
        ] dip
    ] 3tri ;


: interpolate-assoc ( assoc -- quot )
    assoc-invert
    [ '[ _ interpolate>string _ set ] ] { } assoc>map [ ] concat-as ; inline

: create-new-word-in ( string -- word )
    create-word-in dup reset-generic ;

: lookup-word-in ( string -- word )
    current-vocab lookup-word ;

ERROR: no-type arg ;
: argument>type ( argument -- type )
    dup array? [ ?second ] [ no-type ] if ;

SINGLETONS: name new-class new-word existing-class existing-word ;
CONSTANT: scanner-table H{
    { new-class [ scan-new-class ] }
    { existing-class [ scan-class ] }
    { new-word [ scan-new-word ] }
    { existing-word [ scan-word ] }
    { name [ scan-token ] }
    { string [ scan-object ] }
    { quotation [ scan-object ] }
}

: type>scanner ( obj -- quot )
    scanner-table ?at [ no-type ] unless ;

: (make-functor-vocab) ( word effect quot -- )
    swap
    make-in-drop-variables
    prepend-input-vocabs-generated
    ! word quot effect
    [
        [ functor-definer-word-name create-new-word-in ] 2dip
        define-declared
    ] [
        nip
        [
            [ functor-syntax-word-name create-new-word-in ]
            [ functor-definer-word-name lookup-word-in ] bi
        ] dip
        in>> [
            argument>type type>scanner
        ] { } map-as [ ] concat-as
        swap
        1quotation
        '[ @ @ ] define-syntax
    ] 3bi ; inline

: (make-functor-inline) ( word effect quot -- )
    swap
    make-in-drop-variables
    prepend-input-vocabs-inline
    ! word quot effect
    [
        [ functor-definer-word-name create-new-word-in ] 2dip
        define-declared
    ] [
        nip
        [
            [ functor-syntax-word-name create-new-word-in ]
            [ functor-definer-word-name lookup-word-in ] bi
        ] dip
        in>> [
            argument>type type>scanner
        ] { } map-as [ ] concat-as
        swap
        1quotation
        '[ @ @ ] define-syntax
    ] 3bi ; inline

: make-functor-word ( word effect string -- )
    nip
    ! [ functor-word-name ] dip
    1quotation ( -- string ) define-declared ;

: make-variable-functor ( word effect bindings string -- )
    [
        nip make-functor-word
    ] [
        [ interpolate-assoc ] dip ! do bindings in series
        '[ @ _ interpolate>string append ] ! append the interpolated string to the FROM:
        (make-functor-vocab)
    ] 4bi ; inline

: make-variable-functor-inline ( word effect bindings string -- )
    [
        nip make-functor-word
    ] [
        [ interpolate-assoc ] dip ! do bindings in series
        '[ @ _ interpolate>string append ] ! append the interpolated string to the FROM:
        (make-functor-inline)
    ] 4bi ; inline

: make-functor ( word effect string -- )
    { } swap make-variable-functor ;

: make-inline-functor ( word effect string -- )
    { } swap make-variable-functor-inline ;

! SYNTAX: \VARIABLE-FUNCTOR:
    ! scan-new-word scan-effect scan-object scan-object make-variable-functor ;

SYNTAX: \INLINE-FUNCTOR:
    scan-new-word scan-effect scan-object make-inline-functor ;
