! Copyright (C) 2023 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cli.git combinators.short-circuit formatting http.client
io.directories io.files io.files.info io.files.temp io.launcher
io.pathnames kernel layouts namespaces sequences splitting
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

: empty-directory? ( path -- ? )
    { [ directory? ] [ directory-files empty? ] } 1&& ;

! Windows clears the Factor temp directory but leaves the directory names (?)
! C:\Users\sheeple\AppData\Local\Temp\factorcode.org\Factor>
: ?sync-repository-as ( url path -- )
    dup { [ git-directory? ] [ ".git" append-path empty-directory? not ] } 1&&
    [ dup delete-tree ] unless
    sync-repository-as wait-for-success ;

: with-updated-git-repo-as ( git-uri path quot -- )
    '[
        _ _ [ ?sync-repository-as ] keep
        prepend-current-path _ with-directory
    ] with-temp-directory ; inline

: with-updated-git-repo ( git-uri quot -- )
    [ dup git-directory-name ] dip with-updated-git-repo-as ; inline

: ?download ( path -- )
    dup file-name file-exists? [ drop ] [ download ] if ; inline

: with-tar-gz ( path quot -- )
    '[
        _
        [ ?download ]
        [ file-name { "tar" "xvfz" } swap suffix try-process ]
        [ file-name ".tar.gz" ?tail drop ] tri
        prepend-current-path _ with-directory
    ] with-temp-directory ; inline
