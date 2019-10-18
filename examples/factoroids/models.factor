USING: arrays gadgets generic hashtables io kernel math
namespaces opengl sdl sequences threads ;
IN: factoroids

TUPLE: face color normal polygon ;

: draw-face ( colors face -- )
    [ face-color swap nth gl-color ] keep
    ( dup face-normal gl-normal )
    face-polygon gl-fill-poly ;

TUPLE: model faces ;

: draw-model ( colors model -- )
    model-faces [ draw-face ] each-with ;

: cube
    T{ model f
        {
            T{ face f
                0
                { 0 0 -1 }
                {
                    { -1/2 -1/2 -1/2 }
                    { 1/2 -1/2 -1/2 }
                    { 1/2 1/2 -1/2 }
                    { -1/2 1/2 -1/2 }
                }
            }
            
            T{ face f
                0
                { 0 0 1 }
                {
                    { -1/2 -1/2 1/2 }
                    { 1/2 -1/2 1/2 }
                    { 1/2 1/2 1/2 }
                    { -1/2 1/2 1/2 }
                }
            }
            
            T{ face f
                0
                { -1 0 0 }
                {
                    { -1/2 -1/2 -1/2 }
                    { -1/2 -1/2 1/2 }
                    { -1/2 1/2 1/2 }
                    { -1/2 1/2 -1/2 }
                }
            }
            
            T{ face f
                0
                { 1 0 0 }
                {
                    { 1/2 -1/2 -1/2 }
                    { 1/2 -1/2 1/2 }
                    { 1/2 1/2 1/2 }
                    { 1/2 1/2 -1/2 }
                }
            }
            
            T{ face f
                0
                { 0 -1 0 }
                {
                    { -1/2 -1/2 -1/2 }
                    { -1/2 -1/2 1/2 }
                    { 1/2 -1/2 1/2 }
                    { 1/2 -1/2 -1/2 }
                }
            }
            
            T{ face f
                0
                { 0 1 0 }
                {
                    { -1/2 1/2 -1/2 }
                    { -1/2 1/2 1/2 }
                    { 1/2 1/2 1/2 }
                    { 1/2 1/2 -1/2 }
                }
            }
        }
    } ;

: factoroid
    T{ model f
        {
            T{ face f
                1
                f
                {
                    { -1/3 1/2 -1/2 }
                    { 1/3 1/2 -1/2 }
                    { 1/2 -1/2 -1/2 }
                    { -1/2 -1/2 -1/2 }
                }
            }
            
            T{ face f
                0
                f
                {
                    { -1/3 1/2 -1/2 }
                    { -1/2 -1/2 -1/2 }
                    { 0 -1/2 1/2 }
                }
            }
            
            T{ face f
                0
                f
                {
                    { 1/3 1/2 -1/2 }
                    { 1/2 -1/2 -1/2 }
                    { 0 -1/2 1/2 }
                }
            }
            
            T{ face f
                0
                f
                {
                    { -1/3 1/2 -1/2 }
                    { 1/3 1/2 -1/2 }
                    { 0 -1/2 1/2 }
                }
            }
            
            T{ face f
                0
                f
                {
                    { -1/2 -1/2 -1/2 }
                    { -1/2 -1/2 -1/2 }
                    { 0 -1/2 1/2 }
                }
            }
        }
    } ;
