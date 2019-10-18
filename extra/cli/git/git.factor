! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays concurrency.combinators concurrency.semaphores fry
io io.directories io.encodings.utf8 io.files.info io.launcher
io.pathnames kernel math namespaces sequences splitting
system-info unicode ;
IN: cli.git

SYMBOL: cli-git-num-parallel
cli-git-num-parallel [ cpus 2 * ] initialize

: git-command>string ( quot -- string )
    utf8 <process-reader> stream-contents [ blank? ] trim-tail ;

: git-clone-as ( uri path -- process ) [ { "git" "clone" } ] 2dip 2array append run-process ;
: git-clone ( uri -- process ) [ { "git" "clone" } ] dip suffix run-process ;
: git-pull* ( -- process ) { "git" "pull" } run-process ;
: git-pull ( path -- process ) [ git-pull* ] with-directory ;
: git-fetch-all* ( -- process ) { "git" "fetch" "--all" } run-process ;
: git-fetch-all ( path -- process ) [ git-fetch-all* ] with-directory ;
: git-fetch-tags* ( -- process ) { "git" "fetch" "--tags" } run-process ;
: git-fetch-tags ( path -- process ) [ git-fetch-tags* ] with-directory ;
: git-checkout-new-branch* ( branch -- process ) [ { "git" "checkout" "-b" } ] dip suffix run-process ;
: git-checkout-new-branch ( path branch -- process ) '[ _ git-checkout-new-branch* ] with-directory ;
: git-checkout-existing-branch* ( branch -- process ) [ { "git" "checkout" } ] dip suffix run-process ;
: git-checkout-existing-branch ( path branch -- process ) '[ _ git-checkout-existing-branch* ] with-directory ;
: git-change-remote* ( remote uri -- process ) [ { "git" "remote" "set-url" } ] 2dip 2array append run-process ;
: git-change-remote ( path remote uri -- process ) '[ _ _ git-change-remote* ] with-directory ;
: git-remote-add* ( remote uri -- process ) [ { "git" "remote" "add" } ] 2dip 2array append run-process ;
: git-remote-add ( path remote uri -- process ) '[ _ _ git-remote-add* ] with-directory ;
: git-remote-get-url* ( remote -- process ) [ { "git" "remote" "get-url" } ] dip suffix run-process ;
: git-remote-get-url ( path remote -- process ) '[ _ git-remote-get-url* ] with-directory ;
: git-rev-parse* ( branch -- string ) [ { "git" "rev-parse" } ] dip suffix git-command>string ;
: git-rev-parse ( path branch -- string ) '[ _ git-rev-parse* ] with-directory ;
: git-diff-name-only* ( from to -- lines )
    [ { "git" "diff" "--name-only" } ] 2dip 2array append process-lines ;
: git-diff-name-only ( path from to -- lines )
    '[ _ _ git-diff-name-only* ] with-directory ;

: git-repository? ( directory -- ? )
    ".git" append-path current-directory get prepend-path
    ?file-info dup [ directory? ] when ;

: git-current-branch* ( -- name )
     { "git" "rev-parse" "--abbrev-ref" "HEAD" } git-command>string ;

: git-current-branch ( directory -- name )
    [ git-current-branch* ] with-directory ;

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
