USING: accessors combinators effects effects.parser kernel lexer
namespaces parser python python.objects sequences
sequences.generalizations words ;
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

: make-function-quot ( obj-quot effect -- quot )
    [ in>> gather-args-quot ] [ out>> unpack-value-quot ] bi
    swapd '[ @ @ -rot call-object-full @ ] ;

: make-factor-words ( module name prefix? -- call-word obj-word )
    [ [ ":" glue ] [ ":$" glue ] 2bi ] [ nip dup "$" prepend ] if
    [ create-word-in ] bi@ ;

:: add-function ( name effect module prefix? -- )
    module name prefix? make-factor-words :> ( call-word obj-word )
    obj-word module name '[ _ _ py-import-from ] ( -- o ) define-inline
    call-word obj-word def>> effect make-function-quot effect define-inline ;

: make-method-quot ( name effect -- quot )
    [ in>> rest gather-args-quot ] [ out>> unpack-value-quot ] bi swapd
    '[ @ rot _ getattr -rot call-object-full @ ] ;

: method-callable ( name effect -- )
    [ dup create-word-in swap ] dip [ make-method-quot ] keep define-inline ;

: method-object ( name -- )
    [ "$" prepend create-word-in ] [ '[ _ getattr ] ] bi
    { "obj" } { "obj'" } <effect> define-inline ;

: add-method ( name effect -- )
    dupd method-callable method-object ;

PRIVATE>

SYNTAX: PY-FROM: [
    current-context get f add-function
] scan-definitions ; inline

SYNTAX: PY-QUALIFIED-FROM: [
    current-context get t add-function
] scan-definitions ; inline

SYNTAX: PY-METHODS: [ add-method ] scan-definitions ; inline
