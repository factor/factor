! Copyright (C) 2008 Jean-François Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations strings ;
IN: 4DNav


HELP: menu-3D
{ $values
     { "gadget" "gadget" }
}
{ $description "The menu dedicated to 3D movements of the camera" } ;

HELP: menu-4D
{ $values
    
     { "gadget" "gadget" }
}
{ $description "The menu dedicated to 4D movements of space" } ;

HELP: menu-bar
{ $values
    
     { "gadget" "gadget" }
}
{ $description "return gadget containing menu buttons" } ;

HELP: model-projection
{ $values
     { "x" "interger" }
     { "space" "space" }
}
{ $description "Project space following coordinate x" } ;

HELP: mvt-3D-1
{ $values
    
     { "quot" "quotation" }
}
{ $description "return a quotation to orientate space to see it from first point of view" } ;

HELP: mvt-3D-2
{ $values
    
     { "quot" "quotation" }
}
{ $description "return a quotation to orientate space to see it from second point of view" } ;

HELP: mvt-3D-3
{ $values
    
     { "quot" "quotation" }
}
{ $description "return a quotation to orientate space to see it from third point of view" } ;

HELP: mvt-3D-4
{ $values
    
     { "quot" "quotation" }
}
{ $description "return a quotation to orientate space to see it from first point of view" } ;

HELP: load-model-file
{ $description "load space from file" } ;

HELP: rotation-4D
{ $values
     { "m" "a rotation matrix" }
}
{ $description "Apply a 4D rotation matrix" } ;

HELP: translation-4D
{ $values
     { "v" "vector" }
}
{ $description "Apply a 4D translation" } ;


ARTICLE: "implementation details" "How 4DNav is done"
"4DNav is build using :"

{ $subsection "4DNav.camera" }
{ $subsection "adsoda-main-page" }
;

ARTICLE: "Space file" "Create a new space file"
"To build a new space, create an XML file using " { $vocab-link "adsoda" } " model description. A solid is not caracterized by its corners but is defined as the intersection of hyperplanes."

$nl
"An example is:"
{ $code """
<model>
<space>
 <dimension>4</dimension>
 <solid>
     <name>4cube1</name>
     <dimension>4</dimension>
     <face>1,0,0,0,100</face>
     <face>-1,0,0,0,-150</face>
     <face>0,1,0,0,100</face>
     <face>0,-1,0,0,-150</face>
     <face>0,0,1,0,100</face>
     <face>0,0,-1,0,-150</face>
     <face>0,0,0,1,100</face>
     <face>0,0,0,-1,-150</face>
     <color>1,0,0</color>
 </solid>
 <solid>
     <name>4triancube</name>
     <dimension>4</dimension>
     <face>1,0,0,0,160</face>
     <face>-0.4999999999999998,-0.8660254037844387,0,0,-130</face>
     <face>-0.5000000000000004,0.8660254037844384,0,0,-130</face>
     <face>0,0,1,0,140</face>
     <face>0,0,-1,0,-180</face>
     <face>0,0,0,1,110</face>
     <face>0,0,0,-1,-180</face>
     <color>0,1,0</color>
 </solid>
 <solid>
     <name>triangone</name>
     <dimension>4</dimension>
     <face>1,0,0,0,60</face>
     <face>0.5,0.8660254037844386,0,0,60</face>
     <face>-0.5,0.8660254037844387,0,0,-20</face>
     <face>-1.0,0,0,0,-100</face>
     <face>-0.5,-0.8660254037844384,0,0,-100</face>
     <face>0.5,-0.8660254037844387,0,0,-20</face>
     <face>0,0,1,0,120</face>
     <face>0,0,-0.4999999999999998,-0.8660254037844387,-120</face>
     <face>0,0,-0.5000000000000004,0.8660254037844384,-120</face>
     <color>0,1,1</color>
 </solid>
 <light>
     <direction>1,1,1,1</direction>
     <color>0.2,0.2,0.6</color>
 </light>
 <color>0.8,0.9,0.9</color>
</space>
</model>""" } ;

ARTICLE: "TODO" "Todo"
{ $list 
    "A vocab to initialize parameters"
    "an editor mode" 
        { $list "add a face to a solid"
                "add a solid to the space"
                "move a face"
                "move a solid"
                "select a solid in a list"
                "select a face"
                "display selected face"
                "edit a solid color"
                "add a light"
                "edit a light color"
                "move a light"
                }
    "add a tool wich give an hyperplane normal vector with enought points. Will use adsoda.intersect-hyperplanes with { { 0 } { 0 } { 1 } } "
    "decorrelate 3D camera and activate them with select buttons"

} ;


ARTICLE: "4DNav" "The 4DNav app"
{ $vocab-link "4DNav" }
$nl
{ $heading "4D Navigator" }
"4DNav is a simple tool to visualize 4 dimensionnal objects."
$nl
"It uses " { $vocab-link "adsoda" } " library to display a 4D space and navigate thru it."
$nl
"It will display:"
{ $list
    { "a menu window" }
    {  "4 visualization windows" }
}
"Each visualization window represents the projection of the 4D space on a particular 3D space."

{ $heading "Start" }
"type:" { $code "\"4DNav\" run" } 

{ $heading "Navigation" }
"Menu window is divided in 4 areas"
{ $list
    { "a space-file chooser to select the file to display" }
    { "a parametrization area to select the projection mode" }
    { "4D submenu to translate and rotate the 4D space" }
    { "3D submenu to move the camera in 3D space. Cameras in every 3D spaces are manipulated as a single one" }
    }

{ $heading "Links" }
{ $subsection "Space file" }

{ $subsection "TODO" }
{ $subsection "implementation details" }

;

ABOUT: "4DNav"
