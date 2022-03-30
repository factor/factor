! (c)2009 Slava Pestov & Joe Groff, see BSD license
USING: combinators.short-circuit make math kernel sequences ;
IN: sequences.squish

: (squish) ( seq quot: ( obj -- ? ) -- )
    2dup call [ '[ _ (squish) ] each ] [ drop , ] if ; inline recursive

: squish ( seq quot exemplar -- seq' )
    [ [ (squish) ] ] dip make ; inline

: squish-strings ( seq -- seq' )
    [ { [ sequence? ] [ integer? not ] } 1&& ] "" squish ;
