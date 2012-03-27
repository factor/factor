! Copyright (C) 2004, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private sequences init namespaces system io
io.encodings.utf8 io.backend io.pathnames io.encodings io.files.private
alien.strings splitting ;
IN: io.files

MIXIN: file-reader
MIXIN: file-writer

M: file-reader stream-element-type drop +byte+ ; inline
M: file-writer stream-element-type drop +byte+ ; inline

HOOK: (file-reader) io-backend ( path -- stream )

HOOK: (file-writer) io-backend ( path -- stream )

HOOK: (file-appender) io-backend ( path -- stream )

: <file-reader> ( path encoding -- stream )
    [ normalize-path (file-reader) { file-reader } declare ] dip <decoder> ; inline

: <file-writer> ( path encoding -- stream )
    [ normalize-path (file-writer) { file-writer } declare ] dip <encoder> ; inline

: <file-appender> ( path encoding -- stream )
    [ normalize-path (file-appender) { file-writer } declare ] dip <encoder> ; inline

: file-lines ( path encoding -- seq )
    <file-reader> stream-lines ;

: with-file-reader ( path encoding quot -- )
    [ <file-reader> ] dip with-input-stream ; inline

: file-contents ( path encoding -- seq )
    <file-reader> stream-contents ;

: with-file-writer ( path encoding quot -- )
    [ <file-writer> ] dip with-output-stream ; inline

: set-file-lines ( seq path encoding -- )
    [ [ print ] each ] with-file-writer ;

: set-file-contents ( seq path encoding -- )
    [ write ] with-file-writer ;

: with-file-appender ( path encoding quot -- )
    [ <file-appender> ] dip with-output-stream ; inline

: exists? ( path -- ? )
    normalize-path native-string>alien (exists?) ;

! Current directory
<PRIVATE

HOOK: cd io-backend ( path -- )

HOOK: cwd io-backend ( -- path )

M: object cwd ( -- path ) "." ;

PRIVATE>

: init-resource-path ( -- )
    OBJ-ARGS special-object
    [ utf8 alien>string "-resource-path=" ?head [ drop f ] unless ] map-find drop
    [ image parent-directory ] unless* "resource-path" set-global ;

[
    cwd current-directory set-global
    OBJ-IMAGE special-object alien>native-string cwd prepend-path \ image set-global
    OBJ-EXECUTABLE special-object alien>native-string cwd prepend-path \ vm set-global
    init-resource-path
] "io.files" add-startup-hook
