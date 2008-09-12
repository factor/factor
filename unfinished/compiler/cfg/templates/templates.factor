! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors sequences kernel fry namespaces
quotations combinators classes.algebra compiler.instructions
compiler.registers compiler.cfg.stacks ;
IN: compiler.cfg.templates

USE: qualified
FROM: compiler.generator.registers => +input+   ;
FROM: compiler.generator.registers => +output+  ;
FROM: compiler.generator.registers => +scratch+ ;
FROM: compiler.generator.registers => +clobber+ ;

: template-input +input+ swap at ; inline
: template-output +output+ swap at ; inline
: template-scratch +scratch+ swap at ; inline
: template-clobber +clobber+ swap at ; inline

: phantom&spec ( phantom specs -- phantom' specs' )
    >r stack>> r>
    [ length f pad-left ] keep
    [ <reversed> ] bi@ ; inline

: phantom&spec-agree? ( phantom spec quot -- ? )
    >r phantom&spec r> 2all? ; inline

: live-vregs ( -- seq )
    [ stack>> [ >vreg ] map sift ] each-phantom append ;

: clobbered ( template -- seq )
    [ template-output ] [ template-clobber ] bi append ;

: clobbered? ( value name -- ? )
    \ clobbered get member? [
        >vreg \ live-vregs get member?
    ] [ drop f ] if ;

: lazy-load ( specs -- seq )
    [ length phantom-datastack get phantom-input ] keep
    [ drop ] [
        [
            2dup second clobbered?
            [ first (eager-load) ] [ first (lazy-load) ] if
        ] 2map
    ] 2bi
    [ substitute-vregs ] keep ;

: load-inputs ( template -- assoc )
    [
        live-vregs \ live-vregs set
        dup clobbered \ clobbered set
        template-input [ values ] [ lazy-load ] bi zip
    ] with-scope ;

: alloc-scratch ( template -- assoc )
    template-scratch [ swap alloc-vreg ] assoc-map ;

: do-template-inputs ( template -- inputs )
    #! Load input values into registers and allocates scratch
    #! registers.
    [ load-inputs ] [ alloc-scratch ] bi assoc-union ;

: do-template-outputs ( template inputs -- )
    [ template-output ] dip '[ _ at ] map
    phantom-datastack get phantom-append ;

: apply-template ( pair quot -- vregs )
    [
        first2 dup do-template-inputs
        [ do-template-outputs ] keep
    ] dip call ; inline

: value-matches? ( value spec -- ? )
    #! If the spec is a quotation and the value is a literal
    #! fixnum, see if the quotation yields true when applied
    #! to the fixnum. Otherwise, the values don't match. If the
    #! spec is not a quotation, its a reg-class, in which case
    #! the value is always good.
    dup quotation? [
        over constant?
        [ >r value>> r> 2drop f ] [ 2drop f ] if
    ] [
        2drop t
    ] if ;

: class-matches? ( actual expected -- ? )
    {
        { f [ drop t ] }
        { known-tag [ dup [ class-tag >boolean ] when ] }
        [ class<= ]
    } case ;

: spec-matches? ( value spec -- ? )
    2dup first value-matches?
    >r >r operand-class 2 r> ?nth class-matches? r> and ;

: template-matches? ( template -- ? )
    template-input phantom-datastack get swap
    [ spec-matches? ] phantom&spec-agree? ;

: find-template ( templates -- pair/f )
    #! Pair has shape { quot assoc }
    [ second template-matches? ] find nip ;
