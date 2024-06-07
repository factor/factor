USING: arrays assocs kernel kernel.private math math.order
sequences sequences.extras sequences.private sorting ;
IN: sorting.extras

: argsort ( seq quot: ( obj1 obj2 -- <=> ) -- sortedseq )
    [ zip-index ] dip
    [ [ first-unsafe ] bi@ ] prepose
    sort-with [ second-unsafe ] map! ; inline

: map-sort ( ... seq quot: ( ... elt -- ... key ) -- ... sortedseq )
    [ keep ] curry map>alist
    [ { array } declare first-unsafe ] sort-by
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

MACRO: compare-with ( quots -- <=> )
    [ '[ _ bi@ <=> ] ]
    [ '[ _ 2guard dup +eq+ eq? [ drop @ ] [ 2nip ] if ] ]
    map-reduce ;
