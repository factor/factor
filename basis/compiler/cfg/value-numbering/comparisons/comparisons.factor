! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math math.order namespaces
sequences vectors combinators.short-circuit compiler.cfg
compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering.comparisons

: ##branch-t? ( insn -- ? )
    dup ##compare-imm-branch? [
        { [ cc>> cc/= eq? ] [ src2>> not ] } 1&&
    ] [ drop f ] if ; inline

: scalar-compare-expr? ( insn -- ? )
    {
        [ compare-expr? ]
        [ compare-imm-expr? ]
        [ compare-float-unordered-expr? ]
        [ compare-float-ordered-expr? ]
    } 1|| ;

: general-compare-expr? ( insn -- ? )
    {
        [ scalar-compare-expr? ]
        [ test-vector-expr? ]
    } 1|| ;

: rewrite-boolean-comparison? ( insn -- ? )
    dup ##branch-t? [
        src1>> vreg>expr general-compare-expr?
    ] [ drop f ] if ; inline
 
: >compare-expr< ( expr -- in1 in2 cc )
    [ src1>> vn>vreg ] [ src2>> vn>vreg ] [ cc>> ] tri ; inline

: >compare-imm-expr< ( expr -- in1 in2 cc )
    [ src1>> vn>vreg ] [ src2>> vn>integer ] [ cc>> ] tri ; inline

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

: rewrite-redundant-comparison? ( insn -- ? )
    {
        [ src1>> vreg>expr scalar-compare-expr? ]
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

: evaluate-compare-imm ( insn -- ? )
    [ src1>> vreg>comparand ] [ src2>> ] [ cc>> ] tri
    2over [ integer? ] both? [ [ <=> ] dip evaluate-cc ] [
        {
            { cc= [ eq? ] }
            { cc/= [ eq? not ] }
        } case
    ] if ;

: fold-compare-imm? ( insn -- ? )
    src1>> vreg>expr literal-expr? ;

: fold-branch ( ? -- insn )
    0 1 ?
    basic-block get [ nth 1vector ] change-successors drop
    \ ##branch new-insn ;

: fold-compare-imm-branch ( insn -- insn/f )
    evaluate-compare-imm fold-branch ;

M: ##compare-imm-branch rewrite
    {
        { [ dup rewrite-boolean-comparison? ] [ rewrite-boolean-comparison ] }
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
    [ vreg>comparand ] dip
    \ ##compare-imm-branch new-insn ; inline

: self-compare? ( insn -- ? )
    [ src1>> ] [ src2>> ] bi [ vreg>vn ] bi@ = ; inline

: evaluate-self-compare ( insn -- ? )
    cc>> { cc= cc<= cc>= } member-eq? ;

: rewrite-self-compare-branch ( insn -- insn' )
    evaluate-self-compare fold-branch ;

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
    [ vreg>comparand ] dip
    next-vreg \ ##compare-imm new-insn ; inline

: >boolean-insn ( insn ? -- insn' )
    [ dst>> ] dip \ ##load-reference new-insn ;

: rewrite-self-compare ( insn -- insn' )
    dup evaluate-self-compare >boolean-insn ;

M: ##compare rewrite
    {
        { [ dup src1>> vreg-immediate-comparand? ] [ t >compare-imm ] }
        { [ dup src2>> vreg-immediate-comparand? ] [ f >compare-imm ] }
        { [ dup self-compare? ] [ rewrite-self-compare ] }
        [ drop f ]
    } cond ;

: fold-compare-imm ( insn -- insn' )
    dup evaluate-compare-imm >boolean-insn ;

M: ##compare-imm rewrite
    {
        { [ dup rewrite-redundant-comparison? ] [ rewrite-redundant-comparison ] }
        { [ dup fold-compare-imm? ] [ fold-compare-imm ] }
        [ drop f ]
    } cond ;
