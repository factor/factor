! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors sequences kernel fry namespaces
quotations combinators classes.algebra compiler.backend
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stacks ;
IN: compiler.cfg.templates

TUPLE: template input output scratch clobber gc ;

: phantom&spec ( phantom specs -- phantom' specs' )
    >r stack>> r>
    [ length f pad-left ] keep
    [ <reversed> ] bi@ ; inline

: phantom&spec-agree? ( phantom spec quot -- ? )
    >r phantom&spec r> 2all? ; inline

: live-vregs ( -- seq )
    [ stack>> [ >vreg ] map sift ] each-phantom append ;

: clobbered ( template -- seq )
    [ output>> ] [ clobber>> ] bi append ;

: clobbered? ( value name -- ? )
    \ clobbered get member? [
        >vreg \ live-vregs get member?
    ] [ drop f ] if ;

: lazy-load ( specs -- seq )
    [ length phantom-datastack get phantom-input ] keep
    [
        2dup second clobbered?
        [ first (eager-load) ] [ first (lazy-load) ] if
    ] 2map ;

: load-inputs ( template -- assoc )
    [
        live-vregs \ live-vregs set
        dup clobbered \ clobbered set
        input>> [ values ] [ lazy-load ] bi zip
    ] with-scope ;

: alloc-scratch ( template -- assoc )
    scratch>> [ swap alloc-vreg ] assoc-map ;

: do-template-inputs ( template -- defs uses )
    #! Load input values into registers and allocates scratch
    #! registers.
    [ alloc-scratch ] [ load-inputs ] bi ;

: do-template-outputs ( template defs uses -- )
    [ output>> ] 2dip assoc-union '[ _ at ] map
    phantom-datastack get phantom-append ;

: apply-template ( pair quot -- vregs )
    [
        first2
        dup gc>> [ t fresh-object ] when
        dup do-template-inputs
        [ do-template-outputs ] 2keep
    ] dip call ; inline

: value-matches? ( value spec -- ? )
    #! If the spec is a quotation and the value is a literal
    #! fixnum, see if the quotation yields true when applied
    #! to the fixnum. Otherwise, the values don't match. If the
    #! spec is not a quotation, its a reg-class, in which case
    #! the value is always good.
    {
        { [ dup small-slot eq? ] [ drop dup constant? [ value>> small-slot? ] [ drop f ] if ] }
        { [ dup small-tagged eq? ] [ drop dup constant? [ value>> small-tagged? ] [ drop f ] if ] }
        [ 2drop t ]
    } cond ;

: class-matches? ( actual expected -- ? )
    {
        { f [ drop t ] }
        { known-tag [ dup [ class-tag >boolean ] when ] }
        [ class<= ]
    } case ;

: spec-matches? ( value spec -- ? )
    2dup first value-matches?
    >r >r value-class 2 r> ?nth class-matches? r> and ;

: template-matches? ( template -- ? )
    input>> phantom-datastack get swap
    [ spec-matches? ] phantom&spec-agree? ;

: find-template ( templates -- pair/f )
    #! Pair has shape { quot assoc }
    [ second template-matches? ] find nip ;
