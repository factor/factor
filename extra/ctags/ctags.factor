! Copyright (C) 2008 Alfredo Beaumont
! See http://factorcode.org/license.txt for BSD license.

! Simple Ctags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>

USING: assocs definitions io.backend io.encodings.ascii io.files
kernel make math.parser present sequences sorting vocabs ;
IN: ctags

<PRIVATE

: locations ( words -- alist )
    [ dup where ] { } map>assoc sift-values ;

: ctag ( word path lineno -- str )
    [
        [ present % CHAR: \t , ]
        [ normalize-path % CHAR: \t , ]
        [ number>string % ] tri*
    ] "" make ;

: make-ctags ( alist -- seq )
    [ first2 ctag ] { } assoc>map ;

PRIVATE>

: ctags ( -- ctags )
    all-words locations sort-keys make-ctags ;

: write-ctags ( path -- )
    [ ctags ] dip ascii set-file-lines ;
