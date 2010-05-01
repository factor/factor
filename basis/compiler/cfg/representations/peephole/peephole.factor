! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators
combinators.short-circuit kernel layouts locals make math
namespaces sequences cpu.architecture compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.representations.rewrite
compiler.cfg.representations.selection ;
IN: compiler.cfg.representations.peephole

! Representation selection performs some peephole optimizations
! when inserting conversions to optimize for a few common cases

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
            [ [ dst>> ] [ val>> tag-fixnum ] bi ##load-tagged here ]
        }
        [ call-next-method ]
    } cond ;

! When a float is unboxed, we replace the ##load-reference with a ##load-double
! if the architecture supports it
: convert-to-load-double? ( insn -- ? )
    {
        [ drop object-immediates? ]
        [ dst>> rep-of double-rep? ]
        [ obj>> float? ]
    } 1&& ;

: convert-to-load-vector? ( insn -- ? )
    {
        [ drop object-immediates? ]
        [ dst>> rep-of vector-rep? ]
        [ obj>> byte-array? ]
    } 1&& ;

! When a literal zeroes/ones vector is unboxed, we replace the ##load-reference
! with a ##zero-vector or ##fill-vector instruction since this is more efficient.
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
            [ dup convert-to-load-double? ]
            [ [ dst>> ] [ obj>> ] bi ##load-double here ]
        }
        {
            [ dup convert-to-zero-vector? ]
            [ dst>> dup rep-of ##zero-vector here ]
        }
        {
            [ dup convert-to-fill-vector? ]
            [ dst>> dup rep-of ##fill-vector here ]
        }
        {
            [ dup convert-to-load-vector? ]
            [ [ dst>> ] [ obj>> ] [ dst>> rep-of ] tri ##load-vector here ]
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
        { [ 2dup < ] [ swap - ##sar-imm here ] }
        { [ 2dup > ] [ - ##shl-imm here ] }
        [ 2drop int-rep ##copy here ]
    } cond ;

: inert-tag-imm? ( insn -- ? )
    src1>> rep-of tagged-rep? ;

: inert-tag/untag-imm? ( insn -- ? )
    {
        [ dst>> rep-of tagged-rep? ]
        [ inert-tag-imm? ]
    } 1&& ;

M: ##shl-imm optimize-insn
    {
        {
            [ dup inert-tag/untag-imm? ]
            [ unchanged ]
        }
        {
            [ dup dst>> rep-of tagged-rep? ]
            [
                [ emit-use-conversion ]
                [ [ tag-bits get + ] change-src2 finish ]
                [ no-def-conversion ]
                tri
            ]
        }
        {
            [ dup src1>> rep-of tagged-rep? ]
            [
                [ no-use-conversion ]
                [ combine-shl-imm-input ]
                [ emit-def-conversion ]
                tri
            ]
        }
        [ call-next-method ]
    } cond ;

! Optimize this:
! ##sar-imm temp src tag-bits
! ##sar-imm dst temp X
! Into
! ##sar-imm by X + tag-bits
! assuming X + tag-bits is a valid shift count.
: combine-sar-imm? ( insn -- ? )
    {
        [ src1>> rep-of tagged-rep? ]
        [ src2>> tag-bits get + immediate-shift-count? ]
    } 1&& ;

: combine-sar-imm ( insn -- )
    [ dst>> ] [ src1>> ] [ src2>> tag-bits get + ] tri ##sar-imm here ;

M: ##sar-imm optimize-insn
    {
        {
            [ dup combine-sar-imm? ]
            [
                [ no-use-conversion ]
                [ combine-sar-imm ]
                [ emit-def-conversion ]
                tri
            ]
        }
        [ call-next-method ]
    } cond ;

! Peephole optimization: for X = add, sub, and, or, xor, min, max
! we have
! tag(untag(a) X untag(b)) = a X b
!
! so if all inputs and outputs of ##X or ##X-imm are tagged,
! don't have to insert any conversions
: inert-tag? ( insn -- ? )
    {
        [ src1>> rep-of tagged-rep? ]
        [ src2>> rep-of tagged-rep? ]
    } 1&& ;

: inert-tag/untag? ( insn -- ? )
    { [ dst>> rep-of tagged-rep? ] [ inert-tag? ] } 1&& ;

M: inert-tag-untag-insn optimize-insn
    {
        { [ dup inert-tag/untag? ] [ unchanged ] }
        [ call-next-method ]
    } cond ;

! -imm variant of above
: >tagged-imm ( insn -- )
    [ tag-fixnum ] change-src2 unchanged ; inline

M: inert-tag-untag-imm-insn optimize-insn
    {
        { [ dup inert-tag/untag-imm? ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

M: ##mul-imm optimize-insn
    {
        { [ dup inert-tag/untag-imm? ] [ unchanged ] }
        { [ dup dst>> rep-of tagged-rep? ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

! Similar optimization for comparison operators
M: ##compare-integer-imm optimize-insn
    {
        { [ dup inert-tag-imm? ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

M: ##compare-integer-imm-branch optimize-insn
    {
        { [ dup inert-tag-imm? ] [ >tagged-imm ] }
        [ call-next-method ]
    } cond ;

M: ##compare-integer optimize-insn
    {
        { [ dup inert-tag? ] [ unchanged ] }
        [ call-next-method ]
    } cond ;

M: ##compare-integer-branch optimize-insn
    {
        { [ dup inert-tag? ] [ unchanged ] }
        [ call-next-method ]
    } cond ;

! Identities:
! tag(neg(untag(x))) = x
! tag(neg(x)) = x * -2^tag-bits
: inert-tag/untag-unary? ( insn -- ? )
    [ dst>> ] [ src>> ] bi [ rep-of tagged-rep? ] both? ;

: combine-neg-tag ( insn -- )
    [ dst>> ] [ src>> ] bi tag-bits get 2^ neg ##mul-imm here ;

M: ##neg optimize-insn
    {
        { [ dup inert-tag/untag-unary? ] [ unchanged ] }
        {
            [ dup dst>> rep-of tagged-rep? ]
            [
                [ emit-use-conversion ]
                [ combine-neg-tag ]
                [ no-def-conversion ] tri
            ]
        }
        [ call-next-method ]
    } cond ;

! Identity:
! tag(not(untag(x))) = not(x) xor tag-mask
:: emit-tagged-not ( insn -- )
    tagged-rep next-vreg-rep :> temp
    temp insn src>> ##not
    insn dst>> temp tag-mask get ##xor-imm here ;

M: ##not optimize-insn
    {
        {
            [ dup inert-tag/untag-unary? ]
            [
                [ no-use-conversion ]
                [ emit-tagged-not ]
                [ no-def-conversion ]
                tri
            ]
        }
        [ call-next-method ]
    } cond ;
