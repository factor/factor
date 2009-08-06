USING: accessors arrays colors.constants combinators db.sqlite
db.tuples db.types io.files.temp kernel locals math
models.combinators monads persistency sequences
sequences.extras ui ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.labels ui.gadgets.layout ui.gadgets.scrollers
ui.gadgets.tables ui.pens.solid ;
FROM: sets => prune ;
IN: recipes

STORED-TUPLE: recipe { title { VARCHAR 100 } } { votes INTEGER } { txt TEXT } { genre { VARCHAR 100 } } ;
: <recipe> ( title genre text -- recipe ) recipe new swap >>txt swap >>genre swap >>title 0 >>votes ;
"recipes.db" temp-file <sqlite-db> recipe define-db
: top-recipes ( offset search -- recipes ) <query> T{ recipe } rot >>title >>tuple
    "votes" >>order 30 >>limit swap >>offset get-tuples ;
: top-genres ( -- genres ) f f top-recipes [ genre>> ] map prune 4 short head-slice ;

: interface ( -- book ) [ 
     [
        [ $ TOOLBAR $ ] <hbox> COLOR: AliceBlue <solid> >>interior ,
        [ "Genres:" <label> , <spacer> $ ALL $ $ GENRES $ ] <hbox>
            { 5 0 } >>gap COLOR: gray <solid> >>interior ,
        $ RECIPES $
     ] <vbox> ,
     [
        [ "Title:" <label> , $ TITLE $ "Genre:" <label> , $ GENRE $ ] <hbox> ,
        $ BODY $
        $ BUTTON* $
     ] <vbox> ,
  ] <book*> { 350 245 } >>pref-dim ;
  
:: recipe-browser ( -- ) [ [
    interface
      <quot-table*> :> tbl
      "okay" <border-button*> BUTTON* -> :> ok
      IMG-BUTTON*: submit [ store-tuple ] >>value TOOLBAR -> :> submit
      IMG-BUTTON*: love 1 >>value TOOLBAR ->
      IMG-BUTTON*: hate -1 >>value -> 2array merge :> votes
      IMG-BUTTON*: back -> [ -30 ] <$
      IMG-BUTTON*: more -> [ 30 ] <$ 2array merge :> viewed
      <spacer> <model-field*> ->% 1 :> search
      submit ok [ [ drop ] ] <$ 2array merge [ drop ] >>value :> quot
      viewed 0 [ + ] fold search ok t <basic> "all" <button*> ALL ->
      tbl selection>> votes [ [ + ] curry change-votes modify-tuple ] 2$>
        4array merge
        [ drop [ f ] [ "%" dup surround <pattern> ] if-empty top-recipes ] 3fmap :> ups
      ups [ top-genres [ <button*> GENRES -> ] map merge ] bind*
        [ button-text T{ recipe } swap >>genre get-tuples ] fmap
      tbl swap ups 2merge >>model
        [ [ title>> ] [ genre>> ] bi 2array ] >>quot
        { "Title" "Genre" } >>column-titles dup <scroller> RECIPES ,% 1 actions>>
      submit [ "" dup dup <recipe> ] <$ 2array merge
        { [ [ title>> ] fmap <model-field> TITLE ->% .5 ]
          [ [ genre>> ] fmap <model-field> GENRE ->% .5 ]
          [ [ txt>> ] fmap <multiline-field> BODY ->% 1 ]
        } cleave
        [ <recipe> ] 3fmap
      [ [ 1 ] <$ ]
      [ quot ok updates #1 [ call( recipe -- ) 0 ] 2fmap ] bi
      2merge 0 <basic> switch-models >>model
   ] with-interface "recipes" open-window ] with-ui ;

MAIN: recipe-browser