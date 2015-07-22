! Copyright (C) 2010 Slava Pestov.
USING: arrays kernel math.matrices math.vectors.simd.cords
math.trig gml.runtime ;
IN: gml.geometry

GML: rot_vec ( v n alpha -- v )
    ! Inefficient!
    deg>rad rotation-matrix4 swap >array m.v >double-4 ;
