! Copyright (C) 2017-2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors
io io.directories io.encodings.binary io.files io.files.info
io.files.unique io.files.windows io.streams.limited
io.streams.random
kernel math namespaces random windows.kernel32 ;
IN: wipe

: extract-bit ( n mask -- n' ? )
    [ bitnot bitand ] [ bitand 0 = not ] bi-curry bi ; inline

: remove-read-only ( file-name -- )
    dup GetFileAttributesW FILE_ATTRIBUTE_READONLY extract-bit
    [ set-file-attributes ] [ 2drop ] if ;

: overwrite-with-random-bytes ( file-name -- )
    [ remove-read-only ] [ file-info size>> ] [ ] tri binary [
        <random-stream> limit-stream
        0 seek-absolute output-stream get
        [ stream-seek ] keep stream-copy
    ] with-file-appender ;

: make-file-empty ( file-name -- )
    binary [ ] with-file-writer ;

: wipe-file ( file-name -- )
    [ overwrite-with-random-bytes ] [ make-file-empty ] [ delete-file ] tri ;

: wipe-all ( directory -- )
    [ dup directory? [ drop ] [ name>> wipe-file ] if ] each-directory-entry ;

: wipe ( path -- )
    dup file-info regular-file? [ wipe-file ] [ wipe-all ] if ;

: with-temp-directory-at ( path quot -- )
    [ cleanup-unique-directory ] curry with-directory ; inline

: wipe-free-space ( path -- )
    dup [
        file-system-info free-space>>
        "" "" unique-file binary [
            <random-stream> limit-stream
            output-stream get stream-copy
        ] with-file-writer
    ] with-temp-directory-at ;
