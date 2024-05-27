! Copyright (C) 2017 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings assocs byte-arrays
classes.struct continuations io io.encodings.binary
io.encodings.string io.files kernel math math.bitwise sequences
system ;
IN: ldcache

! General util
ERROR: bad-magic got expected ;

: check-magic ( got expected -- )
    2dup = [ 2drop ] [ bad-magic ] if ;

CONSTANT: HEADER_MAGIC_OLD "ld.so-1.7.0"
CONSTANT: HEADER_MAGIC_NEW "glibc-ld.so.cache1.1"

TUPLE: ldcache-entry elf? arch osversion hwcap key value ;

STRUCT: HeaderOld
    { magic char[11] }
    { nlibs uint32_t } ;

STRUCT: EntryOld
    { flags int32_t }
    { key uint32_t }
    { value uint32_t } ;

STRUCT: HeaderNew
    { magic char[20] }
    { nlibs uint32_t }
    { stringslen uint32_t }
    { unused uint32_t[5] } ;

STRUCT: EntryNew
    { flags int16_t }
    { key uint32_t }
    { value uint32_t }
    { osversion uint32_t }
    { hwcap uint64_t } ;

: check-ldcache-magic ( header expected -- )
    [ magic>> ] dip [ >byte-array ] bi@ check-magic ;

: make-string ( string-table i -- str )
    0 spin [ index-from ] 2keep swapd subseq
    native-string-encoding decode ;

: string-offset ( header-new -- n )
    nlibs>> EntryNew struct-size * HeaderNew struct-size + ;

: subtract-string-offset ( ofs entry-new -- entry-new )
    over '[ _ - ] change-key swap '[ _ - ] change-value ;

: parse-new-entries ( header-new -- seq )
    [ string-offset ] keep
    nlibs>> [ EntryNew read-struct ] replicate
    [ subtract-string-offset ] with map ;

: flag>arch ( flag -- arch )
    0xff00 bitand
    { { 0x0800 x86.32 }
      { 0x0300 x86.64 }
      { 0x0500 ppc.64 }
    } at ;

: <ldcache-entry> ( string-table entry-new -- entry )
    [
        nip [
            flags>> [ 1 mask? ] [ flag>arch ] bi
        ] [ osversion>> ] [ hwcap>> ] tri
    ]
    [ key>> make-string ]
    [ value>> make-string ] 2tri ldcache-entry boa ;

: parse ( -- entries )
    ! Read the old header and jump past it.
    HeaderOld read-struct
    [
        [ HEADER_MAGIC_OLD check-ldcache-magic ]
        [ nlibs>> EntryOld struct-size * seek-relative seek-input ] bi
    ] [ 2drop HeaderOld struct-size neg seek-relative seek-input ] recover
    HeaderNew read-struct
    [ HEADER_MAGIC_NEW check-ldcache-magic ] keep
    [ parse-new-entries ]
    [ stringslen>> read ] bi
    swap [ <ldcache-entry> ] with map ;

: search ( entries namespec arch -- entry/f )
    swap "lib" ".so" surround '[ [ arch>> _ = ] [ key>> _ head? ] bi and ] find nip ;

: find-so ( namespec -- so-name/f )
    "/etc/ld.so.cache" [
        binary [ parse ] with-file-reader swap
        cpu search [ key>> ] [ f ] if*
    ] [ 2drop f ] if-file-exists ;
