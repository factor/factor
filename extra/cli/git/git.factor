! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays concurrency.combinators
concurrency.semaphores io io.directories io.encodings.utf8
io.files.info io.launcher io.pathnames kernel math namespaces
sequences splitting system-info unicode ;
IN: cli.git

SYMBOL: cli-git-num-parallel
cli-git-num-parallel [ cpus 2 * ] initialize

: git-command>string ( desc -- string )
    utf8 <process-reader> stream-contents [ blank? ] trim-tail ;

: git-clone-as ( uri path -- process ) [ { "git" "clone" } ] 2dip 2array append run-process ;
: git-clone ( uri -- process ) [ { "git" "clone" } ] dip suffix run-process ;
: git-pull* ( -- process ) { "git" "pull" } run-process ;
: git-pull ( path -- process ) [ git-pull* ] with-directory ;
: git-fetch-all-desc ( -- process ) { "git" "fetch" "--all" } ;
: git-fetch-all* ( -- process ) git-fetch-all-desc run-process ;
: git-fetch-all ( path -- process ) [ git-fetch-all* ] with-directory ;
: git-reset-hard-desc ( branch -- process ) '{ "git" "reset" "--hard" _ } ;
: git-reset-hard ( branch -- process ) git-reset-hard-desc run-process ;
: git-reset-hard-HEAD ( -- process ) "HEAD" git-reset-hard-desc ;
: git-fetch-and-reset-hard ( path branch -- processes ) '[ git-fetch-all-desc _ git-reset-hard-desc 2array run-processes ] with-directory ;
: git-fetch-and-reset-hard-HEAD ( path -- processes ) [ git-fetch-all-desc "HEAD" git-reset-hard-desc 2array run-processes ] with-directory ;
: git-fetch-tags* ( -- process ) { "git" "fetch" "--tags" } run-process ;
: git-fetch-tags ( path -- process ) [ git-fetch-tags* ] with-directory ;
: git-tag* ( -- process ) { "git" "tag" } process-lines ;
: git-tag ( path -- process ) [ git-tag* ] with-directory ;
: git-checkout-new-branch* ( branch -- process ) [ { "git" "checkout" "-b" } ] dip suffix run-process ;
: git-checkout-new-branch ( path branch -- process ) '[ _ git-checkout-new-branch* ] with-directory ;
: git-checkout-existing* ( branch/checksum -- process ) [ { "git" "checkout" } ] dip suffix run-process ;
: git-checkout-existing ( path branch/checksum -- process ) '[ _ git-checkout-existing* ] with-directory ;
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

: git-directory? ( directory -- ? )
    ".git" append-path current-directory get prepend-path
    ?file-info dup [ directory? ] when ;

: git-current-branch* ( -- name )
    { "git" "rev-parse" "--abbrev-ref" "HEAD" } git-command>string ;

: git-current-branch ( directory -- name )
    [ git-current-branch* ] with-directory ;

: git-directory-name ( string -- string' )
    file-name ".git" ?tail drop ;

: sync-repository ( url -- process )
    dup git-directory-name git-directory?
    [ git-directory-name git-pull ] [ git-clone ] if ;

: sync-repository-as ( url path -- processes )
    dup git-directory?
    [ nip git-fetch-and-reset-hard-HEAD ] [ git-clone-as ] if ;

: sync-repositories ( directory urls -- )
    '[
        _ cli-git-num-parallel get <semaphore> '[
            _ [ sync-repository ] with-semaphore
        ] parallel-each
    ] with-ensure-directory ;

: directory-entries-without-git ( directory -- entries )
    recursive-directory-entries
    [ name>> "/.git/" subseq-of? ] reject ;

