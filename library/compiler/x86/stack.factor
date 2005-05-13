! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel lists math
memory sequences words ;

: rel-cs ( -- )
    #! Add an entry to the relocation table for the 32-bit
    #! immediate just compiled.
    "cs" f 0 0 rel-dlsym ;

: CS ( -- [ address ] ) "cs" f dlsym unit ;
: CS> ( register -- ) CS MOV rel-cs ;
: >CS ( register -- ) CS swap MOV rel-cs ;

: reg-stack ( reg n -- op ) cell * neg 2list ;
: ds-op ( n -- op ) ESI swap reg-stack ;
: cs-op ( n -- op ) ECX swap reg-stack ;

M: %peek-d generate-node ( vop -- )
    dup vop-dest v>operand swap vop-literal ds-op MOV ;

M: %replace-d generate-node ( vop -- )
    dup vop-source v>operand swap vop-literal ds-op swap MOV ;

M: %inc-d generate-node ( vop -- )
    ESI swap vop-literal cell *
    dup 0 > [ ADD ] [ neg SUB ] ifte ;

M: %immediate generate-node ( vop -- )
    dup vop-dest v>operand swap vop-literal address MOV ;

M: %immediate-d generate-node ( vop -- )
    vop-literal [ ESI ] swap address MOV ;

: load-indirect ( dest literal -- )
    intern-literal unit MOV 0 0 rel-address ;

M: %indirect generate-node ( vop -- )
    #! indirect load of a literal through a table
    dup vop-dest v>operand swap vop-literal load-indirect ;

M: %peek-r generate-node ( vop -- )
    ECX CS>  dup vop-dest v>operand swap vop-literal cs-op MOV ;

M: %dec-r generate-node ( vop -- )
    #! Can only follow a %peek-r
    vop-literal ECX swap cell * SUB  ECX >CS ;

M: %replace-r generate-node ( vop -- )
    #! Can only follow a %inc-r
    dup vop-source v>operand swap vop-literal cs-op swap MOV
    ECX >CS ;

M: %inc-r generate-node ( vop -- )
    #! Can only follow a %peek-r
    ECX CS>
    vop-literal ECX swap cell * ADD ;
