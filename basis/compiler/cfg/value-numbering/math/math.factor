! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.utilities compiler.cfg.value-numbering.folding
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite cpu.architecture fry kernel
layouts locals make math ;
IN: compiler.cfg.value-numbering.math

: f-insn? ( insn -- ? )
    { [ ##load-reference? ] [ obj>> not ] } 1&& ; inline

: zero-insn? ( insn -- ? )
    { [ ##load-integer? ] [ val>> 0 = ] } 1&& ; inline

M: ##tagged>integer rewrite
    [ dst>> ] [ src>> vreg>insn ] bi {
        { [ dup ##load-integer? ] [ val>> tag-fixnum ##load-integer new-insn ] }
        { [ dup f-insn? ] [ drop \ f type-number ##load-integer new-insn ] }
        [ 2drop f ]
    } cond ;

: self-inverse ( insn -- insn' )
    [ dst>> ] [ src>> vreg>insn src>> ] bi <copy> ;

: identity ( insn -- insn' )
    [ dst>> ] [ src1>> ] bi <copy> ;

M: ##neg rewrite
    {
        { [ dup src>> vreg>insn ##neg? ] [ self-inverse ] }
        { [ dup unary-constant-fold? ] [ unary-constant-fold ] }
        [ drop f ]
    } cond ;

M: ##not rewrite
    {
        { [ dup src>> vreg>insn ##not? ] [ self-inverse ] }
        { [ dup unary-constant-fold? ] [ unary-constant-fold ] }
        [ drop f ]
    } cond ;

! Reassociation converts
! ## *-imm 2 1 X
! ## *-imm 3 2 Y
! into
! ## *-imm 3 1 (X $ Y)
! If * is associative, then $ is the same operation as *.
! In the case of shifts, $ is addition.
: (reassociate) ( insn -- dst src1 src2' src2'' )
    {
        [ dst>> ]
        [ src1>> vreg>insn [ src1>> ] [ src2>> ] bi ]
        [ src2>> ]
    } cleave ; inline

: reassociate ( insn -- dst src1 src2 )
    [ (reassociate) ] keep binary-constant-fold* ;

: ?new-insn ( dst src1 src2 ? class -- insn/f )
    '[ _ new-insn ] [ 3drop f ] if ; inline

: reassociate-arithmetic ( insn new-insn -- insn/f )
    [ reassociate dup immediate-arithmetic? ] dip ?new-insn ; inline

: reassociate-bitwise ( insn new-insn -- insn/f )
    [ reassociate dup immediate-bitwise? ] dip ?new-insn ; inline

: reassociate-shift ( insn new-insn -- insn/f )
    [ (reassociate) + dup immediate-shift-count? ] dip ?new-insn ; inline

M: ##add-imm rewrite
    {
        { [ dup src2>> 0 = ] [ identity ] }
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>insn ##add-imm? ] [ ##add-imm reassociate-arithmetic ] }
        [ drop f ]
    } cond ;

: sub-imm>add-imm ( insn -- insn' )
    [ dst>> ] [ src1>> ] [ src2>> neg ] tri
    dup immediate-arithmetic?
    ##add-imm ?new-insn ;

M: ##sub-imm rewrite sub-imm>add-imm ;

! Convert ##mul-imm -1 => ##neg
: mul-to-neg? ( insn -- ? )
    src2>> -1 = ;

: mul-to-neg ( insn -- insn' )
    [ dst>> ] [ src1>> ] bi ##neg new-insn ;

! Convert ##mul-imm 2^X => ##shl-imm X
: mul-to-shl? ( insn -- ? )
    src2>> power-of-2? ;

: mul-to-shl ( insn -- insn' )
    [ [ dst>> ] [ src1>> ] bi ] [ src2>> log2 ] bi ##shl-imm new-insn ;

! Distribution converts
! ##+-imm 2 1 X
! ##*-imm 3 2 Y
! Into
! ##*-imm 4 1 Y
! ##+-imm 3 4 X*Y
! Where * is mul or shl, + is add or sub
! Have to make sure that X*Y fits in an immediate
:: (distribute) ( outer inner imm temp add-op mul-op -- new-outers/f )
    imm immediate-arithmetic? [
        [
            temp inner src1>> outer src2>> mul-op execute
            outer dst>> temp imm add-op execute
        ] { } make
    ] [ f ] if ; inline

: distribute-over-add? ( insn -- ? )
    src1>> vreg>insn ##add-imm? ;

: distribute-over-sub? ( insn -- ? )
    src1>> vreg>insn ##sub-imm? ;

: distribute ( insn add-op mul-op -- new-insns/f )
    [
        dup src1>> vreg>insn
        2dup src2>> swap [ src2>> ] keep binary-constant-fold*
        next-vreg
    ] 2dip (distribute) ; inline

M: ##mul-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup mul-to-neg? ] [ mul-to-neg ] }
        { [ dup mul-to-shl? ] [ mul-to-shl ] }
        { [ dup src1>> vreg>insn ##mul-imm? ] [ ##mul-imm reassociate-arithmetic ] }
        { [ dup distribute-over-add? ] [ \ ##add-imm, \ ##mul-imm, distribute ] }
        { [ dup distribute-over-sub? ] [ \ ##sub-imm, \ ##mul-imm, distribute ] }
        [ drop f ]
    } cond ;

M: ##and-imm rewrite
    {
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>insn ##and-imm? ] [ ##and-imm reassociate-bitwise ] }
        { [ dup src2>> 0 = ] [ dst>> 0 ##load-integer new-insn ] }
        { [ dup src2>> -1 = ] [ identity ] }
        [ drop f ]
    } cond ;

M: ##or-imm rewrite
    {
        { [ dup src2>> 0 = ] [ identity ] }
        { [ dup src2>> -1 = ] [ dst>> -1 ##load-integer new-insn ] }
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>insn ##or-imm? ] [ ##or-imm reassociate-bitwise ] }
        [ drop f ]
    } cond ;

M: ##xor-imm rewrite
    {
        { [ dup src2>> 0 = ] [ identity ] }
        { [ dup src2>> -1 = ] [ [ dst>> ] [ src1>> ] bi ##not new-insn ] }
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>insn ##xor-imm? ] [ ##xor-imm reassociate-bitwise ] }
        [ drop f ]
    } cond ;

M: ##shl-imm rewrite
    {
        { [ dup src2>> 0 = ] [ identity ] }
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>insn ##shl-imm? ] [ ##shl-imm reassociate-shift ] }
        { [ dup distribute-over-add? ] [ \ ##add-imm, \ ##shl-imm, distribute ] }
        { [ dup distribute-over-sub? ] [ \ ##sub-imm, \ ##shl-imm, distribute ] }
        [ drop f ]
    } cond ;

M: ##shr-imm rewrite
    {
        { [ dup src2>> 0 = ] [ identity ] }
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>insn ##shr-imm? ] [ ##shr-imm reassociate-shift ] }
        [ drop f ]
    } cond ;

M: ##sar-imm rewrite
    {
        { [ dup src2>> 0 = ] [ identity ] }
        { [ dup binary-constant-fold? ] [ binary-constant-fold ] }
        { [ dup src1>> vreg>insn ##sar-imm? ] [ ##sar-imm reassociate-shift ] }
        [ drop f ]
    } cond ;

! Convert
! ##load-integer 2 X
! ##* 3 1 2
! Where * is an operation with an -imm equivalent into
! ##*-imm 3 1 X
: insn>imm-insn ( insn op swap? -- new-insn )
    swap [
        [ [ dst>> ] [ src1>> ] [ src2>> ] tri ] dip
        [ swap ] when vreg>integer
    ] dip new-insn ; inline

M: ##add rewrite
    {
        { [ dup src2>> vreg-immediate-arithmetic? ] [ ##add-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-arithmetic? ] [ ##add-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

: diagonal? ( insn -- ? )
    [ src1>> vreg>vn ] [ src2>> vreg>vn ] bi = ; inline

! ##sub 2 1 1 => ##load-integer 2 0
: rewrite-subtraction-identity ( insn -- insn' )
    dst>> 0 ##load-integer new-insn ;

! ##load-integer 1 0
! ##sub 3 1 2
! =>
! ##neg 3 2
: sub-to-neg? ( ##sub -- ? )
    src1>> vreg>insn zero-insn? ;

: sub-to-neg ( ##sub -- insn )
    [ dst>> ] [ src2>> ] bi ##neg new-insn ;

M: ##sub rewrite
    {
        { [ dup sub-to-neg? ] [ sub-to-neg ] }
        { [ dup diagonal? ] [ rewrite-subtraction-identity ] }
        { [ dup src2>> vreg-immediate-arithmetic? ] [ ##sub-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##mul rewrite
    {
        { [ dup src2>> vreg-immediate-arithmetic? ] [ ##mul-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-arithmetic? ] [ ##mul-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##and rewrite
    {
        { [ dup diagonal? ] [ identity ] }
        { [ dup src2>> vreg-immediate-bitwise? ] [ ##and-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-bitwise? ] [ ##and-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##or rewrite
    {
        { [ dup diagonal? ] [ identity ] }
        { [ dup src2>> vreg-immediate-bitwise? ] [ ##or-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-bitwise? ] [ ##or-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##xor rewrite
    {
        { [ dup diagonal? ] [ dst>> 0 ##load-integer new-insn ] }
        { [ dup src2>> vreg-immediate-bitwise? ] [ ##xor-imm f insn>imm-insn ] }
        { [ dup src1>> vreg-immediate-bitwise? ] [ ##xor-imm t insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##shl rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ ##shl-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##shr rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ ##shr-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;

M: ##sar rewrite
    {
        { [ dup src2>> vreg-immediate-bitwise? ] [ ##sar-imm f insn>imm-insn ] }
        [ drop f ]
    } cond ;
