! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: formatting io.encodings.ascii io.launcher present system
urls webbrowser ;

IN: webbrowser.macosx

M: macosx open-file ( path -- )
    "open \"%s\"" sprintf try-process ;

M: macosx open-url ( url -- )
    >url present "osascript" ascii [
        "open location \"%s\"" printf
    ] with-process-writer ;
