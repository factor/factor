! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.files io.files.links io.pathnames kernel
sequences system unix unix.ffi ;
IN: io.files.links.unix

M: unix make-link ( path1 path2 -- )
    normalize-path [ symlink ] unix-system-call drop ;

M: unix make-hard-link ( path1 path2 -- )
    normalize-path [ link ] unix-system-call drop ;

M: unix read-link ( path -- path' )
    normalize-path read-symbolic-link ;

M: unix resolve-symlinks ( path -- path' )
    path-components "/"
    [ append-path dup exists? [ follow-links ] when ] reduce ;
