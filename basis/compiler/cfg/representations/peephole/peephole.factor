! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators
combinators.short-circuit compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.representations.rewrite
compiler.cfg.representations.selection cpu.architecture kernel
layouts make math namespaces sequences ;
IN: compiler.cfg.representations.peephole

GENERIC: optimize-insn ( insn -- )

SYMBOL: insn-index

: here ( -- )
    building get length 1 - insn-index set ;

: finish ( insn -- ) , here ;

: unchanged ( insn -- )
    [ no-use-conversion ] [ finish ] [ no-def-conversion ] tri ;

: last-insn ( -- insn ) insn-index get building get nth ;

M: vreg-insn conversions-for-insn
    init-renaming-set
    optimize-insn
    last-insn perform-renaming ;

M: vreg-insn optimize-insn
    [ emit-use-conversion ] [ finish ] [ emit-def-conversion ] tri ;

M: ##load-integer optimize-insn
    {
        {
            [ dup dst>> rep-of tagged-rep? ]
            [ [ dst>> ] [ val>> tag-fixnum ] bi ##load-tagged, here ]
        }
        [ call-next-method ]
    } cond ;

! When a constant float is unboxed, we replace the
! ##load-reference with a ##load-float or ##load-double if the
! architecture supports it
: convert-to-load-float? ( insn -- ? )
    {
        [ drop fused-unboxing? ]
        [ dst>> rep-of float-rep? ]
        [ obj>> float? ]
    } 1&& ;

: convert-to-load-double? ( insn -- ? )
    {
        [ drop fused-unboxing? ]
        [ dst>> rep-of double-rep? ]
        [ obj>> float? ]
    } 1&& ;

: convert-to-load-vector? ( insn -- ? )
    {
        [ drop fused-unboxing? ]
        [ dst>> rep-of vector-rep? ]
        [ obj>> byte-array? ]
    } 1&& ;

: convert-to-zero-vector? ( insn -- ? )
    {
        [ dst>> rep-of vector-rep? ]
        [ obj>> B{ 0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0 } = ]
    } 1&& ;

: convert-to-fill-vector? ( insn -- ? )
    {
        [ dst>> rep-of vector-rep? ]
        [ obj>> B{ 255 255 255 255  255 255 255 255  255 255 255 255  255 255 255 255 } = ]
    } 1&& ;

M: ##load-reference optimize-insn
    {
        {
            [ dup convert-to-load-float? ]
            [ [ dst>> ] [ obj>> ] bi ##load-float, here ]
        }
        {
            [ dup convert-to-load-double? ]
            [ [ dst>> ] [ obj>> ] bi ##load-double, here ]
        }
        {
            [ dup convert-to-zero-vector? ]
            [ dst>> dup rep-of ##zero-vector, here ]
        }
        {
            [ dup convert-to-fill-vector? ]
            [ dst>> dup rep-of ##fill-vector, here ]
        }
        {
            [ dup convert-to-load-vector? ]
            [ [ dst>> ] [ obj>> ] [ dst>> rep-of ] tri ##load-vector, here ]
        }
        [ call-next-method ]
    } cond ;

! Optimize this:
! ##sar-imm temp src tag-bits
! ##shl-imm dst temp X
! Into either
! ##shl-imm by X - tag-bits, or
! ##sar-imm by tag-bits - X.
: combine-shl-imm-input ( insn -- )
    [ dst>> ] [ src1>> ] [ src2>> ] tri tag-bits get {
        { [ 2dup < ] [ swap - ##sar-imm, here ] }
        { [ 2dup > ] [ - ##shl-imm, here ] }
        [ 2drop int-rep ##copy, here ]
    } cond ;

: dst-tagged? ( insn -- ? ) dst>> rep-of tagged-rep? ;
: src1-tagged? ( insn -- ? ) src1>> rep-of tagged-rep? ;
: src2-tagged? ( insn -- ? ) src2>> rep-of tagged-rep? ;

: src2-tagged-arithmetic? ( insn -- ? ) src2>> tag-fixnum immediate-arithmetic? ;
: src2-tagged-bitwise? ( insn -- ? ) src2>> tag-fixnum immediate-bitwise? ;
: src2-tagged-shift-count? ( insn -- ? ) src2>> tag-bits get + immediate-shift-count? ;

: >tagged-shift ( insn -- ) [ tag-bits get + ] change-src2 finish ; inline

M: ##shl-imm optimize-insn
    {
        {
            [ dup { [ dst-tagged? ] [ src1-tagged? ] } 1&& ]
            [ unchanged ]
        }
        {
            [ dup { [ dst-tagged? ] [ src2-tagged-shift-count? ] } 1&& ]
            [ [ emit-use-conversion ] [ >tagged-shift ] [ no-def-conversion ] tri ]
        }
        {
            [ dup src1-tagged? ]
            [ [ no-use-conversion ] [ combine-shl-imm-input ] [ emit-def-conversion ] tri ]
        }
        [ call-next-method ]
    } cond ;

! Optimize this:
! ##sar-imm temp src tag-bits
! ##sar-imm dst temp X
! Into
! ##sar-imm by X + tag-bits
! assuming X + tag-bits is a valid shift count.
M: ##sar-imm optimize-insn
    {
        {
            [ dup { [ src1-tagged? ] [ src2-tagged-shift-count? ] } 1&& ]
            [ [ no-use-conversion ] [ >tagged-shift ] [ emit-def-conversion ] tri ]
        }
        [ call-next-method ]
    } cond ;

! Peephole optimization: for X = add, sub, and, or, xor, min, max
! we have
! tag(untag(a) X untag(b)) = a X b
!
! so if all inputs and outputs of ##X or ##X-imm are tagged,
! don't have to insert any conversions
M: inert-tag-untag-insn optimize-insn
    {
        {
            [ dup { [ dst-tagged? ] [ src1-tagged? ] [ src2-tagged? ] } 1&& ]
            [ unchanged ]
        }
        [ call-next-method ]
    } cond ;

! -imm variant of above
: >tagged-imm ( insn -- )
    [ tag-fixnum ] change-src2 unchanged ; inline

M: inert-arithmetic-tag-untag-insn optimize-insn
    {
        {
            [ dup { [ dst-tagged? ] [ src1-tagged? ] [ src2-tagged-arithmetic? ] } 1&& ]
            [ >tagged-imm ]
        }
        [ call-next-method ]
    } cond ;

M: inert-bitwise-tag-untag-insn optimize-insn
    {
        {
            [ dup { [ dst-tagged? ] [ src1-tagged? ] [ src2-tagged-bitwise? ] } 1&& ]
            [ >tagged-imm ]
        }
        [ call-next-method ]
    } cond ;

M: ##mul-imm optimize-insn
    {
        { [ dup { [ dst-tagged? ] [ src1-tagged? ] } 1&& ] [ unchanged ] }
        { [ dup { [ dst-tagged? ] [ src2-tagged-arithmetic? ] } 1&& ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

! Similar optimization for comparison operators
M: ##compare-integer-imm optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged-arithmetic? ] } 1&& ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

M: ##test-imm optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged-bitwise? ] } 1&& ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

M: ##compare-integer-imm-branch optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged-arithmetic? ] } 1&& ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

M: ##test-imm-branch optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged-bitwise? ] } 1&& ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

M: ##compare-integer optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged? ] } 1&& ] [ unchanged ] }
        [ call-next-method ]
    } cond ;

M: ##test optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged? ] } 1&& ] [ unchanged ] }
        [ call-next-method ]
    } cond ;

M: ##compare-integer-branch optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged? ] } 1&& ] [ unchanged ] }
        [ call-next-method ]
    } cond ;

M: ##test-branch optimize-insn
    {
        { [ dup { [ src1-tagged? ] [ src2-tagged? ] } 1&& ] [ unchanged ] }
        [ call-next-method ]
    } cond ;

! Identities:
! tag(neg(untag(x))) = x
! tag(neg(x)) = x * -2^tag-bits
: inert-tag/untag-unary? ( insn -- ? )
    [ dst>> ] [ src>> ] bi [ rep-of tagged-rep? ] both? ;

: combine-neg-tag ( insn -- )
    [ dst>> ] [ src>> ] bi tag-bits get 2^ neg ##mul-imm, here ;

M: ##neg optimize-insn
    {
        { [ dup inert-tag/untag-unary? ] [ unchanged ] }
        {
            [ dup dst>> rep-of tagged-rep? ]
            [ [ emit-use-conversion ] [ combine-neg-tag ] [ no-def-conversion ] tri ]
        }
        [ call-next-method ]
    } cond ;

! Identity:
! tag(not(untag(x))) = not(x) xor tag-mask
:: emit-tagged-not ( insn -- )
    tagged-rep next-vreg-rep :> temp
    temp insn src>> ##not,
    insn dst>> temp tag-mask get ##xor-imm, here ;

M: ##not optimize-insn
    {
        {
            [ dup inert-tag/untag-unary? ]
            [ [ no-use-conversion ] [ emit-tagged-not ] [ no-def-conversion ] tri ]
        }
        [ call-next-method ]
    } cond ;

M: ##bit-count optimize-insn
    [ no-use-conversion ] [ finish ] [ emit-def-conversion ] tri ;
