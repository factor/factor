! Copyright (C) 2005, 2006 Eduardo Cavazos and Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
!
! based on glx.h from xfree86, and some of glxtokens.h
USING: alien.c-types alien.syntax kernel namespaces
specialized-arrays x11 x11.X x11.syntax x11.xlib ;
SPECIALIZED-ARRAY: int
IN: x11.glx

LIBRARY: glx

! Visual Config Attributes (glXGetConfig, glXGetFBConfigAttrib)
CONSTANT: GLX_USE_GL 1 ! support GLX rendering
CONSTANT: GLX_BUFFER_SIZE 2 ! depth of the color buffer
CONSTANT: GLX_LEVEL 3 ! level in plane stacking
CONSTANT: GLX_RGBA 4 ! true if RGBA mode
CONSTANT: GLX_DOUBLEBUFFER 5 ! double buffering supported
CONSTANT: GLX_STEREO 6 ! stereo buffering supported
CONSTANT: GLX_AUX_BUFFERS 7 ! number of aux buffers
CONSTANT: GLX_RED_SIZE 8 ! number of red component bits
CONSTANT: GLX_GREEN_SIZE 9 ! number of green component bits
CONSTANT: GLX_BLUE_SIZE 10 ! number of blue component bits
CONSTANT: GLX_ALPHA_SIZE 11 ! number of alpha component bits
CONSTANT: GLX_DEPTH_SIZE 12 ! number of depth bits
CONSTANT: GLX_STENCIL_SIZE 13 ! number of stencil bits
CONSTANT: GLX_ACCUM_RED_SIZE 14 ! number of red accum bits
CONSTANT: GLX_ACCUM_GREEN_SIZE 15 ! number of green accum bits
CONSTANT: GLX_ACCUM_BLUE_SIZE 16 ! number of blue accum bits
CONSTANT: GLX_ACCUM_ALPHA_SIZE 17 ! number of alpha accum bits

TYPEDEF: XID GLXContextID
TYPEDEF: XID GLXPixmap
TYPEDEF: XID GLXDrawable
TYPEDEF: XID GLXPbuffer
TYPEDEF: XID GLXWindow
TYPEDEF: XID GLXFBConfigID
TYPEDEF: void* GLXContext  ! typedef struct __GLXcontextRec *GLXContext;
TYPEDEF: void* GLXFBConfig ! typedef struct __GLXFBConfigRec *GLXFBConfig;

X-FUNCTION: XVisualInfo* glXChooseVisual ( Display* dpy, int screen, int* attribList )
X-FUNCTION: void glXCopyContext ( Display* dpy, GLXContext src, GLXContext dst, ulong mask )
X-FUNCTION: GLXContext glXCreateContext ( Display* dpy, XVisualInfo* vis, GLXContext shareList, bool direct )
X-FUNCTION: GLXPixmap glXCreateGLXPixmap ( Display* dpy, XVisualInfo* vis, Pixmap pixmap )
X-FUNCTION: void glXDestroyContext ( Display* dpy, GLXContext ctx )
X-FUNCTION: void glXDestroyGLXPixmap ( Display* dpy, GLXPixmap pix )
X-FUNCTION: int glXGetConfig ( Display* dpy, XVisualInfo* vis, int attrib, int* value )
X-FUNCTION: GLXContext glXGetCurrentContext ( )
X-FUNCTION: GLXDrawable glXGetCurrentDrawable ( )
X-FUNCTION: bool glXIsDirect ( Display* dpy, GLXContext ctx )
X-FUNCTION: bool glXMakeCurrent ( Display* dpy, GLXDrawable drawable, GLXContext ctx )
X-FUNCTION: bool glXQueryExtension ( Display* dpy, int* errorBase, int* eventBase )
X-FUNCTION: bool glXQueryVersion ( Display* dpy, int* major, int* minor )
X-FUNCTION: void glXSwapBuffers ( Display* dpy, GLXDrawable drawable )
X-FUNCTION: void glXUseXFont ( Font font, int first, int count, int listBase )
X-FUNCTION: void glXWaitGL ( )
X-FUNCTION: void glXWaitX ( )
X-FUNCTION: c-string glXGetClientString ( Display* dpy, int name )
X-FUNCTION: c-string glXQueryServerString ( Display* dpy, int screen, int name )
X-FUNCTION: c-string glXQueryExtensionsString ( Display* dpy, int screen )

! New for GLX 1.3
X-FUNCTION: GLXFBConfig* glXGetFBConfigs ( Display* dpy, int screen, int* nelements )
X-FUNCTION: GLXFBConfig* glXChooseFBConfig ( Display* dpy, int screen, int* attrib_list, int* nelements )
X-FUNCTION: int glXGetFBConfigAttrib ( Display* dpy, GLXFBConfig config, int attribute, int* value )
X-FUNCTION: XVisualInfo* glXGetVisualFromFBConfig ( Display* dpy, GLXFBConfig config )
X-FUNCTION: GLXWindow glXCreateWindow ( Display* dpy, GLXFBConfig config, Window win, int* attrib_list )
X-FUNCTION: void glXDestroyWindow ( Display* dpy, GLXWindow win )
X-FUNCTION: GLXPixmap glXCreatePixmap ( Display* dpy, GLXFBConfig config, Pixmap pixmap, int* attrib_list )
X-FUNCTION: void glXDestroyPixmap ( Display* dpy, GLXPixmap pixmap )
X-FUNCTION: GLXPbuffer glXCreatePbuffer ( Display* dpy, GLXFBConfig config, int* attrib_list )
X-FUNCTION: void glXDestroyPbuffer ( Display* dpy, GLXPbuffer pbuf )
X-FUNCTION: void glXQueryDrawable ( Display* dpy, GLXDrawable draw, int attribute, uint* value )
X-FUNCTION: GLXContext glXCreateNewContext ( Display* dpy, GLXFBConfig config, int render_type, GLXContext share_list, bool direct )
X-FUNCTION: bool glXMakeContextCurrent ( Display* display, GLXDrawable draw, GLXDrawable read, GLXContext ctx )
X-FUNCTION: GLXDrawable glXGetCurrentReadDrawable ( )
X-FUNCTION: Display*  glXGetCurrentDisplay ( )
X-FUNCTION: int glXQueryContext ( Display* dpy, GLXContext ctx, int attribute, int* value )
X-FUNCTION: void glXSelectEvent ( Display* dpy, GLXDrawable draw, ulong event_mask )
X-FUNCTION: void glXGetSelectedEvent ( Display* dpy, GLXDrawable draw, ulong* event_mask )

! GLX 1.4 and later
X-FUNCTION: void* glXGetProcAddress ( c-string procname )

! GLX_ARB_get_proc_address extension
X-FUNCTION: void* glXGetProcAddressARB ( c-string procname )

! GLX_ARB_multisample
CONSTANT: GLX_SAMPLE_BUFFERS 100000
CONSTANT: GLX_SAMPLES 100001

! GLX_ARB_fbconfig_float
CONSTANT: GLX_RGBA_FLOAT_TYPE 0x20B9
CONSTANT: GLX_RGBA_FLOAT_BIT  0x0004

! GLX Events
! (also skipped for now. only has GLXPbufferClobberEvent, the rest is handled by xlib methinks)

: create-glx ( XVisualInfo* -- GLXContext )
    [ dpy get ] dip f 1 glXCreateContext
    [ "Failed to create GLX context" throw ] unless* ;

: destroy-glx ( GLXContext -- )
    dpy get swap glXDestroyContext ;
