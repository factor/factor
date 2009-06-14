USING: accessors arrays db.tuples db.sqlite persistency
io.files.temp kernel monads sequences ui ui.frp.gadgets
ui.frp.layout ui.frp.signals ui.gadgets.scrollers ui.gadgets.labels
colors.constants ui.pens.solid combinators math locals strings
ui.tools.inspector ;
FROM: sets => prune ;
IN: recipes
STORED-TUPLE: recipe title votes txt genre ;
: <recipe> ( title genre text -- recipe ) recipe new swap >>txt swap >>genre swap >>title ;
"recipes.db" temp-file <sqlite-db> recipe define-db
: top-recipes ( -- recipes ) <query> T{ recipe } >>tuple "votes" >>order get-tuples ;
: top-genres ( -- genres ) top-recipes [ genre>> ] map prune 5 (head-slice) ;
: interface ( -- book ) [ 
     [
        [ $ TOOLBAR $ <spacer> $ GENRES $ ] <hbox> { 5 0 } >>gap COLOR: gray <solid> >>interior ,
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
      "Submit Recipe" <frp-button> [ store-tuple ] >>value TOOLBAR -> :> submit
      submit ok [ [ drop ] ] <$ 2array <merge> [ drop ] >>value :> quot
      ok t <basic> "all" <frp-button> GENRES -> 3array <merge> [ top-recipes ] <$ :> updates
      updates [ top-genres UI[ <frp-button> GENRES ->? ] map <merge> ] bind*
        [ text>> T{ recipe } swap >>genre get-tuples ] fmap
      tbl swap updates 2array <merge> >>model
        [ [ title>> ] [ genre>> ] bi 2array ] >>quot
        { "Title" "Genre" } >>column-titles dup <scroller> RECIPES ,% 1
        actions>> submit [ "" dup dup <recipe> ] <$ 2array <merge>
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

! should clear out old values on submission