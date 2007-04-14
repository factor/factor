! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs kernel math namespaces
prettyprint sequences strings vectors words quotations inspector
io.styles io combinators sorting splitting math.parser effects
continuations debugger io.files io.crc32 vocabs hashtables
graphs compiler.units io.encodings.utf8 ;
IN: source-files

SYMBOL: source-files

TUPLE: source-file
path
checksum
uses definitions ;

: record-checksum ( lines source-file -- )
    >r lines-crc32 r> set-source-file-checksum ;

: (xref-source) ( source-file -- pathname uses )
    dup source-file-path <pathname>
    swap source-file-uses [ crossref? ] subset ;

: xref-source ( source-file -- )
    (xref-source) crossref get add-vertex ;

: unxref-source ( source-file -- )
    (xref-source) crossref get remove-vertex ;

: xref-sources ( -- )
    source-files get [ nip xref-source ] assoc-each ;

: record-form ( quot source-file -- )
    dup unxref-source
    swap quot-uses keys over set-source-file-uses
    xref-source ;

: record-definitions ( file -- )
    new-definitions get swap set-source-file-definitions ;

: <source-file> ( path -- source-file )
    <definitions>
    { set-source-file-path set-source-file-definitions }
    \ source-file construct ;

: source-file ( path -- source-file )
    source-files get [ <source-file> ] cache ;

: reset-checksums ( -- )
    source-files get [
        swap dup exists? [
            utf8 file-lines swap record-checksum
        ] [ 2drop ] if
    ] assoc-each ;

M: pathname where pathname-string 1 2array ;

: forget-source ( path -- )
    dup source-file
    dup unxref-source
    source-file-definitions [ keys forget-all ] each
    source-files get delete-at ;

M: pathname forget*
    pathname-string forget-source ;

: rollback-source-file ( file -- )
    dup source-file-definitions new-definitions get [ union ] 2map
    swap set-source-file-definitions ;

SYMBOL: file

: with-source-file ( name quot -- )
    #! Should be called from inside with-compilation-unit.
    [
        swap source-file
        dup file set
        source-file-definitions old-definitions set
        [ ] [ file get rollback-source-file ] cleanup
    ] with-scope ; inline

: outside-usages ( seq -- usages )
    dup [
        over usage
        [ dup pathname? not swap where and ] subset seq-diff
    ] curry { } map>assoc ;
