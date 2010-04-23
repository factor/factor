! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit kernel
layouts math namespaces cpu.architecture
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.representations.rewrite ;
IN: compiler.cfg.representations.peephole

! Representation selection performs some peephole optimizations
! when inserting conversions to optimize for a few common cases

M: ##load-integer conversions-for-insn
    {
        {
            [ dup dst>> rep-of tagged-rep? ]
            [ [ dst>> ] [ val>> tag-fixnum ] bi ##load-tagged ]
        }
        [ call-next-method ]
    } cond ;

! When a float is unboxed, we replace the ##load-reference with a ##load-double
! if the architecture supports it
: convert-to-load-double? ( insn -- ? )
    {
        [ drop load-double? ]
        [ dst>> rep-of double-rep? ]
        [ obj>> float? ]
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

: (convert-to-load-double) ( insn -- dst val )
    [ dst>> ] [ obj>> ] bi ; inline

: (convert-to-zero/fill-vector) ( insn -- dst rep )
    dst>> dup rep-of ; inline

M: ##load-reference conversions-for-insn
    {
        {
            [ dup convert-to-load-double? ]
            [ (convert-to-load-double) ##load-double ]
        }
        {
            [ dup convert-to-zero-vector? ]
            [ (convert-to-zero/fill-vector) ##zero-vector ]
        }
        {
            [ dup convert-to-fill-vector? ]
            [ (convert-to-zero/fill-vector) ##fill-vector ]
        }
        [ call-next-method ]
    } cond ;

! Optimize this:
! ##sar-imm temp src tag-bits
! ##shl-imm dst temp X
! Into either
! ##shl-imm by X - tag-bits, or
! ##sar-imm by tag-bits - X.
: combine-shl-imm? ( insn -- ? )
    src1>> rep-of tagged-rep? ;

: combine-shl-imm ( insn -- )
    [ dst>> ] [ src1>> ] [ src2>> ] tri tag-bits get {
        { [ 2dup < ] [ swap - ##sar-imm ] }
        { [ 2dup > ] [ - ##shl-imm ] }
        [ 2drop int-rep ##copy ]
    } cond ;

M: ##shl-imm conversions-for-insn
    {
        {
            [ dup combine-shl-imm? ]
            [ [ combine-shl-imm ] [ emit-def-conversion ] bi ]
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
    [ dst>> ] [ src1>> ] [ src2>> tag-bits get + ] tri ##sar-imm ;

M: ##sar-imm conversions-for-insn
    {
        {
            [ dup combine-sar-imm? ]
            [ [ combine-sar-imm ] [ emit-def-conversion ] bi ]
        }
        [ call-next-method ]
    } cond ;
