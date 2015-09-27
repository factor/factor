! Copyright (C) 2010 Slava Pestov.
USING: kernel sequences euler.modeling gml.runtime ;
IN: gml.modeling

GML: poly2doubleface ( poly mode -- edge )
    {
        smooth-smooth
        sharp-smooth
        smooth-sharp
        sharp-sharp
        smooth-like-vertex
        sharp-like-vertex
        smooth-continue
        sharp-continue
    } nth polygon>double-face ;

GML: extrude-simple ( edge dist sharp -- edge ) extrude-simple ;

GML: bridgerings-simple ( e1 e2 sharp -- edge ) bridge-rings-simple ;

GML: project_ptline ( p p0 p1 -- q ) project-pt-line ;

GML: project_ptplane ( p dir n d -- q ) project-pt-plane ;

GML: project_polyplane ( [p] dir n d -- [q] ) project-poly-plane ;
