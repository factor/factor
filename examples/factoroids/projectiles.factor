USING: arrays gadgets generic hashtables io kernel math
namespaces opengl prettyprint sdl sequences threads ;
IN: factoroids

: add-expiring-actor ( actor time-to-live -- )
    millis + over set-actor-expiry add-actor ;

TUPLE: projectile owner ;

C: projectile ( actor owner -- projectile )
    [ set-projectile-owner ] keep
    [ set-delegate ] keep
    projectile-priority over set-actor-priority ;

M: projectile can-collide* ( actor actor -- ? )
    over projectile? >r projectile-owner eq? r> or not ;

: rocket
    T{ model f
        {
            T{ face f
                0
                { 0 -1 0 }
                {
                    { -1/2 0 -1/2 }
                    { 0 1/2 -1/2 }
                    { 1/2 0 -1/2 }
                    { 0 -1/2 -1/2 }
                }
            }
            
            T{ face f
                1
                f
                {
                    { -1/2 0 -1/2 }
                    { 0 1/2 -1/2 }
                    { 0 0 1/2 }
                }
            }
            
            T{ face f
                1
                f
                {
                    { 0 1/2 -1/2 }
                    { 1/2 0 -1/2 }
                    { 0 0 1/2 }
                }
            }
            
            T{ face f
                1
                f
                {
                    { 1/2 0 -1/2 }
                    { 0 -1/2 -1/2 }
                    { 0 0 1/2 }
                }
            }
            
            T{ face f
                1
                f
                {
                    { 0 -1/2 -1/2 }
                    { -1/2 0 -1/2 }
                    { 0 0 1/2 }
                }
            }
        }
    } ;

: <rocket> ( position angle owner -- rocket )
    >r >r >r rocket { { 1 1 0 1 } { 1 1 1 1 } } r> r> { 1/2 1/2 5 }
    <actor> r> <projectile> 1/2000 over set-body-acceleration ;

: spawn-rocket ( position angle owner -- )
    <rocket> 1000 add-expiring-actor ;
