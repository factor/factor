
#include <X11/Xlib.h>
#include <X11/Xutil.h>

int SimpleErrorHandler ( Display* dpy, XErrorEvent* event ) {
  char msg[255];
  printf ( "X11 : SimpleErrorHandler called!!!\n\n" ) ;
  XGetErrorText ( dpy, event->error_code, msg, sizeof msg ) ;
  printf ( "X error (%#lx): %s", event->resourceid, msg ) ;
  return 0 ;
}

void SetSimpleErrorHandler() { XSetErrorHandler( SimpleErrorHandler ) ; }
