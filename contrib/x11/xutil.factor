! from Xutil.h, incomplete
IN: x11
USING: alien ;

LIBRARY: X11

BEGIN-STRUCT: XSizeHints
    FIELD: long flags	! marks which fields in this structure are defined
    FIELD: int x	! obsolete for new window mgrs, but clients
    FIELD: int y	! should set so old wm's don't mess up
    FIELD: int width	
    FIELD: int height
    FIELD: int min_width
    FIELD: int min_height
    FIELD: int max_width
    FIELD: int max_height
    FIELD: int width_inc
    FIELD: int height_inc
    ! struct {
    ! 	int x;	/* numerator */
    ! 	int y;	/* denominator */
    ! } min_aspect, max_aspect;
    FIELD: int min_aspect_x
    FIELD: int min_aspect_y
    FIELD: int max_aspect_x
    FIELD: int max_aspect_y
    FIELD: int base_width	! added by ICCCM version 1
    FIELD: int base_height
    FIELD: int win_gravity;	! added by ICCCM version 1
END-STRUCT

FUNCTION: int XSetStandardProperties ( Display* display, Window w, char* window_name, char* icon_name, Pixmap icon_pixmap, char** argv, int argc, XSizeHints* hints ) ;

! Information used by the visual utility routines to find desired visual
! type from the many visuals a display may support.

BEGIN-STRUCT: XVisualInfo
    FIELD: Visual* visual
    FIELD: VisualID visualid
    FIELD: int screen
    FIELD: int depth
! #if defined(__cplusplus) || defined(c_plusplus)
!   int c_class;					/* C++ */
! #else
    FIELD: int class
! #endif
    FIELD: ulong red_mask
    FIELD: ulong green_mask
    FIELD: ulong blue_mask
    FIELD: int colormap_size
    FIELD: int bits_per_rgb
END-STRUCT

BEGIN-STRUCT: XComposeStatus
    FIELD: XPointer compose_ptr ! state table pointer
    FIELD: int chars_matched    ! match state
END-STRUCT

