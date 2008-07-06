USING: kernel models arrays sequences math math.order
models.compose ;
IN: models.range

TUPLE: range ;

: <range> ( value min max page -- range )
    4array [ <model> ] map <compose>
    { set-delegate } range construct ;

: range-model ( range -- model ) model-dependencies first ;
: range-page ( range -- model ) model-dependencies second ;
: range-min ( range -- model ) model-dependencies third ;
: range-max ( range -- model ) model-dependencies fourth ;

M: range range-value
    [ range-model model-value ] keep clamp-value ;

M: range range-page-value range-page model-value ;

M: range range-min-value range-min model-value ;

M: range range-max-value range-max model-value ;

M: range range-max-value*
    dup range-max-value swap range-page-value [-] ;

M: range set-range-value
    [ clamp-value ] keep range-model set-model ;

M: range set-range-page-value range-page set-model ;

M: range set-range-min-value range-min set-model ;

M: range set-range-max-value range-max set-model ;

: move-by ( amount range -- )
    [ range-value + ] keep set-range-value ;

: move-by-page ( amount range -- )
    [ range-page-value * ] keep move-by ;
