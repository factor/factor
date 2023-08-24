! Copyright (C) 2010 Slava Pestov.
USING: arrays gml.runtime kernel math.matrices
math.matrices.extras math.trig math.vectors.simd.cords   ;
IN: gml.geometry

GML: rot_vec ( v n alpha -- v )
    ! Inefficient!
    deg>rad <rotation-matrix4> swap >array mdotv >double-4 ;
