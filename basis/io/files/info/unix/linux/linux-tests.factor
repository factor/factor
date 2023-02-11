! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test io.files.info io.files.info.unix.linux ;

[ "/media/erg/4TB D" ]
[ "/media/erg/4TB\\040D" decode-mount-point ] unit-test

[ "/run/user/1001/doc" file-system-info ] must-not-fail
