! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators classes math layouts
compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions ;
IN: compiler.cfg.value-numbering.simplify

! Return value of f means we didn't simplify.
GENERIC: simplify* ( expr -- vn/expr/f )

: simplify-not ( in -- vn/expr/f )
    {
        { [ dup constant-expr? ] [ value>> bitnot <constant> ] }
        { [ dup op>> \ ##not = ] [ in>> ] }
        [ drop f ]
    } cond ;

: simplify-box-float ( in -- vn/expr/f )
    dup op>> \ ##unbox-float = [ in>> ] [ drop f ] if ;

: simplify-unbox-float ( in -- vn/expr/f )
    dup op>> \ ##box-float = [ in>> ] [ drop f ] if ;

M: unary-expr simplify*
    #! Note the copy propagation: a copy always simplifies to
    #! its source VN.
    [ in>> vn>expr ] [ op>> ] bi {
        { \ ##copy [ ] }
        { \ ##copy-float [ ] }
        { \ ##not [ simplify-not ] }
        { \ ##box-float [ simplify-box-float ] }
        { \ ##unbox-float [ simplify-unbox-float ] }
        [ 2drop f ]
    } case ;

! : expr-zero? ( expr -- ? ) T{ constant-expr f f 0 } = ; inline
! 
! : expr-one? ( expr -- ? ) T{ constant-expr f f 1 } = ; inline
! 
! : expr-neg-one? ( expr -- ? ) T{ constant-expr f f -1 } = ; inline
! 
! : identity ( in1 in2 val -- expr ) 2nip <constant> ; inline
! 
! : constant-fold? ( in1 in2 -- ? )
!     [ constant-expr? ] both? ;
! 
! : constant-fold ( in1 in2 quot -- expr )
!     2over constant-fold? [
!         [ [ value>> ] bi@ ] dip call <constant>
!     ] [ 3drop f ] if ; inline
! 
! : simplify-add ( in1 in2 -- vn/expr/f )
!     {
!         { [ over expr-zero? ] [ nip ] }
!         { [ dup expr-zero? ] [ drop ] }
!         [ [ + ] constant-fold ]
!     } cond ;
! 
! : simplify-mul ( in1 in2 -- vn/expr/f )
!     {
!         { [ over expr-one? ] [ nip ] }
!         { [ dup expr-one? ] [ drop ] }
!         [ [ * ] constant-fold ]
!     } cond ;
! 
! : simplify-and ( in1 in2 -- vn/expr/f )
!     {
!         { [ dup expr-zero? ] [ 0 identity ] }
!         { [ dup expr-neg-one? ] [ drop ] }
!         { [ 2dup = ] [ drop ] }
!         [ [ bitand ] constant-fold ]
!     } cond ;
! 
! : simplify-or ( in1 in2 -- vn/expr/f )
!     {
!         { [ dup expr-zero? ] [ drop ] }
!         { [ dup expr-neg-one? ] [ -1 identity ] }
!         { [ 2dup = ] [ drop ] }
!         [ [ bitor ] constant-fold ]
!     } cond ;
! 
! : simplify-xor ( in1 in2 -- vn/expr/f )
!     {
!         { [ dup expr-zero? ] [ drop ] }
!         [ [ bitxor ] constant-fold ]
!     } cond ;
! 
! : commutative-operands ( expr -- in1 in2 )
!     [ in1>> vn>expr ] [ in2>> vn>expr ] bi
!     over constant-expr? [ swap ] when ;
! 
! M: commutative-expr simplify*
!     [ commutative-operands ] [ op>> ] bi {
!         { ##add [ simplify-add ] }
!         { ##mul [ simplify-mul ] }
!         { ##and [ simplify-and ] }
!         { ##or [ simplify-or ] }
!         { ##xor [ simplify-xor ] }
!         [ 3drop f ]
!     } case ;
! 
! : simplify-sub ( in1 in2 -- vn/expr/f )
!     {
!         { [ dup expr-zero? ] [ drop ] }
!         { [ 2dup = ] [ 0 identity ] }
!         [ [ - ] constant-fold ]
!     } cond ;
! 
! : simplify-shl ( in1 in2 -- vn/expr/f )
!     {
!         { [ dup expr-zero? ] [ drop ] }
!         { [ over expr-zero? ] [ drop ] }
!         [ [ shift ] constant-fold ]
!     } cond ;
! 
! : unsigned ( n -- n' )
!     cell-bits 2^ 1- bitand ;
! 
! : useless-shift? ( in1 in2 -- ? )
!     over op>> ##shl = [ [ in2>> ] [ expr>vn ] bi* = ] [ 2drop f ] if ;
! 
! : simplify-shr ( in1 in2 -- vn/expr/f )
!     {
!         { [ dup expr-zero? ] [ drop ] }
!         { [ over expr-zero? ] [ drop ] }
!         { [ 2dup useless-shift? ] [ drop in1>> ] }
!         [ [ neg shift unsigned ] constant-fold ]
!     } cond ;
! 
! : simplify-sar ( in1 in2 -- vn/expr/f )
!     {
!         { [ dup expr-zero? ] [ drop ] }
!         { [ over expr-zero? ] [ drop ] }
!         { [ 2dup useless-shift? ] [ drop in1>> ] }
!         [ [ neg shift ] constant-fold ]
!     } cond ;
! 
! : simplify-compare ( in1 in2 -- vn/expr/f )
!     = [ +eq+ %cconst constant ] [ f ] if ;
! 
! M: binary-expr simplify*
!     [ in1>> vn>expr ] [ in2>> vn>expr ] [ op>> ] tri {
!         { ##sub [ simplify-isub ] }
!         { ##shl [ simplify-shl ] }
!         { ##shr [ simplify-shr ] }
!         { ##sar [ simplify-sar ] }
!         { ##compare [ simplify-compare ] }
!         [ 3drop f ]
!     } case ;

M: expr simplify* drop f ;

: simplify ( expr -- vn )
    dup simplify* {
        { [ dup not ] [ drop expr>vn ] }
        { [ dup expr? ] [ expr>vn nip ] }
        { [ dup integer? ] [ nip ] }
    } cond ;
