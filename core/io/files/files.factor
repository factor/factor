! Copyright (C) 2004, 2008 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private sequences init namespaces system io
io.backend io.pathnames io.encodings io.files.private ;
IN: io.files

HOOK: (file-reader) io-backend ( path -- stream )

HOOK: (file-writer) io-backend ( path -- stream )

HOOK: (file-appender) io-backend ( path -- stream )

: <file-reader> ( path encoding -- stream )
    swap normalize-path (file-reader) swap <decoder> ;

: <file-writer> ( path encoding -- stream )
    swap normalize-path (file-writer) swap <encoder> ;

: <file-appender> ( path encoding -- stream )
    swap normalize-path (file-appender) swap <encoder> ;

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

: exists? ( path -- ? ) normalize-path (exists?) ;

! Current directory
<PRIVATE

HOOK: cd io-backend ( path -- )

HOOK: cwd io-backend ( -- path )

M: object cwd ( -- path ) "." ;

PRIVATE>

[
    cwd current-directory set-global
    13 getenv cwd prepend-path \ image set-global
    14 getenv cwd prepend-path \ vm set-global
    image parent-directory "resource-path" set-global
] "io.files" add-init-hook
