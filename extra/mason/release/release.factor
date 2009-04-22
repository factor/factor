! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel debugger namespaces sequences splitting combinators
combinators io io.files io.launcher prettyprint bootstrap.image
mason.common mason.release.branch mason.release.tidy
mason.release.archive mason.release.upload mason.notify ;
IN: mason.release

: release ( -- )
    update-clean-branch
    tidy
    archive-name {
        [ make-archive ]
        [ upload ]
        [ save-archive ]
        [ notify-release ]
    } cleave ;