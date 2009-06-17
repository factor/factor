USING: accessors arrays db.tuples db.sqlite persistency db.queries
io.files.temp kernel monads sequences ui ui.frp.gadgets
ui.frp.layout ui.frp.signals ui.gadgets.scrollers ui.gadgets.labels
colors.constants ui.pens.solid combinators math locals strings
ui.images db.types sequences.extras ;
FROM: sets => prune ;
IN: recipes
STORED-TUPLE: recipe { title { VARCHAR 100 } } { votes INTEGER } { txt TEXT } { genre { VARCHAR 100 } } ;
: <recipe> ( title genre text -- recipe ) recipe new swap >>txt swap >>genre swap >>title 0 >>votes ;
"recipes.db" temp-file <sqlite-db> recipe define-db
: top-recipes ( offset search -- recipes ) <query> T{ recipe } rot >>title >>tuple
    "votes" >>order 30 >>limit swap >>offset get-tuples ;
: top-genres ( -- genres ) f f top-recipes [ genre>> ] map prune 4 (head-slice) ;
: <image-button> ( str -- button ) "vocab:recipes/icons/" ".tiff" surround <image-name> <frp-button> ;

: interface ( -- book ) [ 
     [
        [ $ TOOLBAR $ <spacer> $ SEARCH $ ] <hbox> COLOR: AliceBlue <solid> >>interior ,
        [ "Genres:" <label> , <spacer> $ GENRES $ ] <hbox>
            { 5 0 } >>gap COLOR: gray <solid> >>interior ,
        $ RECIPES $
     ] <vbox> ,
     [
        [ "Title:" <label> , $ TITLE $ "Genre:" <label> , $ GENRE $ ] <hbox> ,
        $ BODY $
        $ BUTTON $
     ] <vbox> ,
  ] <frp-book*> { 350 245 } >>pref-dim ;
  
:: recipe-browser ( -- ) [
    interface
      <frp-table*> :> tbl
      "okay" <frp-border-button> BUTTON -> :> ok
      "submit" <image-button> [ store-tuple ] >>value TOOLBAR -> :> submit
      "love" <image-button> 1 >>value TOOLBAR ->
      "hate" <image-button> -1 >>value -> 2array <merge> :> votes
      "back" <image-button> -> [ -30 ] <$
      "more" <image-button> -> [ 30 ] <$ 2array <merge> :> viewed
      <frp-field*> SEARCH ->% 1 :> search
      submit ok [ [ drop ] ] <$ 2array <merge> [ drop ] >>value :> quot
      viewed 0 [ + ] <fold> search ok t <basic> "all" <frp-button> GENRES ->
      tbl selected-value>> votes [ [ + ] curry change-votes modify-tuple ] 2$>-|
        4array <merge>
        [ drop [ f ] [ "%" dup surround <pattern> ] if-empty top-recipes ] 3fmap-| :> updates
      updates [ top-genres UI[ <frp-button> GENRES ->? ] map <merge> ] bind*
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
   ] with-interface "recipes" open-window ;

MAIN: recipe-browser