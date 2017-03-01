! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: init kernel math sodium.ffi ;
IN: sodium

ERROR: sodium-init-fail ;

! Call this before any other function, may be called multiple times.
: sodium-init ( -- ) sodium_init 0 < [ sodium-init-fail ] when ;

[ sodium-init ] "sodium" add-startup-hook
