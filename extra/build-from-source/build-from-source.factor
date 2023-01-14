! Copyright (C) 2023 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cli.git formatting io.directories io.files.temp
io.launcher io.pathnames kernel layouts namespaces sequences
system ;
IN: build-from-source

: dll-out-directory ( -- path )
    vm-path parent-directory cell-bits "dlls%s-out" sprintf append-path
    dup make-directories ;

: remake-directory ( path -- )
    [ ?delete-tree ] [ make-directories ] bi ;

: prepend-current-path ( path -- path' )
    current-directory get prepend-path ;

: copy-output-file-as ( name new-name -- )
    [ prepend-current-path ]
    [ dll-out-directory prepend-path ] bi* copy-file ;

: copy-output-file ( name -- )
    prepend-current-path dll-out-directory copy-file-into ;

: copy-output-files ( seq -- )
    [ copy-output-file ] each ;

: with-build-directory-as ( name quot -- )
    [ prepend-current-path dup remake-directory ] dip with-directory ; inline

: with-build-directory ( quot -- ) [ "build" ] dip with-build-directory-as ; inline

: with-updated-git-repo-as ( git-uri path quot -- )
    '[
        _ _ [
            sync-repository-as wait-for-success
        ] keep
        prepend-current-path _ with-directory
    ] with-temp-directory ; inline

: with-updated-git-repo ( git-uri quot -- )
    [ dup git-directory-name ] dip with-updated-git-repo-as ; inline
