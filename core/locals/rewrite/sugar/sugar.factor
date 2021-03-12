! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple fry
sequences.generalizations hashtables kernel locals locals.backend
locals.errors locals.types make quotations sequences vectors
words ;
IN: locals.rewrite.sugar

! Step 1: rewrite [| into :> forms, turn
! literals with locals in them into code which constructs
! the literal after pushing locals on the stack

GENERIC: rewrite-sugar* ( obj -- )

: (rewrite-sugar) ( form -- form' )
    [ rewrite-sugar* ] [ ] make ;

GENERIC: quotation-rewrite ( form -- form' )

M: callable quotation-rewrite [ [ rewrite-sugar* ] each ] [ ] make ;

: var-defs ( vars -- defs ) <reversed> [ <def> ] [ ] map-as ;

M: lambda quotation-rewrite
    [ body>> ] [ vars>> var-defs ] bi
    prepend quotation-rewrite ;

M: callable rewrite-sugar* quotation-rewrite , ;

M: lambda rewrite-sugar* quotation-rewrite , ;

GENERIC: rewrite-literal? ( obj -- ? )

M: special rewrite-literal? drop t ;

M: array rewrite-literal? [ rewrite-literal? ] any? ;

M: quotation rewrite-literal? [ rewrite-literal? ] any? ;

M: vector rewrite-literal? [ rewrite-literal? ] any? ;

M: wrapper rewrite-literal? wrapped>> rewrite-literal? ;

M: hashtable rewrite-literal? >alist rewrite-literal? ;

M: tuple rewrite-literal? tuple>array rewrite-literal? ;

M: object rewrite-literal? drop f ;

GENERIC: rewrite-element ( obj -- )

: rewrite-elements ( seq -- )
    [ rewrite-element ] each ;

: rewrite-sequence ( seq -- )
    [ rewrite-elements ] [ length ] [ 0 head ] tri '[ _ _ nsequence ] % ;

M: array rewrite-element
    dup rewrite-literal? [ rewrite-sequence ] [ , ] if ;

M: vector rewrite-element
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

M: local-writer rewrite-element
    local-writer-in-literal-error ;

M: word rewrite-element <wrapper> , ;

: rewrite-wrapper ( wrapper -- )
    dup rewrite-literal?
    [ wrapped>> rewrite-element ] [ , ] if ;

M: wrapper rewrite-element
    rewrite-wrapper \ <wrapper> , ;

M: object rewrite-element , ;

M: array rewrite-sugar* rewrite-element ;

M: vector rewrite-sugar* rewrite-element ;

M: tuple rewrite-sugar* rewrite-element ;

M: def rewrite-sugar* , ;

M: multi-def rewrite-sugar* locals>> <reversed> [ <def> , ] each ;

M: hashtable rewrite-sugar* rewrite-element ;

M: wrapper rewrite-sugar*
    rewrite-wrapper ;

M: word rewrite-sugar*
    dup { load-locals get-local drop-locals } member-eq?
    [ >r/r>-in-lambda-error ] [ call-next-method ] if ;

M: object rewrite-sugar* , ;

M: let rewrite-sugar*
    body>> quotation-rewrite % ;
