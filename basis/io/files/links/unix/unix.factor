! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.files.links system unix ;
IN: io.files.links.unix

M: unix make-link ( path1 path2 -- )
    normalize-path symlink io-error ;

M: unix read-link ( path -- path' )
    normalize-path read-symbolic-link ;
