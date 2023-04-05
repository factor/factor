! File: tools.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors folder io.files io.files.private kernel libc locals
prettyprint sequences ;

IN: io.directories
:: force-file-into ( from to -- )
    from to to-directory :> to
    to exists?
    [ "rm -fr " to append  system drop ] when
    from to move-file  drop ;

: force-files-into ( files to -- )
    [ force-file-into ] curry each ;

IN: tools

CONSTANT: srcFolder "/Sources/PlayNet/SVN/ww2/branches"
CONSTANT: gitFolder "/Sources/PlayNet/ww2"

: src-folder ( -- seq )
    srcFolder string-to-folder ; 

:: mv-entries ( entries dst -- )
    entries [ path+name ] map  dst force-files-into ;

:: update-git ( entry -- )
    entry name>> :> gitName
    gitFolder cd
    "git add ." system drop 
    "git commit . -m\""  gitName append  "\"" append  system drop ;

:: do-entry ( entry -- )
    entry is-directory?
    [ entry path+name pprint
      entry folder-entries  gitFolder mv-entries
      entry update-git
      entry path+name "rm -fr " prepend  system drop ] when
    ;

: do-src-folders ( -- )
    src-folder [ do-entry ] with-folder-entries ; 

: file-entries ( folder -- file )
    dup is-directory? [ [ file-entries ] with-folder-entries ] when ;

: flatten-folder ( path -- seq )
    string-to-folder  file-entries ;

: test ( -- seq )
    "/usr" flatten-folder ; 
      