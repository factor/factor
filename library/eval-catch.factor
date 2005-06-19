! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser USING: kernel errors io ;

: eval-catch ( str -- )
    [ eval ] [ [ print-error debug-help drop ] when* ] catch ;

: eval>string ( in -- out )
    [ eval-catch ] with-string ;
