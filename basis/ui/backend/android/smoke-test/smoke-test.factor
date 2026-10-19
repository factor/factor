! Run in the Android emulator with -run=ui.backend.android.smoke-test.
USING: accessors io kernel namespaces opengl opengl.gl sequences system
threads
ui ui.backend ui.clipboards ui.gadgets ui.gadgets.labels
ui.gadgets.worlds tools.test ;
IN: ui.backend.android.smoke-test

: exercise-android-ui ( world -- )
    "Android UI exercise started" print flush
    "Factor Android 😀 אבג" >clipboard
    clipboard> "Factor Android 😀 אבג" assert=
    dup set-gl-context
    GL_VENDOR glGetString empty? [ "Missing GLES vendor" throw ] when
    GL_VERSION glGetString "OpenGL ES" subseq? not
    [ "Android did not create an OpenGL ES context" throw ] when
    "Android UI exercise passed" print flush
    close-window ;

: run-smoke-test ( -- )
    ui-backend-available? [ "Android UI unavailable" throw ] unless
    [
        "Android UI opening window" print flush
        "Factor Android UI" <label> "Factor Android smoke test" open-window*
        "Android UI window opened" print flush
        '[ _ exercise-android-ui ] "Android UI smoke test" spawn drop
    ] with-ui
    "Android UI smoke test passed" print ;

MAIN: run-smoke-test
