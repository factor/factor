! Cairo stuff
!
! To run this code, bootstrap Factor like so:
!
! ./f boot.image.le32
!     -libraries:sdl:name=libSDL.so
!     -libraries:sdl-gfx:name=libSDL_gfx
!     -libraries:cairo:name=libcairo
!
! (But all on one line)
!

IN: cairo
USING: hashtables ;
USE: compiler
USE: alien
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: sdl
USE: vectors
USE: prettyprint
USE: io
USE: test
USE: syntax
USE: sequences

! cairo_status_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_STATUS_SUCCESS
	ENUM:	CAIRO_STATUS_NO_MEMORY
	ENUM:	CAIRO_STATUS_INVALID_RESTORE
	ENUM:	CAIRO_STATUS_INVALID_POP_GROUP
	ENUM:	CAIRO_STATUS_NO_CURRENT_POINT
	ENUM:	CAIRO_STATUS_INVALID_MATRIX
	ENUM:	CAIRO_STATUS_NO_TARGET_SURFACE
	ENUM:	CAIRO_STATUS_NULL_POINTER
	ENUM:	CAIRO_STATUS_INVALID_STRING
END-ENUM

! cairo_operator_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_OPERATOR_CLEAR
	ENUM:	CAIRO_OPERATOR_SRC
	ENUM:	CAIRO_OPERATOR_DST
	ENUM:	CAIRO_OPERATOR_OVER
	ENUM:	CAIRO_OPERATOR_OVER_REVERSE
	ENUM:	CAIRO_OPERATOR_IN
	ENUM:	CAIRO_OPERATOR_IN_REVERSE
	ENUM:	CAIRO_OPERATOR_OUT
	ENUM:	CAIRO_OPERATOR_OUT_REVERSE
	ENUM:	CAIRO_OPERATOR_ATOP
	ENUM:	CAIRO_OPERATOR_ATOP_REVERSE
	ENUM:	CAIRO_OPERATOR_XOR
	ENUM:	CAIRO_OPERATOR_ADD
	ENUM:	CAIRO_OPERATOR_SATURATE
END-ENUM

! cairo_line_cap_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_LINE_CAP_BUTT
	ENUM:	CAIRO_LINE_CAP_ROUND
	ENUM:	CAIRO_LINE_CAP_SQUARE
END-ENUM

! cair_line_join_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_LINE_JOIN_MITER
	ENUM:	CAIRO_LINE_JOIN_ROUND
	ENUM:	CAIRO_LINE_JOIN_BEVEL
END-ENUM

! cairo_fill_rule_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_FILL_RULE_WINDING
	ENUM:	CAIRO_FILL_RULE_EVEN_ODD
END-ENUM

! cairo_font_slant_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_FONT_SLANT_NORMAL
	ENUM:	CAIRO_FONT_SLANT_ITALIC
	ENUM:	CAIRO_FONT_SLANT_OBLIQUE
END-ENUM

! cairo_font_weight_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_FONT_WEIGHT_NORMAL
	ENUM:	CAIRO_FONT_WEIGHT_BOLD
END-ENUM

BEGIN-STRUCT: cairo_font_t
	FIELD:	int					refcount
	FIELD:	uint				scale
	FIELD:	void*				backend			! cairo_font_backend*
END-STRUCT

BEGIN-STRUCT: cairo_rectangle_t
	FIELD:	short				x
	FIELD:	short				y
	FIELD:	ushort				width
	FIELD:	ushort				height
END-STRUCT

BEGIN-STRUCT: cairo_clip_rec_t
	FIELD:	cairo_rectangle_t	rect
	FIELD:	void*				region
	FIELD:	void*				surface
END-STRUCT

BEGIN-STRUCT: cairo_matrix_t
	FIELD:	void*				m
END-STRUCT

BEGIN-STRUCT: cairo_gstate_t
	FIELD:	uint				operator		! cairo_operator_t
	FIELD:	double				tolerance
	FIELD:	double				line_width
	FIELD:	uint				line_cap		! cairo_line_cap_t
	FIELD:	uint				line_join		! cairo_line_join_t
	FIELD:	double				miter_limit
	FIELD:	uint				fill_rule		! cairo_fill_rule_t
	FIELD:	void*				dash			! double*
	FIELD:	int					num_dashes
	FIELD:	double 				dash_offset
	FIELD:	char*				font_family 
	FIELD:	uint				font_slant 		! cairo_font_slant_t
	FIELD:	uint				font_weight		! cairo_font_weight_t
	FIELD:	void*				font			! cairo_font_t*
	FIELD:	void*				surface			! cairo_surface_t*
	FIELD:	void*				pattern			! cairo_pattern_t*
	FIELD:	double				alpha
	FIELD:	cairo_clip_rec_t	clip
	FIELD:	double				pixels_per_inch
	FIELD:	cairo_matrix_t		font_matrix
	FIELD:	cairo_matrix_t		ctm
	FIELD:	cairo_matrix_t		ctm_inverse
	FIELD:	void*				path			! cairo_path_t
	FIELD:	void*				pen_regular		! cairo_pen_t
	FIELD:	void*				next			! cairo_gstate*
END-STRUCT

BEGIN-STRUCT: cairo_t
	FIELD:	uint			ref_count
	FIELD:	cairo_gstate_t*	gstate
	FIELD:	uint			status	! cairo_status_t
END-STRUCT

! cairo_format_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_FORMAT_ARGB32
	ENUM:	CAIRO_FORMAT_RGB24
	ENUM:	CAIRO_FORMAT_A8
	ENUM:	CAIRO_FORMAT_A1
END-ENUM

! cairo_antialias_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_ANTIALIAS_DEFAULT
	ENUM:	CAIRO_ANTIALIAS_NONE
	ENUM:	CAIRO_ANTIALIAS_GRAY
	ENUM:	CAIRO_ANTIALIAS_SUBPIXEL
END-ENUM

! cairo_subpixel_order_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_SUBPIXEL_ORDER_DEFAULT
	ENUM:	CAIRO_SUBPIXEL_ORDER_RGB
	ENUM:	CAIRO_SUBPIXEL_ORDER_BGR
	ENUM:	CAIRO_SUBPIXEL_ORDER_VRGB
	ENUM:	CAIRO_SUBPIXEL_ORDER_VBGR
END-ENUM

! cairo_hint_style_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_HINT_STYLE_DEFAULT
	ENUM:	CAIRO_HINT_STYLE_NONE
	ENUM:	CAIRO_HINT_STYLE_SLIGHT
	ENUM:	CAIRO_HINT_STYLE_MEDIUM
	ENUM:	CAIRO_HINT_STYLE_FULL
END-ENUM

! cairo_hint_metrics_t
BEGIN-ENUM: 0
	ENUM:	CAIRO_HINT_METRICS_DEFAULT
	ENUM:	CAIRO_HINT_METRICS_OFF
	ENUM:	CAIRO_HINT_METRICS_ON
END-ENUM

: cairo_create ( cairo_surface_t -- cairo_t )
	"cairo_t*" "cairo" "cairo_create" [ "void*" ] alien-invoke ; compiled

: cairo_destroy ( cairo_t -- )
	"void" "cairo" "cairo_destroy" [ "cairo_t*" ] ; compiled

: cairo_set_operator ( cairo_t cairo_operator_t -- )
	"void" "cairo" "cairo_set_operator" [ "cairo_t*" "int" ] ; compiled

: cairo_image_surface_create_for_data ( data format width height stride -- cairo_surface_t)
	"void*" "cairo" "cairo_image_surface_create_for_data" [ "void*" "uint" "int" "int" "int" ] alien-invoke ; compiled
	
: cairo_set_source_rgb ( cairo_t red green blue -- )
	"void" "cairo" "cairo_set_source_rgb" [ "cairo_t*" "double" "double" "double" ] alien-invoke ; compiled

: cairo_set_source_rgba ( cairo_t red green blue alpha -- )
	"void" "cairo" "cairo_set_source_rgb" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_set_source_surface ( cairo_t cairo_surface_t x y -- )
	"void" "cairo" "cairo_set_source_surface" [ "cairo_t*" "void*" "double" "double" ] alien-invoke ; compiled

: cairo_set_tolerance ( cairo_t tolerance -- )
	"void" "cairo" "cairo_set_tolerance" [ "cairo_t*" "double" ] alien-invoke ; compiled

: cairo_set_antialias ( cairo_t cairo_antialias_t -- )
	"void" "cairo" "cairo_set_antialias" [ "cairo_t*" "int" ] alien-invoke ; compiled

: cairo_set_fill_rule ( cairo_t cairo_fill_rule_t -- )
	"void" "cairo" "cairo_set_fill_rule" [ "cairo_t*" "int" ] alien-invoke ; compiled

: cairo_set_line_width ( cairo_t width -- )
	"void" "cairo" "cairo_set_line_width" [ "cairo_t*" "double" ] alien-invoke ; compiled

: cairo_set_line_cap ( cairo_t cairo_line_cap_t -- )
	"void" "cairo" "cairo_set_line_cap" [ "cairo_t*" "int" ] alien-invoke ; compiled

: cairo_set_line_join ( cairo_t cairo_line_join_t -- )
	"void" "cairo" "cairo_set_line_join" [ "cairo_t*" "int" ] alien-invoke ; compiled

: cairo_set_dash ( cairo_t dashes num_dashes offset -- )
	"void" "cairo" "cairo_set_dash" [ "cairo_t*" "double" "int" "double" ] alien-invoke ; compiled

: cairo_set_miter_limit ( cairo_t limit -- )
	"void" "cairo" "cairo_set_miter_limit" [ "cairo_t*" "double" ] alien-invoke ; compiled

: cairo_translate ( cairo_t x y -- )
	"void" "cairo" "cairo_translate" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled

: cairo_scale ( cairo_t sx sy -- )
	"void" "cairo" "cairo_scale" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled

: cairo_rotate ( cairo_t angle -- )
	"void" "cairo" "cairo_rotate" [ "cairo_t*" "double" ] alien-invoke ; compiled


! cairo path creating functions

: cairo_new_path ( cairo_t -- )
	"void" "cairo" "cairo_new_path" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_move_to ( cairo_t x y -- )
	"void" "cairo" "cairo_move_to" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled
	
: cairo_line_to ( cairo_t x y -- )
	"void" "cairo" "cairo_line_to" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled

: cairo_curve_to ( cairo_t x1 y1 x2 y2 x3 y3 -- )
	"void" "cairo" "cairo_curve_to" [ "cairo_t*" "double" "double" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_arc ( cairo_t xc yc radius angle1 angle2 -- )
	"void" "cairo" "cairo_arc" [ "cairo_t*" "double" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_arc_negative ( cairo_t xc yc radius angle1 angle2 -- )
	"void" "cairo" "cairo_arc_negative" [ "cairo_t*" "double" "double" "double" "double" "double" ] alien-invoke ; compiled
	
: cairo_rel_move_to ( cairo_t dx dy -- )
	"void" "cairo" "cairo_rel_move_to" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled
	
: cairo_rel_line_to ( cairo_t dx dy -- )
	"void" "cairo" "cairo_rel_line_to" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled

: cairo_rel_curve_to ( cairo_t dx1 dy1 dx2 dy2 dx3 dy3 -- )
	"void" "cairo" "cairo_rel_curve_to" [ "cairo_t*" "double" "double" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_rectangle ( cairo_t x y width height -- )
	"void" "cairo" "cairo_rectangle" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_close_path ( cairo_t -- )
	"void" "cairo" "cairo_close_path" [ "cairo_t*" ] alien-invoke ; compiled

! painting functions
: cairo_paint ( cairo_t -- )
	"void" "cairo" "cairo_paint" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_paint_with_alpha ( cairo_t alpha -- )
	"void" "cairo" "cairo_paint_with_alpha" [ "cairo_t*" "double" ] alien-invoke ; compiled

: cairo_mask ( cairo_t cairo_pattern_t -- )
	"void" "cairo" "cairo_mask" [ "cairo_t*" "void*" ] alien-invoke ; compiled

: cairo_mask_surface ( cairo_t cairo_pattern_t surface-x surface-y -- )
	"void" "cairo" "cairo_mask_surface" [ "cairo_t*" "void*" "double" "double" ] alien-invoke ; compiled

: cairo_stroke ( cairo_t -- )
	"void" "cairo" "cairo_stroke" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_stroke_preserve ( cairo_t -- )
	"void" "cairo" "cairo_stroke_preserve" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_fill ( cairo_t -- )
	"void" "cairo" "cairo_fill" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_fill_preserve ( cairo_t -- )
	"void" "cairo" "cairo_fill_preserve" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_copy_page ( cairo_t -- )
	"void" "cairo" "cairo_copy_page" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_show_page ( cairo_t -- )
	"void" "cairo" "cairo_show_page" [ "cairo_t*" ] alien-invoke ; compiled

! insideness testing
: cairo_in_stroke ( cairo_t x y -- t/f )
	"int" "cairo" "cairo_in_stroke" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled

: cairo_in_fill ( cairo_t x y -- t/f )
	"int" "cairo" "cairo_in_fill" [ "cairo_t*" "double" "double" ] alien-invoke ; compiled

! rectangular extents
: cairo_stroke_extents ( cairo_t x1 y1 x2 y2 -- )
	"void" "cairo" "cairo_stroke_extents" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_fill_extents ( cairo_t x1 y1 x2 y2 -- )
	"void" "cairo" "cairo_fill_extents" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ; compiled

! clipping
: cairo_reset_clip ( cairo_t -- )
	"void" "cairo" "cairo_reset_clip" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_clip ( cairo_t -- )
	"void" "cairo" "cairo_clip" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_clip_preserve ( cairo_t -- )
	"void" "cairo" "cairo_clip_preserve" [ "cairo_t*" ] alien-invoke ; compiled

: cairo_set_source ( cairo_t cairo_pattern_t -- )
	"void" "cairo" "cairo_set_source" [ "cairo_t*" "void*" ] alien-invoke ; compiled

: cairo_pattern_create_linear ( x0 y0 x1 y1 -- cairo_pattern_t )
	"void*" "cairo" "cairo_pattern_create_linear" [ "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_pattern_create_radial ( cx0 cy0 radius0 cx1 cy1 radius1 -- cairo_pattern_t )
	"void*" "cairo" "cairo_pattern_create_radial" [ "double" "double" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_pattern_add_color_stop_rgba ( pattern offset red green blue alpha -- status )
	"uint" "cairo" "cairo_pattern_add_color_stop_rgba" [ "void*" "double" "double" "double" "double" "double" ] alien-invoke ; compiled

: cairo_show_text ( cairo_t msg_utf8 -- )
	"void" "cairo" "cairo_show_text" [ "cairo_t*" "char*" ] alien-invoke ; compiled

: cairo_text_path ( cairo_t msg_utf8 -- )
	"void" "cairo" "cairo_text_path" [ "cairo_t*" "char*" ] alien-invoke ; compiled

: cairo_select_font_face ( cairo_t family font_slant font_weight -- )
	"void" "cairo" "cairo_select_font_face" [ "cairo_t*" "char*" "uint" "uint" ] alien-invoke ; compiled

: cairo_set_font_size ( cairo_t scale -- )
	"void" "cairo" "cairo_set_font_size" [ "cairo_t*" "double" ] alien-invoke ; compiled

: cairo_identity_matrix ( cairo_t -- )
	"void" "cairo" "cairo_identity_matrix" [ "cairo_t*" ] alien-invoke ; compiled

