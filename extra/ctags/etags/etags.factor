! Copyright (C) 2008 Alfredo Beaumont
! See https://factorcode.org/license.txt for BSD license.

! Emacs Etags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>
USING: arrays assocs ctags.private fry io.backend
io.encodings.ascii io.files kernel make math math.parser present
sequences sorting strings vocabs ;
IN: ctags.etags

<PRIVATE

: etag-hash ( alist -- hash )
    H{ } clone [
        '[ first2 swap [ 2array ] dip _ push-at ] assoc-each
    ] keep ;

: lines>bytes ( lines -- bytes )
    0 [ length 1 + + ] accumulate nip ;

: etag ( bytes seq -- str )
    [
        dup first present %
        0x7f ,
        second dup number>string %
        "," %
        1 - swap nth number>string %
    ] "" make ;

: etag-header ( vec1 resource -- vec2 )
    [
        normalize-path %
        "," %
        dup sum-lengths number>string %
    ] "" make prefix "\f" prefix ;

: make-etags ( alist -- seq )
    V{ } clone swap [
        over [
            [ ascii file-lines lines>bytes ] dip
            [ etag ] with map
        ] dip etag-header append!
    ] assoc-each ;

PRIVATE>

: etags ( -- etags )
    all-words locations etag-hash sort-keys make-etags ;

: write-etags ( path -- )
    [ etags ] dip ascii set-file-lines ;
