! Copyright (C) 2008 Jean-François Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel sequences ;
IN: 4DNav.turtle

HELP: <turtle>
{ $values
    
     { "turtle" null }
}
{ $description "" } ;

HELP: >turtle-ori
{ $values
     { "val" null }
}
{ $description "" } ;

HELP: >turtle-pos
{ $values
     { "val" null }
}
{ $description "" } ;

HELP: Rx
{ $values
     { "angle" null }
     { "Rz" null }
}
{ $description "" } ;

HELP: Ry
{ $values
     { "angle" null }
     { "Ry" null }
}
{ $description "" } ;

HELP: Rz
{ $values
     { "angle" null }
     { "Rx" null }
}
{ $description "" } ;

HELP: V
{ $values
    
     { "V" null }
}
{ $description "" } ;

HELP: X
{ $values
    
     { "3array" null }
}
{ $description "" } ;

HELP: Y
{ $values
    
     { "3array" null }
}
{ $description "" } ;

HELP: Z
{ $values
    
     { "3array" null }
}
{ $description "" } ;

HELP: apply-rotation
{ $values
     { "rotation" null }
}
{ $description "" } ;

HELP: distance
{ $values
     { "turtle" null } { "turtle" null }
     { "n" null }
}
{ $description "" } ;

HELP: move-by
{ $values
     { "point" null }
}
{ $description "" } ;

HELP: pitch-down
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: pitch-up
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: reset-turtle
{ $description "" } ;

HELP: roll-left
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: roll-right
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: roll-until-horizontal
{ $description "" } ;

HELP: rotate-x
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: rotate-y
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: rotate-z
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: set-X
{ $values
     { "seq" sequence }
}
{ $description "" } ;

HELP: set-Y
{ $values
     { "seq" sequence }
}
{ $description "" } ;

HELP: set-Z
{ $values
     { "seq" sequence }
}
{ $description "" } ;

HELP: step-turtle
{ $values
     { "length" null }
}
{ $description "" } ;

HELP: step-vector
{ $values
     { "length" null }
     { "array" array }
}
{ $description "" } ;

HELP: strafe-down
{ $values
     { "length" null }
}
{ $description "" } ;

HELP: strafe-left
{ $values
     { "length" null }
}
{ $description "" } ;

HELP: strafe-right
{ $values
     { "length" null }
}
{ $description "" } ;

HELP: strafe-up
{ $values
     { "length" null }
}
{ $description "" } ;

HELP: turn-left
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: turn-right
{ $values
     { "angle" null }
}
{ $description "" } ;

HELP: turtle
{ $description "" } ;

HELP: turtle-ori>
{ $values
    
     { "val" null }
}
{ $description "" } ;

HELP: turtle-pos>
{ $values
    
     { "val" null }
}
{ $description "" } ;

ARTICLE: "4DNav.turtle" "4DNav.turtle"
{ $vocab-link "4DNav.turtle" }
;

ABOUT: "4DNav.turtle"
