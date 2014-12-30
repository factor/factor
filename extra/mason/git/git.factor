! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit continuations
debugger io io.directories io.directories.hierarchy
io.encodings.utf8 io.files io.launcher io.sockets
io.streams.string kernel mason.common mason.email sequences
splitting ;
IN: mason.git

: git-id ( -- id )
    { "git" "show" } utf8 [ lines ] with-process-reader
    first " " split second ;

<PRIVATE

: git-clone-cmd ( -- cmd )
    {
        "git"
        "clone"
        "git://factorcode.org/git/factor.git"
    } ;

: git-clone ( -- )
    #! Must be run from builds-dir
    "Cloning initial repository" print-timestamp
    git-clone-cmd try-output-process ;

: git-pull-cmd ( -- cmd )
    {
        "git"
        "pull"
        "git://factorcode.org/git/factor.git"
        "master"
    } ;

: repo-corrupted-body ( error -- string )
    [
        "Corrupted repository on " write host-name write " will be re-cloned." print
        "Error while pulling was:" print
        nl
        error.
    ] with-string-writer ;

: git-repo-corrupted ( error -- )
    repo-corrupted-body "corrupted repo" email-fatal
    "factor" delete-tree
    git-clone ;

: git-pull-failed ( error -- )
    dup output-process-error? [
        dup output>> "not uptodate. Cannot merge." swap subseq?
        [ git-repo-corrupted ]
        [ rethrow ]
        if
    ] [ rethrow ] if ;

: git-status-cmd ( -- cmd )
    { "git" "status" } ;

: git-status-failed ( error -- )
    #! Exit code 1 means there's nothing to commit.
    dup { [ process-failed? ] [ code>> 1 = ] } 1&&
    [ drop ] [ rethrow ] if ;

: git-status ( -- seq )
    [
        git-status-cmd utf8 [ lines ] with-process-reader*
        { 0 1 } member? [ 2drop ] [ process-failed ] if
        [ "#\t" head? ] filter
    ] [ git-status-failed { } ] recover ;

: check-repository ( -- seq )
    "factor" [ git-status ] with-directory ;

: repo-dirty-body ( error -- string )
    [
        "Dirty repository on " write host-name write " will be re-cloned." print
        "Modified and untracked files:" print nl
        [ print ] each
    ] with-string-writer ;

: git-repo-dirty ( files -- )
    repo-dirty-body "dirty repo" email-fatal
    "factor" delete-tree
    git-clone ;

PRIVATE>

: git-pull ( -- id )
    #! Must be run from builds-dir.
    "factor" exists? [
        check-repository [
            "factor" [
                [ git-pull-cmd short-running-process ]
                [ git-pull-failed ]
                recover
            ] with-directory
        ] [ git-repo-dirty ] if-empty
    ] [ git-clone ] if
    "factor" [ git-id ] with-directory ;
