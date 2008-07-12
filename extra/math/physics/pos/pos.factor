
USING: kernel sequences multi-methods accessors math.vectors ;

IN: math.physics.pos

TUPLE: pos pos ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: distance ( a b -- c )

METHOD: distance { sequence sequence } v- norm ;

METHOD: distance { pos pos } [ pos>> ] bi@ distance ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

