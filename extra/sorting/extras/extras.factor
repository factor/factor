USING: arrays assocs kernel kernel.private locals math
math.order sequences sequences.extras sequences.private sorting ;
IN: sorting.extras

: argsort ( seq quot: ( obj1 obj2 -- <=> ) -- sortedseq )
    [ zip-index ] dip
    [ [ first-unsafe ] bi@ ] prepose
    sort [ second-unsafe ] map! ; inline

: map-sort ( ... seq quot: ( ... elt -- ... key ) -- ... sortedseq )
    [ keep ] curry { } map>assoc
    [ { array } declare first-unsafe ] sort-with
    [ { array } declare second-unsafe ] map ; inline

:: bisect-left ( obj seq -- i )
    0 seq length [ 2dup < ] [
        2dup + 2/ dup seq nth-unsafe obj before?
        [ swap [ nip 1 + ] dip ] [ nip ] if
    ] while drop ;

:: bisect-right ( obj seq -- i )
    0 seq length [ 2dup < ] [
        2dup + 2/ dup seq nth-unsafe obj after?
        [ nip ] [ swap [ nip 1 + ] dip ] if
    ] while drop ;

: insort-left ( obj seq -- seq' )
    [ bisect-left ] 2keep swapd insert-nth ;

: insort-right ( obj seq -- seq' )
    [ bisect-right ] 2keep swapd insert-nth ;

: insort-left! ( obj seq -- seq )
    [ bisect-left ] 2keep swapd [ insert-nth! ] keep ;

: insort-right! ( obj seq -- seq )
    [ bisect-right ] 2keep swapd [ insert-nth! ] keep ;
