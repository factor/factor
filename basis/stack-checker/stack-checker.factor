! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes effects generic io kernel namespaces
quotations sequences stack-checker.backend stack-checker.errors
stack-checker.inlining stack-checker.known-words
stack-checker.state stack-checker.transforms
stack-checker.visitor.dummy vocabs vocabs.loader words ;
IN: stack-checker

: infer ( quot -- effect )
    callable check-instance
    [ infer-quot-here ] with-infer drop ;

: infer. ( quot -- )
    ! Safe to call from inference transforms.
    infer effect>string print ;

M: callable stack-effect infer ;
