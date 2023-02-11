USING: accessors inverse kernel models models.arrow ;
IN: models.illusion

TUPLE: illusion < arrow ;

: <illusion> ( model quot -- illusion )
    f illusion new-model
        swap >>quot
        over >>model
    [ add-dependency ] keep ;

: <activated-illusion> ( model quot -- illusion )
    <illusion> dup activate-model ;

: backtalk ( value object -- )
    [ quot>> [undo] call( a -- b ) ] [ model>> ] bi set-model ;

M: illusion update-model ( model -- )
    [ [ value>> ] keep backtalk ] with-locked-model ;
