! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: files
USING: kernel hashtables lists namespaces presentation stdio
streams strings unparser ;

! Hyperlinked directory listings.

: file-actions ( -- list )
    [
        [[ "Push"             ""           ]]
        [[ "Run file"         "run-file"   ]]
        [[ "List directory"   "directory." ]]
        [[ "Change directory" "cd"         ]]
    ] ;

: dir-icon "/library/icons/Folder.png" ;
 : file-icon "/library/icons/File.png" ;
 : file-icon. directory? dir-icon file-icon ? write-icon ;

: file-link. ( dir name -- )
    tuck "/" swap cat3 dup "file" swons swap
    unparse file-actions <actions> "actions" swons
    2list write-attr ;

: file. ( dir name -- )
    #! If "doc-root" set, create links relative to it.
    2dup "/" swap cat3 file-icon. bl file-link. terpri ;

: directory. ( dir -- )
    #! If "doc-root" set, create links relative to it.
    dup directory [
        dup [ "." ".." ] contains? [
            2drop
        ] [
            file.
        ] ifte
    ] each-with ;
