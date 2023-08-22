! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators environment
gobject-introspection.common gobject-introspection.ffi
gobject-introspection.loader gobject-introspection.types io
io.files io.pathnames kernel lexer make namespaces parser
sequences splitting summary vocabs vocabs.parser xdg xml ;
IN: gobject-introspection

ERROR: gir-not-found name paths ;

M: gir-not-found summary
    [ name>> "“" "” file not found on paths:\n" surround ]
    [ paths>> join-lines ] bi
    "\n\nUse the existing path or declare GIR_DIRS environment variable"
    3append ;

<PRIVATE

: system-gir-dirs ( -- dirs )
    xdg-data-dirs [ "gir-1.0" append-path ] map ;

: custom-gir-dirs ( -- dirs )
    "GIR_DIRS" os-env ":" split ;

: current-vocab-path ( -- path )
    current-vocab vocab-name "." split "/" join vocab-path ;

: current-vocab-dirs ( -- dirs )
    [
        current-vocab-path
        [ , ] [ "/ffi" ?tail [ , ] [ drop ] if ] bi
    ] { } make ;

:: resolve-gir-path ( path -- path )
    path file-exists?
    [ path ] [
        current-vocab-dirs custom-gir-dirs system-gir-dirs
        3append sift :> paths
        paths [ path append-path file-exists? ] find nip
        [ path append-path ] [ path paths gir-not-found ] if*
    ] if ;

: define-gir-vocab ( path -- )
    resolve-gir-path dup "Loading " write print
    file>xml xml>repository
    {
        [ namespace>> name>> current-namespace-name set-global ]
        [ def-ffi-repository ]
    } cleave
    V{ } clone implement-structs set-global ;

PRIVATE>

SYNTAX: GIR: scan-token define-gir-vocab ;

SYNTAX: IMPLEMENT-STRUCTS:
    ";" parse-tokens
    implement-structs [ swap append! ] change-global ;

SYNTAX: FOREIGN-ATOMIC-TYPE:
    scan-token scan-object swap register-atomic-type ;

SYNTAX: FOREIGN-ENUM-TYPE:
    scan-token scan-object swap register-enum-type ;

SYNTAX: FOREIGN-RECORD-TYPE:
    scan-token scan-object swap register-record-type ;
