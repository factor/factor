! File: utilities.factor
! Version: 0.1
! DRI: Dave Carlton <davec@polymicro.net>
! Description: Folder utility code
! Copyright (C) 2013 Dave Carlton
! See http://factorcode.org/license.txt for BSD license.

USING: accessors folder io.directories io.files io.pathnames kernel
locals sequences sets variables ;

IN: folder.utilities

VAR: downloads

:: move-to ( folder-entry directory -- )
    folder-entry path+name
    downloads path>>  as-directory
    directory append as-directory
    folder-entry name>> append
    dup parent-directory  exists?
    [ dup parent-directory make-directory ] unless
    move-file ;

: has-extension? ( folder-entry set -- bool )
    [ name>> file-extension ] dip in? ;

: move-if ( bool folder-entry dst -- )
    rot [ move-to ] [ 2drop ] if  ;

:: move-to-if ( folder-entry seq dest -- folder-entry )
    folder-entry seq has-extension? folder-entry dest move-if
    folder-entry ;
    
: org-folder ( path -- )
     "~/Downloads" string-to-folder set: downloads
     string-to-folder
     [
         { "dmg" "pkg" "mpkg" } "!Disks/" move-to-if
         { "tar" "rar" "zip" "bzip" "bz2" } "!Archives/" move-to-if
         { "app" } "!Applications/" move-to-if
         { "pdf" } "!PDF/" move-to-if
         { "mscz" "mp3" "mid" "mxl" } "!Music/" move-to-if
         { "h" "c" "sh" "factor" } "!Sources/" move-to-if
         { "exe" } "!Windows" move-to-if
         drop
     ] with-folder-entries
     ;

: org-downloads ( -- )  "~/Downloads" org-folder ;
