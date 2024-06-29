! Copyright (C) 2007 Sampo Vuori.
! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax classes.struct combinators system ;
IN: cairo.ffi

! Adapted from cairo.h, version 1.8.10

<< "cairo" {
    { [ os windows? ] [ "cairo-2.dll" ] }
    { [ os macos? ] [ "libcairo.dylib" ] }
    { [ os unix? ] [ "libcairo.so" ] }
} cond cdecl add-library >>

LIBRARY: cairo

FUNCTION: int cairo_version ( )
FUNCTION: c-string cairo_version_string ( )

TYPEDEF: int cairo_bool_t

! I am leaving these and other void* types as opaque structures
TYPEDEF: void* cairo_t
TYPEDEF: void* cairo_surface_t

STRUCT: cairo_matrix_t
    { xx double }
    { yx double }
    { xy double }
    { yy double }
    { x0 double }
    { y0 double } ;

TYPEDEF: void* cairo_pattern_t

CALLBACK: void
cairo_destroy_func_t ( void* data )

! See cairo.h for details
STRUCT: cairo_user_data_key_t
    { unused int } ;

ENUM: cairo_status_t
    CAIRO_STATUS_SUCCESS
    CAIRO_STATUS_NO_MEMORY
    CAIRO_STATUS_INVALID_RESTORE
    CAIRO_STATUS_INVALID_POP_GROUP
    CAIRO_STATUS_NO_CURRENT_POINT
    CAIRO_STATUS_INVALID_MATRIX
    CAIRO_STATUS_INVALID_STATUS
    CAIRO_STATUS_NULL_POINTER
    CAIRO_STATUS_INVALID_STRING
    CAIRO_STATUS_INVALID_PATH_DATA
    CAIRO_STATUS_READ_ERROR
    CAIRO_STATUS_WRITE_ERROR
    CAIRO_STATUS_SURFACE_FINISHED
    CAIRO_STATUS_SURFACE_TYPE_MISMATCH
    CAIRO_STATUS_PATTERN_TYPE_MISMATCH
    CAIRO_STATUS_INVALID_CONTENT
    CAIRO_STATUS_INVALID_FORMAT
    CAIRO_STATUS_INVALID_VISUAL
    CAIRO_STATUS_FILE_NOT_FOUND
    CAIRO_STATUS_INVALID_DASH
    CAIRO_STATUS_INVALID_DSC_COMMENT
    CAIRO_STATUS_INVALID_INDEX
    CAIRO_STATUS_CLIP_NOT_REPRESENTABLE
    CAIRO_STATUS_TEMP_FILE_ERROR
    CAIRO_STATUS_INVALID_STRIDE
    CAIRO_STATUS_FONT_TYPE_MISMATCH
    CAIRO_STATUS_USER_FONT_IMMUTABLE
    CAIRO_STATUS_USER_FONT_ERROR
    CAIRO_STATUS_NEGATIVE_COUNT
    CAIRO_STATUS_INVALID_CLUSTERS
    CAIRO_STATUS_INVALID_SLANT
    CAIRO_STATUS_INVALID_WEIGHT ;

ENUM: cairo_content_t
    { CAIRO_CONTENT_COLOR 0x1000 }
    { CAIRO_CONTENT_ALPHA 0x2000 }
    { CAIRO_CONTENT_COLOR_ALPHA 0x3000 } ;

CALLBACK: cairo_status_t
cairo_write_func_t ( void* closure, uchar* data, uint length )

CALLBACK: cairo_status_t
cairo_read_func_t ( void* closure, uchar* data, uint length )

! Functions for manipulating state objects

FUNCTION: cairo_t*
cairo_create ( cairo_surface_t* target )

FUNCTION: cairo_t*
cairo_reference ( cairo_t* cr )

FUNCTION: void
cairo_destroy ( cairo_t* cr )

DESTRUCTOR: cairo_destroy

FUNCTION: uint
cairo_get_reference_count ( cairo_t* cr )

FUNCTION: void*
cairo_get_user_data ( cairo_t* cr, cairo_user_data_key_t* key )

FUNCTION: cairo_status_t
cairo_set_user_data ( cairo_t* cr, cairo_user_data_key_t* key, void* user_data, cairo_destroy_func_t destroy )

FUNCTION: void
cairo_save ( cairo_t* cr )

FUNCTION: void
cairo_restore ( cairo_t* cr )

FUNCTION: void
cairo_push_group ( cairo_t* cr )

FUNCTION: void
cairo_push_group_with_content ( cairo_t* cr, cairo_content_t content )

FUNCTION: cairo_pattern_t*
cairo_pop_group ( cairo_t* cr )

FUNCTION: void
cairo_pop_group_to_source ( cairo_t* cr )

! Modify state

ENUM: cairo_operator_t
    CAIRO_OPERATOR_CLEAR

    CAIRO_OPERATOR_SOURCE
    CAIRO_OPERATOR_OVER
    CAIRO_OPERATOR_IN
    CAIRO_OPERATOR_OUT
    CAIRO_OPERATOR_ATOP

    CAIRO_OPERATOR_DEST
    CAIRO_OPERATOR_DEST_OVER
    CAIRO_OPERATOR_DEST_IN
    CAIRO_OPERATOR_DEST_OUT
    CAIRO_OPERATOR_DEST_ATOP

    CAIRO_OPERATOR_XOR
    CAIRO_OPERATOR_ADD
    CAIRO_OPERATOR_SATURATE ;

FUNCTION: void
cairo_set_operator ( cairo_t* cr, cairo_operator_t op )

FUNCTION: void
cairo_set_source ( cairo_t* cr, cairo_pattern_t* source )

FUNCTION: void
cairo_set_source_rgb ( cairo_t* cr, double red, double green, double blue )

FUNCTION: void
cairo_set_source_rgba ( cairo_t* cr, double red, double green, double blue, double alpha )

FUNCTION: void
cairo_set_source_surface ( cairo_t* cr, cairo_surface_t* surface, double x, double y )

FUNCTION: void
cairo_set_tolerance ( cairo_t* cr, double tolerance )

ENUM: cairo_antialias_t
    CAIRO_ANTIALIAS_DEFAULT
    CAIRO_ANTIALIAS_NONE
    CAIRO_ANTIALIAS_GRAY
    CAIRO_ANTIALIAS_SUBPIXEL ;

FUNCTION: void
cairo_set_antialias ( cairo_t* cr, cairo_antialias_t antialias )

ENUM: cairo_fill_rule_t
    CAIRO_FILL_RULE_WINDING
    CAIRO_FILL_RULE_EVEN_ODD ;

FUNCTION: void
cairo_set_fill_rule ( cairo_t* cr, cairo_fill_rule_t fill_rule )

FUNCTION: void
cairo_set_line_width ( cairo_t* cr, double width )

ENUM: cairo_line_cap_t
    CAIRO_LINE_CAP_BUTT
    CAIRO_LINE_CAP_ROUND
    CAIRO_LINE_CAP_SQUARE ;

FUNCTION: void
cairo_set_line_cap ( cairo_t* cr, cairo_line_cap_t line_cap )

ENUM: cairo_line_join_t
    CAIRO_LINE_JOIN_MITER
    CAIRO_LINE_JOIN_ROUND
    CAIRO_LINE_JOIN_BEVEL ;

FUNCTION: void
cairo_set_line_join ( cairo_t* cr, cairo_line_join_t line_join )

FUNCTION: void
cairo_set_dash ( cairo_t* cr, double* dashes, int num_dashes, double offset )

FUNCTION: void
cairo_set_miter_limit ( cairo_t* cr, double limit )

FUNCTION: void
cairo_translate ( cairo_t* cr, double tx, double ty )

FUNCTION: void
cairo_scale ( cairo_t* cr, double sx, double sy )

FUNCTION: void
cairo_rotate ( cairo_t* cr, double angle )

FUNCTION: void
cairo_transform ( cairo_t* cr, cairo_matrix_t* matrix )

FUNCTION: void
cairo_set_matrix ( cairo_t* cr, cairo_matrix_t* matrix )

FUNCTION: void
cairo_identity_matrix ( cairo_t* cr )

FUNCTION: void
cairo_user_to_device ( cairo_t* cr, double* x, double* y )

FUNCTION: void
cairo_user_to_device_distance ( cairo_t* cr, double* dx, double* dy )

FUNCTION: void
cairo_device_to_user ( cairo_t* cr, double* x, double* y )

FUNCTION: void
cairo_device_to_user_distance ( cairo_t* cr, double* dx, double* dy )

! Path creation functions

FUNCTION: void
cairo_new_path ( cairo_t* cr )

FUNCTION: void
cairo_move_to ( cairo_t* cr, double x, double y )

FUNCTION: void
cairo_new_sub_path ( cairo_t* cr )

FUNCTION: void
cairo_line_to ( cairo_t* cr, double x, double y )

FUNCTION: void
cairo_curve_to ( cairo_t* cr, double x1, double y1, double x2, double y2, double x3, double y3 )

FUNCTION: void
cairo_arc ( cairo_t* cr, double xc, double yc, double radius, double angle1, double angle2 )

FUNCTION: void
cairo_arc_negative ( cairo_t* cr, double xc, double yc, double radius, double angle1, double angle2 )

FUNCTION: void
cairo_rel_move_to ( cairo_t* cr, double dx, double dy )

FUNCTION: void
cairo_rel_line_to ( cairo_t* cr, double dx, double dy )

FUNCTION: void
cairo_rel_curve_to ( cairo_t* cr, double dx1, double dy1, double dx2, double dy2, double dx3, double dy3 )

FUNCTION: void
cairo_rectangle ( cairo_t* cr, double x, double y, double width, double height )

FUNCTION: void
cairo_close_path ( cairo_t* cr )

FUNCTION: void
cairo_path_extents ( cairo_t* cr, double* x1, double* y1, double* x2, double* y2 )

! Painting functions

FUNCTION: void
cairo_paint ( cairo_t* cr )

FUNCTION: void
cairo_paint_with_alpha ( cairo_t* cr, double alpha )

FUNCTION: void
cairo_mask ( cairo_t* cr, cairo_pattern_t* pattern )

FUNCTION: void
cairo_mask_surface ( cairo_t* cr, cairo_surface_t* surface, double surface_x, double surface_y )

FUNCTION: void
cairo_stroke ( cairo_t* cr )

FUNCTION: void
cairo_stroke_preserve ( cairo_t* cr )

FUNCTION: void
cairo_fill ( cairo_t* cr )

FUNCTION: void
cairo_fill_preserve ( cairo_t* cr )

FUNCTION: void
cairo_copy_page ( cairo_t* cr )

FUNCTION: void
cairo_show_page ( cairo_t* cr )

! Insideness testing

FUNCTION: cairo_bool_t
cairo_in_stroke ( cairo_t* cr, double x, double y )

FUNCTION: cairo_bool_t
cairo_in_fill ( cairo_t* cr, double x, double y )

! Rectangular extents

FUNCTION: void
cairo_stroke_extents ( cairo_t* cr, double* x1, double* y1, double* x2, double* y2 )

FUNCTION: void
cairo_fill_extents ( cairo_t* cr, double* x1, double* y1, double* x2, double* y2 )

! Clipping

FUNCTION: void
cairo_reset_clip ( cairo_t* cr )

FUNCTION: void
cairo_clip ( cairo_t* cr )

FUNCTION: void
cairo_clip_preserve ( cairo_t* cr )

FUNCTION: void
cairo_clip_extents ( cairo_t* cr, double* x1, double* y1, double* x2, double* y2 )

STRUCT: cairo_rectangle_t
    { x      double }
    { y      double }
    { width  double }
    { height double } ;

STRUCT: cairo_rectangle_list_t
    { status         cairo_status_t     }
    { rectangles     cairo_rectangle_t* }
    { num_rectangles int                } ;

FUNCTION: cairo_rectangle_list_t*
cairo_copy_clip_rectangle_list ( cairo_t* cr )

FUNCTION: void
cairo_rectangle_list_destroy ( cairo_rectangle_list_t* rectangle_list )

! Font/Text functions

TYPEDEF: void* cairo_scaled_font_t

TYPEDEF: void* cairo_font_face_t

STRUCT: cairo_glyph_t
    { index ulong  }
    { x     double }
    { y     double } ;

FUNCTION: cairo_glyph_t*
cairo_glyph_allocate ( int num_glyphs )

FUNCTION: void
cairo_glyph_free ( cairo_glyph_t* glyphs )

STRUCT: cairo_text_cluster_t
    { num_bytes  int }
    { num_glyphs int } ;

FUNCTION: cairo_text_cluster_t*
cairo_text_cluster_allocate ( int num_clusters )

FUNCTION: void
cairo_text_cluster_free ( cairo_text_cluster_t* clusters )

ENUM: cairo_text_cluster_flags_t
    { CAIRO_TEXT_CLUSTER_FLAG_BACKWARD 0x00000001 } ;

STRUCT: cairo_text_extents_t
    { x_bearing double }
    { y_bearing double }
    { width     double }
    { height    double }
    { x_advance double }
    { y_advance double } ;

STRUCT: cairo_font_extents_t
    { ascent double }
    { descent double }
    { height double }
    { max_x_advance double }
    { max_y_advance double } ;

ENUM: cairo_font_slant_t
    CAIRO_FONT_SLANT_NORMAL
    CAIRO_FONT_SLANT_ITALIC
    CAIRO_FONT_SLANT_OBLIQUE ;

ENUM: cairo_font_weight_t
    CAIRO_FONT_WEIGHT_NORMAL
    CAIRO_FONT_WEIGHT_BOLD ;

ENUM: cairo_subpixel_order_t
    CAIRO_SUBPIXEL_ORDER_DEFAULT
    CAIRO_SUBPIXEL_ORDER_RGB
    CAIRO_SUBPIXEL_ORDER_BGR
    CAIRO_SUBPIXEL_ORDER_VRGB
    CAIRO_SUBPIXEL_ORDER_VBGR ;

ENUM: cairo_hint_style_t
    CAIRO_HINT_STYLE_DEFAULT
    CAIRO_HINT_STYLE_NONE
    CAIRO_HINT_STYLE_SLIGHT
    CAIRO_HINT_STYLE_MEDIUM
    CAIRO_HINT_STYLE_FULL ;

ENUM: cairo_hint_metrics_t
    CAIRO_HINT_METRICS_DEFAULT
    CAIRO_HINT_METRICS_OFF
    CAIRO_HINT_METRICS_ON ;

TYPEDEF: void* cairo_font_options_t

FUNCTION: cairo_font_options_t*
cairo_font_options_create ( )

FUNCTION: cairo_font_options_t*
cairo_font_options_copy ( cairo_font_options_t* original )

FUNCTION: void
cairo_font_options_destroy ( cairo_font_options_t* options )

FUNCTION: cairo_status_t
cairo_font_options_status ( cairo_font_options_t* options )

FUNCTION: void
cairo_font_options_merge ( cairo_font_options_t* options, cairo_font_options_t* other )

FUNCTION: cairo_bool_t
cairo_font_options_equal ( cairo_font_options_t* options, cairo_font_options_t* other )

FUNCTION: ulong
cairo_font_options_hash ( cairo_font_options_t* options )

FUNCTION: void
cairo_font_options_set_antialias ( cairo_font_options_t* options, cairo_antialias_t antialias )

FUNCTION: cairo_antialias_t
cairo_font_options_get_antialias ( cairo_font_options_t* options )

FUNCTION: void
cairo_font_options_set_subpixel_order ( cairo_font_options_t* options, cairo_subpixel_order_t subpixel_order )

FUNCTION: cairo_subpixel_order_t
cairo_font_options_get_subpixel_order ( cairo_font_options_t* options )

FUNCTION: void
cairo_font_options_set_hint_style ( cairo_font_options_t* options, cairo_hint_style_t hint_style )

FUNCTION: cairo_hint_style_t
cairo_font_options_get_hint_style ( cairo_font_options_t* options )

FUNCTION: void
cairo_font_options_set_hint_metrics ( cairo_font_options_t* options, cairo_hint_metrics_t hint_metrics )

FUNCTION: cairo_hint_metrics_t
cairo_font_options_get_hint_metrics ( cairo_font_options_t* options )

! This interface is for dealing with text as text, not caring about the
!  font object inside the the cairo_t.

FUNCTION: void
cairo_select_font_face ( cairo_t* cr, c-string family, cairo_font_slant_t slant, cairo_font_weight_t weight )

FUNCTION: void
cairo_set_font_size ( cairo_t* cr, double size )

FUNCTION: void
cairo_set_font_matrix ( cairo_t* cr, cairo_matrix_t* matrix )

FUNCTION: void
cairo_get_font_matrix ( cairo_t* cr, cairo_matrix_t* matrix )

FUNCTION: void
cairo_set_font_options ( cairo_t* cr, cairo_font_options_t* options )

FUNCTION: void
cairo_get_font_options ( cairo_t* cr, cairo_font_options_t* options )

FUNCTION: void
cairo_set_font_face ( cairo_t* cr, cairo_font_face_t* font_face )

FUNCTION: cairo_font_face_t*
cairo_get_font_face ( cairo_t* cr )

FUNCTION: void
cairo_set_scaled_font ( cairo_t* cr, cairo_scaled_font_t* scaled_font )

FUNCTION: cairo_scaled_font_t*
cairo_get_scaled_font ( cairo_t* cr )

FUNCTION: void
cairo_show_text ( cairo_t* cr, c-string utf8 )

FUNCTION: void
cairo_show_glyphs ( cairo_t* cr, cairo_glyph_t* glyphs, int num_glyphs )

FUNCTION: void
cairo_show_text_glyphs ( cairo_t* cr, c-string utf8, int utf8_len, cairo_glyph_t* glyphs, int num_glyphs, cairo_text_cluster_t* clusters, int num_clusters, cairo_text_cluster_flags_t cluster_flags )

FUNCTION: void
cairo_text_path ( cairo_t* cr, c-string utf8 )

FUNCTION: void
cairo_glyph_path ( cairo_t* cr, cairo_glyph_t* glyphs, int num_glyphs )

FUNCTION: void
cairo_text_extents ( cairo_t* cr, c-string utf8, cairo_text_extents_t* extents )

FUNCTION: void
cairo_glyph_extents ( cairo_t* cr, cairo_glyph_t* glyphs, int num_glyphs, cairo_text_extents_t* extents )

FUNCTION: void
cairo_font_extents ( cairo_t* cr, cairo_font_extents_t* extents )

! Generic identifier for a font style

FUNCTION: cairo_font_face_t*
cairo_font_face_reference ( cairo_font_face_t* font_face )

FUNCTION: void
cairo_font_face_destroy ( cairo_font_face_t* font_face )

FUNCTION: uint
cairo_font_face_get_reference_count ( cairo_font_face_t* font_face )

FUNCTION: cairo_status_t
cairo_font_face_status ( cairo_font_face_t* font_face )

ENUM: cairo_font_type_t
    CAIRO_FONT_TYPE_TOY
    CAIRO_FONT_TYPE_FT
    CAIRO_FONT_TYPE_WIN32
    CAIRO_FONT_TYPE_QUARTZ
    CAIRO_FONT_TYPE_USER ;

FUNCTION: cairo_font_type_t
cairo_font_face_get_type ( cairo_font_face_t* font_face )

FUNCTION: void*
cairo_font_face_get_user_data ( cairo_font_face_t* font_face, cairo_user_data_key_t* key )

FUNCTION: cairo_status_t
cairo_font_face_set_user_data ( cairo_font_face_t* font_face, cairo_user_data_key_t* key, void* user_data, cairo_destroy_func_t destroy )

! Portable interface to general font features.

FUNCTION: cairo_scaled_font_t*
cairo_scaled_font_create ( cairo_font_face_t* font_face, cairo_matrix_t* font_matrix, cairo_matrix_t* ctm, cairo_font_options_t* options )

FUNCTION: cairo_scaled_font_t*
cairo_scaled_font_reference ( cairo_scaled_font_t* scaled_font )

FUNCTION: void
cairo_scaled_font_destroy ( cairo_scaled_font_t* scaled_font )

FUNCTION: uint
cairo_scaled_font_get_reference_count ( cairo_scaled_font_t* scaled_font )

FUNCTION: cairo_status_t
cairo_scaled_font_status ( cairo_scaled_font_t* scaled_font )

FUNCTION: cairo_font_type_t
cairo_scaled_font_get_type ( cairo_scaled_font_t* scaled_font )

FUNCTION: void*
cairo_scaled_font_get_user_data ( cairo_scaled_font_t* scaled_font, cairo_user_data_key_t* key )

FUNCTION: cairo_status_t
cairo_scaled_font_set_user_data ( cairo_scaled_font_t* scaled_font, cairo_user_data_key_t* key, void* user_data, cairo_destroy_func_t destroy )

FUNCTION: void
cairo_scaled_font_extents ( cairo_scaled_font_t* scaled_font, cairo_font_extents_t* extents )

FUNCTION: void
cairo_scaled_font_text_extents ( cairo_scaled_font_t* scaled_font, c-string utf8, cairo_text_extents_t* extents )

FUNCTION: void
cairo_scaled_font_glyph_extents ( cairo_scaled_font_t* scaled_font, cairo_glyph_t* glyphs, int num_glyphs, cairo_text_extents_t* extents )

FUNCTION: cairo_status_t
cairo_scaled_font_text_to_glyphs ( cairo_scaled_font_t* scaled_font, double x, double y, c-string utf8, int utf8_len, cairo_glyph_t** glyphs, int* num_glyphs, cairo_text_cluster_t** clusters, int* num_clusters, cairo_text_cluster_flags_t* cluster_flags )

FUNCTION: cairo_font_face_t*
cairo_scaled_font_get_font_face ( cairo_scaled_font_t* scaled_font )

FUNCTION: void
cairo_scaled_font_get_font_matrix ( cairo_scaled_font_t* scaled_font, cairo_matrix_t* font_matrix )

FUNCTION: void
cairo_scaled_font_get_ctm ( cairo_scaled_font_t* scaled_font, cairo_matrix_t* ctm )

FUNCTION: void
cairo_scaled_font_get_scale_matrix ( cairo_scaled_font_t* scaled_font, cairo_matrix_t* scale_matrix )

FUNCTION: void
cairo_scaled_font_get_font_options ( cairo_scaled_font_t* scaled_font, cairo_font_options_t* options )

! Toy fonts

FUNCTION: cairo_font_face_t*
cairo_toy_font_face_create ( c-string family, cairo_font_slant_t slant, cairo_font_weight_t weight )

FUNCTION: c-string
cairo_toy_font_face_get_family ( cairo_font_face_t* font_face )

FUNCTION: cairo_font_slant_t
cairo_toy_font_face_get_slant ( cairo_font_face_t* font_face )

FUNCTION: cairo_font_weight_t
cairo_toy_font_face_get_weight ( cairo_font_face_t* font_face )

! User fonts

FUNCTION: cairo_font_face_t*
cairo_user_font_face_create ( )

! User-font method signatures

CALLBACK: cairo_status_t
cairo_user_scaled_font_init_func_t ( cairo_scaled_font_t* scaled_font, cairo_t* cr, cairo_font_extents_t* extents )

CALLBACK: cairo_status_t
cairo_user_scaled_font_render_glyph_func_t ( cairo_scaled_font_t* scaled_font, ulong glyph, cairo_t* cr, cairo_text_extents_t* extents )

CALLBACK: cairo_status_t
cairo_user_scaled_font_text_to_glyphs_func_t ( cairo_scaled_font_t* scaled_font, char* utf8, int utf8_len, cairo_glyph_t** glyphs, int* num_glyphs, cairo_text_cluster_t** clusters, int* num_clusters, cairo_text_cluster_flags_t* cluster_flags )

CALLBACK: cairo_status_t
cairo_user_scaled_font_unicode_to_glyph_func_t ( cairo_scaled_font_t* scaled_font, ulong unicode, ulong* glyph_index )

! User-font method setters

FUNCTION: void
cairo_user_font_face_set_init_func ( cairo_font_face_t* font_face, cairo_user_scaled_font_init_func_t init_func )

FUNCTION: void
cairo_user_font_face_set_render_glyph_func ( cairo_font_face_t* font_face, cairo_user_scaled_font_render_glyph_func_t render_glyph_func )

FUNCTION: void
cairo_user_font_face_set_text_to_glyphs_func ( cairo_font_face_t* font_face, cairo_user_scaled_font_text_to_glyphs_func_t text_to_glyphs_func )

FUNCTION: void
cairo_user_font_face_set_unicode_to_glyph_func ( cairo_font_face_t* font_face, cairo_user_scaled_font_unicode_to_glyph_func_t unicode_to_glyph_func )

! User-font method getters

FUNCTION: cairo_user_scaled_font_init_func_t
cairo_user_font_face_get_init_func ( cairo_font_face_t* font_face )

FUNCTION: cairo_user_scaled_font_render_glyph_func_t
cairo_user_font_face_get_render_glyph_func ( cairo_font_face_t* font_face )

FUNCTION: cairo_user_scaled_font_text_to_glyphs_func_t
cairo_user_font_face_get_text_to_glyphs_func ( cairo_font_face_t* font_face )

FUNCTION: cairo_user_scaled_font_unicode_to_glyph_func_t
cairo_user_font_face_get_unicode_to_glyph_func ( cairo_font_face_t* font_face )

! Query functions

FUNCTION: cairo_operator_t
cairo_get_operator ( cairo_t* cr )

FUNCTION: cairo_pattern_t*
cairo_get_source ( cairo_t* cr )

FUNCTION: double
cairo_get_tolerance ( cairo_t* cr )

FUNCTION: cairo_antialias_t
cairo_get_antialias ( cairo_t* cr )

FUNCTION: cairo_bool_t
cairo_has_current_point ( cairo_t* cr )

FUNCTION: void
cairo_get_current_point ( cairo_t* cr, double* x, double* y )

FUNCTION: cairo_fill_rule_t
cairo_get_fill_rule ( cairo_t* cr )

FUNCTION: double
cairo_get_line_width ( cairo_t* cr )

FUNCTION: cairo_line_cap_t
cairo_get_line_cap ( cairo_t* cr )

FUNCTION: cairo_line_join_t
cairo_get_line_join ( cairo_t* cr )

FUNCTION: double
cairo_get_miter_limit ( cairo_t* cr )

FUNCTION: int
cairo_get_dash_count ( cairo_t* cr )

FUNCTION: void
cairo_get_dash ( cairo_t* cr, double* dashes, double* offset )

FUNCTION: void
cairo_get_matrix ( cairo_t* cr, cairo_matrix_t* matrix )

FUNCTION: cairo_surface_t*
cairo_get_target ( cairo_t* cr )

FUNCTION: cairo_surface_t*
cairo_get_group_target ( cairo_t* cr )

ENUM: cairo_path_data_type_t
    CAIRO_PATH_MOVE_TO
    CAIRO_PATH_LINE_TO
    CAIRO_PATH_CURVE_TO
    CAIRO_PATH_CLOSE_PATH ;

! NEED TO DO UNION HERE
STRUCT: cairo_path_data_t-point
    { x double }
    { y double } ;

STRUCT: cairo_path_data_t-header
    { type cairo_path_data_type_t }
    { length int } ;

UNION-STRUCT: cairo_path_data_t
    { point  cairo_path_data_t-point }
    { header cairo_path_data_t-header } ;

STRUCT: cairo_path_t
    { status   cairo_status_t     }
    { data     cairo_path_data_t* }
    { num_data int                } ;

FUNCTION: cairo_path_t*
cairo_copy_path ( cairo_t* cr )

FUNCTION: cairo_path_t*
cairo_copy_path_flat ( cairo_t* cr )

FUNCTION: void
cairo_append_path ( cairo_t* cr, cairo_path_t* path )

FUNCTION: void
cairo_path_destroy ( cairo_path_t* path )

! Error status queries

FUNCTION: cairo_status_t
cairo_status ( cairo_t* cr )

FUNCTION: c-string
cairo_status_to_string ( cairo_status_t status )

! Surface manipulation

FUNCTION: cairo_surface_t*
cairo_surface_create_similar ( cairo_surface_t* other, cairo_content_t content, int width, int height )

FUNCTION: cairo_surface_t*
cairo_surface_reference ( cairo_surface_t* surface )

FUNCTION: void
cairo_surface_finish ( cairo_surface_t* surface )

FUNCTION: void
cairo_surface_destroy ( cairo_surface_t* surface )

DESTRUCTOR: cairo_surface_destroy

FUNCTION: uint
cairo_surface_get_reference_count ( cairo_surface_t* surface )

FUNCTION: cairo_status_t
cairo_surface_status ( cairo_surface_t* surface )

ENUM: cairo_surface_type_t
    CAIRO_SURFACE_TYPE_IMAGE
    CAIRO_SURFACE_TYPE_PDF
    CAIRO_SURFACE_TYPE_PS
    CAIRO_SURFACE_TYPE_XLIB
    CAIRO_SURFACE_TYPE_XCB
    CAIRO_SURFACE_TYPE_GLITZ
    CAIRO_SURFACE_TYPE_QUARTZ
    CAIRO_SURFACE_TYPE_WIN32
    CAIRO_SURFACE_TYPE_BEOS
    CAIRO_SURFACE_TYPE_DIRECTFB
    CAIRO_SURFACE_TYPE_SVG
    CAIRO_SURFACE_TYPE_OS2
    CAIRO_SURFACE_TYPE_WIN32_PRINTING
    CAIRO_SURFACE_TYPE_QUARTZ_IMAGE ;

FUNCTION: cairo_surface_type_t
cairo_surface_get_type ( cairo_surface_t* surface )

FUNCTION: cairo_content_t
cairo_surface_get_content ( cairo_surface_t* surface )

FUNCTION: cairo_status_t
cairo_surface_write_to_png ( cairo_surface_t* surface, c-string filename )

FUNCTION: cairo_status_t
cairo_surface_write_to_png_stream ( cairo_surface_t* surface, cairo_write_func_t write_func, void* closure )

FUNCTION: void*
cairo_surface_get_user_data ( cairo_surface_t* surface, cairo_user_data_key_t* key )

FUNCTION: cairo_status_t
cairo_surface_set_user_data ( cairo_surface_t* surface, cairo_user_data_key_t* key, void* user_data, cairo_destroy_func_t destroy )

FUNCTION: void
cairo_surface_get_font_options ( cairo_surface_t* surface, cairo_font_options_t* options )

FUNCTION: void
cairo_surface_flush ( cairo_surface_t* surface )

FUNCTION: void
cairo_surface_mark_dirty ( cairo_surface_t* surface )

FUNCTION: void
cairo_surface_mark_dirty_rectangle ( cairo_surface_t* surface, int x, int y, int width, int height )

FUNCTION: void
cairo_surface_set_device_offset ( cairo_surface_t* surface, double x_offset, double y_offset )

FUNCTION: void
cairo_surface_get_device_offset ( cairo_surface_t* surface, double* x_offset, double* y_offset )

FUNCTION: void
cairo_surface_set_fallback_resolution ( cairo_surface_t* surface, double x_pixels_per_inch, double y_pixels_per_inch )

FUNCTION: void
cairo_surface_get_fallback_resolution ( cairo_surface_t* surface, double* x_pixels_per_inch, double* y_pixels_per_inch )

FUNCTION: void
cairo_surface_copy_page ( cairo_surface_t* surface )

FUNCTION: void
cairo_surface_show_page ( cairo_surface_t* surface )

FUNCTION: cairo_bool_t
cairo_surface_has_show_text_glyphs ( cairo_surface_t* surface )

! Image-surface functions

ENUM: cairo_format_t
    CAIRO_FORMAT_ARGB32
    CAIRO_FORMAT_RGB24
    CAIRO_FORMAT_A8
    CAIRO_FORMAT_A1 ;

FUNCTION: cairo_surface_t*
cairo_image_surface_create ( cairo_format_t format, int width, int height )

FUNCTION: int
cairo_format_stride_for_width ( cairo_format_t format, int width )

FUNCTION: cairo_surface_t*
cairo_image_surface_create_for_data ( char* data, cairo_format_t format, int width, int height, int stride )

FUNCTION: uchar*
cairo_image_surface_get_data ( cairo_surface_t* surface )

FUNCTION: cairo_format_t
cairo_image_surface_get_format ( cairo_surface_t* surface )

FUNCTION: int
cairo_image_surface_get_width ( cairo_surface_t* surface )

FUNCTION: int
cairo_image_surface_get_height ( cairo_surface_t* surface )

FUNCTION: int
cairo_image_surface_get_stride ( cairo_surface_t* surface )

FUNCTION: cairo_surface_t*
cairo_image_surface_create_from_png ( c-string filename )

FUNCTION: cairo_surface_t*
cairo_image_surface_create_from_png_stream ( cairo_read_func_t read_func, void* closure )

! Pattern creation functions

FUNCTION: cairo_pattern_t*
cairo_pattern_create_rgb ( double red, double green, double blue )

FUNCTION: cairo_pattern_t*
cairo_pattern_create_rgba ( double red, double green, double blue, double alpha )

FUNCTION: cairo_pattern_t*
cairo_pattern_create_for_surface ( cairo_surface_t* surface )

FUNCTION: cairo_pattern_t*
cairo_pattern_create_linear ( double x0, double y0, double x1, double y1 )

FUNCTION: cairo_pattern_t*
cairo_pattern_create_radial ( double cx0, double cy0, double radius0, double cx1, double cy1, double radius1 )

FUNCTION: cairo_pattern_t*
cairo_pattern_reference ( cairo_pattern_t* pattern )

FUNCTION: void
cairo_pattern_destroy ( cairo_pattern_t* pattern )

FUNCTION: uint
cairo_pattern_get_reference_count ( cairo_pattern_t* pattern )

FUNCTION: cairo_status_t
cairo_pattern_status ( cairo_pattern_t* pattern )

FUNCTION: void*
cairo_pattern_get_user_data ( cairo_pattern_t* pattern, cairo_user_data_key_t* key )

FUNCTION: cairo_status_t
cairo_pattern_set_user_data ( cairo_pattern_t* pattern, cairo_user_data_key_t* key, void* user_data, cairo_destroy_func_t destroy )

ENUM: cairo_pattern_type_t
    CAIRO_PATTERN_TYPE_SOLID
    CAIRO_PATTERN_TYPE_SURFACE
    CAIRO_PATTERN_TYPE_LINEAR
    CAIRO_PATTERN_TYPE_RADIAL ;

FUNCTION: cairo_pattern_type_t
cairo_pattern_get_type ( cairo_pattern_t* pattern )

FUNCTION: void
cairo_pattern_add_color_stop_rgb ( cairo_pattern_t* pattern, double offset, double red, double green, double blue )

FUNCTION: void
cairo_pattern_add_color_stop_rgba ( cairo_pattern_t* pattern, double offset, double red, double green, double blue, double alpha )

FUNCTION: void
cairo_pattern_set_matrix ( cairo_pattern_t* pattern, cairo_matrix_t* matrix )

FUNCTION: void
cairo_pattern_get_matrix ( cairo_pattern_t* pattern, cairo_matrix_t* matrix )

ENUM: cairo_extend_t
    CAIRO_EXTEND_NONE
    CAIRO_EXTEND_REPEAT
    CAIRO_EXTEND_REFLECT
    CAIRO_EXTEND_PAD ;

FUNCTION: void
cairo_pattern_set_extend ( cairo_pattern_t* pattern, cairo_extend_t extend )

FUNCTION: cairo_extend_t
cairo_pattern_get_extend ( cairo_pattern_t* pattern )

ENUM: cairo_filter_t
    CAIRO_FILTER_FAST
    CAIRO_FILTER_GOOD
    CAIRO_FILTER_BEST
    CAIRO_FILTER_NEAREST
    CAIRO_FILTER_BILINEAR
    CAIRO_FILTER_GAUSSIAN ;

FUNCTION: void
cairo_pattern_set_filter ( cairo_pattern_t* pattern, cairo_filter_t filter )

FUNCTION: cairo_filter_t
cairo_pattern_get_filter ( cairo_pattern_t* pattern )

FUNCTION: cairo_status_t
cairo_pattern_get_rgba ( cairo_pattern_t* pattern, double* red, double* green, double* blue, double* alpha )

FUNCTION: cairo_status_t
cairo_pattern_get_surface ( cairo_pattern_t* pattern, cairo_surface_t** surface )

FUNCTION: cairo_status_t
cairo_pattern_get_color_stop_rgba ( cairo_pattern_t* pattern, int index, double* offset, double* red, double* green, double* blue, double* alpha )

FUNCTION: cairo_status_t
cairo_pattern_get_color_stop_count ( cairo_pattern_t* pattern, int* count )

FUNCTION: cairo_status_t
cairo_pattern_get_linear_points ( cairo_pattern_t* pattern, double* x0, double* y0, double* x1, double* y1 )

FUNCTION: cairo_status_t
cairo_pattern_get_radial_circles ( cairo_pattern_t* pattern, double* x0, double* y0, double* r0, double* x1, double* y1, double* r1 )

! Matrix functions

FUNCTION: void
cairo_matrix_init ( cairo_matrix_t* matrix, double xx, double yx, double xy, double yy, double x0, double y0 )

FUNCTION: void
cairo_matrix_init_identity ( cairo_matrix_t* matrix )

FUNCTION: void
cairo_matrix_init_translate ( cairo_matrix_t* matrix, double tx, double ty )

FUNCTION: void
cairo_matrix_init_scale ( cairo_matrix_t* matrix, double sx, double sy )

FUNCTION: void
cairo_matrix_init_rotate ( cairo_matrix_t* matrix, double radians )

FUNCTION: void
cairo_matrix_translate ( cairo_matrix_t* matrix, double tx, double ty )

FUNCTION: void
cairo_matrix_scale ( cairo_matrix_t* matrix, double sx, double sy )

FUNCTION: void
cairo_matrix_rotate ( cairo_matrix_t* matrix, double radians )

FUNCTION: cairo_status_t
cairo_matrix_invert ( cairo_matrix_t* matrix )

FUNCTION: void
cairo_matrix_multiply ( cairo_matrix_t* result, cairo_matrix_t* a, cairo_matrix_t* b )

FUNCTION: void
cairo_matrix_transform_distance ( cairo_matrix_t* matrix, double* dx, double* dy )

FUNCTION: void
cairo_matrix_transform_point ( cairo_matrix_t* matrix, double* x, double* y )

! Functions to be used while debugging (not intended for use in production code)
FUNCTION: void
cairo_debug_reset_static_data ( )
