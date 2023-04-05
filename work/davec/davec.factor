! Copyright (C) 2011 PolyMicro Systems
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs editors.emacs math io kernel namespaces prettyprint
system sequences eval vocabs.parser ui.tools.listener ;

IN: vocabs
: current-vocab-str ( -- str )
    current-vocab name>> ;

: vwords ( -- )
    current-vocab-str vocab-words [ pprint " " print ] each ;

IN: prettyprint.config
: hex ( -- )
    16 number-base set ;

: decimal ( -- )
    10 number-base set ;    
   
os macosx? [
    "/Applications/Aquamacs.app/Contents/MacOS/bin/emacsclient" emacsclient-path set-global
] when


