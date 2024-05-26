! Copyright (C) 2017-2019, 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io io.directories io.encodings.binary io.files
io.files.info io.files.unique io.streams.limited
io.streams.random kernel namespaces system vocabs ;
IN: wipe

HOOK: remove-read-only os ( file-name -- )

M: object remove-read-only drop ;

! Load a Windows-specific implementation of remove-read-only.
os windows? [ "wipe.windows" require ] when

: overwrite-with-random-bytes ( file-name -- )
    [ remove-read-only ] [ file-info size>> ] [ ] tri binary [
        <limited-random-stream>
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
            <limited-random-stream>
            output-stream get stream-copy
        ] with-file-writer
    ] with-temp-directory-at ;
