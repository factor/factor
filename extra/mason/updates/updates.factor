! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.download combinators.short-circuit
io.directories io.launcher kernel mason.common mason.platform ;
IN: mason.updates

: git-reset-cmd ( -- cmd )
    {
        "git"
        "reset"
        "--hard"
        "HEAD"
    } ;

: git-pull-cmd ( -- cmd )
    {
        "git"
        "pull"
        "--no-summary"
        "git://factorcode.org/git/factor.git"
        "master"
    } ;

: updates-available? ( -- ? )
    ".git/index" delete-file
    git-reset-cmd short-running-process
    git-id
    git-pull-cmd short-running-process
    git-id
    = not ;

: new-image-available? ( -- ? )
    boot-image-name maybe-download-image ;

: new-code-available? ( -- ? )
    { [ updates-available? ] [ new-image-available? ] } 0|| ;
