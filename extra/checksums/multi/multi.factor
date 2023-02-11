! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors checksums checksums.common destructors
kernel sequences ;
IN: checksums.multi

TUPLE: multi-checksum checksums ;

C: <multi-checksum> multi-checksum

TUPLE: multi-state < disposable states results ;

M: multi-checksum initialize-checksum-state
    checksums>> [ initialize-checksum-state ] map
    multi-state new-disposable swap >>states ;

M: multi-state dispose*
    states>> dispose-each ;

M: multi-state add-checksum-bytes
    '[ [ _ add-checksum-bytes ] map! ] change-states ;

M: multi-state get-checksum
    dup results>> [
        dup states>> [ get-checksum ] map [ >>results ] keep
    ] unless* nip ;

INSTANCE: multi-checksum block-checksum
