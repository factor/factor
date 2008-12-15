! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
IN: io.files.links

HOOK: make-link io-backend ( target symlink -- )

HOOK: read-link io-backend ( symlink -- path )

: copy-link ( target symlink -- )
    [ read-link ] dip make-link ;