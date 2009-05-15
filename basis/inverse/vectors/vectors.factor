USING: generalizations inverse kernel locals sequences vectors ;
IN: inverse.vectors
: assure-vector ( vector -- vector )
    dup vector? assure ; inline

: undo-nvector ( array n -- ... )
    [ assure-vector ] dip
    [ assure-length ] [ firstn ] 2bi ; inline

\ 1vector [ 1 undo-nvector ] define-inverse

\ peek [ 1vector ] define-inverse

:: undo-if-empty ( result a b -- seq )
   a call( -- b ) result = [ V{ } clone ] [ result b [undo] call( a -- b ) ] if ;

\ if-empty 2 [ swap [ undo-if-empty ] 2curry ] define-pop-inverse
