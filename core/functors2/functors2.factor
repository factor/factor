! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators 
generalizations interpolate io.streams.string kernel
make math.parser namespaces parser quotations sequences
sequences.generalizations vocabs.generated vocabs.parser
words ;
QUALIFIED: sets
IN: functors2

<<
ERROR: not-all-unique seq ;

: ensure-unique ( seq -- seq )
    dup sets:all-unique? [ not-all-unique ] unless ; inline

: effect-in>drop-variables ( effect -- quot )
    in>> ensure-unique
    [ '[ name>> _ set ] ] map
    '[ _ spread ] ; inline

: make-in-drop-variables ( def effect -- def effect )
    [
        effect-in>drop-variables swap
        '[ [ @ @ ] with-scope ]
    ] keep ;
>>

: functor-definer-word-name ( word -- string )
    name>> >lower "define-" prepend ;

: functor-syntax-word-name ( word -- string )
    name>> >upper ":" append ;

: functor-instantiated-vocab-name ( functor-word parameters -- string )
    dupd
    '[
        ! box-functor:functors:box:float:1827917291
        _ vocabulary>> %
        ":functors:" %
        _ name>> % ! functor name, e.g. box
        ":" %
        _ hashcode number>string % ! narray for all the template parameters
    ] "" make ;

: prepend-input-vocabs ( word def effect -- word def effect )
    [ 2drop ]
    [
        ! make FROM: vocab => word ; for each input argument
        nip in>> length
        [
            dup dup '[ [ [ _ ] _ ndip _ narray functor-instantiated-vocab-name ] _ nkeep ]
        ] [
            [
                [
                    [ vocabulary>> ] [ name>> ] bi
                    " => " glue "FROM: " " ;\n" surround
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
            '[ @ over '[ _ <string-reader> _ parse-stream drop ] generate-vocab drop ]
        ] dip
    ] 3tri ;

: interpolate-assoc ( assoc -- quot )
    assoc-invert
    [ '[ _ interpolate>string _ set ] ] { } assoc>map [ ] concat-as ; inline

: create-new-word-in ( string -- word )
    create-word-in dup reset-generic ; 

: lookup-word-in ( string -- word )
    current-vocab lookup-word ;

: (make-functor) ( word effect quot -- )
    swap
    make-in-drop-variables
    prepend-input-vocabs
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
        in>> length [ [ scan-object ] ] replicate [ ] concat-as
        swap
        1quotation
        '[ @ @ ] define-syntax
    ] 3bi ; inline

: make-functor-word ( word effect string -- )
    nip 1quotation ( -- string ) define-declared ;

: make-variable-functor ( word effect bindings string -- )
    [
        nip make-functor-word
    ] [
        [ interpolate-assoc ] dip ! do bindings in series
        '[ @ _ interpolate>string append ] ! append the interpolated string to the FROM:
        (make-functor)
    ] 4bi ; inline

: make-functor ( word effect string -- )
    { } swap make-variable-functor ;

! FUNCTOR: foo, define-foo, and FOO: go into the vocabulary where the FUNCTOR: appears
! SYNTAX: \FUNCTOR:
    ! scan-new-word scan-effect scan-object make-functor ;

! SYNTAX: \VARIABLE-FUNCTOR:
    ! scan-new-word scan-effect scan-object scan-object make-variable-functor ;
