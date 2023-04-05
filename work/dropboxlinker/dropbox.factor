! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors folder io io.directories io.files io.files.info
io.files.links io.files.private io.files.types io.pathnames kernel
locals namespaces regexp sequences ;

IN: dropbox

TUPLE: dropbox ;

CONSTANT: db-library-folder "~/Dropbox/Private/Library"
CONSTANT: user-library-folder "~/Library"
CONSTANT: db-appsupport-name  "Application\ Support"
CONSTANT: db-preferences-name "Preferences"

:: db-is-linked-to-db? ( symlink -- ? )
    "Dropbox" symlink read-link start
    [ " to Dropbox" print f ]
    [ " but not to Dropbox" print symlink move-aside t ] if
    ;

:: db-check-symbolic? ( path -- ? )
    path link-info type>> +symbolic-link+ =
    [ ", is symbolic" write  path db-is-linked-to-db? ]
    [ " , move aside" print  path move-aside t ] if
    ;

:: db-moved-path? ( path -- ? )
    path write
    path exists?
    [ " path exists" write path db-check-symbolic? ]
    [ " no path, will link it" print t ] if
    ;

: user-library-path ( -- path )
    user-library-folder  "/" append
    ;

FROM: folder => pathname ;
: link-to-cwd ( seq -- )
    [ dup name>> cwd as-directory prepend
      db-moved-path? 
      [ link-to-current-directory ] [ drop ] if
    ] each
    ;  
    
FROM: io.directories => link-to-current-directory directory-entries ;
:: do-folder-name ( folder db-folder-name -- )
    folder folder-entries
    [ name>> ".DS_Store" = not ] filter
    [ name>> R/ .*conflicted copy.*/ matches? not ] filter
    user-library-path db-folder-name append
    absolute-path dup cd current-directory set
    link-to-cwd ;

: do-appsupport ( folder -- )
    db-appsupport-name do-folder-name
    ;

: do-preferences ( folder -- )
    db-preferences-name do-folder-name
    ;
    
:: do-link ( folder -- )
    user-library-path absolute-path [ current-directory set ] keep
    "/" append folder name>> append
    db-moved-path? 
    [ folder link-to-current-directory ] [ ] if
;

:: db-process-folder ( folder -- )
    folder name>> db-appsupport-name =
    [ folder do-appsupport ]
    [ folder name>> db-preferences-name =
      [ folder do-preferences ]
      [ folder do-link ] if
    ] if
    ;

:: db-process-item ( folder -- )
    folder db-process-folder
    ;

: db-library-item ( folder-entry -- )
    dup type>> +directory+ =
    [ db-process-item ] [ drop ] if
    ;

FROM: string => to-folder ;
: db-main ( -- )
    db-library-folder exists?
    [
        db-library-folder to-folder folder-entries
        [ db-library-item ] each
    ] [
        "The folder " db-library-folder append
        " does not exist and it must to continue." append print
        " Check configuration setting in the \"dropbox\" vocabulary" print
    ] if
    ;
MAIN: db-main