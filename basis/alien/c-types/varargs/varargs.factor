! Shared C default argument promotions for callers and argument cursors.
USING: accessors alien.c-types combinators cpu.architecture delegate
kernel locals math system ;
QUALIFIED-WITH: alien.c-types c
IN: alien.c-types.varargs

! Argument promotion happens after conversion to the declared source type.
! Retain that conversion (notably enum>number and >c-bool), while exposing
! the promoted type to register allocation and the incoming va-arg reader.
TUPLE: promoted-vararg-c-type promoted unboxer-quot ;
C: <promoted-vararg-c-type> promoted-vararg-c-type

CONSULT: c-type-protocol promoted-vararg-c-type promoted>> ;
M: promoted-vararg-c-type lookup-c-type ;
M: promoted-vararg-c-type c-type-unboxer-quot unboxer-quot>> ;
M: promoted-vararg-c-type c-type-string promoted>> c-type-string ;

<PRIVATE

:: narrow-vararg-integer ( value width signed? -- integer )
    width 2^ :> modulus
    value modulus 1 - bitand :> bits
    signed? bits modulus 2 /i >= and [ bits modulus - ] [ bits ] if ;

:: integer-promotion ( source -- promoted )
    source c-type-unboxer-quot :> unbox
    source heap-size 8 * :> width
    source c-type-signed :> signed?
    c:int unbox width signed? '[ @ _ _ narrow-vararg-integer >fixnum ]
    <promoted-vararg-c-type> ;

: narrow-integer-type? ( type -- ? )
    [ c-type-rep int-rep = ] [ heap-size 4 < ] bi and ;

: float-promotion ( source -- promoted )
    c-type-unboxer-quot '[ @ float>bits bits>float ]
    c:double swap <promoted-vararg-c-type> ;

PRIVATE>

: promote-vararg-type ( type -- type' )
    dup lookup-c-type {
        { [ dup small-float-c-type? ]
          [ os macos? cpu arm.64? and [ nip vararg-type>> ] [ drop ] if ] }
        { [ dup c-type-rep float-rep = ] [ nip float-promotion ] }
        { [ dup narrow-integer-type? ] [ nip integer-promotion ] }
        [ drop ]
    } cond ;
