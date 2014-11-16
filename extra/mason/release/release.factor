! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators mason.notify mason.release.archive
mason.release.branch mason.release.tidy mason.release.upload ;
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
