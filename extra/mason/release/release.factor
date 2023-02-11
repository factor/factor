! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators mason.notify mason.release.archive
mason.release.branch mason.release.dlls mason.release.sign
mason.release.tidy mason.release.upload ;
IN: mason.release

: release ( -- )
    update-clean-branch
    tidy
    copy-dlls
    sign-factor-app
    archive-name {
        [ make-archive ]
        [ sign-archive ]
        [ upload ]
        [ save-archive ]
        [ notify-release ]
    } cleave ;
