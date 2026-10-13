USING: init kernel namespaces python.ffi ;
IN: python.lifecycle

SYMBOL: python-used?

! Do not initialize the interpreter just because its bindings are in an image.
: ensure-python ( -- )
    Py_IsInitialized [ Py_Initialize ] unless
    t python-used? set-global ;

: finalize-python ( -- )
    python-used? get [
        Py_IsInitialized [ Py_Finalize ] when
        f python-used? set-global
    ] when ;

STARTUP-HOOK: [ f python-used? set-global ]
SHUTDOWN-HOOK: [ finalize-python ]
