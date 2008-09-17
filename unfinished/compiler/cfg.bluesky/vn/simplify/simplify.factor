! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators classes math math.order
layouts locals
compiler.vops
compiler.cfg.vn.graph
compiler.cfg.vn.expressions ;
IN: compiler.cfg.vn.simplify

! Return value of f means we didn't simplify.
GENERIC: simplify* ( expr -- vn/expr/f )

: constant ( val type -- expr ) swap constant-expr boa ;

: simplify-not ( in -- vn/expr/f )
    {
        { [ dup constant-expr? ] [ value>> bitnot %iconst constant ] }
        { [ dup op>> %not = ] [ in>> ] }
        [ drop f ]
    } cond ;

: simplify-box-float ( in -- vn/expr/f )
    {
        { [ dup op>> %%unbox-float = ] [ in>> ] }
        [ drop f ]
    } cond ;

: simplify-unbox-float ( in -- vn/expr/f )
    {
        { [ dup literal-expr? ] [ object>> %fconst constant ] }
        { [ dup op>> %%box-float = ] [ in>> ] }
        [ drop f ]
    } cond ;

M: unary-expr simplify*
    #! Note the copy propagation: a %copy always simplifies to
    #! its source vn.
    [ in>> vn>expr ] [ op>> ] bi {
        { %copy [ ] }
        { %not [ simplify-not ] }
        { %%box-float [ simplify-box-float ] }
        { %%unbox-float [ simplify-unbox-float ] }
        [ 2drop f ]
    } case ;

: izero? ( expr -- ? ) T{ constant-expr f %iconst 0 } = ;

: ione? ( expr -- ? ) T{ constant-expr f %iconst 1 } = ;

: ineg-one? ( expr -- ? ) T{ constant-expr f %iconst -1 } = ;

: fzero? ( expr -- ? ) T{ constant-expr f %fconst 0 } = ;

: fone? ( expr -- ? ) T{ constant-expr f %fconst 1 } = ;

: fneg-one? ( expr -- ? ) T{ constant-expr f %fconst -1 } = ;

: identity ( in1 in2 val type -- expr ) constant 2nip ;

: constant-fold? ( in1 in2 -- ? )
    [ constant-expr? ] both? ;

:: constant-fold ( in1 in2 quot type -- expr )
    in1 in2 constant-fold?
    [ in1 value>> in2 value>> quot call type constant ]
    [ f ]
    if ; inline

: simplify-iadd ( in1 in2 -- vn/expr/f )
    {
        { [ over izero? ] [ nip ] }
        { [ dup izero? ] [ drop ] }
        [ [ + ] %iconst constant-fold ]
    } cond ;

: simplify-imul ( in1 in2 -- vn/expr/f )
    {
        { [ over ione? ] [ nip ] }
        { [ dup ione? ] [ drop ] }
        [ [ * ] %iconst constant-fold ]
    } cond ;

: simplify-and ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ 0 %iconst identity ] }
        { [ dup ineg-one? ] [ drop ] }
        { [ 2dup = ] [ drop ] }
        [ [ bitand ] %iconst constant-fold ]
    } cond ;

: simplify-or ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ drop ] }
        { [ dup ineg-one? ] [ -1 %iconst identity ] }
        { [ 2dup = ] [ drop ] }
        [ [ bitor ] %iconst constant-fold ]
    } cond ;

: simplify-xor ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ drop ] }
        [ [ bitxor ] %iconst constant-fold ]
    } cond ;

: simplify-fadd ( in1 in2 -- vn/expr/f )
    {
        { [ over fzero? ] [ nip ] }
        { [ dup fzero? ] [ drop ] }
        [ [ + ] %fconst constant-fold ]
    } cond ;

: simplify-fmul ( in1 in2 -- vn/expr/f )
    {
        { [ over fone? ] [ nip ] }
        { [ dup fone? ] [ drop ] }
        [ [ * ] %fconst constant-fold ]
    } cond ;

: commutative-operands ( expr -- in1 in2 )
    [ in1>> vn>expr ] [ in2>> vn>expr ] bi
    over constant-expr? [ swap ] when ;

M: commutative-expr simplify*
    [ commutative-operands ] [ op>> ] bi {
        { %iadd [ simplify-iadd ] }
        { %imul [ simplify-imul ] }
        { %and [ simplify-and ] }
        { %or [ simplify-or ] }
        { %xor [ simplify-xor ] }
        { %fadd [ simplify-fadd ] }
        { %fmul [ simplify-fmul ] }
        [ 3drop f ]
    } case ;

: simplify-isub ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ drop ] }
        { [ 2dup = ] [ 0 %iconst identity ] }
        [ [ - ] %iconst constant-fold ]
    } cond ;

: simplify-idiv ( in1 in2 -- vn/expr/f )
    {
        { [ dup ione? ] [ drop ] }
        [ [ /i ] %iconst constant-fold ]
    } cond ;

: simplify-imod ( in1 in2 -- vn/expr/f )
    {
        { [ dup ione? ] [ 0 %iconst identity ] }
        { [ 2dup = ] [ 0 %iconst identity ] }
        [ [ mod ] %iconst constant-fold ]
    } cond ;

: simplify-shl ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ drop ] }
        { [ over izero? ] [ drop ] }
        [ [ shift ] %iconst constant-fold ]
    } cond ;

: unsigned ( n -- n' )
    cell-bits 2^ 1- bitand ;

: useless-shift? ( in1 in2 -- ? )
    over op>> %shl = [ [ in2>> ] [ expr>vn ] bi* = ] [ 2drop f ] if ;

: simplify-shr ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ drop ] }
        { [ over izero? ] [ drop ] }
        { [ 2dup useless-shift? ] [ drop in1>> ] }
        [ [ neg shift unsigned ] %iconst constant-fold ]
    } cond ;

: simplify-sar ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ drop ] }
        { [ over izero? ] [ drop ] }
        { [ 2dup useless-shift? ] [ drop in1>> ] }
        [ [ neg shift ] %iconst constant-fold ]
    } cond ;

: simplify-icmp ( in1 in2 -- vn/expr/f )
    = [ +eq+ %cconst constant ] [ f ] if ;

: simplify-fsub ( in1 in2 -- vn/expr/f )
    {
        { [ dup izero? ] [ drop ] }
        [ [ - ] %fconst constant-fold ]
    } cond ;

: simplify-fdiv ( in1 in2 -- vn/expr/f )
    {
        { [ dup fone? ] [ drop ] }
        [ [ /i ] %fconst constant-fold ]
    } cond ;

M: binary-expr simplify*
    [ in1>> vn>expr ] [ in2>> vn>expr ] [ op>> ] tri {
        { %isub [ simplify-isub ] }
        { %idiv [ simplify-idiv ] }
        { %imod [ simplify-imod ] }
        { %shl [ simplify-shl ] }
        { %shr [ simplify-shr ] }
        { %sar [ simplify-sar ] }
        { %icmp [ simplify-icmp ] }
        { %fsub [ simplify-fsub ] }
        { %fdiv [ simplify-fdiv ] }
        [ 3drop f ]
    } case ;

M: expr simplify* drop f ;

: simplify ( expr -- vn )
    dup simplify* {
        { [ dup not ] [ drop expr>vn ] }
        { [ dup expr? ] [ expr>vn nip ] }
        { [ dup vn? ] [ nip ] }
    } cond ;
