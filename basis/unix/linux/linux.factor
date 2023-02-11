! Copyright (C) 2005, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: system unix unix.ffi unix.ffi.linux ;
IN: unix.linux

M: linux open-file [ open64 ] unix-system-call ;
