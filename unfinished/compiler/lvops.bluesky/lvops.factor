! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.lvops

! Machine representation ("linear virtual operations"). Uses
! same operations as CFG basic blocks, except edges and branches
! are replaced by linear jumps (_b* instances).

TUPLE: _label label ;

! Unconditional jump to label
TUPLE: _b label ;

! Integer
TUPLE: _bi label in code ;
TUPLE: _bf label in code ;

! Dispatch table, jumps to one of following _address
! depending value of 'in'
TUPLE: _dispatch in ;
TUPLE: _address word ;
