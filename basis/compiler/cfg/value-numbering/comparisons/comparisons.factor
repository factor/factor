! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.math
compiler.cfg.value-numbering.rewrite cpu.architecture kernel
math math.order namespaces sequences vectors ;
IN: compiler.cfg.value-numbering.comparisons

: fold-compare-imm? ( insn -- ? )
    src1>> vreg>insn literal-insn? ;

: evaluate-compare-imm ( insn -- ? )
    [ src1>> vreg>literal ] [ src2>> ] [ cc>> ] tri
    {
        { cc= [ eq? ] }
        { cc/= [ eq? not ] }
    } case ;

: fold-compare-integer-imm? ( insn -- ? )
    src1>> vreg>insn ##load-integer? ;

: evaluate-compare-integer-imm ( insn -- ? )
    [ src1>> vreg>integer ] [ src2>> ] [ cc>> ] tri
    [ <=> ] dip evaluate-cc ;

: fold-test-imm? ( insn -- ? )
    src1>> vreg>insn ##load-integer? ;

: evaluate-test-imm ( insn -- ? )
    [ src1>> vreg>integer ] [ src2>> ] [ cc>> ] tri
    [ bitand ] dip {
        { cc= [ 0 = ] }
        { cc/= [ 0 = not ] }
    } case ;

: rewrite-into-test? ( insn -- ? )
    {
        [ drop test-instruction? ]
        [ cc>> { cc= cc/= } member-eq? ]
        [ src2>> 0 = ]
    } 1&& ;

: >compare< ( insn -- in1 in2 cc )
    [ src1>> ] [ src2>> ] [ cc>> ] tri ; inline

: >test-vector< ( insn -- src1 temp rep vcc )
    {
        [ src1>> ]
        [ drop next-vreg ]
        [ rep>> ]
        [ vcc>> ]
    } cleave ; inline

UNION: scalar-compare-insn
    ##compare
    ##compare-imm
    ##compare-integer
    ##compare-integer-imm
    ##test
    ##test-imm
    ##compare-float-unordered
    ##compare-float-ordered ;

UNION: general-compare-insn scalar-compare-insn ##test-vector ;

: rewrite-boolean-comparison? ( insn -- ? )
    {
        [ src1>> vreg>insn general-compare-insn? ]
        [ src2>> not ]
        [ cc>> cc/= eq? ]
    } 1&& ; inline

: rewrite-boolean-comparison ( insn -- insn )
    src1>> vreg>insn {
        { [ dup ##compare? ] [ >compare< ##compare-branch new-insn ] }
        { [ dup ##compare-imm? ] [ >compare< ##compare-imm-branch new-insn ] }
        { [ dup ##compare-integer? ] [ >compare< ##compare-integer-branch new-insn ] }
        { [ dup ##compare-integer-imm? ] [ >compare< ##compare-integer-imm-branch new-insn ] }
        { [ dup ##test? ] [ >compare< ##test-branch new-insn ] }
        { [ dup ##test-imm? ] [ >compare< ##test-imm-branch new-insn ] }
        { [ dup ##compare-float-unordered? ] [ >compare< ##compare-float-unordered-branch new-insn ] }
        { [ dup ##compare-float-ordered? ] [ >compare< ##compare-float-ordered-branch new-insn ] }
        { [ dup ##test-vector? ] [ >test-vector< ##test-vector-branch new-insn ] }
    } cond ;

: fold-branch ( ? -- insn )
    0 1 ?
    basic-block get [ nth 1vector ] change-successors drop
    ##branch new-insn ;

: fold-compare-imm-branch ( insn -- insn/f )
    evaluate-compare-imm fold-branch ;

: >test-branch ( insn -- insn' )
    [ src1>> ] [ src1>> ] [ cc>> ] tri ##test-branch new-insn ;

M: ##compare-imm-branch rewrite
    {
        { [ dup rewrite-boolean-comparison? ] [ rewrite-boolean-comparison ] }
        { [ dup fold-compare-imm? ] [ fold-compare-imm-branch ] }
        [ drop f ]
    } cond ;

: fold-compare-integer-imm-branch ( insn -- insn/f )
    evaluate-compare-integer-imm fold-branch ;

M: ##compare-integer-imm-branch rewrite
    {
        { [ dup fold-compare-integer-imm? ] [ fold-compare-integer-imm-branch ] }
        { [ dup rewrite-into-test? ] [ >test-branch ] }
        [ drop f ]
    } cond ;

: fold-test-imm-branch ( insn -- insn/f )
    evaluate-test-imm fold-branch ;

M: ##test-imm-branch rewrite
    {
        { [ dup fold-test-imm? ] [ fold-test-imm-branch ] }
        [ drop f ]
    } cond ;

: swap-compare ( src1 src2 cc swap? -- src1 src2 cc )
    [ swapd swap-cc ] when ; inline

: (>compare-imm-branch) ( insn swap? -- src1 src2 cc )
    [ [ src1>> ] [ src2>> ] [ cc>> ] tri ] dip swap-compare ; inline

: >compare-imm-branch ( insn swap? -- insn' )
    (>compare-imm-branch)
    [ vreg>literal ] dip
    ##compare-imm-branch new-insn ; inline

: >compare-integer-imm-branch ( insn swap? -- insn' )
    (>compare-imm-branch)
    [ vreg>integer ] dip
    ##compare-integer-imm-branch new-insn ; inline

: evaluate-self-compare ( insn -- ? )
    cc>> { cc= cc<= cc>= } member-eq? ;

: rewrite-self-compare-branch ( insn -- insn' )
    evaluate-self-compare fold-branch ;

M: ##compare-branch rewrite
    {
        { [ dup src1>> vreg-immediate-comparand? ] [ t >compare-imm-branch ] }
        { [ dup src2>> vreg-immediate-comparand? ] [ f >compare-imm-branch ] }
        { [ dup diagonal? ] [ rewrite-self-compare-branch ] }
        [ drop f ]
    } cond ;

M: ##compare-integer-branch rewrite
    {
        { [ dup src1>> vreg-immediate-arithmetic? ] [ t >compare-integer-imm-branch ] }
        { [ dup src2>> vreg-immediate-arithmetic? ] [ f >compare-integer-imm-branch ] }
        { [ dup diagonal? ] [ rewrite-self-compare-branch ] }
        [ drop f ]
    } cond ;

: (>compare-imm) ( insn swap? -- dst src1 src2 cc )
    [ { [ dst>> ] [ src1>> ] [ src2>> ] [ cc>> ] } cleave ] dip
    swap-compare ; inline

: >compare-imm ( insn swap? -- insn' )
    (>compare-imm)
    [ vreg>literal ] dip
    next-vreg ##compare-imm new-insn ; inline

: >compare-integer-imm ( insn swap? -- insn' )
    (>compare-imm)
    [ vreg>integer ] dip
    next-vreg ##compare-integer-imm new-insn ; inline

: >boolean-insn ( insn ? -- insn' )
    [ dst>> ] dip ##load-reference new-insn ;

: rewrite-self-compare ( insn -- insn' )
    dup evaluate-self-compare >boolean-insn ;

M: ##compare rewrite
    {
        { [ dup src1>> vreg-immediate-comparand? ] [ t >compare-imm ] }
        { [ dup src2>> vreg-immediate-comparand? ] [ f >compare-imm ] }
        { [ dup diagonal? ] [ rewrite-self-compare ] }
        [ drop f ]
    } cond ;

M: ##compare-integer rewrite
    {
        { [ dup src1>> vreg-immediate-arithmetic? ] [ t >compare-integer-imm ] }
        { [ dup src2>> vreg-immediate-arithmetic? ] [ f >compare-integer-imm ] }
        { [ dup diagonal? ] [ rewrite-self-compare ] }
        [ drop f ]
    } cond ;

: rewrite-redundant-comparison? ( insn -- ? )
    {
        [ src1>> vreg>insn scalar-compare-insn? ]
        [ src2>> not ]
        [ cc>> { cc= cc/= } member? ]
    } 1&& ; inline

: rewrite-redundant-comparison ( insn -- insn' )
    [ cc>> ] [ dst>> ] [ src1>> vreg>insn ] tri {
        { [ dup ##compare? ] [ >compare< next-vreg ##compare new-insn ] }
        { [ dup ##compare-imm? ] [ >compare< next-vreg ##compare-imm new-insn ] }
        { [ dup ##compare-integer? ] [ >compare< next-vreg ##compare-integer new-insn ] }
        { [ dup ##compare-integer-imm? ] [ >compare< next-vreg ##compare-integer-imm new-insn ] }
        { [ dup ##test? ] [ >compare< next-vreg ##test new-insn ] }
        { [ dup ##test-imm? ] [ >compare< next-vreg ##test-imm new-insn ] }
        { [ dup ##compare-float-unordered? ] [ >compare< next-vreg ##compare-float-unordered new-insn ] }
        { [ dup ##compare-float-ordered? ] [ >compare< next-vreg ##compare-float-ordered new-insn ] }
    } cond
    swap cc= eq? [ [ negate-cc ] change-cc ] when ;

: fold-compare-imm ( insn -- insn' )
    dup evaluate-compare-imm >boolean-insn ;

M: ##compare-imm rewrite
    {
        { [ dup rewrite-redundant-comparison? ] [ rewrite-redundant-comparison ] }
        { [ dup fold-compare-imm? ] [ fold-compare-imm ] }
        [ drop f ]
    } cond ;

: fold-compare-integer-imm ( insn -- insn' )
    dup evaluate-compare-integer-imm >boolean-insn ;

: >test ( insn -- insn' )
    { [ dst>> ] [ src1>> ] [ src1>> ] [ cc>> ] [ temp>> ] } cleave
    ##test new-insn ;

M: ##compare-integer-imm rewrite
    {
        { [ dup fold-compare-integer-imm? ] [ fold-compare-integer-imm ] }
        { [ dup rewrite-into-test? ] [ >test ] }
        [ drop f ]
    } cond ;

: (simplify-test) ( insn -- src1 src2 cc )
    [ src1>> vreg>insn [ src1>> ] [ src2>> ] bi ] [ cc>> ] bi ; inline

: simplify-test ( insn -- insn )
    dup (simplify-test) drop [ >>src1 ] [ >>src2 ] bi* ; inline

: simplify-test-imm ( insn -- insn )
    [ dst>> ] [ (simplify-test) ] [ temp>> ] tri ##test-imm new-insn ; inline

: simplify-test-imm-branch ( insn -- insn )
    (simplify-test) ##test-imm-branch new-insn ; inline

: >test-imm ( insn ? -- insn' )
    (>compare-imm) [ vreg>integer ] dip next-vreg
    ##test-imm new-insn ; inline

: >test-imm-branch ( insn ? -- insn' )
    (>compare-imm-branch) [ vreg>integer ] dip
    ##test-imm-branch new-insn ; inline

M: ##test rewrite
    {
        { [ dup src1>> vreg-immediate-comparand? ] [ t >test-imm ] }
        { [ dup src2>> vreg-immediate-comparand? ] [ f >test-imm ] }
        { [ dup diagonal? ] [
            {
                { [ dup src1>> vreg>insn ##and? ] [ simplify-test ] }
                { [ dup src1>> vreg>insn ##and-imm? ] [ simplify-test-imm ] }
                [ drop f ]
            } cond
        ] }
        [ drop f ]
    } cond ;

M: ##test-branch rewrite
    {
        { [ dup src1>> vreg-immediate-comparand? ] [ t >test-imm-branch ] }
        { [ dup src2>> vreg-immediate-comparand? ] [ f >test-imm-branch ] }
        { [ dup diagonal? ] [
            {
                { [ dup src1>> vreg>insn ##and? ] [ simplify-test ] }
                { [ dup src1>> vreg>insn ##and-imm? ] [ simplify-test-imm-branch ] }
                [ drop f ]
            } cond
        ] }
        [ drop f ]
    } cond ;

: fold-test-imm ( insn -- insn' )
    dup evaluate-test-imm >boolean-insn ;

M: ##test-imm rewrite
    {
        { [ dup fold-test-imm? ] [ fold-test-imm ] }
        [ drop f ]
    } cond ;
