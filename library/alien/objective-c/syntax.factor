! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: kernel lists namespaces objective-c parser syntax words ;

: OBJC-CLASS:
    #! Syntax: name
    CREATE dup word-name
    [ objc_getClass ] curry define-compound ; parsing

: OBJC-MESSAGE:
    scan string-mode on
    [ string-mode off msg-send-args define-msg-send ] f ;
    parsing
