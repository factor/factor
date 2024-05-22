! Copyright (C) 2008 Doug Coleman, Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
io.files io.files.types io.pathnames kernel math strings system
vocabs ;
IN: io.files.info

! File info
TUPLE: file-info-tuple type size size-on-disk permissions created modified
accessed ;

HOOK: file-info os ( path -- info )

: ?file-info ( path -- info/f )
    dup file-exists? [ file-info ] [ drop f ] if ;

HOOK: link-info os ( path -- info )

: ?link-info ( path -- info/f )
    dup file-exists? [ link-info ] [ drop f ] if ;

<PRIVATE

: >file-info ( path/info -- info )
    dup { [ string? ] [ pathname? ] } 1|| [ file-info ] when ;

PRIVATE>

: directory? ( path/info -- ? )
    [ >file-info type>> +directory+ = ] ?call ;

: regular-file? ( path/info -- ? )
    [ >file-info type>> +regular-file+ = ] ?call ;

: symbolic-link? ( path/info -- ? )
    [ >file-info type>> +symbolic-link+ = ] ?call ;

: sparse-file? ( path/info -- ? )
    [ >file-info [ size-on-disk>> ] [ size>> ] bi < ] ?call ;

! File systems
HOOK: file-systems os ( -- array )

TUPLE: file-system-info-tuple device-name mount-point type
available-space free-space used-space total-space ;

HOOK: file-system-info os ( path -- file-system-info )

HOOK: file-readable? os ( path -- ? )
HOOK: file-writable? os ( path -- ? )
HOOK: file-executable? os ( path -- ? )

HOOK: mount-points os ( -- assoc )

M: object mount-points
    file-systems [ [ mount-point>> ] keep ] H{ } map>assoc ;

: (find-mount-point) ( path assoc -- object )
    [ resolve-symlinks canonicalize-path-full ] dip
    2dup at* [
        2nip
    ] [
        drop [ parent-directory ] dip (find-mount-point)
    ] if ;

: find-mount-point ( path -- object )
    mount-points (find-mount-point) ;

{
    { [ os unix? ] [ "io.files.info.unix" ] }
    { [ os windows? ] [ "io.files.info.windows" ] }
} cond require
