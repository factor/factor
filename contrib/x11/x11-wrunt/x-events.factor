IN: x11
USING: alien kernel sequences namespaces strings syntax math generic parser ;

: x-event-type
    #! XEvent is a union of the various X*Event structs. All of them have
    #! 'int type' as their first field.
    0 alien-signed-4 ;

PREDICATE: integer upper
    dup CHAR: A >= swap CHAR: Z <= and ;
 
: uncapitalise ( "Capitalised" | "capitalised" -- "capitalised" )
    dup first ch>lower swap >sbuf 0 swap [ set-nth ] keep >string ;

GENERIC: (camel>dashed)
M: upper (camel>dashed) ( CHAR: X -- )
    CHAR: - , ch>lower , ;
M: object (camel>dashed) ( CHAR: x -- ) , ;

: camel>dashed ( "SomeName" -- "some-name" )
    uncapitalise [ [ (camel>dashed) ] each ] "" make ;

: x-event-predicate ( EventName -- )
    #! creates a predicate for x-event-name-event
    #! EventName should be a valid XEvent.type (defined in x.factor)
    #! note: c structs are represented as byte-arrays in factor
    [ "IN: x11 PREDICATE: byte-array x-" % dup camel>dashed % "-event x-event-type " %
      % " = ;" % ] "" make eval ;

[
    "KeyPress" "KeyRelease" "ButtonPress" "ButtonRelease" "MotionNotify"
    "EnterNotify" "LeaveNotify" "FocusIn" "FocusOut" "KeymapNotify"
    "Expose" "GraphicsExpose" "NoExpose" "VisibilityNotify" "CreateNotify"
    "DestroyNotify" "UnmapNotify" "MapNotify" "MapRequest" "ReparentNotify"
    "ConfigureNotify" "ConfigureRequest" "GravityNotify" "ResizeRequest"
    "CirculateNotify" "CirculateRequest" "PropertyNotify" "SelectionClear"
    "SelectionRequest" "SelectionNotify" "ColormapNotify" "ClientMessage"
    "MappingNotify"
] [ x-event-predicate ] each

