! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: files
USING: kernel hashtables lists namespaces presentation stdio
strings unparser ;

: exists? ( file -- ? )
    stat >boolean ;

: directory? ( file -- ? )
    stat dup [ car ] when ;

: directory ( dir -- list )
    #! List a directory.
    (directory) [ str-lexi> ] sort ;

: file-length ( file -- length )
    stat dup [ cdr cdr car ] when ;

: file-actions ( -- list )
    [
        [[ "Push"             ""           ]]
        [[ "Run file"         "run-file"   ]]
        [[ "List directory"   "directory." ]]
        [[ "Change directory" "cd"         ]]
    ] ;

: set-mime-types ( assoc -- )
    "mime-types" global set-hash ;

: mime-types ( -- assoc )
    "mime-types" global hash ;

: file-extension ( filename -- extension )
    "." split cdr dup [ last ] when ;

: mime-type ( filename -- mime-type )
    file-extension mime-types assoc [ "text/plain" ] unless* ;

: dir-icon
    "/library/icons/Folder.png" ;

: file-icon
    "/library/icons/File.png" ;

: file-icon. ( path -- )
    directory? dir-icon file-icon ? write-icon ;

: file-link. ( dir name -- )
    tuck "/" swap cat3 dup "file-link" swons swap
    unparse file-actions <actions> "actions" swons
    2list write-attr ;

: file. ( dir name -- )
    #! If "doc-root" set, create links relative to it.
    2dup "/" swap cat3 file-icon. " " write file-link. terpri ;

: directory. ( dir -- )
    #! If "doc-root" set, create links relative to it.
    dup directory [
        dup [ "." ".." ] contains? [
            2drop
        ] [
            file.
        ] ifte
    ] each-with ;

: pwd cwd print ;
: dir. cwd directory. ;

[
    [[ "html"   "text/html"                        ]]
    [[ "txt"    "text/plain"                       ]]
                                                    
    [[ "gif"    "image/gif"                        ]]
    [[ "png"    "image/png"                        ]]
    [[ "jpg"    "image/jpeg"                       ]]
    [[ "jpeg"   "image/jpeg"                       ]]
                                                    
    [[ "jar"    "application/octet-stream"         ]]
    [[ "zip"    "application/octet-stream"         ]]
    [[ "tgz"    "application/octet-stream"         ]]
    [[ "tar.gz" "application/octet-stream"         ]]
    [[ "gz"     "application/octet-stream"         ]]
                                                    
    [[ "factor" "application/x-factor"             ]]
    [[ "factsp" "application/x-factor-server-page" ]]
] set-mime-types
