! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.destructors alien.syntax classes.struct system ;
IN: android.ffi

LIBRARY: factor-android

C-LIBRARY: factor-android {
    { android "libfactor-android.so" }
    { unix "libfactor-android.so" }
}

CONSTANT: FACTOR_ANDROID_EVENT_SURFACE 1
CONSTANT: FACTOR_ANDROID_EVENT_SURFACE_LOST 2
CONSTANT: FACTOR_ANDROID_EVENT_RESIZE 3
CONSTANT: FACTOR_ANDROID_EVENT_FOCUS 4
CONSTANT: FACTOR_ANDROID_EVENT_POINTER_DOWN 5
CONSTANT: FACTOR_ANDROID_EVENT_POINTER_UP 6
CONSTANT: FACTOR_ANDROID_EVENT_POINTER_MOVE 7
CONSTANT: FACTOR_ANDROID_EVENT_KEY_DOWN 8
CONSTANT: FACTOR_ANDROID_EVENT_KEY_UP 9
CONSTANT: FACTOR_ANDROID_EVENT_QUIT 10
CONSTANT: FACTOR_ANDROID_EVENT_TEXT 11

STRUCT: factor-android-event
    { type int }
    { code int }
    { modifiers int }
    { pointer int }
    { x float }
    { y float }
    { character uint } ;

STRUCT: factor-android-text-metrics
    { width float } { ascent float } { descent float } { height float }
    { leading float } { cap-height float } { x-height float } ;

FUNCTION: int factor_android_poll_event ( factor-android-event* event )
FUNCTION: int factor_android_wait_for_surface ( int timeout_ms )
FUNCTION: int factor_android_surface_width ( )
FUNCTION: int factor_android_surface_height ( )
FUNCTION: float factor_android_density ( )

FUNCTION: int factor_android_gl_open ( )
FUNCTION: int factor_android_gl_make_current ( )
FUNCTION: int factor_android_gl_swap ( )
FUNCTION: void factor_android_gl_close ( )
FUNCTION: void factor_android_gl_suspend ( )
FUNCTION: void* factor_android_gl_proc ( c-string name )
FUNCTION: void* factor_android_gl_context ( )

FUNCTION: void* factor_android_clipboard_get ( )
FUNCTION: void factor_android_clipboard_set ( c-string text )
FUNCTION: void factor_android_free ( void* pointer )
FUNCTION: void factor_android_finish ( )
FUNCTION: void factor_android_show_keyboard ( int visible )
FUNCTION: void* factor_android_text_create ( uchar* text, size_t length, c-string family,
    float size, int bold, int italic )
FUNCTION: void factor_android_text_destroy ( void* text )
DESTRUCTOR: factor_android_text_destroy
FUNCTION: int factor_android_text_metrics ( void* text,
    factor-android-text-metrics* metrics )
FUNCTION: float factor_android_text_offset_x ( void* text, int codepoint )
FUNCTION: int factor_android_text_x_offset ( void* text, float x )
FUNCTION: int factor_android_text_selection_spans ( void* text, int start,
    int end, float* spans, int capacity )
FUNCTION: uchar* factor_android_text_render ( void* text, uint foreground,
    uint background, int selection-start, int selection-end,
    uint selection-color, int* width, int* height )
FUNCTION: void factor_android_open_url ( c-string url )
