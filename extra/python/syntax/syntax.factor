USING: accessors arrays combinators effects effects.parser fry generalizations
kernel lexer math namespaces parser python python.ffi python.objects sequences
sequences.generalizations vocabs.parser words ;
IN: python.syntax

<PRIVATE

SYMBOL: current-context

: with-each-definition ( quot -- )
    scan-token dup ";" = [ 2drop ] [
        scan-effect rot [ call( tok eff -- ) ] keep with-each-definition
    ] if ; inline recursive

: scan-definitions ( quot -- )
    scan-token current-context set "=>" expect with-each-definition ; inline

: gather-args-quot ( in-effect -- quot )
    dup ?last "**" = [
        but-last length '[ [ _ narray array>py-tuple ] dip ]
    ] [
        length '[ _ narray array>py-tuple f ]
    ] if ;

: unpack-value-quot ( out-effect -- quot )
    length {
        { 0 [ [ drop ] ] }
        { 1 [ [ ] ] }
        [ '[ py-tuple>array _ firstn ] ]
    } case ;

: make-function-quot ( alien effect -- quot )
    [ in>> gather-args-quot ] [ out>> unpack-value-quot ] bi
    swapd '[ @ _ -rot call-object-full @ ] ;

: make-factor-words ( module name prefix? -- call-word obj-word )
    [ [ ":" glue ] [ ":$" glue ] 2bi ] [ nip dup "$" prepend ] if
    [ create-in ] bi@ ;

: import-getattr ( module name -- alien )
    [ py-import ] dip getattr ;

: make-creator-quots ( alien effect -- call-quot obj-quot )
    [ '[ _ _ [ make-function-quot ] keep define-inline ] ]
    [ drop '[ [ _ ] { } { "obj" } <effect> define-inline ] ] 2bi ; inline

: add-function ( effect module name prefix? -- )
    [ make-factor-words ] [ drop import-getattr ] 3bi [ rot ] dip swap
    make-creator-quots bi* ;

: make-method-quot ( name effect -- quot )
    [ in>> 1 tail gather-args-quot ] [ out>> unpack-value-quot ] bi swapd
    '[ @ rot _ getattr -rot call-object-full @ ] ;

: method-callable ( name effect -- )
    [ dup create-in swap ] dip [ make-method-quot ] keep define-inline ;

: method-object ( name -- )
    [ "$" prepend create-in ] [ '[ _ getattr ] ] bi
    { "obj" } { "obj'" } <effect> define-inline ;

: add-method ( name effect -- )
    dupd method-callable method-object ;

PRIVATE>

SYNTAX: PY-FROM: [
    current-context get rot f add-function
] scan-definitions ; inline

SYNTAX: PY-QUALIFIED-FROM: [
    current-context get rot t add-function
] scan-definitions ; inline

SYNTAX: PY-METHODS: [ add-method ] scan-definitions ; inline
