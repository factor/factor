! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: parser system kernel sequences math ranges
cpu.ppc.assembler combinators compiler.constants
bootstrap.image.private layouts namespaces ;
IN: bootstrap.assembler.ppc

4 \ cell set
big-endian on

: reserved-size ( -- n ) 24 ;
: lr-save ( -- n ) 4 ;

CONSTANT: ds-reg    14
CONSTANT: rs-reg    15
CONSTANT: vm-reg    16
CONSTANT: ctx-reg   17
CONSTANT: frame-reg 31
: nv-int-regs ( -- seq ) 13 31 [a..b] ;

: LOAD32 ( r n -- )
    [ -16 shift 0xffff bitand LIS ]
    [ dupd 0xffff bitand ORI ] 2bi ;

: jit-trap-null ( src -- ) drop ;
: jit-load-vm ( dst -- )
    0 LOAD32 0 rc-absolute-ppc-2/2 jit-vm ;
: jit-load-dlsym ( dst string -- )
    [ 0 LOAD32 ] dip rc-absolute-ppc-2/2 jit-dlsym ;
: jit-load-dlsym-toc ( string -- ) drop ;
: jit-load-vm-arg ( dst -- )
    0 LOAD32 rc-absolute-ppc-2/2 rt-vm jit-rel ;
: jit-load-entry-point-arg ( dst -- )
    0 LOAD32 rc-absolute-ppc-2/2 rt-entry-point jit-rel ;
: jit-load-this-arg ( dst -- )
    0 LOAD32 rc-absolute-ppc-2/2 rt-this jit-rel ;
: jit-load-literal-arg ( dst -- )
    0 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel ;
: jit-load-dlsym-arg ( dst -- )
    0 LOAD32 rc-absolute-ppc-2/2 rt-dlsym jit-rel ;
: jit-load-dlsym-toc-arg ( -- ) ;
: jit-load-here-arg ( dst -- )
    0 LOAD32 rc-absolute-ppc-2/2 rt-here jit-rel ;
: jit-load-megamorphic-cache-arg ( dst -- )
    0 LOAD32 rc-absolute-ppc-2/2 rt-megamorphic-cache-hits jit-rel ;
: jit-load-cell ( dst src offset -- ) LWZ ;
: jit-load-cell-x ( dst src offset -- ) LWZX ;
: jit-load-cell-update ( dst src offset -- ) LWZU ;
: jit-save-cell ( dst src offset -- ) STW ;
: jit-save-cell-x ( dst src offset -- ) STWX ;
: jit-save-cell-update ( dst src offset -- ) STWU ;
: jit-load-int ( dst src offset -- ) LWZ ;
: jit-save-int ( dst src offset -- ) STW ;
: jit-shift-tag-bits ( dst src -- ) tag-bits get SRAWI ;
: jit-mask-tag-bits ( dst src -- ) tag-bits get CLRRWI ;
: jit-shift-fixnum-slot ( dst src -- ) 2 SRAWI ;
: jit-class-hashcode ( dst src -- ) 1 SRAWI ;
: jit-shift-left-logical ( dst src n -- ) SLW ;
: jit-shift-left-logical-imm ( dst src n -- ) SLWI ;
: jit-shift-right-algebraic ( dst src n -- ) SRAW ;
: jit-divide ( dst ra rb -- ) DIVW ;
: jit-multiply-low ( dst ra rb -- ) MULLW ;
: jit-multiply-low-ov-rc ( dst ra rb -- ) MULLWO. ;
: jit-compare-cell ( cr ra rb -- ) CMPW ;
: jit-compare-cell-imm ( cr ra imm -- ) CMPWI ;

: cell-size ( -- n ) 4 ;
: factor-area-size ( -- n ) 16 ;
: param-size ( -- n ) 32 ;
: saved-int-regs-size ( -- n ) 96 ;

<< "resource:basis/bootstrap/assembler/ppc.factor" parse-file suffix! >>
call
