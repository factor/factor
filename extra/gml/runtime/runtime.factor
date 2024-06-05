! Copyright (C) 2010 Slava Pestov.
USING: accessors arrays assocs fry generic.parser kernel locals
locals.parser macros math ranges memoize parser sequences
sequences.private strings strings.parser lexer namespaces
vectors words generalizations sequences.generalizations
effects.parser gml.types ;
IN: gml.runtime

TUPLE: gml-name < identity-tuple { string read-only } ;

SYMBOL: gml-names

gml-names [ H{ } clone ] initialize

: >gml-name ( string -- name ) gml-names get-global [ \ gml-name boa ] cache ;

TUPLE: gml { operand-stack vector } { dictionary-stack vector } ;

: push-operand ( value gml -- ) operand-stack>> push ; inline

: peek-operand ( gml -- value ? )
    operand-stack>> [ f f ] [ last t ] if-empty ; inline

: pop-operand ( gml -- value ) operand-stack>> pop ; inline

GENERIC: (exec) ( registers gml obj -- registers gml )

! A bit of efficiency
FROM: kernel.private => declare ;

: is-gml ( registers gml obj -- registers gml obj )
    { array gml object } declare ; inline

<<

: (EXEC:) ( quot -- method def )
    scan-word \ (exec) create-method-in
    swap call( -- quot ) [ is-gml ] prepend ;

SYNTAX: EXEC: [ parse-definition ] (EXEC:) define ;

SYNTAX: EXEC:: [ [ parse-definition ] parse-locals-definition drop ] (EXEC:) define ;

>>

! Literals
EXEC: object over push-operand ;

EXEC: proc array>> pick <proc> over push-operand ;

! Executable names
TUPLE: gml-exec-name < identity-tuple name ;

MEMO: >gml-exec-name ( string -- name ) >gml-name \ gml-exec-name boa ;

SYNTAX: exec" lexer get skip-blank parse-string >gml-exec-name suffix! ;

ERROR: unbound-name { name gml-name } ;

: lookup-name ( name gml -- value )
    dupd dictionary-stack>> assoc-stack
    ?or* [ unbound-name ] unless ; inline

GENERIC: exec-proc ( registers gml proc -- registers gml )

M:: proc exec-proc ( registers gml proc -- registers gml )
    proc registers>>
    gml
    proc array>> [ (exec) ] each 2drop
    registers gml ;

FROM: combinators.private => execute-effect-unsafe ;

CONSTANT: primitive-effect ( registers gml -- registers gml )

M: word exec-proc primitive-effect execute-effect-unsafe ;

M: object exec-proc (exec) ;

EXEC: gml-exec-name name>> over lookup-name exec-proc ;

! Registers
ERROR: unbound-register name ;

:: lookup-register ( registers gml obj -- value )
    obj n>> registers nth [
        obj name>> unbound-register
    ] unless* ;

TUPLE: read-register { name string } { n fixnum } ;

: <read-register> ( name -- read-register ) 0 read-register boa ;

EXEC: read-register
    [ 2dup ] dip lookup-register over push-operand ;

TUPLE: exec-register { name string } { n fixnum } ;

: <exec-register> ( name -- exec-register ) 0 exec-register boa ;

EXEC: exec-register
    [ 2dup ] dip lookup-register exec-proc ;

TUPLE: write-register { name string } { n fixnum } ;

: <write-register> ( name -- write-register ) 0 write-register boa ;

EXEC:: write-register ( registers gml obj -- registers gml )
    gml pop-operand obj n>> registers set-nth
    registers gml ;

TUPLE: use-registers { n fixnum } ;

: <use-registers> ( -- use-registers ) use-registers new ;

EXEC: use-registers
    n>> f <array> '[ drop _ ] dip ;

! Pathnames
TUPLE: pathname names ;

C: <pathname> pathname

: at-pathname ( pathname assoc -- value )
    swap names>> [ swap ?at [ unbound-name ] unless ] each ;

EXEC:: pathname ( registers gml obj -- registers gml )
    obj gml pop-operand at-pathname gml push-operand
    registers gml ;

! List building and stuff
TUPLE: gml-marker < identity-tuple ;
CONSTANT: marker T{ gml-marker }

ERROR: no-marker-found ;
ERROR: gml-stack-underflow ;

: find-marker ( gml -- n )
    operand-stack>> [ marker eq? ] find-last
    [ 1 + ] [ no-marker-found ] if ; inline

! Primitives
: check-stack ( seq n -- seq n )
    2dup swap length > [ gml-stack-underflow ] when ; inline

: popn ( seq n -- elts... )
    check-stack
    [ lastn ] [ over length swap - swap shorten ] 2bi ; inline

: pushn ( elts... seq n -- )
    [ over length + swap lengthen ] 2keep set-lastn ; inline

MACRO: inputs ( inputs# -- quot: ( gml -- gml inputs... ) )
    '[ dup operand-stack>> _ popn ] ;

MACRO: outputs ( outputs# -- quot: ( gml outputs... -- gml ) )
    [ 1 + ] keep '[ _ npick operand-stack>> _ pushn ] ;

MACRO: gml-primitive (
    inputs#
    outputs#
    quot: ( registers gml inputs... -- outputs... )
    --
    quot: ( registers gml -- registers gml )
)
    swap '[ _ inputs @ _ outputs ] ;

SYMBOL: global-dictionary

global-dictionary [ H{ } clone ] initialize

: add-primitive ( word name -- )
    >gml-name global-dictionary get-global set-at ;

: define-gml-primitive ( word name effect def -- )
    [ '[ _ add-primitive ] keep ]
    [ [ in>> length ] [ out>> length ] bi ]
    [ '[ { gml } declare _ _ _ gml-primitive ] ] tri*
    primitive-effect define-declared ;

: scan-gml-name ( -- word name )
    scan-token [ "gml-" prepend create-word-in ] keep ;

: (GML:) ( -- word name effect def )
    scan-gml-name scan-effect parse-definition ;

SYNTAX: GML:
    (GML:) define-gml-primitive ;

SYNTAX: GML::
    [let
        scan-gml-name :> ( word name )
        word [ parse-definition ] parse-locals-definition :> ( word def effect )
        word name effect def define-gml-primitive
    ] ;

: <gml> ( -- gml )
    gml new
    global-dictionary get clone 1vector >>dictionary-stack
    V{ } clone >>operand-stack ;

: exec ( gml proc -- gml ) [ { } ] 2dip exec-proc nip ;
