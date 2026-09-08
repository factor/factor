! Run under Xvfb; exercises the native GTK3 resize callback and gadget layout.
USING: accessors arrays boids boids.simulation bubble-chamber calendar
continuations debugger io kernel locals math namespaces prettyprint
sequences system threads ui ui.backend.gtk3 ui.gadgets.worlds ;
FROM: boids => iterate-system ;
IN: linux-issues.resize

:: check-resize ( gadget size title -- )
    gadget title open-window* :> window
    500 milliseconds sleep
    window size resize-window
    500 milliseconds sleep
    window dim>> [ >integer ] map size assert=
    gadget dim>> [ >integer ] map size assert=
    title print gadget dim>> . ;

:: check-demos ( -- )
    <boids-gadget> :> flock
    flock { 1024 768 } "Boids resize" check-resize
    flock { } >>behaviors
    { 598.0 600.0 } { 1.0 0.0 } <boid> 1array >>boids
    dup iterate-system boids>> first pos>> { 603.0 600.0 } assert=

    <bubble-chamber> :> chamber
    chamber { 1200 800 } "Bubble chamber resize" check-resize
    <quark> chamber >>bubble-chamber center
    [ >integer ] map { 600 400 } assert=
    "GTK3 resize and simulation bounds passed" print
    0 exit ;

[ [ [ check-demos ] [ print-error 1 exit ] recover ] in-thread ] with-ui
