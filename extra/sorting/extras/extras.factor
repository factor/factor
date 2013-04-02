USING: assocs kernel sequences sequences.private sorting ;
IN: sorting.extras

: argsort ( seq quot: ( obj1 obj2 -- <=> ) -- sortedseq )
    [ dup length iota zip ] dip
    [ [ first-unsafe ] bi@ ] prepose
    sort [ second-unsafe ] map! ; inline

: map-sort ( ... seq quot: ( ... elt -- ... key ) -- ... sortedseq )
    [ map ] curry keep zip [ second-unsafe ] sort-with
    [ first-unsafe ] map ; inline
