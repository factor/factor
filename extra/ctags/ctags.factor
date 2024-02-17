! Copyright (C) 2008 Alfredo Beaumont
! See https://factorcode.org/license.txt for BSD license.

! Simple Ctags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>

USING: assocs definitions io.backend io.encodings.utf8 io.files
kernel make math.parser present sequences sorting vocabs ;
IN: ctags

<PRIVATE

: locations ( words -- alist )
    [ where ] zip-with sift-values ;

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
    [ ctags ] dip utf8 set-file-lines ;
