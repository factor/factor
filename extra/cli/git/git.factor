! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays concurrency.combinators concurrency.semaphores fry
io.directories io.files.info io.launcher io.pathnames kernel
math namespaces sequences splitting system-info ;
IN: cli.git

SYMBOL: cli-git-num-parallel
cli-git-num-parallel [ cpus 2 * ] initialize

: git-clone-as ( ssh-url path -- process )
    [ { "git" "clone" } ] 2dip 2array append run-process ;

: git-clone ( ssh-url -- process )
    [ { "git" "clone" } ] dip suffix run-process ;

: git-pull ( path -- process )
    [ { "git" "pull" } run-process ] with-directory ;

: git-repository? ( directory -- ? )
    ".git" append-path current-directory get prepend-path
    ?file-info dup [ directory? ] when ;

: repository-url>name ( string -- string' )
    file-name ".git" ?tail drop ;

: update-repository ( url -- process )
    dup repository-url>name git-repository?
    [ repository-url>name git-pull ] [ git-clone ] if ;

: sync-repositories ( directory urls -- )
    '[
        _ cli-git-num-parallel get <semaphore> '[
            _ [ update-repository ] with-semaphore
        ] parallel-each
    ] with-ensure-directory ;

