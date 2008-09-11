! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system ;
IN: compiler.backend

! Is this structure small enough to be returned in registers?
HOOK: struct-small-enough? cpu ( size -- ? )

! Mapping from register class to machine registers
HOOK: machine-registers cpu ( -- assoc )
