USING: accessors arrays colors combinators db.sqlite db.tuples
db.types io.files.temp kernel locals math models.combinators
monads persistency sequences sequences.extras sets ui
ui.gadgets.controls ui.gadgets.labels ui.gadgets.layout
ui.gadgets.scrollers ui.pens.solid ;
IN: recipes

STORED-TUPLE: recipe
    { title { VARCHAR 100 } }
    { votes INTEGER }
    { txt TEXT }
    { genre { VARCHAR 100 } } ;

: <recipe> ( title genre text -- recipe )
    recipe new swap >>txt swap >>genre swap >>title 0 >>votes ;

: init-recipe-db ( -- )
    "recipes.db" temp-file <sqlite-db> recipe define-db ;

: top-recipes ( offset search -- recipes )
    <query> T{ recipe } rot >>title >>tuple
    "votes" >>order 30 >>limit swap >>offset get-tuples ;

: top-genres ( -- genres )
    f f top-recipes [ genre>> ] map members 4 index-or-length head-slice ;

: interface ( -- book )
    [
        [
            [ $ TOOLBAR $ ] <hbox> COLOR: AliceBlue <solid> >>interior ,
            [ "Genres:" <label> , <spacer> $ ALL $ $ GENRES $ ] <hbox>
            { 5 0 } >>gap COLOR: gray <solid> >>interior ,
            $ RECIPES $
        ] <vbox> ,
        [
            [ "Title:" <label> , $ TITLE $ "Genre:" <label> , $ GENRE $ ] <hbox> ,
            $ BODY $
            $ BUTTON $
        ] <vbox> ,
    ] <book*> { 350 245 } >>pref-dim ;

:: <recipe-gadget> ( -- gadget )
    [
        interface
        <table*> :> tbl
        "okay" <model-border-btn> BUTTON -> :> ok
        IMG-MODEL-BTN: submit [ store-tuple ] >>value TOOLBAR -> :> submit
        IMG-MODEL-BTN: love 1 >>value TOOLBAR ->
        IMG-MODEL-BTN: hate -1 >>value -> 2array merge :> votes
        IMG-MODEL-BTN: back -> [ -30 ] <$
        IMG-MODEL-BTN: more -> [ 30 ] <$ 2array merge :> viewed
        <spacer> <model-field*> ->% 1 :> search
        submit ok [ [ drop ] ] <$ 2array merge [ drop ] >>value :> quot
        viewed 0 [ + ] fold search ok t <basic> "all" <model-btn> ALL ->
        tbl selection>> votes [ [ + ] curry change-votes modify-tuple ] 2$>
        4array merge
        [ drop [ f ] [ "%" dup surround <pattern> ] if-empty top-recipes ] 3fmap :> ups
        ups [ top-genres [ <model-btn> GENRES -> ] map merge ] bind*
        [ text>> T{ recipe } swap >>genre get-tuples ] fmap
        tbl swap ups 2merge >>model
        [ [ title>> ] [ genre>> ] bi 2array ] >>quot
        { "Title" "Genre" } >>column-titles dup <scroller> RECIPES ,% 1 actions>>
        submit [ "" dup dup <recipe> ] <$ 2array merge
        {
            [ [ title>> ] fmap <model-field> TITLE ->% .5 ]
            [ [ genre>> ] fmap <model-field> GENRE ->% .5 ]
            [ [ txt>> ] fmap <model-editor> BODY ->% 1 ]
        } cleave
        [ <recipe> ] 3fmap
        [ [ 1 ] <$ ]
        [ quot ok updates #1 [ call( recipe -- ) 0 ] 2fmap ] bi
        2merge 0 <basic> switch-models >>model
    ] with-interface ;

MAIN-WINDOW: recipe-browser
    { { title "Recipes" } }
    init-recipe-db <recipe-gadget> >>gadgets ;
