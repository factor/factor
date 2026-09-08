USING: accessors arrays boids.simulation kernel sequences tools.test ;

{ { 600 700 } } [ { 600 700 } { 1024 768 } wrap-pos-in ] unit-test
{ { 176 132 } } [ { 1200 900 } { 1024 768 } wrap-pos-in ] unit-test
{ { 1023 767 } } [ { -2049 -1537 } { 1024 768 } wrap-pos-in ] unit-test
{ { 0 0 } } [ { 10 20 } { 0 0 } wrap-pos-in ] unit-test
{ { 88 188 } } [ { 600 700 } wrap-pos ] unit-test

! The same flock moves into the expanded area, then wraps after shrinking.
{ { 603.0 600.0 } { 91.0 88.0 } } [
    { 598.0 600.0 } { 1.0 0.0 } <boid> 1array
    { } 5 { 1024 768 } simulate-in
    dup first pos>> swap
    { } 0 { 256 256 } simulate-in first pos>>
] unit-test

{ 10 t } [
    10 { 1 1 } random-boids-in
    [ length ] [ [ pos>> { 0 0 } = ] all? ] bi
] unit-test
