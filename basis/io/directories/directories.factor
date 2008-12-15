! Copyright (C) 2004, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators destructors io io.backend
io.encodings.binary io.files io.files.info io.files.links
io.pathnames kernel namespaces sequences system vocabs.loader ;
IN: io.directories

: set-current-directory ( path -- )
    (normalize-path) current-directory set ;

: with-directory ( path quot -- )
    [ (normalize-path) current-directory ] dip with-variable ; inline

! Creating directories
HOOK: make-directory io-backend ( path -- )

: make-directories ( path -- )
    normalize-path trim-right-separators {
        { [ dup "." = ] [ ] }
        { [ dup root-directory? ] [ ] }
        { [ dup empty? ] [ ] }
        { [ dup exists? ] [ ] }
        [
            dup parent-directory make-directories
            dup make-directory
        ]
    } cond drop ;

! Listing directories
TUPLE: directory-entry name type ;

HOOK: >directory-entry os ( byte-array -- directory-entry )

HOOK: (directory-entries) os ( path -- seq )

: directory-entries ( path -- seq )
    normalize-path
    (directory-entries)
    [ name>> { "." ".." } member? not ] filter ;
    
: directory-files ( path -- seq )
    directory-entries [ name>> ] map ;

: with-directory-files ( path quot -- )
    [ "" directory-files ] prepose with-directory ; inline

! Touching files
HOOK: touch-file io-backend ( path -- )

! Deleting files
HOOK: delete-file io-backend ( path -- )

HOOK: delete-directory io-backend ( path -- )

: delete-tree ( path -- )
    dup link-info type>> +directory+ = [
        [ [ [ delete-tree ] each ] with-directory-files ]
        [ delete-directory ]
        bi
    ] [ delete-file ] if ;

: to-directory ( from to -- from to' )
    over file-name append-path ;

! Moving and renaming files
HOOK: move-file io-backend ( from to -- )

: move-file-into ( from to -- )
    to-directory move-file ;

: move-files-into ( files to -- )
    [ move-file-into ] curry each ;

! Copying files
HOOK: copy-file io-backend ( from to -- )

M: object copy-file
    dup parent-directory make-directories
    binary <file-writer> [
        swap binary <file-reader> [
            swap stream-copy
        ] with-disposal
    ] with-disposal ;

: copy-file-into ( from to -- )
    to-directory copy-file ;

: copy-files-into ( files to -- )
    [ copy-file-into ] curry each ;

DEFER: copy-tree-into

: copy-tree ( from to -- )
    normalize-path
    over link-info type>>
    {
        { +symbolic-link+ [ copy-link ] }
        { +directory+ [
            swap [
                [ swap copy-tree-into ] with each
            ] with-directory-files
        ] }
        [ drop copy-file ]
    } case ;

: copy-tree-into ( from to -- )
    to-directory copy-tree ;

: copy-trees-into ( files to -- )
    [ copy-tree-into ] curry each ;

{
    { [ os unix? ] [ "io.directories.unix" require ] }
} cond