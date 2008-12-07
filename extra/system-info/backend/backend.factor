! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: system ;
IN: system-info.backend

HOOK: cpus os ( -- n )
HOOK: cpu-mhz os ( -- n )
HOOK: memory-load os ( -- n )
HOOK: physical-mem os ( -- n )
HOOK: available-mem os ( -- n )
HOOK: total-page-file os ( -- n )
HOOK: available-page-file os ( -- n )
HOOK: total-virtual-mem os ( -- n )
HOOK: available-virtual-mem os ( -- n )
HOOK: available-virtual-extended-mem os ( -- n )
