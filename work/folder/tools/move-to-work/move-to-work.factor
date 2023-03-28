! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cli.git folder io.directories io.launcher io.pathnames
kernel namespaces scratchpad sequences string  ;

IN: cli.git
: git-add* ( path -- ) { "git" "add" } swap suffix run-process drop ;
: git-commit* ( path -- )  { "git" "commit" }  over suffix  swap "-m\"Added " prepend  suffix  run-process drop ;

: git-add ( path path -- ) [ [ git-add* ] [ git-commit* ] bi ] with-directory ;

IN: folder.tools.move-to-work

: git? ( s -- ? ) 4 head ".git" = ;
: only-gits ( f -- f )
    deep folder-entries [ name>> git? ] filter ;

:: to-dest ( f -- )
    dest get :> d
    f d folder-copy-tree
    d pathname>>  as-directory f name>> append >folder :> new
    new only-gits  [ delete-entry ] each
    new pathname>> d path>> git-add
    ;
