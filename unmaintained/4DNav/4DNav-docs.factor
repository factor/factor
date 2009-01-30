! Copyright (C) 2008 Jean-François Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations strings ;
IN: 4DNav

HELP: (mvt-4D)
{ $values
     { "quot" quotation }
}
{ $description "" } ;

HELP: 4D-Rxw
{ $values
     { "angle" null }
     { "Rz" null }
}
{ $description "" } ;

HELP: 4D-Rxy
{ $values
     { "angle" null }
     { "Rx" null }
}
{ $description "" } ;

HELP: 4D-Rxz
{ $values
     { "angle" null }
     { "Ry" null }
}
{ $description "" } ;

HELP: 4D-Ryw
{ $values
     { "angle" null }
     { "Ry" null }
}
{ $description "" } ;

HELP: 4D-Ryz
{ $values
     { "angle" null }
     { "Rx" null }
}
{ $description "" } ;

HELP: 4D-Rzw
{ $values
     { "angle" null }
     { "Rz" null }
}
{ $description "" } ;

HELP: 4DNav
{ $description "" } ;

HELP: >observer3d
{ $values
     { "value" null }
}
{ $description "" } ;

HELP: >present-space
{ $values
     { "value" null }
}
{ $description "" } ;


HELP: >view1
{ $values
     { "value" null }
}
{ $description "" } ;

HELP: >view2
{ $values
     { "value" null }
}
{ $description "" } ;

HELP: >view3
{ $values
     { "value" null }
}
{ $description "" } ;

HELP: >view4
{ $values
     { "value" null }
}
{ $description "" } ;

HELP: add-keyboard-delegate
{ $values
     { "obj" object }
     { "obj" object }
}
{ $description "" } ;

HELP: button*
{ $values
     { "string" string } { "quot" quotation }
     { "button" null }
}
{ $description "" } ;

HELP: camera-action
{ $values
     { "quot" quotation }
     { "quot" quotation }
}
{ $description "" } ;

HELP: camera-button
{ $values
     { "string" string } { "quot" quotation }
     { "button" null }
}
{ $description "" } ;

HELP: controller-window*
{ $values
     { "gadget" "a gadget" } 
}
{ $description "" } ;


HELP: init-models
{ $description "" } ;

HELP: init-variables
{ $description "" } ;

HELP: menu-3D
{ $values
     { "gadget" null }
}
{ $description "The menu dedicated to 3D movements of the camera" } ;

HELP: menu-4D
{ $values
    
     { "gadget" null }
}
{ $description "The menu dedicated to 4D movements of space" } ;

HELP: menu-bar
{ $values
    
     { "gadget" null }
}
{ $description "return gadget containing menu buttons" } ;

HELP: model-projection
{ $values
     { "x" null }
     { "space" null }
}
{ $description "Project space following coordinate x" } ;

HELP: mvt-3D-1
{ $values
    
     { "quot" quotation }
}
{ $description "return a quotation to orientate space to see it from first point of view" } ;

HELP: mvt-3D-2
{ $values
    
     { "quot" quotation }
}
{ $description "return a quotation to orientate space to see it from second point of view" } ;

HELP: mvt-3D-3
{ $values
    
     { "quot" quotation }
}
{ $description "return a quotation to orientate space to see it from third point of view" } ;

HELP: mvt-3D-4
{ $values
    
     { "quot" quotation }
}
{ $description "return a quotation to orientate space to see it from first point of view" } ;

HELP: observer3d
{ $description "" } ;

HELP: observer3d>
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: present-space
{ $description "" } ;

HELP: present-space>
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: load-model-file
{ $description "load space from file" } ;

HELP: rotation-4D
{ $values
     { "m" "a rotation matrix" }
}
{ $description "Apply a 4D rotation matrix" } ;

HELP: translation-4D
{ $values
     { "v" null }
}
{ $description "" } ;

HELP: update-model-projections
{ $description "" } ;

HELP: update-observer-projections
{ $description "" } ;

HELP: view1
{ $description "" } ;

HELP: view1>
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: view2
{ $description "" } ;

HELP: view2>
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: view3
{ $description "" } ;

HELP: view3>
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: view4
{ $description "" } ;

HELP: view4>
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: viewer-windows*
{ $description "" } ;

HELP: win3D
{ $values
     { "text" null } { "gadget" null }
}
{ $description "" } ;

HELP: windows
{ $description "" } ;

ARTICLE: "Space file" "Create a new space file"
"\nTo build a new space, create an XML file using " { $vocab-link "adsoda" } " model description. \nAn example is:"
$nl

"\n<model>"
"\n<space>"
"\n <dimension>4</dimension>"
"\n <solid>"
"\n     <name>4cube1</name>"
"\n     <dimension>4</dimension>"
"\n     <face>1,0,0,0,100</face>"
"\n     <face>-1,0,0,0,-150</face>"
"\n     <face>0,1,0,0,100</face>"
"\n     <face>0,-1,0,0,-150</face>"
"\n     <face>0,0,1,0,100</face>"
"\n     <face>0,0,-1,0,-150</face>"
"\n     <face>0,0,0,1,100</face>"
"\n     <face>0,0,0,-1,-150</face>"
"\n     <color>1,0,0</color>"
"\n </solid>"
"\n <solid>"
"\n     <name>4triancube</name>"
"\n     <dimension>4</dimension>"
"\n     <face>1,0,0,0,160</face>"
"\n     <face>-0.4999999999999998,-0.8660254037844387,0,0,-130</face>"
"\n     <face>-0.5000000000000004,0.8660254037844384,0,0,-130</face>"
"\n     <face>0,0,1,0,140</face>"
"\n     <face>0,0,-1,0,-180</face>"
"\n     <face>0,0,0,1,110</face>"
"\n     <face>0,0,0,-1,-180</face>"
"\n     <color>0,1,0</color>"
"\n </solid>"
"\n <solid>"
"\n     <name>triangone</name>"
"\n     <dimension>4</dimension>"
"\n     <face>1,0,0,0,60</face>"
"\n     <face>0.5,0.8660254037844386,0,0,60</face>"
"\n     <face>-0.5,0.8660254037844387,0,0,-20</face>"
"\n     <face>-1.0,0,0,0,-100</face>"
"\n     <face>-0.5,-0.8660254037844384,0,0,-100</face>"
"\n     <face>0.5,-0.8660254037844387,0,0,-20</face>"
"\n     <face>0,0,1,0,120</face>"
"\n     <face>0,0,-0.4999999999999998,-0.8660254037844387,-120</face>"
"\n     <face>0,0,-0.5000000000000004,0.8660254037844384,-120</face>"
"\n     <color>0,1,1</color>"
"\n </solid>"
"\n <light>"
"\n     <direction>1,1,1,1</direction>"
"\n     <color>0.2,0.2,0.6</color>"
"\n </light>"
"\n <color>0.8,0.9,0.9</color>"
"\n</space>"
"\n</model>"


;

ARTICLE: "TODO" "Todo"
{ $list 
    "A file chooser"
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


ARTICLE: "4DNav" "4DNav"
{ $vocab-link "4DNav" }
$nl
{ $heading "4D Navigator" }
"4DNav is a simple tool to visualize 4 dimensionnal objects."
"\n"
"It uses " { $vocab-link "adsoda" } " library to display a 4D space and navigate thru it."

"It will display:"
{ $list
    { "a menu window" }
    {  "4 visualization windows" }
}
"Each window represents the projection of the 4D space on a particular 3D space."
$nl

{ $heading "Initialization" }
"put the space file " { $strong "space-exemple.xml" } "  in temp directory"
" and then type:" { $code "\"4DNav\" run" } 
{ $heading "Navigation" }
"4D submenu move the space in translations and rotation."
"\n3D submenu move the camera in 3D space. Cameras in every 3D spaces are manipulated as a single one"
$nl




{ $heading "Links" }
{ $subsection "Space file" }

{ $subsection "TODO" }


;

ABOUT: "4DNav"
