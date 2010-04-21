! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators cpu.architecture fry kernel layouts
math sequences compiler.cfg.instructions
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.folding
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite
compiler.cfg.value-numbering.simplify ;
IN: compiler.cfg.value-numbering.math

M: ##tagged>integer rewrite
    [ dst>> ] [ src>> vreg>expr ] bi {
        { [ dup integer-expr? ] [ value>> tag-fixnum \ ##load-integer new-insn ] }
        { [ dup reference-expr? ] [ value>> [ drop f ] [ \ f type-number \ ##load-integer new-insn ] if ] }
        [ 2drop f ]
    } cond ;

M: ##neg rewrite
    dup unary-constant-fold? [ unary-constant-fold ] [ drop f ] if ;

M: ##not rewrite
    dup unary-constant-fold? [ unary-constant-fold ] [ drop f ] if ;

: reassociate ( insn -- dst src1 src2 )
    {
        [ dst>> ]
        [ src1>> vreg>expr [ src1>> vn>vreg ] [ src2>> vn>integer ] bi ]
        [ src2>> ]
        [ ]
    } cleave binary-constant-fold* ;

: ?new-insn ( dst src1 src2 ? class -- insn/f )
    '[ _ new-insn ] [ 3drop f ] if ; inline

: reassociate-arithmetic ( insn new-insn -- insn/f )
    [ reassociate dup immediate-arithmetic? ] dip ?new-insn ; inline

: reassociate-bitwise ( insn new-insn -- insn/f )
    [ reassociate dup immediate-bitwise? ] dip ?new-insn ; inline

M: ##add-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>expr add-imm-expr? ] [ \ ##add-imm reassociate-arithmetic ] }
        [ drop f ]
    } cond ;

: sub-imm>add-imm ( insn -- insn' )
    [ dst>> ] [ src1>> ] [ src2>> neg ] tri dup immediate-arithmetic?
    \ ##add-imm ?new-insn ;

M: ##sub-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
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
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup mul-to-neg? ] [ mul-to-neg ] }
        { [ dup mul-to-shl? ] [ mul-to-shl ] }
        { [ dup src1>> vreg>expr mul-imm-expr? ] [ \ ##mul-imm reassociate-arithmetic ] }
        [ drop f ]
    } cond ;

M: ##and-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>expr and-imm-expr? ] [ \ ##and-imm reassociate-bitwise ] }
        [ drop f ]
    } cond ;

M: ##or-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>expr or-imm-expr? ] [ \ ##or-imm reassociate-bitwise ] }
        [ drop f ]
    } cond ;

M: ##xor-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>expr xor-imm-expr? ] [ \ ##xor-imm reassociate-bitwise ] }
        [ drop f ]
    } cond ;

M: ##shl-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        [ drop f ]
    } cond ;

M: ##shr-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        [ drop f ]
    } cond ;

M: ##sar-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        [ drop f ]
    } cond ;

: insn>imm-insn ( insn op swap? -- new-insn )
    swap [
        [ [ dst>> ] [ src1>> ] [ src2>> ] tri ] dip
        [ swap ] when vreg>integer
    ] dip new-insn ; inline

M: ##add rewrite
    {
        { [ dup src2>> vreg-immediate-arithmetic? ] [ \ ##add-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-arithmetic? ] [ \ ##add-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

: subtraction-identity? ( insn -- ? )
    [ src1>> ] [ src2>> ] bi [ vreg>vn ] bi@ eq? ;

: rewrite-subtraction-identity ( insn -- insn' )
    dst>> 0 \ ##load-integer new-insn ;

: sub-to-neg? ( ##sub -- ? )
    src1>> vn>expr expr-zero? ;

: sub-to-neg ( ##sub -- insn )
    [ dst>> ] [ src2>> ] bi \ ##neg new-insn ;

M: ##sub rewrite
    {
        { [ dup sub-to-neg? ] [ sub-to-neg ] }
        { [ dup subtraction-identity? ] [ rewrite-subtraction-identity ] }
        { [ dup src2>> vreg-immediate-arithmetic? ] [ \ ##sub-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##mul rewrite
    {
        { [ dup src2>> vreg-immediate-arithmetic? ] [ \ ##mul-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-arithmetic? ] [ \ ##mul-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##and rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ \ ##and-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-bitwise? ] [ \ ##and-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##or rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ \ ##or-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-bitwise? ] [ \ ##or-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##xor rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ \ ##xor-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-bitwise? ] [ \ ##xor-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##shl rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ \ ##shl-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##shr rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ \ ##shr-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##sar rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ \ ##sar-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;
