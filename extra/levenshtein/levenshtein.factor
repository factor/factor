! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help io kernel math namespaces sequences ;
IN: levenshtein

: <matrix> ( m n -- matrix )
    [ drop 0 <array> ] curry* map ; inline

: matrix-> nth nth ; inline
: ->matrix nth set-nth ; inline

SYMBOL: d

: ->d ( n i j -- ) d get ->matrix ; inline
: d-> ( i j -- n ) d get matrix-> ; inline

SYMBOL: costs

: init-d ( str1 str2 -- )
    [ length 1+ ] 2apply 2dup <matrix> d set
    [ 0 over ->d ] each
    [ dup 0 ->d ] each ; inline

: compute-costs ( str1 str2 -- )
    swap [
        [ = 0 1 ? ] curry* { } map-as
    ] curry { } map-as costs set ; inline

: levenshtein-step ( i j -- )
    [ 1+ d-> 1+ ] 2keep
    [ >r 1+ r> d-> 1+ ] 2keep
    [ d-> ] 2keep
    [ costs get matrix-> + min min ] 2keep
    >r 1+ r> 1+ ->d ; inline

: levenshtein-result ( -- n ) d get peek peek ; inline

: levenshtein ( str1 str2 -- n )
    [
        2dup init-d
        2dup compute-costs
        [ length ] 2apply [
            [ levenshtein-step ] curry each
        ] curry* each
        levenshtein-result
    ] with-scope ;
