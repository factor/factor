! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger io prettyprint sequences system ;
IN: debugger.windows

M: windows signal-error. "Windows exception #" write third .h ;