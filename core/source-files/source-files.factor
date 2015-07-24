! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs checksums checksums.crc32
compiler.units continuations definitions io.encodings.utf8
io.files io.pathnames kernel namespaces sequences sets
source-files.errors strings words ;
FROM: namespaces => set ;
IN: source-files

SYMBOL: source-files

TUPLE: source-file
path
top-level-form
checksum
definitions
main ;

: record-top-level-form ( quot source-file -- )
    top-level-form<<
    [ ] [ f notify-definition-observers ] if-bootstrapping ;

: record-checksum ( lines source-file -- )
    [ crc32 checksum-lines ] dip checksum<< ;

: record-definitions ( source-file -- )
    new-definitions get >>definitions drop ;

: <source-file> ( path -- source-file )
    \ source-file new
        swap >>path
        <definitions> >>definitions ;

ERROR: invalid-source-file-path path ;

: path>source-file ( path -- source-file )
    dup string? [ invalid-source-file-path ] unless
    source-files get [ <source-file> ] cache ;

: reset-checksums ( -- )
    source-files get [
        over exists? [
            [ utf8 file-lines ] dip record-checksum
        ] [ 2drop ] if
    ] assoc-each ;

M: pathname where string>> 1 2array ;

: forget-source ( path -- )
    source-files get delete-at*
    [ definitions>> [ members forget-all ] each ] [ drop ] if ;

M: pathname forget*
    string>> forget-source ;

: rollback-source-file ( source-file -- )
    [
        new-definitions get [ union ] 2map
    ] change-definitions drop ;

SYMBOL: current-source-file

: wrap-source-file-error ( error -- * )
    current-source-file get rollback-source-file
    source-file-error new
        f >>line#
        current-source-file get path>> >>path
        swap >>error rethrow ;

: with-source-file ( name quot -- )
    #! Should be called from inside with-compilation-unit.
    [
        [
            path>source-file
            [ current-source-file set ]
            [ definitions>> old-definitions set ] bi
        ] dip
        [ wrap-source-file-error ] recover
    ] with-scope ; inline
