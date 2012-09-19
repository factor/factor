USING: assocs kernel sequences sequences.private sorting ;
IN: sorting.extras

: argsort ( seq quot: ( obj1 obj2 -- <=> ) -- sortedseq )
    [ dup length iota zip ] dip
    [ [ first-unsafe ] bi@ ] prepose
    sort [ second-unsafe ] map! ; inline
