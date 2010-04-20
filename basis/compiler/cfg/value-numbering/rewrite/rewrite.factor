! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit arrays
fry kernel layouts math namespaces sequences cpu.architecture
math.bitwise math.order classes
vectors locals make alien.c-types io.binary grouping
compiler.cfg
compiler.cfg.registers
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.simplify ;
IN: compiler.cfg.value-numbering.rewrite

: vreg-immediate-arithmetic? ( vreg -- ? )
    vreg>expr {
        [ constant-expr? ]
        [ value>> fixnum? ]
        [ value>> immediate-arithmetic? ]
    } 1&& ;

: vreg-immediate-bitwise? ( vreg -- ? )
    vreg>expr {
        [ constant-expr? ]
        [ value>> fixnum? ]
        [ value>> immediate-bitwise? ]
    } 1&& ;

: vreg-immediate-comparand? ( vreg -- ? )
    vreg>expr {
        [ constant-expr? ]
        [ value>> immediate-comparand? ]
    } 1&& ;

! Outputs f to mean no change

GENERIC: rewrite ( insn -- insn/f )

M: insn rewrite drop f ;

: ##branch-t? ( insn -- ? )
    dup ##compare-imm-branch? [
        { [ cc>> cc/= eq? ] [ src2>> not ] } 1&&
    ] [ drop f ] if ; inline

: general-compare-expr? ( insn -- ? )
    {
        [ compare-expr? ]
        [ compare-imm-expr? ]
        [ compare-float-unordered-expr? ]
        [ compare-float-ordered-expr? ]
    } 1|| ;

: general-or-vector-compare-expr? ( insn -- ? )
    {
        [ compare-expr? ]
        [ compare-imm-expr? ]
        [ compare-float-unordered-expr? ]
        [ compare-float-ordered-expr? ]
        [ test-vector-expr? ]
    } 1|| ;

: rewrite-boolean-comparison? ( insn -- ? )
    dup ##branch-t? [
        src1>> vreg>expr general-or-vector-compare-expr?
    ] [ drop f ] if ; inline
 
: >compare-expr< ( expr -- in1 in2 cc )
    [ src1>> vn>vreg ] [ src2>> vn>vreg ] [ cc>> ] tri ; inline

: >compare-imm-expr< ( expr -- in1 in2 cc )
    [ src1>> vn>vreg ] [ src2>> vn>constant ] [ cc>> ] tri ; inline

: >test-vector-expr< ( expr -- src1 temp rep vcc )
    {
        [ src1>> vn>vreg ]
        [ drop next-vreg ]
        [ rep>> ]
        [ vcc>> ]
    } cleave ; inline

: rewrite-boolean-comparison ( expr -- insn )
    src1>> vreg>expr {
        { [ dup compare-expr? ] [ >compare-expr< \ ##compare-branch new-insn ] }
        { [ dup compare-imm-expr? ] [ >compare-imm-expr< \ ##compare-imm-branch new-insn ] }
        { [ dup compare-float-unordered-expr? ] [ >compare-expr< \ ##compare-float-unordered-branch new-insn ] }
        { [ dup compare-float-ordered-expr? ] [ >compare-expr< \ ##compare-float-ordered-branch new-insn ] }
        { [ dup test-vector-expr? ] [ >test-vector-expr< \ ##test-vector-branch new-insn ] }
    } cond ;

: tag-fixnum-expr? ( expr -- ? )
    dup shl-imm-expr?
    [ src2>> vn>constant tag-bits get = ] [ drop f ] if ;

: rewrite-tagged-comparison? ( insn -- ? )
    #! Are we comparing two tagged fixnums? Then untag them.
    {
        [ src1>> vreg>expr tag-fixnum-expr? ]
        [ src2>> tag-mask get bitand 0 = ]
    } 1&& ; inline

: tagged>constant ( n -- n' )
    tag-bits get neg shift ; inline

: (rewrite-tagged-comparison) ( insn -- src1 src2 cc )
    [ src1>> vreg>expr src1>> vn>vreg ]
    [ src2>> tagged>constant ]
    [ cc>> ]
    tri ; inline

GENERIC: rewrite-tagged-comparison ( insn -- insn/f )

M: ##compare-imm-branch rewrite-tagged-comparison
    (rewrite-tagged-comparison) \ ##compare-imm-branch new-insn ;

M: ##compare-imm rewrite-tagged-comparison
    [ dst>> ] [ (rewrite-tagged-comparison) ] bi
    next-vreg \ ##compare-imm new-insn ;

: rewrite-redundant-comparison? ( insn -- ? )
    {
        [ src1>> vreg>expr general-compare-expr? ]
        [ src2>> not ]
        [ cc>> { cc= cc/= } member? ]
    } 1&& ; inline

: rewrite-redundant-comparison ( insn -- insn' )
    [ cc>> ] [ dst>> ] [ src1>> vreg>expr ] tri {
        { [ dup compare-expr? ] [ >compare-expr< next-vreg \ ##compare new-insn ] }
        { [ dup compare-imm-expr? ] [ >compare-imm-expr< next-vreg \ ##compare-imm new-insn ] }
        { [ dup compare-float-unordered-expr? ] [ >compare-expr< next-vreg \ ##compare-float-unordered new-insn ] }
        { [ dup compare-float-ordered-expr? ] [ >compare-expr< next-vreg \ ##compare-float-ordered new-insn ] }
    } cond
    swap cc= eq? [ [ negate-cc ] change-cc ] when ;

: (fold-compare-imm) ( insn -- ? )
    [ src1>> vreg>constant ] [ src2>> ] [ cc>> ] tri
    2over [ integer? ] both? [ [ <=> ] dip evaluate-cc ] [
        {
            { cc= [ eq? ] }
            { cc/= [ eq? not ] }
        } case
    ] if ;

: fold-compare-imm? ( insn -- ? )
    src1>> vreg>expr [ constant-expr? ] [ reference-expr? ] bi or ;

: fold-branch ( ? -- insn )
    0 1 ?
    basic-block get [ nth 1vector ] change-successors drop
    \ ##branch new-insn ;

: fold-compare-imm-branch ( insn -- insn/f )
    (fold-compare-imm) fold-branch ;

M: ##compare-imm-branch rewrite
    {
        { [ dup rewrite-boolean-comparison? ] [ rewrite-boolean-comparison ] }
        { [ dup rewrite-tagged-comparison? ] [ rewrite-tagged-comparison ] }
        { [ dup fold-compare-imm? ] [ fold-compare-imm-branch ] }
        [ drop f ]
    } cond ;

: swap-compare ( src1 src2 cc swap? -- src1 src2 cc )
    [ [ swap ] dip swap-cc ] when ; inline

: >compare-imm-branch ( insn swap? -- insn' )
    [
        [ src1>> ]
        [ src2>> ]
        [ cc>> ]
        tri
    ] dip
    swap-compare
    [ vreg>constant ] dip
    \ ##compare-imm-branch new-insn ; inline

: self-compare? ( insn -- ? )
    [ src1>> ] [ src2>> ] bi [ vreg>vn ] bi@ = ; inline

: (rewrite-self-compare) ( insn -- ? )
    cc>> { cc= cc<= cc>= } member-eq? ;

: rewrite-self-compare-branch ( insn -- insn' )
    (rewrite-self-compare) fold-branch ;

M: ##compare-branch rewrite
    {
        { [ dup src1>> vreg-immediate-comparand? ] [ t >compare-imm-branch ] }
        { [ dup src2>> vreg-immediate-comparand? ] [ f >compare-imm-branch ] }
        { [ dup self-compare? ] [ rewrite-self-compare-branch ] }
        [ drop f ]
    } cond ;

: >compare-imm ( insn swap? -- insn' )
    [
        {
            [ dst>> ]
            [ src1>> ]
            [ src2>> ]
            [ cc>> ]
        } cleave
    ] dip
    swap-compare
    [ vreg>constant ] dip
    next-vreg \ ##compare-imm new-insn ; inline

: >boolean-insn ( insn ? -- insn' )
    [ dst>> ] dip \ ##load-constant new-insn ;

: rewrite-self-compare ( insn -- insn' )
    dup (rewrite-self-compare) >boolean-insn ;

M: ##compare rewrite
    {
        { [ dup src1>> vreg-immediate-comparand? ] [ t >compare-imm ] }
        { [ dup src2>> vreg-immediate-comparand? ] [ f >compare-imm ] }
        { [ dup self-compare? ] [ rewrite-self-compare ] }
        [ drop f ]
    } cond ;

: fold-compare-imm ( insn -- insn' )
    dup (fold-compare-imm) >boolean-insn ;

M: ##compare-imm rewrite
    {
        { [ dup rewrite-redundant-comparison? ] [ rewrite-redundant-comparison ] }
        { [ dup rewrite-tagged-comparison? ] [ rewrite-tagged-comparison ] }
        { [ dup fold-compare-imm? ] [ fold-compare-imm ] }
        [ drop f ]
    } cond ;

: constant-fold? ( insn -- ? )
    src1>> vreg>expr constant-expr? ; inline

GENERIC: constant-fold* ( x y insn -- z )

M: ##add-imm constant-fold* drop + ;
M: ##sub-imm constant-fold* drop - ;
M: ##mul-imm constant-fold* drop * ;
M: ##and-imm constant-fold* drop bitand ;
M: ##or-imm constant-fold* drop bitor ;
M: ##xor-imm constant-fold* drop bitxor ;
M: ##shr-imm constant-fold* drop [ cell-bits 2^ wrap ] dip neg shift ;
M: ##sar-imm constant-fold* drop neg shift ;
M: ##shl-imm constant-fold* drop shift ;

: constant-fold ( insn -- insn' )
    [ dst>> ]
    [
        [ src1>> vreg>constant \ f type-number or ]
        [ src2>> ]
        [ ]
        tri constant-fold*
    ] bi
    \ ##load-immediate new-insn ; inline

: unary-constant-fold? ( insn -- ? )
    src>> vreg>expr constant-expr? ; inline

GENERIC: unary-constant-fold* ( x insn -- y )

M: ##not unary-constant-fold* drop bitnot ;
M: ##neg unary-constant-fold* drop neg ;

: unary-constant-fold ( insn -- insn' )
    [ dst>> ]
    [ [ src>> vreg>constant ] [ ] bi unary-constant-fold* ] bi
    \ ##load-immediate new-insn ; inline

: maybe-unary-constant-fold ( insn -- insn' )
    dup unary-constant-fold? [ unary-constant-fold ] [ drop f ] if ;

M: ##neg rewrite
    maybe-unary-constant-fold ;

M: ##not rewrite
    maybe-unary-constant-fold ;

: arithmetic-op? ( op -- ? )
    {
        ##add
        ##add-imm
        ##sub
        ##sub-imm
        ##mul
        ##mul-imm
    } member-eq? ;

: immediate? ( value op -- ? )
    arithmetic-op? [ immediate-arithmetic? ] [ immediate-bitwise? ] if ;

: reassociate ( insn op -- insn )
    [
        {
            [ dst>> ]
            [ src1>> vreg>expr [ src1>> vn>vreg ] [ src2>> vn>constant ] bi ]
            [ src2>> ]
            [ ]
        } cleave constant-fold*
    ] dip
    2dup immediate? [ new-insn ] [ 2drop 2drop f ] if ; inline

M: ##add-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup src1>> vreg>expr add-imm-expr? ] [ \ ##add-imm reassociate ] }
        [ drop f ]
    } cond ;

: sub-imm>add-imm ( insn -- insn' )
    [ dst>> ] [ src1>> ] [ src2>> neg ] tri dup immediate-arithmetic?
    [ \ ##add-imm new-insn ] [ 3drop f ] if ;

M: ##sub-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        [ sub-imm>add-imm ]
    } cond ;

: mul-to-neg? ( insn -- ? )
    src2>> -1 = ;

: mul-to-neg ( insn -- insn' )
    [ dst>> ] [ src1>> ] bi \ ##neg new-insn ;

: mul-to-shl? ( insn -- ? )
    src2>> power-of-2? ;

: mul-to-shl ( insn -- insn' )
    [ [ dst>> ] [ src1>> ] bi ] [ src2>> log2 ] bi \ ##shl-imm new-insn ;

M: ##mul-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup mul-to-neg? ] [ mul-to-neg ] }
        { [ dup mul-to-shl? ] [ mul-to-shl ] }
        { [ dup src1>> vreg>expr mul-imm-expr? ] [ \ ##mul-imm reassociate ] }
        [ drop f ]
    } cond ;

M: ##and-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup src1>> vreg>expr and-imm-expr? ] [ \ ##and-imm reassociate ] }
        [ drop f ]
    } cond ;

M: ##or-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup src1>> vreg>expr or-imm-expr? ] [ \ ##or-imm reassociate ] }
        [ drop f ]
    } cond ;

M: ##xor-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup src1>> vreg>expr xor-imm-expr? ] [ \ ##xor-imm reassociate ] }
        [ drop f ]
    } cond ;

M: ##shl-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        [ drop f ]
    } cond ;

M: ##shr-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        [ drop f ]
    } cond ;

M: ##sar-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        [ drop f ]
    } cond ;

: insn>imm-insn ( insn op swap? -- new-insn )
    swap [
        [ [ dst>> ] [ src1>> ] [ src2>> ] tri ] dip
        [ swap ] when vreg>constant
    ] dip new-insn ; inline

: vreg-immediate? ( vreg op -- ? )
    arithmetic-op?
    [ vreg-immediate-arithmetic? ] [ vreg-immediate-bitwise? ] if ;

: rewrite-arithmetic ( insn op -- insn/f )
    {
        { [ over src2>> over vreg-immediate? ] [ f insn>imm-insn ] }
        [ 2drop f ]
    } cond ; inline

: rewrite-arithmetic-commutative ( insn op -- insn/f )
    {
        { [ over src2>> over vreg-immediate? ] [ f insn>imm-insn ] }
        { [ over src1>> over vreg-immediate? ] [ t insn>imm-insn ] }
        [ 2drop f ]
    } cond ; inline

M: ##add rewrite \ ##add-imm rewrite-arithmetic-commutative ;

: subtraction-identity? ( insn -- ? )
    [ src1>> ] [ src2>> ] bi [ vreg>vn ] bi@ eq?  ;

: rewrite-subtraction-identity ( insn -- insn' )
    dst>> 0 \ ##load-immediate new-insn ;

: sub-to-neg? ( ##sub -- ? )
    src1>> vn>expr expr-zero? ;

: sub-to-neg ( ##sub -- insn )
    [ dst>> ] [ src2>> ] bi \ ##neg new-insn ;

M: ##sub rewrite
    {
        { [ dup sub-to-neg? ] [ sub-to-neg ] }
        { [ dup subtraction-identity? ] [ rewrite-subtraction-identity ] }
        [ \ ##sub-imm rewrite-arithmetic ]
    } cond ;

M: ##mul rewrite \ ##mul-imm rewrite-arithmetic-commutative ;

M: ##and rewrite \ ##and-imm rewrite-arithmetic-commutative ;

M: ##or rewrite \ ##or-imm rewrite-arithmetic-commutative ;

M: ##xor rewrite \ ##xor-imm rewrite-arithmetic-commutative ;

M: ##shl rewrite \ ##shl-imm rewrite-arithmetic ;

M: ##shr rewrite \ ##shr-imm rewrite-arithmetic ;

M: ##sar rewrite \ ##sar-imm rewrite-arithmetic ;

! ##box-displaced-alien f 1 2 3 <class>
! ##unbox-c-ptr 4 1 <class>
! =>
! ##box-displaced-alien f 1 2 3 <class>
! ##unbox-c-ptr 5 3 <class>
! ##add 4 5 2

:: rewrite-unbox-displaced-alien ( insn expr -- insns )
    [
        next-vreg :> temp
        temp expr base>> vn>vreg expr base-class>> ##unbox-c-ptr
        insn dst>> temp expr displacement>> vn>vreg ##add
    ] { } make ;

M: ##unbox-any-c-ptr rewrite
    dup src>> vreg>expr dup box-displaced-alien-expr?
    [ rewrite-unbox-displaced-alien ] [ 2drop f ] if ;

! More efficient addressing for alien intrinsics
: rewrite-alien-addressing ( insn -- insn' )
    dup src>> vreg>expr dup add-imm-expr? [
        [ src1>> vn>vreg ] [ src2>> vn>constant ] bi
        [ >>src ] [ '[ _ + ] change-offset ] bi*
    ] [ 2drop f ] if ;

M: ##alien-unsigned-1 rewrite rewrite-alien-addressing ;
M: ##alien-unsigned-2 rewrite rewrite-alien-addressing ;
M: ##alien-unsigned-4 rewrite rewrite-alien-addressing ;
M: ##alien-signed-1 rewrite rewrite-alien-addressing ;
M: ##alien-signed-2 rewrite rewrite-alien-addressing ;
M: ##alien-signed-4 rewrite rewrite-alien-addressing ;
M: ##alien-float rewrite rewrite-alien-addressing ;
M: ##alien-double rewrite rewrite-alien-addressing ;
M: ##set-alien-integer-1 rewrite rewrite-alien-addressing ;
M: ##set-alien-integer-2 rewrite rewrite-alien-addressing ;
M: ##set-alien-integer-4 rewrite rewrite-alien-addressing ;
M: ##set-alien-float rewrite rewrite-alien-addressing ;
M: ##set-alien-double rewrite rewrite-alien-addressing ;

