USING: accessors arrays combinators combinators.smart help
help.markup help.topics kernel sequences sorting tools.crossref
vocabs words ;
IN: annotations

<PRIVATE
: comment-word ( base -- word ) "!" prepend "annotations" lookup-word ;
: comment-usage-word ( base -- word ) "s" append "annotations" lookup-word ;
: comment-usage.-word ( base -- word ) "s." append "annotations" lookup-word ;
PRIVATE>

: $annotation ( element -- )
    first
    [ "!" " your comment here" surround 1array $syntax ]
    [ [ "Treats the rest of the line after the exclamation point as a code annotation that can be looked up with the " \ $link ] dip comment-usage.-word 2array " word." 3array $description ]
    [ ": foo ( x y z -- w )\n    !" " --w-ó()ò-w-- kilroy was here\n    + * ;" surround 1array $code ]
    tri ;

: <$annotation> ( word -- element )
    \ $annotation swap 2array 1array ;

: $annotation-usage. ( element -- )
    first
    [ "Displays a list of words, help articles, and vocabularies that contain " \ $link ] dip comment-word 2array " annotations." 3array $description ;

: <$annotation-usage.> ( word -- element )
    \ $annotation-usage. swap 2array 1array ;

: $annotation-usage ( element -- )
    first [
        [ "Returns a list of words, help articles, and vocabularies that contain " ] dip
        [
            comment-word <$link>
            " annotations. For a more user-friendly display, use the "
        ] [
            comment-usage.-word <$link>
            " word."
        ] bi
    ] output>array $description ;

: <$annotation-usage> ( word -- element )
    [ { $values { "usages" sequence } } ] dip
    \ $annotation-usage swap 2array
    2array ;

"Code annotations"
{
    "The " { $vocab-link "annotations" } " vocabulary provides syntax for comment-like annotations that can be looked up with Factor's " { $link usage } " mechanism."
}
annotation-tags sort
[
    [ \ $subsection swap comment-word 2array ] map append
    "To look up annotations:" suffix
] [
    [ \ $subsection swap comment-usage.-word 2array ] map append
] bi
<article> "annotations" add-article

"annotations" lookup-vocab "annotations" >>help drop

annotation-tags [
    {
        [ [ <$annotation> ] [ comment-word set-word-help ] bi ]
        [ [ <$annotation-usage> ] [ comment-usage-word set-word-help ] bi ]
        [ [ <$annotation-usage.> ] [ comment-usage.-word set-word-help ] bi ]
        [ [ comment-word ] [ comment-usage-word ] [ comment-usage.-word ] tri 3array related-words ]
    } cleave
] each
