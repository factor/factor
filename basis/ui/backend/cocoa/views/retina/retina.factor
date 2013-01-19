USING: alien.c-types cocoa cocoa.subclassing core-text kernel
math namespaces opengl ;
IN: ui.backend.cocoa.views.retina

CLASS: BaseFactorView < NSOpenGLView NSTextInput
[
    METHOD: void prepareOpenGL [
        self 1 -> setWantsBestResolutionOpenGLSurface:
        self -> backingScaleFactor dup 1.0 > [
            gl-scale-factor set-global t retina? set-global
        ] [ drop ] if
    ]
]
