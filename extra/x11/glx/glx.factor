! Copyright (C) 2005, 2006 Eduardo Cavazos and Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
!
! based on glx.h from xfree86, and some of glxtokens.h
USING: alien alien.c-types alien.syntax x11.xlib
namespaces kernel sequences ;
IN: x11.glx

LIBRARY: glx

! Visual Config Attributes (glXGetConfig, glXGetFBConfigAttrib)
: GLX_USE_GL		1  ; ! support GLX rendering
: GLX_BUFFER_SIZE	2  ; ! depth of the color buffer
: GLX_LEVEL		3  ; ! level in plane stacking
: GLX_RGBA		4  ; ! true if RGBA mode
: GLX_DOUBLEBUFFER	5  ; ! double buffering supported
: GLX_STEREO		6  ; ! stereo buffering supported
: GLX_AUX_BUFFERS	7  ; ! number of aux buffers
: GLX_RED_SIZE		8  ; ! number of red component bits
: GLX_GREEN_SIZE	9  ; ! number of green component bits
: GLX_BLUE_SIZE		10 ; ! number of blue component bits
: GLX_ALPHA_SIZE	11 ; ! number of alpha component bits
: GLX_DEPTH_SIZE	12 ; ! number of depth bits
: GLX_STENCIL_SIZE	13 ; ! number of stencil bits
: GLX_ACCUM_RED_SIZE	14 ; ! number of red accum bits
: GLX_ACCUM_GREEN_SIZE	15 ; ! number of green accum bits
: GLX_ACCUM_BLUE_SIZE	16 ; ! number of blue accum bits
: GLX_ACCUM_ALPHA_SIZE	17 ; ! number of alpha accum bits

TYPEDEF: XID GLXContextID
TYPEDEF: XID GLXPixmap
TYPEDEF: XID GLXDrawable
TYPEDEF: XID GLXPbuffer
TYPEDEF: XID GLXWindow
TYPEDEF: XID GLXFBConfigID
TYPEDEF: void* GLXContext  ! typedef struct __GLXcontextRec *GLXContext;
TYPEDEF: void* GLXFBConfig ! typedef struct __GLXFBConfigRec *GLXFBConfig;

FUNCTION: XVisualInfo* glXChooseVisual ( Display* dpy, int screen, int* attribList ) ;
FUNCTION: void glXCopyContext ( Display* dpy, GLXContext src, GLXContext dst, ulong mask ) ;
FUNCTION: GLXContext glXCreateContext ( Display* dpy, XVisualInfo* vis, GLXContext shareList, bool direct ) ;
FUNCTION: GLXPixmap glXCreateGLXPixmap ( Display* dpy, XVisualInfo* vis, Pixmap pixmap ) ;
FUNCTION: void glXDestroyContext ( Display* dpy, GLXContext ctx ) ;
FUNCTION: void glXDestroyGLXPixmap ( Display* dpy, GLXPixmap pix ) ;
FUNCTION: int glXGetConfig ( Display* dpy, XVisualInfo* vis, int attrib, int* value) ;
FUNCTION: GLXContext glXGetCurrentContext ( ) ;
FUNCTION: GLXDrawable glXGetCurrentDrawable ( ) ;
FUNCTION: bool glXIsDirect ( Display* dpy, GLXContext ctx ) ;
FUNCTION: bool glXMakeCurrent ( Display* dpy, GLXDrawable drawable, GLXContext ctx ) ;
FUNCTION: bool glXQueryExtension ( Display* dpy, int* errorBase, int* eventBase ) ;
FUNCTION: bool glXQueryVersion ( Display* dpy, int* major, int* minor ) ;
FUNCTION: void glXSwapBuffers ( Display* dpy, GLXDrawable drawable ) ;
FUNCTION: void glXUseXFont ( Font font, int first, int count, int listBase ) ;
FUNCTION: void glXWaitGL ( ) ;
FUNCTION: void glXWaitX ( ) ;
FUNCTION: char* glXGetClientString ( Display* dpy, int name ) ;
FUNCTION: char* glXQueryServerString ( Display* dpy, int screen, int name ) ;
FUNCTION: char* glXQueryExtensionsString ( Display* dpy, int screen ) ;

! New for GLX 1.3
FUNCTION: GLXFBConfig* glXGetFBConfigs ( Display* dpy, int screen, int* nelements ) ;
FUNCTION: GLXFBConfig* glXChooseFBConfig ( Display* dpy, int screen, int* attrib_list, int* nelements ) ;
FUNCTION: int glXGetFBConfigAttrib ( Display* dpy, GLXFBConfig config, int attribute, int* value ) ;
FUNCTION: XVisualInfo* glXGetVisualFromFBConfig ( Display* dpy, GLXFBConfig config ) ;
FUNCTION: GLXWindow glXCreateWindow ( Display* dpy, GLXFBConfig config, Window win, int* attrib_list ) ;
FUNCTION: void glXDestroyWindow ( Display* dpy, GLXWindow win ) ;
FUNCTION: GLXPixmap glXCreatePixmap ( Display* dpy, GLXFBConfig config, Pixmap pixmap, int* attrib_list ) ;
FUNCTION: void glXDestroyPixmap ( Display* dpy, GLXPixmap pixmap ) ;
FUNCTION: GLXPbuffer glXCreatePbuffer ( Display* dpy, GLXFBConfig config, int* attrib_list ) ;
FUNCTION: void glXDestroyPbuffer ( Display* dpy, GLXPbuffer pbuf ) ;
FUNCTION: void glXQueryDrawable ( Display* dpy, GLXDrawable draw, int attribute, uint* value ) ;
FUNCTION: GLXContext glXCreateNewContext ( Display* dpy, GLXFBConfig config, int render_type, GLXContext share_list, bool direct ) ;
FUNCTION: bool glXMakeContextCurrent ( Display* display, GLXDrawable draw, GLXDrawable read, GLXContext ctx ) ;
FUNCTION: GLXDrawable glXGetCurrentReadDrawable ( ) ;
FUNCTION: Display*  glXGetCurrentDisplay ( ) ;
FUNCTION: int glXQueryContext ( Display* dpy, GLXContext ctx, int attribute, int* value ) ;
FUNCTION: void glXSelectEvent ( Display* dpy, GLXDrawable draw, ulong event_mask ) ;
FUNCTION: void glXGetSelectedEvent ( Display* dpy, GLXDrawable draw, ulong* event_mask ) ;

! GLX 1.4 and later
FUNCTION: void* glXGetProcAddress ( char* procname ) ;

! GLX Events
! (also skipped for now. only has GLXPbufferClobberEvent, the rest is handled by xlib methinks

: choose-visual ( -- XVisualInfo* )
    dpy get scr get
    [
        GLX_RGBA ,
        GLX_DOUBLEBUFFER ,
        GLX_DEPTH_SIZE , 16 ,
        0 ,
    ] { } make >c-int-array
    glXChooseVisual
    [ "Could not get a double-buffered GLX RGBA visual" throw ] unless* ;

: create-glx ( XVisualInfo* -- GLXContext )
    >r dpy get r> f 1 glXCreateContext
    [ "Failed to create GLX context" throw ] unless* ;

: destroy-glx ( GLXContext -- )
    dpy get swap glXDestroyContext ;