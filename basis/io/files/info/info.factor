! Copyright (C) 2008 Doug Coleman, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel system sequences combinators
vocabs vocabs.loader io.files.types math ;
IN: io.files.info

! File info
TUPLE: file-info type size size-on-disk permissions created modified
accessed ;

HOOK: file-info os ( path -- info )

HOOK: link-info os ( path -- info )

: directory? ( file-info -- ? ) type>> +directory+ = ;

: sparse-file? ( file-info -- ? )
    [ size-on-disk>> ] [ size>> ] bi < ;

! File systems
HOOK: file-systems os ( -- array )

TUPLE: file-system-info device-name mount-point type
available-space free-space used-space total-space ;

HOOK: file-system-info os ( path -- file-system-info )

HOOK: file-readable? os ( path -- ? )
HOOK: file-writable? os ( path -- ? )
HOOK: file-executable? os ( path -- ? )

{
    { [ os unix? ] [ "io.files.info.unix" ] }
    { [ os windows? ] [ "io.files.info.windows" ] }
} cond require
