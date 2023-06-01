! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: parser system kernel sequences math ranges
cpu.ppc.assembler combinators compiler.constants
bootstrap.image.private layouts namespaces ;
IN: bootstrap.assembler.ppc

8 \ cell set
big-endian on

: reserved-size ( -- n ) 48 ;
: lr-save ( -- n ) 16 ;

CONSTANT: ds-reg    14
CONSTANT: rs-reg    15
CONSTANT: vm-reg    16
CONSTANT: ctx-reg   17
CONSTANT: frame-reg 31
: nv-int-regs ( -- seq ) 13 31 [a..b] ;

: LOAD64 ( r n -- )
    dupd {
        [ nip -48 shift 0xffff bitand LIS ]
        [ -32 shift 0xffff bitand ORI ]
        [ drop 32 SLDI ]
        [ -16 shift 0xffff bitand ORIS ]
        [ 0xffff bitand ORI ]
    } 3cleave ;

: jit-trap-null ( src -- ) drop ;
: jit-load-vm ( dst -- )
    0 LOAD64 0 rc-absolute-ppc-2/2/2/2 jit-vm ;
: jit-load-dlsym ( dst string -- )
    [ 0 LOAD64 ] dip rc-absolute-ppc-2/2/2/2 jit-dlsym ;
: jit-load-dlsym-toc ( string -- )
    [ 2 0 LOAD64 ] dip rc-absolute-ppc-2/2/2/2 jit-dlsym-toc ;
: jit-load-vm-arg ( dst -- )
    0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-vm jit-rel ;
: jit-load-entry-point-arg ( dst -- )
    0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-entry-point jit-rel ;
: jit-load-this-arg ( dst -- )
    0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-this jit-rel ;
: jit-load-literal-arg ( dst -- )
    0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-literal jit-rel ;
: jit-load-dlsym-arg ( dst -- )
    0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-dlsym jit-rel ;
: jit-load-dlsym-toc-arg ( -- )
    2 0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-dlsym-toc jit-rel ;
: jit-load-here-arg ( dst -- )
    0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-here jit-rel ;
: jit-load-megamorphic-cache-arg ( dst -- )
    0 LOAD64 rc-absolute-ppc-2/2/2/2 rt-megamorphic-cache-hits jit-rel ;
: jit-load-cell ( dst src offset -- ) LD ;
: jit-load-cell-x ( dst src offset -- ) LDX ;
: jit-load-cell-update ( dst src offset -- ) LDU ;
: jit-save-cell ( dst src offset -- ) STD ;
: jit-save-cell-x ( dst src offset -- ) STDX ;
: jit-save-cell-update ( dst src offset -- ) STDU ;
: jit-load-int ( dst src offset -- ) LD ;
: jit-save-int ( dst src offset -- ) STD ;
: jit-shift-tag-bits ( dst src -- ) tag-bits get SRADI ;
: jit-mask-tag-bits ( dst src -- ) tag-bits get CLRRDI ;
: jit-shift-fixnum-slot ( dst src -- ) 1 SRADI ;
: jit-class-hashcode ( dst src -- ) 1 SRADI ;
: jit-shift-left-logical ( dst src n -- ) SLD ;
: jit-shift-left-logical-imm ( dst src n -- ) SLDI ;
: jit-shift-right-algebraic ( dst src n -- ) SRAD ;
: jit-divide ( dst ra rb -- ) DIVD ;
: jit-multiply-low ( dst ra rb -- ) MULLD ;
: jit-multiply-low-ov-rc ( dst ra rb -- ) MULLDO. ;
: jit-compare-cell ( cr ra rb -- ) CMPD ;
: jit-compare-cell-imm ( cr ra imm -- ) CMPDI ;

: cell-size ( -- n ) 8 ;
: factor-area-size ( -- n ) 32 ;
: param-size ( -- n ) 64 ;
: saved-int-regs-size ( -- n ) 192 ;

<< "resource:basis/bootstrap/assembler/ppc.factor" parse-file suffix! >>
call
