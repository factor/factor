! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io.backend io.files.info io.files.types
io.pathnames kernel math namespaces system vocabs ;
IN: io.files.links

HOOK: make-link os ( target symlink -- )

HOOK: make-hard-link os ( target link -- )

HOOK: read-link os ( symlink -- path )

: copy-link ( target symlink -- )
    [ read-link ] dip make-link ;

os unix? [ "io.files.links.unix" require ] when

: follow-link ( path -- path' )
    [ parent-directory ] [ read-link ] bi append-path ;

SYMBOL: symlink-depth
10 symlink-depth set-global

ERROR: too-many-symlinks path n ;

<PRIVATE

: (follow-links) ( n path -- path' )
    over 0 = [ symlink-depth get too-many-symlinks ] when
    dup link-info symbolic-link?
    [ [ 1 - ] [ follow-link ] bi* (follow-links) ]
    [ nip ] if ; inline recursive

PRIVATE>

: follow-links ( path -- path' )
    [ symlink-depth get ] dip normalize-path (follow-links) ;
