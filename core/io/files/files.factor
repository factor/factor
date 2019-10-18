! Copyright (C) 2004, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings init io io.backend io.encodings io.pathnames
kernel kernel.private namespaces sequences splitting system ;
IN: io.files

<PRIVATE
PRIMITIVE: (exists?) ( path -- ? )
PRIVATE>

SYMBOL: +retry+ ! just try the operation again without blocking
SYMBOL: +input+
SYMBOL: +output+

! Returns an event to wait for which will ensure completion of
! this request
GENERIC: drain ( port handle -- event/f )
GENERIC: refill ( port handle -- event/f )

HOOK: wait-for-fd io-backend ( handle event -- )

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

: change-file-lines ( path encoding quot -- )
    [ [ file-lines ] dip call ]
    [ drop set-file-lines ] 3bi ; inline

: set-file-contents ( seq path encoding -- )
    [ write ] with-file-writer ;

: change-file-contents ( path encoding quot -- )
    [ [ file-contents ] dip call ]
    [ drop set-file-contents ] 3bi ; inline

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
    OBJ-ARGS special-object [
        alien>native-string "-resource-path=" ?head [ drop f ] unless
    ] map-find drop
    [ image-path parent-directory ] unless* "resource-path" set-global ;

[
    cwd current-directory set-global
    OBJ-IMAGE special-object alien>native-string \ image-path set-global
    OBJ-EXECUTABLE special-object alien>native-string \ vm-path set-global
    init-resource-path
] "io.files" add-startup-hook
