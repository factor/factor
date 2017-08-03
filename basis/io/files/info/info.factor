! Copyright (C) 2008 Doug Coleman, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel system sequences combinators
vocabs vocabs.loader io.files io.files.types math ;
IN: io.files.info

! File info
TUPLE: file-info-tuple type size size-on-disk permissions created modified
accessed ;

HOOK: file-info os ( path -- info )

: ?file-info ( path -- info/f )
    dup exists? [ file-info ] [ drop f ] if ; inline

HOOK: link-info os ( path -- info )

: directory? ( file-info -- ? ) type>> +directory+ = ;
: regular-file? ( file-info -- ? ) type>> +regular-file+ = ;
: symbolic-link? ( file-info -- ? ) type>> +symbolic-link+ = ;

: sparse-file? ( file-info -- ? )
    [ size-on-disk>> ] [ size>> ] bi < ;

! File systems
HOOK: file-systems os ( -- array )

TUPLE: file-system-info-tuple device-name mount-point type
available-space free-space used-space total-space ;

HOOK: file-system-info os ( path -- file-system-info )

HOOK: file-readable? os ( path -- ? )
HOOK: file-writable? os ( path -- ? )
HOOK: file-executable? os ( path -- ? )

{
    { [ os unix? ] [ "io.files.info.unix" ] }
    { [ os windows? ] [ "io.files.info.windows" ] }
} cond require
