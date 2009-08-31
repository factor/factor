! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays kernel layouts math namespaces
sequences classes.tuple cpu.architecture compiler.cfg.registers
compiler.cfg.instructions ;
IN: compiler.cfg.hats

: ^^r ( -- vreg vreg ) next-vreg dup ; inline
: ^^r1 ( obj -- vreg vreg obj ) [ ^^r ] dip ; inline
: ^^r2 ( obj obj -- vreg vreg obj obj ) [ ^^r ] 2dip ; inline
: ^^r3 ( obj obj obj -- vreg vreg obj obj obj ) [ ^^r ] 3dip ; inline

: ^^load-literal ( obj -- dst ) ^^r1 ##load-literal ; inline
: ^^copy ( src -- dst ) ^^r1 any-rep ##copy ; inline
: ^^slot ( obj slot tag -- dst ) ^^r3 next-vreg ##slot ; inline
: ^^slot-imm ( obj slot tag -- dst ) ^^r3 ##slot-imm ; inline
: ^^set-slot ( src obj slot tag -- ) next-vreg ##set-slot ; inline
: ^^string-nth ( obj index -- dst ) ^^r2 next-vreg ##string-nth ; inline
: ^^add ( src1 src2 -- dst ) ^^r2 ##add ; inline
: ^^add-imm ( src1 src2 -- dst ) ^^r2 ##add-imm ; inline
: ^^sub ( src1 src2 -- dst ) ^^r2 ##sub ; inline
: ^^sub-imm ( src1 src2 -- dst ) ^^r2 ##sub-imm ; inline
: ^^neg ( src -- dst ) [ 0 ^^load-literal ] dip ^^sub ; inline
: ^^mul ( src1 src2 -- dst ) ^^r2 ##mul ; inline
: ^^mul-imm ( src1 src2 -- dst ) ^^r2 ##mul-imm ; inline
: ^^and ( input mask -- output ) ^^r2 ##and ; inline
: ^^and-imm ( input mask -- output ) ^^r2 ##and-imm ; inline
: ^^or ( src1 src2 -- dst ) ^^r2 ##or ; inline
: ^^or-imm ( src1 src2 -- dst ) ^^r2 ##or-imm ; inline
: ^^xor ( src1 src2 -- dst ) ^^r2 ##xor ; inline
: ^^xor-imm ( src1 src2 -- dst ) ^^r2 ##xor-imm ; inline
: ^^shl ( src1 src2 -- dst ) ^^r2 ##shl ; inline
: ^^shl-imm ( src1 src2 -- dst ) ^^r2 ##shl-imm ; inline
: ^^shr ( src1 src2 -- dst ) ^^r2 ##shr ; inline
: ^^shr-imm ( src1 src2 -- dst ) ^^r2 ##shr-imm ; inline
: ^^sar ( src1 src2 -- dst ) ^^r2 ##sar ; inline
: ^^sar-imm ( src1 src2 -- dst ) ^^r2 ##sar-imm ; inline
: ^^min ( src1 src2 -- dst ) ^^r2 ##min ; inline
: ^^max ( src1 src2 -- dst ) ^^r2 ##max ; inline
: ^^not ( src -- dst ) ^^r1 ##not ; inline
: ^^log2 ( src -- dst ) ^^r1 ##log2 ; inline
: ^^bignum>integer ( src -- dst ) ^^r1 next-vreg ##bignum>integer ; inline
: ^^integer>bignum ( src -- dst ) ^^r1 next-vreg ##integer>bignum ; inline
: ^^add-float ( src1 src2 -- dst ) ^^r2 ##add-float ; inline
: ^^sub-float ( src1 src2 -- dst ) ^^r2 ##sub-float ; inline
: ^^mul-float ( src1 src2 -- dst ) ^^r2 ##mul-float ; inline
: ^^div-float ( src1 src2 -- dst ) ^^r2 ##div-float ; inline
: ^^max-float ( src1 src2 -- dst ) ^^r2 ##max-float ; inline
: ^^min-float ( src1 src2 -- dst ) ^^r2 ##min-float ; inline
: ^^unary-float-function ( src func -- dst ) ^^r2 ##unary-float-function ; inline
: ^^binary-float-function ( src1 src2 func -- dst ) ^^r3 ##binary-float-function ; inline
: ^^sqrt ( src -- dst ) ^^r1 ##sqrt ; inline
: ^^float>integer ( src -- dst ) ^^r1 ##float>integer ; inline
: ^^integer>float ( src -- dst ) ^^r1 ##integer>float ; inline
: ^^allot ( size class -- dst ) ^^r2 next-vreg ##allot ; inline
: ^^allot-tuple ( n -- dst ) 2 + cells tuple ^^allot ; inline
: ^^allot-array ( n -- dst ) 2 + cells array ^^allot ; inline
: ^^allot-byte-array ( n -- dst ) 2 cells + byte-array ^^allot ; inline
: ^^box-alien ( src -- dst ) ^^r1 next-vreg ##box-alien ; inline
: ^^box-displaced-alien ( base displacement base-class -- dst )
    ^^r3 [ next-vreg next-vreg ] dip ##box-displaced-alien ; inline
: ^^unbox-alien ( src -- dst ) ^^r1 ##unbox-alien ; inline
: ^^unbox-c-ptr ( src class -- dst ) ^^r2 next-vreg ##unbox-c-ptr ;
: ^^alien-unsigned-1 ( src -- dst ) ^^r1 ##alien-unsigned-1 ; inline
: ^^alien-unsigned-2 ( src -- dst ) ^^r1 ##alien-unsigned-2 ; inline
: ^^alien-unsigned-4 ( src -- dst ) ^^r1 ##alien-unsigned-4 ; inline
: ^^alien-signed-1 ( src -- dst ) ^^r1 ##alien-signed-1 ; inline
: ^^alien-signed-2 ( src -- dst ) ^^r1 ##alien-signed-2 ; inline
: ^^alien-signed-4 ( src -- dst ) ^^r1 ##alien-signed-4 ; inline
: ^^alien-cell ( src -- dst ) ^^r1 ##alien-cell ; inline
: ^^alien-float ( src -- dst ) ^^r1 ##alien-float ; inline
: ^^alien-double ( src -- dst ) ^^r1 ##alien-double ; inline
: ^^alien-global ( symbol library -- dst ) ^^r2 ##alien-global ; inline
: ^^compare ( src1 src2 cc -- dst ) ^^r3 next-vreg ##compare ; inline
: ^^compare-imm ( src1 src2 cc -- dst ) ^^r3 next-vreg ##compare-imm ; inline
: ^^compare-float ( src1 src2 cc -- dst ) ^^r3 next-vreg ##compare-float ; inline
: ^^offset>slot ( vreg -- vreg' ) cell 4 = [ 1 ^^shr-imm ] [ ^^copy ] if ; inline
: ^^tag-fixnum ( src -- dst ) ^^r1 ##tag-fixnum ; inline
: ^^untag-fixnum ( src -- dst ) ^^r1 ##untag-fixnum ; inline
: ^^fixnum-add ( src1 src2 -- dst ) ^^r2 ##fixnum-add ; inline
: ^^fixnum-sub ( src1 src2 -- dst ) ^^r2 ##fixnum-sub ; inline
: ^^fixnum-mul ( src1 src2 -- dst ) ^^r2 ##fixnum-mul ; inline
: ^^phi ( inputs -- dst ) ^^r1 ##phi ; inline