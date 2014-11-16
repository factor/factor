! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image io.directories io.directories.hierarchy
io.encodings.ascii io.files kernel namespaces sequences system ;
FROM: mason.config => target-os ;
IN: mason.release.tidy

: useless-files ( -- seq )
    "build-support/cleanup" ascii file-lines
    images [ boot-image-name ] map append
    target-os get macosx? [ "Factor.app" suffix ] unless ;

: tidy ( -- )
    "factor" [
        useless-files
        [ exists? ] filter
        [ delete-tree ] each
    ] with-directory ;
