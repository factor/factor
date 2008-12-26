! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel sequences ;
IN: adsoda.tools

HELP: 3cube
{ $values 
    { "array" "array" } { "name" "name" } 
    { "solid" "solid" } 
}
{ $description "array : xmin xmax ymin ymax zmin zmax" 
"\n returns a 3D solid with given limits"
} ;

HELP: 4cube
{ $values 
    { "array" "array" } { "name" "name" } 
    { "solid" "solid" } 
}
{ $description "array : xmin xmax ymin ymax zmin zmax wmin wmax"  
"\n returns a 4D solid with given limits"
} ;


HELP: coord-max
{ $values
     { "x" null } { "array" array }
     { "array" array }
}
{ $description "" } ;

HELP: coord-min
{ $values
     { "x" null } { "array" array }
     { "array" array }
}
{ $description "" } ;

HELP: equation-system-for-normal
{ $values
     { "points" "a list of n points" }
     { "matrix" "matrix" }
}
{ $description "From a list of points, return the matrix" 
"to solve in order to find the vector normal to the plan defined by the points" } 
;

HELP: normal-vector
{ $values
     { "points" "a list of n points" }
     { "v" "a vector" }
}
{ $description "From a list of points, returns the vector normal to the plan defined by the points" 
"\nWith n points, creates n-1 vectors and then find a vector orthogonal to every others"
"\n returns { f } if a normal vector can not be found" } 
;

HELP: points-to-hyperplane
{ $values
     { "points" "a list of n points" }
     { "hyperplane" "an hyperplane equation" }
}
{ $description "From a list of points, returns the equation of the hyperplan"
"\n Finds a normal vector and then translate it so that it includes one of the points"

} 
;

ARTICLE: "adsoda.tools" "adsoda.tools"
{ $vocab-link "adsoda.tools" }
"\nTools to help in building an " { $vocab-link "adsoda" } "-space"
;

ABOUT: "adsoda.tools"


