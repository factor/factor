USING: alien.syntax math prettyprint system ;
IN: hardware-info

SYMBOL: os
HOOK: cpus os ( -- n )

HOOK: memory-load os ( -- n )
HOOK: physical-mem os ( -- n )
HOOK: available-mem os ( -- n )
HOOK: total-page-file os ( -- n )
HOOK: available-page-file os ( -- n )
HOOK: total-virtual-mem os ( -- n )
HOOK: available-virtual-mem os ( -- n )
HOOK: available-virtual-extended-mem os ( -- n )

: kb. ( x -- ) 10 2^ /f . ;
: megs. ( x -- ) 20 2^ /f . ;
: gigs. ( x -- ) 30 2^ /f . ;

USE-IF: windows? hardware-info.windows
USE-IF: linux? hardware-info.linux
USE-IF: macosx? hardware-info.macosx

