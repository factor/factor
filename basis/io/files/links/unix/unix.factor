! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io.backend io.files io.files.links io.pathnames kernel
sequences system unix unix.ffi ;
IN: io.files.links.unix

M: unix make-link
    normalize-path [ symlink ] unix-system-call drop ;

M: unix make-hard-link
    normalize-path [ link ] unix-system-call drop ;

M: unix read-link
    normalize-path read-symbolic-link ;

M: unix resolve-symlinks
    path-components "/"
    [ append-path dup file-exists? [ follow-links ] when ] reduce ;
