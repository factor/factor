USING: system ;
IN: hardware-info.backend

HOOK: cpus os ( -- n )
HOOK: memory-load os ( -- n )
HOOK: physical-mem os ( -- n )
HOOK: available-mem os ( -- n )
HOOK: total-page-file os ( -- n )
HOOK: available-page-file os ( -- n )
HOOK: total-virtual-mem os ( -- n )
HOOK: available-virtual-mem os ( -- n )
HOOK: available-virtual-extended-mem os ( -- n )
