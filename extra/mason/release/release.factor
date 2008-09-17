! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel debugger namespaces sequences splitting
combinators io io.files io.launcher prettyprint bootstrap.image
mason.common mason.release.branch mason.release.tidy
mason.release.archive mason.release.upload ;
IN: mason.release

: (release) ( -- )
    update-clean-branch
    tidy
    make-archive
    upload
    save-archive ;

: release ( -- ) status get status-clean eq? [ (release) ] when ;