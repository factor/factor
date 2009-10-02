! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: adsoda

! --------------------------------------------------------------
! faces
! --------------------------------------------------------------
ARTICLE: "face-page" "Face in ADSODA"
"explanation of faces"
$nl
"link to functions" $nl
"what is an halfspace" $nl
"halfspace touching-corners adjacent-faces" $nl
"touching-corners list of pointers to the corners which touch this face" $nl
"adjacent-faces list of pointers to the faces which touch this face"
{ $subsections
    face
    <face>
}
"test relative position"
{ $subsections
    point-inside-or-on-face?
    point-inside-face?
}
"handling face"
{ $subsections
    flip-face
    face-translate
    face-transform
}

;

HELP: face
{ $class-description "a face is defined by"
{ $list "halfspace equation" }
{ $list "list of touching corners" }
{ $list "list of adjacent faces" }
$nl
"Touching corners and adjacent faces are defined by algorithm thanks to other faces of the solid"
}


;
HELP: <face> 
{ $values { "v" "an halfspace equation" } { "tuple" "a face" }  }   ;
HELP: flip-face 
{ $values { "face" "a face" } { "face" "flipped face" } }
{ $description "change the orientation of a face" }
;

HELP: face-translate 
{ $values { "face" "a face" } { "v" "a vector" } }
{ $description 
"translate a face following a vector"
$nl
"a translation of an halfspace doesn't change the normal vector. this word just compute the new constant term" }

 
 ;
HELP: face-transform 
{ $values { "face" "a face" } { "m" "a transformation matrix" } }
{ $description  "compute the transformation of a face using a transformation matrix" }
 
 ;
! --------------------------------
! solid
! --------------------------------------------------------------
ARTICLE: "solid-page" "Solid in ADSODA"
"explanation of solids"
$nl
"link to functions"
{ $subsections
    solid
    <solid>
}
"test relative position"
{ $subsections
    point-inside-solid?
    point-inside-or-on-solid?
}
"playing with faces and solids"
{ $subsections
    add-face
    cut-solid
    slice-solid
}
"solid handling"
{ $subsections
    solid-project
    solid-translate
    solid-transform
    subtract
    get-silhouette 
    solid=
}
;

HELP: solid 
{ $class-description "dimension" $nl "silhouettes" $nl "faces" $nl "corners" $nl "adjacencies-valid" $nl "color" $nl "name" 
}
;

HELP: add-face 
{ $values { "solid" "a solid" } { "face" "a face" } }
{ $description "reshape a solid with a face. The face truncate the solid." } ;

HELP: cut-solid
{ $values { "solid" "a solid" } { "halfspace" "an halfspace" } }
{ $description "like add-face but just with halfspace equation" } ;

HELP: slice-solid
{ $values { "solid" "a solid" } { "face" "a face" } { "solid1" "the outer part of the former solid" } { "solid2" "the inner part of the former solid" } }
{ $description "cut a solid into two parts. The face acts like a knife"
}  ;


HELP: solid-project
{ $values { "lights" "lights" } { "ambient" "ambient" } { "solid" "solid" } { "solids" "projection of solid" } }
{ $description "Project the solid using pv vector" 
$nl
"TODO: explain how to use lights"
} ;

HELP: solid-translate 
{ $values { "solid" "a solid" } { "v" "translating vector" } }
{ $description "Translate a solid using a vector" 
$nl
"v and solid must have the same dimension "
} ;

HELP: solid-transform 
{ $values { "solid" "a solid" } { "m" "transformation matrix" } }
{ $description "Transform a solid using a matrix"
$nl
"v and solid must have the same dimension "
} ;

HELP: subtract 
{ $values { "solid1" "initial shape" } { "solid2" "shape to remove" } { "solids" "resulting shape" } }
{ $description  "Substract solid2 from solid1" } ;


! --------------------------------------------------------------
! space 
! --------------------------------------------------------------
ARTICLE: "space-page" "Space in ADSODA"
"A space is a collection of solids and lights."
$nl
"link to functions"
$nl
"Defining words"
{ $subsections
    space
    <space>
    suffix-solids 
    suffix-lights
    clear-space-solids 
    describe-space
}


"Handling space"
{ $subsections
    space-ensure-solids
    eliminate-empty-solids
    space-transform
    space-translate
    remove-hidden-solids
    space-project
}


;

HELP: space 
{ $class-description 
"dimension" $nl " solids" $nl " ambient-color" $nl "lights" 
}
;

HELP: suffix-solids 
"( space solid -- space )"
{ $values { "space" "a space" } { "solid" "a solid to add" } }
{ $description "Add solid to space definition" } ;

HELP: suffix-lights 
"( space light -- space ) "
{ $values { "space" "a space" } { "light" "a light to add" } }
{ $description "Add a light to space definition" } ;

HELP: clear-space-solids 
"( space -- space )"   
{ $values { "space" "a space" } }
{ $description "remove all solids in space" } ;

HELP: space-ensure-solids 
{ $values { "space" "a space" } }
{ $description "rebuild corners of all solids in space" } ;



HELP: space-transform 
" ( space m -- space )" 
{ $values { "space" "a space" } { "m" "a matrix" } }
{ $description "Transform a space using a matrix" } ;

HELP: space-translate 
{ $values { "space" "a space" } { "v" "a vector" } }
{ $description "Translate a space following a vector" } ;

HELP: describe-space " ( space -- )"
{ $values { "space" "a space" } }
{ $description "return a description of space" } ;

HELP: space-project 
{ $values { "space" "a space" } { "i" "an integer" } }
{ $description "Project a space along ith coordinate" } ;

! --------------------------------------------------------------
! 3D rendering
! --------------------------------------------------------------
ARTICLE: "3D-rendering-page" "The 3D rendering in ADSODA"
"explanation of 3D rendering"
$nl
"link to functions"
{ $subsections
    face->GL
    solid->GL
    space->GL
}

;

HELP: face->GL 
{ $values { "face" "a face" } { "color" "3 3 values array" } }
{ $description "display a face" } ;

HELP: solid->GL 
{ $values { "solid" "a solid" } }
{ $description "display a solid" } ;

HELP: space->GL 
{ $values { "space" "a space" } }
{ $description "display a space" } ;

! --------------------------------------------------------------
! light
! --------------------------------------------------------------

ARTICLE: "light-page" "Light in ADSODA"
"explanation of light"
$nl
"link to functions"
;

ARTICLE: { "adsoda" "light" } "ADSODA : lights"
{ $code """
! HELP: light position color
! <light> ( -- tuple ) light new ;
! light est un vecteur avec 3 variables pour les couleurs\n
 void Light::Apply(Vector& normal, double &cRed, double &cGreen, double &cBlue)\n
 { \n
   // Dot the light direction with the normalized normal of Face.
   register double intensity = -(normal * (*this));
   // Face is a backface, from light's perspective
   if (intensity < 0)
     return;
   
   // Add the intensity componentwise
   cRed += red * intensity;
   cGreen += green * intensity;
   cBlue += blue * intensity;
   // Clip to unit range
  if (cRed > 1.0) cRed = 1.0;
   if (cGreen > 1.0) cGreen = 1.0;
   if (cBlue > 1.0) cBlue = 1.0;
""" }
;



ARTICLE: { "adsoda" "halfspace" } "ADSODA : halfspace"
" defined by the concatenation of the normal vector and a constant"  
 ;



ARTICLE:  "adsoda-main-page"  "ADSODA : Arbitrary-Dimensional Solid Object Display Algorithm"
"multidimensional handler :" 
$nl
"design a solid using face delimitations. Only works on convex shapes"
$nl
{ $emphasis "written in C++ by Greg Ferrar" }
$nl
"full explanation on adsoda page at " { $url "http://www.flowerfire.com/ADSODA/" }
$nl
"Useful words are describe on the following pages: "
{ $subsections
    "face-page"
    "solid-page"
    "space-page"
    "light-page"
    "3D-rendering-page"
} ;

ABOUT: "adsoda-main-page"
