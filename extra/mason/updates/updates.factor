! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.launcher bootstrap.image.download
mason.common mason.platform ;
IN: mason.updates

: git-pull-cmd ( -- cmd )
    {
        "git"
        "pull"
        "--no-summary"
        "git://factorcode.org/git/factor.git"
        "master"
    } ;

: updates-available? ( -- ? )
    git-id
    git-pull-cmd short-running-process
    git-id
    = not ;

: new-image-available? ( -- ? )
    boot-image-name maybe-download-image ;

: new-code-available? ( -- ? )
    updates-available?
    new-image-available?
    or ;