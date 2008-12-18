! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: system kernel vocabs.loader ;
IN: io.files.links

HOOK: make-link os ( target symlink -- )

HOOK: read-link os ( symlink -- path )

: copy-link ( target symlink -- )
    [ read-link ] dip make-link ;

os unix? [ "io.files.links.unix" require ] when