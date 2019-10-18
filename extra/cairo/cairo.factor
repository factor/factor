! Cairo binding
IN: cairo
USING: alien alien.syntax ;

! cairo_status_t
C-ENUM:
    CAIRO_STATUS_SUCCESS
    CAIRO_STATUS_NO_MEMORY
    CAIRO_STATUS_INVALID_RESTORE
    CAIRO_STATUS_INVALID_POP_GROUP
    CAIRO_STATUS_NO_CURRENT_POINT
    CAIRO_STATUS_INVALID_MATRIX
    CAIRO_STATUS_NO_TARGET_SURFACE
    CAIRO_STATUS_NULL_POINTER
    CAIRO_STATUS_INVALID_STRING
;

! cairo_operator_t
C-ENUM:
    CAIRO_OPERATOR_CLEAR
    CAIRO_OPERATOR_SRC
    CAIRO_OPERATOR_DST
    CAIRO_OPERATOR_OVER
    CAIRO_OPERATOR_OVER_REVERSE
    CAIRO_OPERATOR_IN
    CAIRO_OPERATOR_IN_REVERSE
    CAIRO_OPERATOR_OUT
    CAIRO_OPERATOR_OUT_REVERSE
    CAIRO_OPERATOR_ATOP
    CAIRO_OPERATOR_ATOP_REVERSE
    CAIRO_OPERATOR_XOR
    CAIRO_OPERATOR_ADD
    CAIRO_OPERATOR_SATURATE
;

! cairo_line_cap_t
C-ENUM:
    CAIRO_LINE_CAP_BUTT
    CAIRO_LINE_CAP_ROUND
    CAIRO_LINE_CAP_SQUARE
;

! cair_line_join_t
C-ENUM:
    CAIRO_LINE_JOIN_MITER
    CAIRO_LINE_JOIN_ROUND
    CAIRO_LINE_JOIN_BEVEL
;

! cairo_fill_rule_t
C-ENUM:
    CAIRO_FILL_RULE_WINDING
    CAIRO_FILL_RULE_EVEN_ODD
;

! cairo_font_slant_t
C-ENUM:
    CAIRO_FONT_SLANT_NORMAL
    CAIRO_FONT_SLANT_ITALIC
    CAIRO_FONT_SLANT_OBLIQUE
;

! cairo_font_weight_t
C-ENUM:
    CAIRO_FONT_WEIGHT_NORMAL
    CAIRO_FONT_WEIGHT_BOLD
;

C-STRUCT: cairo_font_t
    { "int" "refcount" }
    { "uint" "scale" } ;

C-STRUCT: cairo_rectangle_t
    { "short" "x" }
    { "short" "y" }
    { "ushort" "width" }
    { "ushort" "height" } ;

C-STRUCT: cairo_clip_rec_t
    { "cairo_rectangle_t" "rect" }
    { "void*" "region" }
    { "void*" "surface" } ;

C-STRUCT: cairo_matrix_t
    { "void*" "m" } ;

C-STRUCT: cairo_gstate_t
    { "uint" "operator" }
    { "double" "tolerance" }
    { "double" "line_width" }
    { "uint" "line_cap" }
    { "uint" "line_join" }
    { "double" "miter_limit" }
    { "uint" "fill_rule" }
    { "void*" "dash" }
    { "int" "num_dashes" }
    { "double" "dash_offset" }
    { "char*" "font_family " }
    { "uint" "font_slant" }
    { "uint" "font_weight" }
    { "void*" "font" }
    { "void*" "surface" }
    { "void*" "pattern " }
    { "double" "alpha" }
    { "cairo_clip_rec_t" "clip" }
    { "double" "pixels_per_inch" }
    { "cairo_matrix_t" "font_matrix" }
    { "cairo_matrix_t" "ctm" }
    { "cairo_matrix_t" "ctm_inverse" }
    { "void*" "path" }
    { "void*" "pen_regular" }
    { "void*" "next" } ;

C-STRUCT: cairo_t
    { "uint" "ref_count" }
    { "cairo_gstate_t*" "gstate" }
    { "uint" "status ! cairo_status_t" } ;

! cairo_format_t
C-ENUM:
    CAIRO_FORMAT_ARGB32
    CAIRO_FORMAT_RGB24
    CAIRO_FORMAT_A8
    CAIRO_FORMAT_A1
;

! cairo_antialias_t
C-ENUM:
    CAIRO_ANTIALIAS_DEFAULT
    CAIRO_ANTIALIAS_NONE
    CAIRO_ANTIALIAS_GRAY
    CAIRO_ANTIALIAS_SUBPIXEL
;

! cairo_subpixel_order_t
C-ENUM:
    CAIRO_SUBPIXEL_ORDER_DEFAULT
    CAIRO_SUBPIXEL_ORDER_RGB
    CAIRO_SUBPIXEL_ORDER_BGR
    CAIRO_SUBPIXEL_ORDER_VRGB
    CAIRO_SUBPIXEL_ORDER_VBGR
;

! cairo_hint_style_t
C-ENUM:
    CAIRO_HINT_STYLE_DEFAULT
    CAIRO_HINT_STYLE_NONE
    CAIRO_HINT_STYLE_SLIGHT
    CAIRO_HINT_STYLE_MEDIUM
    CAIRO_HINT_STYLE_FULL
;

! cairo_hint_metrics_t
C-ENUM:
    CAIRO_HINT_METRICS_DEFAULT
    CAIRO_HINT_METRICS_OFF
    CAIRO_HINT_METRICS_ON
;

: cairo_create ( cairo_surface_t -- cairo_t )
    "cairo_t*" "cairo" "cairo_create" [ "void*" ] alien-invoke ;

: cairo_destroy ( cairo_t -- )
    "void" "cairo" "cairo_destroy" [ "cairo_t*" ] alien-invoke ;

: cairo_set_operator ( cairo_t cairo_operator_t -- )
    "void" "cairo" "cairo_set_operator" [ "cairo_t*" "int" ] alien-invoke ;

: cairo_image_surface_create_for_data ( data format width height stride -- cairo_surface_t )
    "void*" "cairo" "cairo_image_surface_create_for_data" [ "void*" "uint" "int" "int" "int" ] alien-invoke ;
    
: cairo_set_source_rgb ( cairo_t red green blue -- )
    "void" "cairo" "cairo_set_source_rgb" [ "cairo_t*" "double" "double" "double" ] alien-invoke ;

: cairo_set_source_rgba ( cairo_t red green blue alpha -- )
    "void" "cairo" "cairo_set_source_rgb" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ;

: cairo_set_source_surface ( cairo_t cairo_surface_t x y -- )
    "void" "cairo" "cairo_set_source_surface" [ "cairo_t*" "void*" "double" "double" ] alien-invoke ;

: cairo_set_tolerance ( cairo_t tolerance -- )
    "void" "cairo" "cairo_set_tolerance" [ "cairo_t*" "double" ] alien-invoke ;

: cairo_set_antialias ( cairo_t cairo_antialias_t -- )
    "void" "cairo" "cairo_set_antialias" [ "cairo_t*" "int" ] alien-invoke ;

: cairo_set_fill_rule ( cairo_t cairo_fill_rule_t -- )
    "void" "cairo" "cairo_set_fill_rule" [ "cairo_t*" "int" ] alien-invoke ;

: cairo_set_line_width ( cairo_t width -- )
    "void" "cairo" "cairo_set_line_width" [ "cairo_t*" "double" ] alien-invoke ;

: cairo_set_line_cap ( cairo_t cairo_line_cap_t -- )
    "void" "cairo" "cairo_set_line_cap" [ "cairo_t*" "int" ] alien-invoke ;

: cairo_set_line_join ( cairo_t cairo_line_join_t -- )
    "void" "cairo" "cairo_set_line_join" [ "cairo_t*" "int" ] alien-invoke ;

: cairo_set_dash ( cairo_t dashes num_dashes offset -- )
    "void" "cairo" "cairo_set_dash" [ "cairo_t*" "double" "int" "double" ] alien-invoke ;

: cairo_set_miter_limit ( cairo_t limit -- )
    "void" "cairo" "cairo_set_miter_limit" [ "cairo_t*" "double" ] alien-invoke ;

: cairo_translate ( cairo_t x y -- )
    "void" "cairo" "cairo_translate" [ "cairo_t*" "double" "double" ] alien-invoke ;

: cairo_scale ( cairo_t sx sy -- )
    "void" "cairo" "cairo_scale" [ "cairo_t*" "double" "double" ] alien-invoke ;

: cairo_rotate ( cairo_t angle -- )
    "void" "cairo" "cairo_rotate" [ "cairo_t*" "double" ] alien-invoke ;


! cairo path creating functions

: cairo_new_path ( cairo_t -- )
    "void" "cairo" "cairo_new_path" [ "cairo_t*" ] alien-invoke ;

: cairo_move_to ( cairo_t x y -- )
    "void" "cairo" "cairo_move_to" [ "cairo_t*" "double" "double" ] alien-invoke ;
    
: cairo_line_to ( cairo_t x y -- )
    "void" "cairo" "cairo_line_to" [ "cairo_t*" "double" "double" ] alien-invoke ;

: cairo_curve_to ( cairo_t x1 y1 x2 y2 x3 y3 -- )
    "void" "cairo" "cairo_curve_to" [ "cairo_t*" "double" "double" "double" "double" "double" "double" ] alien-invoke ;

: cairo_arc ( cairo_t xc yc radius angle1 angle2 -- )
    "void" "cairo" "cairo_arc" [ "cairo_t*" "double" "double" "double" "double" "double" ] alien-invoke ;

: cairo_arc_negative ( cairo_t xc yc radius angle1 angle2 -- )
    "void" "cairo" "cairo_arc_negative" [ "cairo_t*" "double" "double" "double" "double" "double" ] alien-invoke ;
    
: cairo_rel_move_to ( cairo_t dx dy -- )
    "void" "cairo" "cairo_rel_move_to" [ "cairo_t*" "double" "double" ] alien-invoke ;
    
: cairo_rel_line_to ( cairo_t dx dy -- )
    "void" "cairo" "cairo_rel_line_to" [ "cairo_t*" "double" "double" ] alien-invoke ;

: cairo_rel_curve_to ( cairo_t dx1 dy1 dx2 dy2 dx3 dy3 -- )
    "void" "cairo" "cairo_rel_curve_to" [ "cairo_t*" "double" "double" "double" "double" "double" "double" ] alien-invoke ;

: cairo_rectangle ( cairo_t x y width height -- )
    "void" "cairo" "cairo_rectangle" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ;

: cairo_close_path ( cairo_t -- )
    "void" "cairo" "cairo_close_path" [ "cairo_t*" ] alien-invoke ;

! painting functions
: cairo_paint ( cairo_t -- )
    "void" "cairo" "cairo_paint" [ "cairo_t*" ] alien-invoke ;

: cairo_paint_with_alpha ( cairo_t alpha -- )
    "void" "cairo" "cairo_paint_with_alpha" [ "cairo_t*" "double" ] alien-invoke ;

: cairo_mask ( cairo_t cairo_pattern_t -- )
    "void" "cairo" "cairo_mask" [ "cairo_t*" "void*" ] alien-invoke ;

: cairo_mask_surface ( cairo_t cairo_pattern_t surface-x surface-y -- )
    "void" "cairo" "cairo_mask_surface" [ "cairo_t*" "void*" "double" "double" ] alien-invoke ;

: cairo_stroke ( cairo_t -- )
    "void" "cairo" "cairo_stroke" [ "cairo_t*" ] alien-invoke ;

: cairo_stroke_preserve ( cairo_t -- )
    "void" "cairo" "cairo_stroke_preserve" [ "cairo_t*" ] alien-invoke ;

: cairo_fill ( cairo_t -- )
    "void" "cairo" "cairo_fill" [ "cairo_t*" ] alien-invoke ;

: cairo_fill_preserve ( cairo_t -- )
    "void" "cairo" "cairo_fill_preserve" [ "cairo_t*" ] alien-invoke ;

: cairo_copy_page ( cairo_t -- )
    "void" "cairo" "cairo_copy_page" [ "cairo_t*" ] alien-invoke ;

: cairo_show_page ( cairo_t -- )
    "void" "cairo" "cairo_show_page" [ "cairo_t*" ] alien-invoke ;

! insideness testing
: cairo_in_stroke ( cairo_t x y -- t/f )
    "int" "cairo" "cairo_in_stroke" [ "cairo_t*" "double" "double" ] alien-invoke ;

: cairo_in_fill ( cairo_t x y -- t/f )
    "int" "cairo" "cairo_in_fill" [ "cairo_t*" "double" "double" ] alien-invoke ;

! rectangular extents
: cairo_stroke_extents ( cairo_t x1 y1 x2 y2 -- )
    "void" "cairo" "cairo_stroke_extents" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ;

: cairo_fill_extents ( cairo_t x1 y1 x2 y2 -- )
    "void" "cairo" "cairo_fill_extents" [ "cairo_t*" "double" "double" "double" "double" ] alien-invoke ;

! clipping
: cairo_reset_clip ( cairo_t -- )
    "void" "cairo" "cairo_reset_clip" [ "cairo_t*" ] alien-invoke ;

: cairo_clip ( cairo_t -- )
    "void" "cairo" "cairo_clip" [ "cairo_t*" ] alien-invoke ;

: cairo_clip_preserve ( cairo_t -- )
    "void" "cairo" "cairo_clip_preserve" [ "cairo_t*" ] alien-invoke ;

: cairo_set_source ( cairo_t cairo_pattern_t -- )
    "void" "cairo" "cairo_set_source" [ "cairo_t*" "void*" ] alien-invoke ;

: cairo_pattern_create_linear ( x0 y0 x1 y1 -- cairo_pattern_t )
    "void*" "cairo" "cairo_pattern_create_linear" [ "double" "double" "double" "double" ] alien-invoke ;

: cairo_pattern_create_radial ( cx0 cy0 radius0 cx1 cy1 radius1 -- cairo_pattern_t )
    "void*" "cairo" "cairo_pattern_create_radial" [ "double" "double" "double" "double" "double" "double" ] alien-invoke ;

: cairo_pattern_add_color_stop_rgba ( pattern offset red green blue alpha -- status )
    "uint" "cairo" "cairo_pattern_add_color_stop_rgba" [ "void*" "double" "double" "double" "double" "double" ] alien-invoke ;

: cairo_show_text ( cairo_t msg_utf8 -- )
    "void" "cairo" "cairo_show_text" [ "cairo_t*" "char*" ] alien-invoke ;

: cairo_text_path ( cairo_t msg_utf8 -- )
    "void" "cairo" "cairo_text_path" [ "cairo_t*" "char*" ] alien-invoke ;

: cairo_select_font_face ( cairo_t family font_slant font_weight -- )
    "void" "cairo" "cairo_select_font_face" [ "cairo_t*" "char*" "uint" "uint" ] alien-invoke ;

: cairo_set_font_size ( cairo_t scale -- )
    "void" "cairo" "cairo_set_font_size" [ "cairo_t*" "double" ] alien-invoke ;

: cairo_identity_matrix ( cairo_t -- )
    "void" "cairo" "cairo_identity_matrix" [ "cairo_t*" ] alien-invoke ;
