USING: accessors models models.arrow inverse kernel ;
IN: models.illusion

TUPLE: illusion < arrow ;

: <illusion> ( model quot -- illusion )
    illusion new V{ } clone >>connections V{ } clone >>dependencies 0 >>ref
    swap >>quot over >>model [ add-dependency ] keep ;

: <activated-illusion> ( model quot -- illusion ) <illusion> dup activate-model ;

: backtalk ( value object -- )
   [ quot>> [undo] call( a -- b ) ] [ model>> ] bi set-model ;

M: illusion update-model ( model -- ) [ [ value>> ] keep backtalk ] with-locked-model ;