! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.enums alien.strings gobject.ffi gtk.ffi gdk.gl.ffi
gtk.gl.ffi io.encodings.utf8 kernel locals math opengl.gl prettyprint ;
IN: gir.samples.lowlevel.opengl

! This sample based on
! http://code.valaide.org/content/simple-opengl-sample-using-gtkglext

:: on-configure ( sender event user-data -- result )
    sender gtk_widget_get_gl_context :> gl-context
    sender gtk_widget_get_gl_window :> gl-drawable

    gl-drawable gl-context gdk_gl_drawable_gl_begin dup
    [
        0 0 200 200 glViewport
        gl-drawable gdk_gl_drawable_gl_end
    ] when ;

:: on-expose ( sender event user-data -- result )
    sender gtk_widget_get_gl_context :> gl-context
    sender gtk_widget_get_gl_window :> gl-drawable

    gl-drawable gl-context gdk_gl_drawable_gl_begin dup
    [
        GL_COLOR_BUFFER_BIT glClear

        GL_TRIANGLES glBegin
        1.0 0.0 0.0 glColor3f
        0 1 glVertex2i
        0.0 1.0 0.0 glColor3f
        -1 -1 glVertex2i
        0.0 0.0 1.0 glColor3f
        1 -1 glVertex2i
        glEnd
 
        gl-drawable gdk_gl_drawable_is_double_buffered 1 =
        [ gl-drawable gdk_gl_drawable_swap_buffers ]
        [ glFlush ] if

        gl-drawable gdk_gl_drawable_gl_end
    ] when ;
    
:: opengl-win ( -- window )  
    GTK_WINDOW_TOPLEVEL gtk_window_new :> window

    window
    [ "OpenGL" utf8 string>alien gtk_window_set_title ]
    [ 200 200 gtk_window_set_default_size ]
    [ GTK_WIN_POS_CENTER gtk_window_set_position ] tri

    GDK_GL_MODE_RGBA enum>number
    gdk_gl_config_new_by_mode :> gl-config
    
    window gl-config f t GDK_GL_RGBA_TYPE enum>number
    gtk_widget_set_gl_capability drop

    window "configure-event" utf8 string>alien
    [ on-configure ] GtkWidget:configure-event
    f f 0 g_signal_connect_data drop

    window "expose-event" utf8 string>alien
    [ on-expose ] GtkWidget:expose-event
    f f 0 g_signal_connect_data drop

    window ;

:: opengl-main ( -- )
    f f gtk_init
    f f gtk_gl_init
    opengl-win :> window

    window "destroy" utf8 string>alien
    [ 2drop gtk_main_quit ] GtkObject:destroy
    f f 0 g_signal_connect_data drop

    window gtk_widget_show_all
    
    gtk_main ;

MAIN: opengl-main

