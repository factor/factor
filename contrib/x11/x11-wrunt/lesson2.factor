IN: nehe
USING: opengl x11 syntax kernel sequences alien namespaces math threads generic io prettyprint ;

TUPLE: gl-window dpy screen win ctx x y width height depth ;
SYMBOL: current-window

SYMBOL: dpy
SYMBOL: screen
SYMBOL: root
SYMBOL: win
SYMBOL: ctx
SYMBOL: title
SYMBOL: vi
SYMBOL: x
SYMBOL: y
SYMBOL: width
SYMBOL: height

: >int-array ( seq -- int-array )
    dup length dup <int-array> -rot [
	pick set-int-nth
    ] 2each ;

: attr-list ( -- c-array )
    [
        GLX_RGBA , GLX_DOUBLEBUFFER ,
        GLX_RED_SIZE , 4 ,
        GLX_GREEN_SIZE , 4 ,
        GLX_BLUE_SIZE , 4 ,
        GLX_DEPTH_SIZE , 16 ,
        None ,
    ] f make >int-array ;

: resize-gl-scene ( glwin -- )
    0 0 rot [ gl-window-width ] keep [ gl-window-height ] keep >r glViewport
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    45 r> [ gl-window-width ] keep gl-window-height / 0.1 100 gluPerspective
    GL_MODELVIEW glMatrixMode ;

: gl-init ( glwin -- )
    GL_SMOOTH glShadeModel
    0 0 0 0 glClearColor
    1 glClearDepth
    GL_DEPTH_TEST glEnable
    GL_LEQUAL glDepthFunc
    GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST glHint
    resize-gl-scene
    glFlush ;

: normal-XSetWindowAttributes ( cmap -- valuemask attr )
    <XSetWindowAttributes> [
	set-XSetWindowAttributes-colormap
    ] keep
    ExposureMask KeyPressMask bitor ButtonPressMask bitor StructureNotifyMask bitor
    over set-XSetWindowAttributes-event_mask
!    dup 1 <int> swap set-XSetWindowAttributes-border_pixel
    CWColormap CWEventMask bitor swap ;
!    CWBorderPixel CWColormap bitor CWEventMask bitor swap ;

: make-display ( display-num -- display )
    XOpenDisplay dup dpy set ;

: make-screen ( display -- screen )
    XDefaultScreen dup screen set ;

: make-vi ( display screen -- vi )
    attr-list glXChooseVisual dup vi set ;

: make-ctx ( display vi -- )
    0 <alien> GL_TRUE glXCreateContext ctx set ;

: make-colormap ( -- cmap )
    dpy get vi get 2dup XVisualInfo-screen XRootWindow dup root set
    swap XVisualInfo-visual AllocNone XCreateColormap ;

: make-win ( valuemask attr -- win )
    >r >r dpy get root get x get y get width get height get 0 vi get
    dup XVisualInfo-depth InputOutput rot XVisualInfo-visual r> r> XCreateWindow dup win set ;

: make-gl-window ( display-num x y width height depth title -- glwin )
    [
        title set depth set height set width set y set x set
        make-display dup dup make-screen make-vi make-ctx
        make-colormap normal-XSetWindowAttributes make-win
        dpy get swap 2dup over "WM_DELETE_WINDOW" t XInternAtom <int> 1 XSetWMProtocols drop
        2dup title get dup None 0 <alien> 0 over XSetStandardProperties drop
        2dup XMapRaised drop
        2dup ctx get glXMakeCurrent 2drop
        screen get win get ctx get x get y get width get height get depth get <gl-window>
        dup gl-init
	dup global [ current-window set ] bind
    ] with-scope ;

: draw-gl-scene ( -- )
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    glLoadIdentity
    -1.5 0 -6 glTranslatef
    GL_TRIANGLES [
	0 1 0 glVertex3f
	-1 -1 0 glVertex3f
	1 -1 0 glVertex3f
    ] do-state
    3 0 0 glTranslatef
    GL_QUADS [
        -1 1 1 glVertex3f
	1 1 0 glVertex3f
	1 -1 0 glVertex3f
	-1 -1 0 glVertex3f
    ] do-state
    current-window get dup gl-window-dpy swap gl-window-win glXSwapBuffers ;

: kill-gl-window ( glwin -- )
    dup gl-window-ctx [
	over gl-window-dpy dup None 0 <alien> glXMakeCurrent drop
        swap glXDestroyContext
	0 over set-gl-window-ctx
    ] when*
    gl-window-dpy XCloseDisplay ;

GENERIC: (handle-event) ( glwin xevent -- continue? )

M: x-expose-event (handle-event)
    nip XExposeEvent-count 0 = [ draw-gl-scene ] when t ;

M: x-configure-notify-event (handle-event)
    #! resize if the width or height has changed
    [ XConfigureEvent-width swap gl-window-width = ] 2keep
    [ XConfigureEvent-height swap gl-window-height = and ] 2keep rot [
	2drop
    ] [
        [ XConfigureEvent-width swap set-gl-window-width ] 2keep
	[ XConfigureEvent-height swap set-gl-window-height ] 2keep
	drop resize-gl-scene
    ] if t ;

M: x-button-press-event (handle-event)
    #! quit if a mouse button is pressed
    2drop f ;

PREDICATE: x-key-press-event quit-key-event
!    0 XLookupKeysym XK_Escape = ;
    0 XLookupKeysym dup CHAR: q = swap XK_Escape = or ;

M: quit-key-event (handle-event)
    2drop f ;

M: x-client-message-event (handle-event)
    swap gl-window-dpy swap XClientMessageEvent-message_type XGetAtomName
    "WM_PROTOCOLS" = not ;

M: object (handle-event)
    #! unknown event, ignore and continue
    2drop t ;

: handle-event ( glwin -- continue? )
    ! TODO: don't create a new XEvent object each time (but don't use a global)
    dup gl-window-dpy <XEvent> tuck XNextEvent drop (handle-event) ;

: (loop) ( glwin -- continue? )
    dup gl-window-dpy XPending 0 > [
	dup handle-event [ (loop) ] [ drop f ] if
    ] [ drop t ] if ;

: loop ( glwin -- )
    dup (loop) [ draw-gl-scene loop ] [ drop ] if ;

: main ( -- )
    ":0.0" 10 10 640 480 16 "NeHe Lesson 2" make-gl-window
    dup loop kill-gl-window ;
