! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations debugger io io.directories
io.encodings.utf8 io.files io.launcher io.sockets
io.streams.string kernel mason.common mason.email sequences
splitting ;
IN: mason.git

: git-id ( -- id )
    { "git" "rev-parse" "HEAD" } process-lines first ;

<PRIVATE

: git-clone-cmd ( -- cmd )
    {
        "git"
        "clone"
        "https://github.com/factor/factor.git"
    } ;

: git-clone ( -- )
    ! Must be run from builds-dir
    "Cloning initial repository" print-timestamp
    git-clone-cmd try-output-process ;

: git-pull-cmd ( -- cmd )
    {
        "git"
        "pull"
        "https://github.com/factor/factor.git"
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
        dup output>> "not uptodate. Cannot merge." subseq-of?
        [ git-repo-corrupted ]
        [ rethrow ]
        if
    ] [ rethrow ] if ;

: git-status-cmd ( -- cmd )
    { "git" "status" "--porcelain" } ;

: git-status ( -- seq )
    git-status-cmd process-lines ;

: check-repository ( -- seq )
    "factor" [ git-status ] with-directory ;

: repo-dirty-body ( error -- string )
    [
        "Dirty repository on " write host-name write " will be re-cloned." print
        "Modified and untracked files:" print nl write-lines
    ] with-string-writer ;

: git-repo-dirty ( files -- )
    repo-dirty-body "dirty repo" email-fatal
    "factor" delete-tree
    git-clone ;

PRIVATE>

: git-clone-or-pull ( -- id )
    ! Must be run from builds-dir.
    "factor" file-exists? [
        check-repository [
            "factor" [
                [ git-pull-cmd short-running-process ]
                [ git-pull-failed ]
                recover
            ] with-directory
        ] [ git-repo-dirty ] if-empty
    ] [ git-clone ] if
    "factor" [ git-id ] with-directory ;
