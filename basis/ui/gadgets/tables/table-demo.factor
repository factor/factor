USING: accessors arrays effects help kernel locals models
present prettyprint ui ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tables ui.gadgets.tracks vocabs models.filter
ui.gadgets.search-tables sequences fry ;
IN: scratchpad

SINGLETON: word-renderer
M: word-renderer row-columns
    drop
    [ name>> ] [ stack-effect present ] 
    bi 2array ;

SINGLETON: vocab-renderer
M: vocab-renderer row-columns
    drop vocab-name
    1array ;

: search-vocabs ( vocabs search -- vocabs' )
    '[ _ swap subseq? ] filter [ >vocab-link ] map ;

: <vocabs-table> ( in-model -- gadget )
    vocabs <model> [ search-vocabs ] <search-table>
        vocab-renderer >>renderer
        swap >>selected-value
    "Vocabularies" <labelled-gadget> ;

: search-words ( words search -- words' )
    '[ _ swap name>> subseq? ] filter ;

: <vocab-table> ( out-model in-model -- gadget )
    [ words natural-sort ] <filter>
    [ search-words ] <search-table>
        word-renderer >>renderer
        swap >>selected-value
    "Words" <labelled-gadget> ;

: table-demo ( -- )
    [let | m [ f <model> ] m' [ f <model> ] |
        { 1 0 } <track>
            { 0 1 } <track>
                m <vocabs-table> 1/2 track-add
                m' m <vocab-table> 1/2 track-add
            1/3 track-add
            { m' m } <compose>
            [ first2 or [ help ] when* ] <pane-control> <scroller>
            "Definition" <labelled-gadget> 2/3 track-add
        "Hi" open-status-window
    ] ;