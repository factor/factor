! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple combinators
fry.private hashtables kernel locals.backend locals.errors
locals.types macros.expander make math memoize.private
quotations sequences sets words ;

IN: locals.rewrite

DEFER: point-free

! Step 1: rewrite [| into :> forms, turn
! literals with locals in them into code which constructs
! the literal after pushing locals on the stack

GENERIC: rewrite-sugar* ( obj -- )

: (rewrite-sugar) ( form -- form' )
    [ rewrite-sugar* ] [ ] make ;

GENERIC: quotation-rewrite ( form -- form' )

M: callable quotation-rewrite [ [ rewrite-sugar* ] each ] [ ] make ;

: var-defs ( vars -- defs )
    [ [ ] ] [ <multi-def> 1quotation ] if-empty ;

M: lambda quotation-rewrite
    [ body>> ] [ vars>> var-defs ] bi prepend quotation-rewrite ;

M: callable rewrite-sugar* quotation-rewrite , ;

M: lambda rewrite-sugar* quotation-rewrite , ;

GENERIC: rewrite-literal? ( obj -- ? )

M: special rewrite-literal? drop t ;

M: sequence rewrite-literal? [ rewrite-literal? ] any? ;

M: wrapper rewrite-literal? wrapped>> rewrite-literal? ;

M: hashtable rewrite-literal? >alist rewrite-literal? ;

M: tuple rewrite-literal? tuple>array rewrite-literal? ;

M: object rewrite-literal? drop f ;

GENERIC: rewrite-element ( obj -- )

: rewrite-elements ( seq -- )
    [ rewrite-element ] each ;

: rewrite-sequence ( seq -- )
    [ rewrite-elements ] [ length ] [ 0 head ] tri
    [ [nsequence] % ] [ [ like ] curry % ] bi ;

M: sequence rewrite-element
    dup rewrite-literal? [ rewrite-sequence ] [ , ] if ;

M: hashtable rewrite-element
    dup rewrite-literal? [ >alist rewrite-sequence \ >hashtable , ] [ , ] if ;

M: tuple rewrite-element
    dup rewrite-literal? [
        [ tuple-slots rewrite-elements ] [ class-of ] bi '[ _ boa ] %
    ] [ , ] if ;

M: quotation rewrite-element rewrite-sugar* ;

M: lambda rewrite-element rewrite-sugar* ;

M: let rewrite-element let-form-in-literal-error ;

M: local rewrite-element , ;

M: local-reader rewrite-element , ;

M: local-writer rewrite-element local-writer-in-literal-error ;

M: word rewrite-element <wrapper> , ;

: rewrite-wrapper ( wrapper -- )
    dup rewrite-literal? [ wrapped>> rewrite-element ] [ , ] if ;

M: wrapper rewrite-element
    rewrite-wrapper \ <wrapper> , ;

M: object rewrite-element , ;

M: sequence rewrite-sugar* rewrite-element ;

M: tuple rewrite-sugar* rewrite-element ;

M: multi-def rewrite-sugar* , ;

M: hashtable rewrite-sugar* rewrite-element ;

M: wrapper rewrite-sugar*
    rewrite-wrapper ;

M: word rewrite-sugar*
    dup { load-locals get-local drop-locals } member-eq?
    [ >r/r>-in-lambda-error ] [ call-next-method ] if ;

M: object rewrite-sugar* , ;

M: let rewrite-sugar*
    body>> quotation-rewrite % ;

! Step 2: identify free variables and make them into explicit
! parameters of lambdas which are curried on

GENERIC: rewrite-closures* ( obj -- )

: (rewrite-closures) ( form -- form' )
    [ [ rewrite-closures* ] each ] [ ] make ;

: rewrite-closures ( form -- form' )
    expand-macros (rewrite-sugar) (rewrite-closures) point-free ;

GENERIC: defs-vars* ( seq form -- seq' )

: defs-vars ( form -- vars ) { } [ defs-vars* ] reduce members ;

M: multi-def defs-vars* locals>> [ unquote suffix ] each ;

M: quotation defs-vars* [ defs-vars* ] each ;

M: object defs-vars* drop ;

GENERIC: uses-vars* ( seq form -- seq' )

: uses-vars ( form -- vars ) { } [ uses-vars* ] reduce members ;

M: local-writer uses-vars* "local-reader" word-prop suffix ;

M: lexical uses-vars* suffix ;

M: quote uses-vars* local>> uses-vars* ;

M: object uses-vars* drop ;

M: quotation uses-vars* [ uses-vars* ] each ;

: free-vars ( form -- seq )
    [ uses-vars ] [ defs-vars ] bi diff ;

M: callable rewrite-closures*
    ! Turn free variables into bound variables, curry them
    ! onto the body
    dup free-vars [ <quote> ] map
    [ % ]
    [ var-defs prepend (rewrite-closures) point-free , ]
    [ length \ curry <repetition> % ]
    tri ;

M: object rewrite-closures* , ;

! Step 3: rewrite locals usage within a single quotation into
! retain stack manipulation

: local-index ( args obj -- n )
    2dup '[ unquote _ eq? ] find drop
    [ 2nip ] [ bad-local ] if* ;

: read-local-quot ( args obj -- quot )
    local-index neg [ get-local ] curry ;

GENERIC: localize ( args obj -- args quot )

M: local localize dupd read-local-quot ;

M: quote localize dupd local>> read-local-quot ;

M: local-reader localize dupd read-local-quot [ local-value ] append ;

M: local-writer localize
    dupd "local-reader" word-prop
    read-local-quot [ set-local-value ] append ;

M: multi-def localize
    locals>> <reversed>
    [ prepend ]
    [ [ [ local-reader? ] dip '[ [ 1array ] _ [ndip] ] [ [ ] ] if ] map-index concat ]
    [
        length {
            { [ dup 1 > ] [ [ load-locals ] curry ] }
            { [ dup 1 = ] [ drop [ load-local ] ] }
            [ drop [ ] ]
        } cond
    ] tri append ;

M: object localize 1quotation ;

: drop-locals-quot ( args -- )
    [ length , [ drop-locals ] % ] unless-empty ;

: point-free ( quot -- newquot )
    [ { } swap [ localize % ] each drop-locals-quot ] [ ] make ;
