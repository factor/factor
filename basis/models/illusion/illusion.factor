USING: accessors models models.arrow inverse inverse.vectors kernel ;
IN: models.illusion

TUPLE: illusion < arrow ;

: <illusion> ( model quot -- illusion )
    illusion new V{ } clone >>connections V{ } clone >>dependencies 0 >>ref
    swap >>quot over >>model [ add-dependency ] keep ;

: backtalk ( value object -- ) [ quot>> [undo] call( a -- b ) ] [ model>> ] bi (>>value) ;

IN: accessors
M: illusion (>>value) ( value object -- ) swap throw [ call-next-method ] 2keep
   dup [ quot>> ] [ model>> ] bi and
   [ backtalk ]
   [ 2drop ] if ;