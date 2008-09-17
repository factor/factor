! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors math namespaces sequences kernel fry
compiler.vops ;
IN: compiler.cfg.stack

! Combine multiple stack height changes into one, done at the
! start of the basic block.
!
! Alias analysis and value numbering assume this optimization
! has been performed.

! Current data and retain stack height is stored in
! %data, %retain variables.
GENERIC: compute-heights ( insn -- )

M: %height compute-heights
    [ n>> ] [ stack>> ] bi [ + ] change ;

M: object compute-heights drop ;

GENERIC: normalize-height* ( insn -- insn )

M: %height normalize-height*
    [ n>> ] [ stack>> ] bi [ swap - ] change nop ;

: (normalize-height) ( insn -- insn )
    dup stack>> get '[ , + ] change-n ; inline

M: %peek normalize-height* (normalize-height) ;

M: %replace normalize-height* (normalize-height) ;

M: object normalize-height* ;

: normalize-height ( insns -- insns' )
    0 %data set
    0 %retain set
    [ [ compute-heights ] each ]
    [ [ [ normalize-height* ] map ] with-scope ] bi
    %data get dup zero? [ drop ] [ %data %height boa prefix ] if
    %retain get dup zero? [ drop ] [ %retain %height boa prefix ] if ;
