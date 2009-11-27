! Copyright (C) 2008 Jean-François Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: 4DNav.camera

HELP: camera-eye
{ $values
    
     { "point" "position" }
}
{ $description "return the position of the camera" } ;

HELP: camera-focus
{ $values
    
     { "point" "position" }
}
{ $description "return the point the camera looks at" } ;

HELP: camera-up
{ $values
    
     { "dirvec" "upside direction" }
}
{ $description "In order to precise the roling position of camera give an upward vector" } ;

HELP: do-look-at
{ $values
     { "camera" "direction" }
}
{ $description "Word to use in replacement of gl-look-at when using a camera" } ;

ARTICLE: "4DNav.camera" "Camera"
{ $vocab-link "4DNav.camera" }
$nl
"A camera is defined by:"
{ $list
{ "a position (" { $link camera-eye } ")" }
{ "a focus direction (" { $link camera-focus } ")" }
{ "an attitude information (" { $link camera-up } ")" }
}
"Use " { $link do-look-at } " in opengl statement in placement of gl-look-at"
$nl
"A camera is a " { $vocab-link "4DNav.turtle" } " object. Its a special vocab to handle mouvements of a 3D object:"
{ $list
{ "To define a camera"
{
    $unchecked-example
    
"VAR: my-camera"
": init-my-camera ( -- )"
"    <turtle> >my-camera"
"    [ my-camera> >self"
"      reset-turtle "
"    ] with-scope ;"
} }
{ "To move it"
{
    $unchecked-example

"    [ my-camera> >self"
"      45 pitch-up "
"      5 step-turtle" 
"    ] with-scope "
} }
{ "or"
{
    $unchecked-example

"    [ my-camera> >self"
"      5 strafe-left"
"    ] with-scope "
}
}
{
"to use it in an opengl statement"
{
    $unchecked-example
  "my-camera> do-look-at"

}
}
}


;

ABOUT: "4DNav.camera"
