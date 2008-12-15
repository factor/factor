! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
IN: io.files.info.windows.nt

ERROR: not-absolute-path ;

M: winnt root-directory ( string -- string' )
    unicode-prefix ?head drop
    dup {
        [ length 2 >= ]
        [ second CHAR: : = ]
        [ first Letter? ]
    } 1&& [ 2 head "\\" append ] [ not-absolute-path ] if ;
