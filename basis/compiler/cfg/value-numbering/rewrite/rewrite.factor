! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit arrays
fry kernel layouts math namespaces sequences cpu.architecture
math.bitwise math.order classes vectors
compiler.cfg
compiler.cfg.hats
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.simplify ;
IN: compiler.cfg.value-numbering.rewrite

: vreg-small-constant? ( vreg -- ? )
    vreg>expr {
        [ constant-expr? ]
        [ value>> small-enough? ]
    } 1&& ;

! Outputs f to mean no change

GENERIC: rewrite ( insn -- insn/f )

M: insn rewrite drop f ;

: ##branch-t? ( insn -- ? )
    dup ##compare-imm-branch? [
        {
            [ cc>> cc/= eq? ]
            [ src2>> \ f tag-number eq? ]
        } 1&&
    ] [ drop f ] if ; inline

: rewrite-boolean-comparison? ( insn -- ? )
    dup ##branch-t? [
        src1>> vreg>expr compare-expr?
    ] [ drop f ] if ; inline
 
: >compare-expr< ( expr -- in1 in2 cc )
    [ in1>> vn>vreg ] [ in2>> vn>vreg ] [ cc>> ] tri ; inline

: >compare-imm-expr< ( expr -- in1 in2 cc )
    [ in1>> vn>vreg ] [ in2>> vn>constant ] [ cc>> ] tri ; inline

: rewrite-boolean-comparison ( expr -- insn )
    src1>> vreg>expr dup op>> {
        { \ ##compare [ >compare-expr< \ ##compare-branch new-insn ] }
        { \ ##compare-imm [ >compare-imm-expr< \ ##compare-imm-branch new-insn ] }
        { \ ##compare-float [ >compare-expr< \ ##compare-float-branch new-insn ] }
    } case ;

: tag-fixnum-expr? ( expr -- ? )
    dup op>> \ ##shl-imm eq?
    [ in2>> vn>constant tag-bits get = ] [ drop f ] if ;

: rewrite-tagged-comparison? ( insn -- ? )
    #! Are we comparing two tagged fixnums? Then untag them.
    {
        [ src1>> vreg>expr tag-fixnum-expr? ]
        [ src2>> tag-mask get bitand 0 = ]
    } 1&& ; inline

: tagged>constant ( n -- n' )
    tag-bits get neg shift ; inline

: (rewrite-tagged-comparison) ( insn -- src1 src2 cc )
    [ src1>> vreg>expr in1>> vn>vreg ]
    [ src2>> tagged>constant ]
    [ cc>> ]
    tri ; inline

GENERIC: rewrite-tagged-comparison ( insn -- insn/f )

M: ##compare-imm-branch rewrite-tagged-comparison
    (rewrite-tagged-comparison) \ ##compare-imm-branch new-insn ;

M: ##compare-imm rewrite-tagged-comparison
    [ dst>> ] [ (rewrite-tagged-comparison) ] bi
    i \ ##compare-imm new-insn ;

: rewrite-redundant-comparison? ( insn -- ? )
    {
        [ src1>> vreg>expr compare-expr? ]
        [ src2>> \ f tag-number = ]
        [ cc>> { cc= cc/= } memq? ]
    } 1&& ; inline

: rewrite-redundant-comparison ( insn -- insn' )
    [ cc>> ] [ dst>> ] [ src1>> vreg>expr dup op>> ] tri {
        { \ ##compare [ >compare-expr< i \ ##compare new-insn ] }
        { \ ##compare-imm [ >compare-imm-expr< i \ ##compare-imm new-insn ] }
        { \ ##compare-float [ >compare-expr< i \ ##compare-float new-insn ] }
    } case
    swap cc= eq? [ [ negate-cc ] change-cc ] when ;

ERROR: bad-comparison ;

: (fold-compare-imm) ( insn -- ? )
    [ [ src1>> vreg>constant ] [ src2>> ] bi ] [ cc>> ] bi
    pick integer?
    [ [ <=> ] dip evaluate-cc ]
    [
        2nip {
            { cc= [ f ] }
            { cc/= [ t ] }
            [ bad-comparison ]
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
    cc>> { cc= cc<= cc>= } memq? ;

: rewrite-self-compare-branch ( insn -- insn' )
    (rewrite-self-compare) fold-branch ;

M: ##compare-branch rewrite
    {
        { [ dup src1>> vreg-small-constant? ] [ t >compare-imm-branch ] }
        { [ dup src2>> vreg-small-constant? ] [ f >compare-imm-branch ] }
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
    i \ ##compare-imm new-insn ; inline

: >boolean-insn ( insn ? -- insn' )
    [ dst>> ] dip
    {
        { t [ t \ ##load-reference new-insn ] }
        { f [ \ f tag-number \ ##load-immediate new-insn ] }
    } case ;

: rewrite-self-compare ( insn -- insn' )
    dup (rewrite-self-compare) >boolean-insn ;

M: ##compare rewrite
    {
        { [ dup src1>> vreg-small-constant? ] [ t >compare-imm ] }
        { [ dup src2>> vreg-small-constant? ] [ f >compare-imm ] }
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
    [ [ src1>> vreg>constant ] [ src2>> ] [ ] tri constant-fold* ] bi
    \ ##load-immediate new-insn ; inline

: reassociate? ( insn -- ? )
    [ src1>> vreg>expr op>> ] [ class ] bi = ; inline

: reassociate ( insn op -- insn )
    [
        {
            [ dst>> ]
            [ src1>> vreg>expr [ in1>> vn>vreg ] [ in2>> vn>constant ] bi ]
            [ src2>> ]
            [ ]
        } cleave constant-fold*
    ] dip
    over small-enough? [ new-insn ] [ 2drop 2drop f ] if ; inline

M: ##add-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup reassociate? ] [ \ ##add-imm reassociate ] }
        [ drop f ]
    } cond ;

: sub-imm>add-imm ( insn -- insn' )
    [ dst>> ] [ src1>> ] [ src2>> neg ] tri dup small-enough?
    [ \ ##add-imm new-insn ] [ 3drop f ] if ;

M: ##sub-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        [ sub-imm>add-imm ]
    } cond ;

: strength-reduce-mul ( insn -- insn' )
    [ [ dst>> ] [ src1>> ] bi ] [ src2>> log2 ] bi \ ##shl-imm new-insn ;

: strength-reduce-mul? ( insn -- ? )
    src2>> power-of-2? ;

M: ##mul-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup strength-reduce-mul? ] [ strength-reduce-mul ] }
        { [ dup reassociate? ] [ \ ##mul-imm reassociate ] }
        [ drop f ]
    } cond ;

M: ##and-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup reassociate? ] [ \ ##and-imm reassociate ] }
        [ drop f ]
    } cond ;

M: ##or-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup reassociate? ] [ \ ##or-imm reassociate ] }
        [ drop f ]
    } cond ;

M: ##xor-imm rewrite
    {
        { [ dup constant-fold? ] [ constant-fold ] }
        { [ dup reassociate? ] [ \ ##xor-imm reassociate ] }
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

: insn>imm-insn ( insn op swap? -- )
    swap [
        [ [ dst>> ] [ src1>> ] [ src2>> ] tri ] dip
        [ swap ] when vreg>constant
    ] dip new-insn ; inline

: rewrite-arithmetic ( insn op -- ? )
    {
        { [ over src2>> vreg-small-constant? ] [ f insn>imm-insn ] }
        [ 2drop f ]
    } cond ; inline

: rewrite-arithmetic-commutative ( insn op -- ? )
    {
        { [ over src2>> vreg-small-constant? ] [ f insn>imm-insn ] }
        { [ over src1>> vreg-small-constant? ] [ t insn>imm-insn ] }
        [ 2drop f ]
    } cond ; inline

M: ##add rewrite \ ##add-imm rewrite-arithmetic-commutative ;

: subtraction-identity? ( insn -- ? )
    [ src1>> ] [ src2>> ] bi [ vreg>vn ] bi@ eq?  ;

: rewrite-subtraction-identity ( insn -- insn' )
    dst>> 0 \ ##load-immediate new-insn ;

M: ##sub rewrite
    {
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
