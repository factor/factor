USING: generalizations inverse kernel locals sequences vectors ;
IN: inverse.vectors
: assure-vector ( vector -- vector )
    dup vector? assure ; inline

: undo-nvector ( array n -- ... )
    [ assure-vector ] dip
    firstn ; inline

\ 1vector [ 1 undo-nvector ] define-inverse

\ last [ 1vector ] define-inverse

! if is too general to undo, but its derivatives aren't

:: undo-if-empty ( result a b -- seq )
   a call( -- b ) result = [ V{ } clone ] [ result b [undo] call( a -- b ) ] if ;

:: undo-if* ( result a b -- boolean )
   b call( -- b ) result = [ f ] [ result a [undo] call( a -- b ) ] if ;

\ if-empty 2 [ swap [ undo-if-empty ] 2curry ] define-pop-inverse

\ if* 2 [ swap [ undo-if* ] 2curry ] define-pop-inverse
