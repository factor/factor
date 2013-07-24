USING: arrays assocs kernel kernel.private sequences
sequences.private sorting ;
IN: sorting.extras

: argsort ( seq quot: ( obj1 obj2 -- <=> ) -- sortedseq )
    [ dup length iota zip ] dip
    [ [ first-unsafe ] bi@ ] prepose
    sort [ second-unsafe ] map! ; inline

: map-sort ( ... seq quot: ( ... elt -- ... key ) -- ... sortedseq )
    [ map ] curry keep zip
    [ { array } declare first-unsafe ] sort-with
    [ { array } declare second-unsafe ] map ; inline
