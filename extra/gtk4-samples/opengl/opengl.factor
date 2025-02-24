! Copyright (C) 2024 knottio.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.strings alien.syntax destructors
gio.ffi gobject-introspection.standard-types gobject.ffi
gtk4.ffi io.encodings.utf8 kernel opengl.capabilities opengl.gl
prettyprint ;
IN: gtk4-samples.opengl

: string>utf8 ( str -- utf8 ) utf8 string>alien ;

: signal-connect ( instance name callback data -- )
    [ string>utf8 ] 2dip g_signal_connect drop ;

: render ( -- callback )
    [| gl-area ctx user-data |
        0 0 0.5 1.0 glClearColor
        GL_COLOR_BUFFER_BIT glClear
        t
    ] GtkGLArea:render ;

: activate ( -- callback )
    [| app user-data |
        app gtk_application_window_new :> win
        win "Factor GTK4 OpenGL" string>utf8 gtk_window_set_title
        win 200 200 gtk_window_set_default_size

        gtk_gl_area_new :> gl-area
        gl-area "render" render f signal-connect
        win gl-area gtk_window_set_child

        win gtk_window_present
    ] GApplication:activate ;

:: main ( -- )
    [
        "org.factorcode.gtk4-samples.opengl" string>utf8 G_APPLICATION_DEFAULT_FLAGS
        gtk_application_new &g_object_unref :> app
        app "activate" activate f signal-connect

        app 0 f g_application_run drop
    ] with-destructors ;

MAIN: main
