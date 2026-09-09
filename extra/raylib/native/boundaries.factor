! Optional headless ABI tests. Register the C fixture as "raylib-api60" and
! set RAYLIB_API60_FONT to upstream examples/text/resources/anonymous_pro_bold.ttf.
! api60.c uses the real raylib 6.0 header and library as an independent oracle.
USING: accessors alien alien.c-types alien.data alien.syntax arrays
classes.struct compiler.test continuations kernel locals math
namespaces raylib sequences system tools.test words ;
IN: raylib.tests
FROM: alien.c-types => float ;

LIBRARY: raylib-api60
CALLBACK: void RaylibAnimationProbe ( Model* model, ModelAnimation* animation )
CALLBACK: bool RaylibFontProbe ( void* data, int length )
FUNCTION: size_t raylib_api60_layout ( int index )
FUNCTION: bool raylib_api60_animation_case ( RaylibAnimationProbe probe )
FUNCTION: void raylib_api60_audio_case ( AudioCallback callback )
FUNCTION: bool raylib_api60_glyphs_valid ( GlyphInfo* glyphs, int count )
FUNCTION: bool raylib_api60_font_case ( c-string path, RaylibFontProbe probe )
FUNCTION: bool raylib_api60_controls ( c-string path )

{ t } [ "RAYLIB_API60_FONT" os-env raylib_api60_controls ] unit-test

! Every field in the changed structs is checked against sizeof/offsetof in C.
{ t } [
    {
        [ ModelSkeleton heap-size ] [ "boneCount" ModelSkeleton offset-of ]
        [ "_bones" ModelSkeleton offset-of ] [ "bindPose" ModelSkeleton offset-of ]
        [ Model heap-size ] [ "transform" Model offset-of ]
        [ "meshCount" Model offset-of ] [ "materialCount" Model offset-of ]
        [ "_meshes" Model offset-of ] [ "_materials" Model offset-of ]
        [ "meshMaterial" Model offset-of ] [ "skeleton" Model offset-of ]
        [ "currentPose" Model offset-of ] [ "boneMatrices" Model offset-of ]
        [ ModelAnimation heap-size ] [ "name" ModelAnimation offset-of ]
        [ "boneCount" ModelAnimation offset-of ] [ "keyframeCount" ModelAnimation offset-of ]
        [ "keyframePoses" ModelAnimation offset-of ] [ AudioStream heap-size ]
        [ "buffer" AudioStream offset-of ] [ "processor" AudioStream offset-of ]
        [ "sampleRate" AudioStream offset-of ] [ "sampleSize" AudioStream offset-of ]
        [ "channels" AudioStream offset-of ]
    } [ call( -- n ) ] map
    25 <iota> [ raylib_api60_layout ] map =
] unit-test

! An int declaration sends the frame in a different register bank. Do not call
! the old ABI with an unspecified float register (possibly an invalid index).
{ float } [ \ update-model-animation def>> fourth third ] unit-test
\ update-model-animation def>> fourth third float = [
    { t } [ [
        [ [ Model memory>struct ] [ ModelAnimation memory>struct ] bi*
          0.5 update-model-animation ] RaylibAnimationProbe
        [ raylib_api60_animation_case ] with-callback
    ] compile-call ] unit-test
] when

SYMBOL: raylib-audio-frames
{ 0x80000005 } [ [
    [ nip raylib-audio-frames set-global ] AudioCallback
    [ raylib_api60_audio_case ] with-callback
    raylib-audio-frames get-global
] compile-call ] unit-test

! Check arity before making a seven-argument call: the old binding would let C
! write through an unspecified seventh argument and could corrupt the process.
{ 7 } [ \ load-font-data def>> fourth length ] unit-test

:: raylib-font-probe ( data length -- valid? )
    -1 int <ref> :> count
    data length 24 f 0 FONT_DEFAULT count
    \ load-font-data execute( data length size codepoints codepoint-count type glyph-count -- glyphs )
    :> glyphs
    [ glyphs count int deref raylib_api60_glyphs_valid ]
    [ glyphs count int deref unload-font-data ] finally ;

\ load-font-data def>> fourth length 7 = [
    { t } [ [
        [ raylib-font-probe ] RaylibFontProbe [| callback |
            "RAYLIB_API60_FONT" os-env callback raylib_api60_font_case
        ] with-callback
    ] compile-call ] unit-test
] when
