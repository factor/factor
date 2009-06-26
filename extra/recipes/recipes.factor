USING: accessors arrays colors.constants combinators db.queries
db.sqlite db.tuples db.types io.files.temp kernel locals math
monads persistency sequences sequences.extras ui ui.frp.gadgets
ui.frp.layout ui.frp.signals ui.gadgets.labels
ui.gadgets.scrollers ui.pens.solid ;
FROM: sets => prune ;
IN: recipes

STORED-TUPLE: recipe { title { VARCHAR 100 } } { votes INTEGER } { txt TEXT } { genre { VARCHAR 100 } } ;
: <recipe> ( title genre text -- recipe ) recipe new swap >>txt swap >>genre swap >>title 0 >>votes ;
"recipes.db" temp-file <sqlite-db> recipe define-db
: top-recipes ( offset search -- recipes ) <query> T{ recipe } rot >>title >>tuple
    "votes" >>order 30 >>limit swap >>offset get-tuples ;
: top-genres ( -- genres ) f f top-recipes [ genre>> ] map prune 4 (head-slice) ;

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
        $ BUTTON $
     ] <vbox> ,
  ] <frp-book*> { 350 245 } >>pref-dim ;
  
:: recipe-browser ( -- ) [ [
    interface
      <frp-table*> :> tbl
      "okay" <frp-border-button> BUTTON -> :> ok
      IMAGE-BUTTON: submit [ store-tuple ] >>value TOOLBAR -> :> submit
      IMAGE-BUTTON: love 1 >>value TOOLBAR ->
      IMAGE-BUTTON: hate -1 >>value -> 2array <merge> :> votes
      IMAGE-BUTTON: back -> [ -30 ] <$
      IMAGE-BUTTON: more -> [ 30 ] <$ 2array <merge> :> viewed
      <spacer> <frp-field*> ->% 1 :> search
      submit ok [ [ drop ] ] <$ 2array <merge> [ drop ] >>value :> quot
      viewed 0 [ + ] <fold> search ok t <basic> "all" <frp-button> ALL ->
      tbl selected-value>> votes [ [ + ] curry change-votes modify-tuple ] 2$>-|
        4array <merge>
        [ drop [ f ] [ "%" dup surround <pattern> ] if-empty top-recipes ] 3fmap-| :> updates
      updates [ top-genres [ <frp-button> GENRES -> ] map <merge> ] bind*
        [ text>> T{ recipe } swap >>genre get-tuples ] fmap
      tbl swap updates 2array <merge> >>model
        [ [ title>> ] [ genre>> ] bi 2array ] >>quot
        { "Title" "Genre" } >>column-titles dup <scroller> RECIPES ,% 1 actions>>
      submit [ "" dup dup <recipe> ] <$ 2array <merge>
        { [ [ title>> ] fmap <frp-field> TITLE ->% .5 ]
          [ [ genre>> ] fmap <frp-field> GENRE ->% .5 ]
          [ [ txt>> ] fmap <frp-editor> BODY ->% 1 ]
        } cleave
        [ <recipe> ] 3fmap-|
      [ [ 1 ] <$ ]
      [ quot ok <updates> #1 [ call( recipe -- ) 0 ] 2fmap-& ] bi
      2array <merge> 0 <basic> <switch> >>model
   ] with-interface "recipes" open-window ] with-ui ;

MAIN: recipe-browser