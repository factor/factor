! Copyright (C) 2019 Jack Lucas
! See https://factorcode.org/license.txt for BSD license.
! These should be complete bindings to the Raylib library. (v4.0)
! Most of the comments are included from the original header
! for your convenience.
USING: accessors alien alien.c-types alien.destructors
alien.libraries alien.syntax classes.struct combinators kernel
math raylib.util sequences sequences.private system ;
IN: raylib
FROM: alien.c-types => float ;

<<
"raylib" {
    { [ os windows? ] [ "raylib.dll" ] }
    { [ os macosx? ] [ "libraylib.dylib" ] }
    { [ os unix? ] [ "libraylib.so" ] }
} cond cdecl add-library

"raylib" deploy-library
>>

LIBRARY: raylib

! Last updated 1/23/2023
CONSTANT: RAYLIB_VERSION_MAJOR 4
CONSTANT: RAYLIB_VERSION_MINOR 5
CONSTANT: RAYLIB_VERSION_PATCH 0
CONSTANT: RAYLIB_VERSION  "4.5"

! Enumerations ---------------------------------------------------------

! Putting some of the #define's as enums.
ENUM: ConfigFlags
    { FLAG_VSYNC_HINT         0x00000040 }   ! Set to try enabling V-Sync on GPU
    { FLAG_FULLSCREEN_MODE    0x00000002 }   ! Set to run program in fullscreen
    { FLAG_WINDOW_RESIZABLE   0x00000004 }   ! Set to allow resizable window
    { FLAG_WINDOW_UNDECORATED 0x00000008 }   ! Set to disable window decoration (frame and buttons)
    { FLAG_WINDOW_HIDDEN      0x00000080 }   ! Set to hide window
    { FLAG_WINDOW_MINIMIZED   0x00000200 }   ! Set to minimize window (iconify)
    { FLAG_WINDOW_MAXIMIZED   0x00000400 }   ! Set to maximize window (expanded to monitor)
    { FLAG_WINDOW_UNFOCUSED   0x00000800 }   ! Set to window non focused
    { FLAG_WINDOW_TOPMOST     0x00001000 }   ! Set to window always on top
    { FLAG_WINDOW_ALWAYS_RUN  0x00000100 }   ! Set to allow windows running while minimized
    { FLAG_WINDOW_TRANSPARENT 0x00000010 }   ! Set to allow transparent framebuffer
    { FLAG_WINDOW_HIGHDPI     0x00002000 }   ! Set to support HighDPI
    { FLAG_MSAA_4X_HINT       0x00000020 }   ! Set to try enabling MSAA 4X
    { FLAG_INTERLACED_HINT    0x00010000 } ; ! Set to try enabling interlaced video format (for V3D)

ENUM: TraceLogLevel
    LOG_ALL
    LOG_TRACE
    LOG_DEBUG
    LOG_INFO
    LOG_WARNING
    LOG_ERROR
    LOG_FATAL
    LOG_NONE ;

ENUM: KeyboardKey
    { KEY_NULL            0 }      ! Key: NULL, used for no key pressed
    ! Alphanumeric keys
    { KEY_APOSTROPHE      39 }     ! Key: '
    { KEY_COMMA           44 }     ! Key: ,
    { KEY_MINUS           45 }     ! Key: -
    { KEY_PERIOD          46 }     ! Key: .
    { KEY_SLASH           47 }     ! Key: /
    { KEY_ZERO            48 }     ! Key: 0
    { KEY_ONE             49 }     ! Key: 1
    { KEY_TWO             50 }     ! Key: 2
    { KEY_THREE           51 }     ! Key: 3
    { KEY_FOUR            52 }     ! Key: 4
    { KEY_FIVE            53 }     ! Key: 5
    { KEY_SIX             54 }     ! Key: 6
    { KEY_SEVEN           55 }     ! Key: 7
    { KEY_EIGHT           56 }     ! Key: 8
    { KEY_NINE            57 }     ! Key: 9
    { KEY_SEMICOLON       59 }     ! Key: ;
    { KEY_EQUAL           61 }     ! Key: =
    { KEY_A               65 }     ! Key: A | a
    { KEY_B               66 }     ! Key: B | b
    { KEY_C               67 }     ! Key: C | c
    { KEY_D               68 }     ! Key: D | d
    { KEY_E               69 }     ! Key: E | e
    { KEY_F               70 }     ! Key: F | f
    { KEY_G               71 }     ! Key: G | g
    { KEY_H               72 }     ! Key: H | h
    { KEY_I               73 }     ! Key: I | i
    { KEY_J               74 }     ! Key: J | j
    { KEY_K               75 }     ! Key: K | k
    { KEY_L               76 }     ! Key: L | l
    { KEY_M               77 }     ! Key: M | m
    { KEY_N               78 }     ! Key: N | n
    { KEY_O               79 }     ! Key: O | o
    { KEY_P               80 }     ! Key: P | p
    { KEY_Q               81 }     ! Key: Q | q
    { KEY_R               82 }     ! Key: R | r
    { KEY_S               83 }     ! Key: S | s
    { KEY_T               84 }     ! Key: T | t
    { KEY_U               85 }     ! Key: U | u
    { KEY_V               86 }     ! Key: V | v
    { KEY_W               87 }     ! Key: W | w
    { KEY_X               88 }     ! Key: X | x
    { KEY_Y               89 }     ! Key: Y | y
    { KEY_Z               90 }     ! Key: Z | z
    { KEY_LEFT_BRACKET    91 }     ! Key: [
    { KEY_BACKSLASH       92 }     ! Key: '\'
    { KEY_RIGHT_BRACKET   93 }     ! Key: ]
    { KEY_GRAVE           96 }     ! Key: `
    ! Function keys
    { KEY_SPACE           32 }     ! Key: Space
    { KEY_ESCAPE          256 }    ! Key: Esc
    { KEY_ENTER           257 }    ! Key: Enter
    { KEY_TAB             258 }    ! Key: Tab
    { KEY_BACKSPACE       259 }    ! Key: Backspace
    { KEY_INSERT          260 }    ! Key: Ins
    { KEY_DELETE          261 }    ! Key: Del
    { KEY_RIGHT           262 }    ! Key: Cursor right
    { KEY_LEFT            263 }    ! Key: Cursor left
    { KEY_DOWN            264 }    ! Key: Cursor down
    { KEY_UP              265 }    ! Key: Cursor up
    { KEY_PAGE_UP         266 }    ! Key: Page up
    { KEY_PAGE_DOWN       267 }    ! Key: Page down
    { KEY_HOME            268 }    ! Key: Home
    { KEY_END             269 }    ! Key: End
    { KEY_CAPS_LOCK       280 }    ! Key: Caps lock
    { KEY_SCROLL_LOCK     281 }    ! Key: Scroll down
    { KEY_NUM_LOCK        282 }    ! Key: Num lock
    { KEY_PRINT_SCREEN    283 }    ! Key: Print screen
    { KEY_PAUSE           284 }    ! Key: Pause
    { KEY_F1              290 }    ! Key: F1
    { KEY_F2              291 }    ! Key: F2
    { KEY_F3              292 }    ! Key: F3
    { KEY_F4              293 }    ! Key: F4
    { KEY_F5              294 }    ! Key: F5
    { KEY_F6              295 }    ! Key: F6
    { KEY_F7              296 }    ! Key: F7
    { KEY_F8              297 }    ! Key: F8
    { KEY_F9              298 }    ! Key: F9
    { KEY_F10             299 }    ! Key: F10
    { KEY_F11             300 }    ! Key: F11
    { KEY_F12             301 }    ! Key: F12
    { KEY_LEFT_SHIFT      340 }    ! Key: Shift left
    { KEY_LEFT_CONTROL    341 }    ! Key: Control left
    { KEY_LEFT_ALT        342 }    ! Key: Alt left
    { KEY_LEFT_SUPER      343 }    ! Key: Super left
    { KEY_RIGHT_SHIFT     344 }    ! Key: Shift right
    { KEY_RIGHT_CONTROL   345 }    ! Key: Control right
    { KEY_RIGHT_ALT       346 }    ! Key: Alt right
    { KEY_RIGHT_SUPER     347 }    ! Key: Super right
    { KEY_KB_MENU         348 }    ! Key: KB menu
    ! Keypad keys
    { KEY_KP_0            320 }    ! Key: Keypad 0
    { KEY_KP_1            321 }    ! Key: Keypad 1
    { KEY_KP_2            322 }    ! Key: Keypad 2
    { KEY_KP_3            323 }    ! Key: Keypad 3
    { KEY_KP_4            324 }    ! Key: Keypad 4
    { KEY_KP_5            325 }    ! Key: Keypad 5
    { KEY_KP_6            326 }    ! Key: Keypad 6
    { KEY_KP_7            327 }    ! Key: Keypad 7
    { KEY_KP_8            328 }    ! Key: Keypad 8
    { KEY_KP_9            329 }    ! Key: Keypad 9
    { KEY_KP_DECIMAL      330 }    ! Key: Keypad .
    { KEY_KP_DIVIDE       331 }    ! Key: Keypad /
    { KEY_KP_MULTIPLY     332 }    ! Key: Keypad *
    { KEY_KP_SUBTRACT     333 }    ! Key: Keypad -
    { KEY_KP_ADD          334 }    ! Key: Keypad +
    { KEY_KP_ENTER        335 }    ! Key: Keypad Enter
    { KEY_KP_EQUAL        336 }    ! Key: Keypad =
    ! Android key buttons
    { KEY_BACK            4 }      ! Key: Android back button
    { KEY_MENU            82 }     ! Key: Android menu button
    { KEY_VOLUME_UP       24 }     ! Key: Android volume up button
    { KEY_VOLUME_DOWN     25 } ;   ! Key: Android volume down button

ENUM: MouseButton
    MOUSE_BUTTON_LEFT        ! Mouse button left
    MOUSE_BUTTON_RIGHT       ! Mouse button right
    MOUSE_BUTTON_MIDDLE      ! Mouse button middle (pressed wheel)
    MOUSE_BUTTON_SIDE        ! Mouse button side (advanced mouse device)
    MOUSE_BUTTON_EXTRA       ! Mouse button extra (advanced mouse device)
    MOUSE_BUTTON_FORWARD     ! Mouse button forward (advanced mouse device)
    MOUSE_BUTTON_BACK ;      ! Mouse button back (advanced mouse device)

ENUM: MouseCursor
    MOUSE_CURSOR_DEFAULT        ! Default pointer shape
    MOUSE_CURSOR_ARROW          ! Arrow shape
    MOUSE_CURSOR_IBEAM          ! Text writing cursor shape
    MOUSE_CURSOR_CROSSHAIR      ! Cross shape
    MOUSE_CURSOR_POINTING_HAND  ! Pointing hand cursor
    MOUSE_CURSOR_RESIZE_EW      ! Horizontal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NS      ! Vertical resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NWSE    ! Top-left to bottom-right diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NESW    ! The top-right to bottom-left diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_ALL     ! The omni-directional resize/move cursor shape
    MOUSE_CURSOR_NOT_ALLOWED ;  ! The operation-not-allowed shape

ENUM: GamepadButton
    GAMEPAD_BUTTON_UNKNOWN             ! Unknown button, just for error checking
    GAMEPAD_BUTTON_LEFT_FACE_UP        ! Gamepad left DPAD up button
    GAMEPAD_BUTTON_LEFT_FACE_RIGHT     ! Gamepad left DPAD right button
    GAMEPAD_BUTTON_LEFT_FACE_DOWN      ! Gamepad left DPAD down button
    GAMEPAD_BUTTON_LEFT_FACE_LEFT      ! Gamepad left DPAD left button
    GAMEPAD_BUTTON_RIGHT_FACE_UP       ! Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
    GAMEPAD_BUTTON_RIGHT_FACE_RIGHT    ! Gamepad right button right (i.e. PS3: Square, Xbox: X)
    GAMEPAD_BUTTON_RIGHT_FACE_DOWN     ! Gamepad right button down (i.e. PS3: Cross, Xbox: A)
    GAMEPAD_BUTTON_RIGHT_FACE_LEFT     ! Gamepad right button left (i.e. PS3: Circle, Xbox: B)
    GAMEPAD_BUTTON_LEFT_TRIGGER_1      ! Gamepad top/back trigger left (first), it could be a trailing button
    GAMEPAD_BUTTON_LEFT_TRIGGER_2      ! Gamepad top/back trigger left (second), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_1     ! Gamepad top/back trigger right (one), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_2     ! Gamepad top/back trigger right (second), it could be a trailing button
    GAMEPAD_BUTTON_MIDDLE_LEFT         ! Gamepad center buttons, left one (i.e. PS3: Select)
    GAMEPAD_BUTTON_MIDDLE              ! Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
    GAMEPAD_BUTTON_MIDDLE_RIGHT        ! Gamepad center buttons, right one (i.e. PS3: Start)
    GAMEPAD_BUTTON_LEFT_THUMB          ! Gamepad joystick pressed button left
    GAMEPAD_BUTTON_RIGHT_THUMB ;       ! Gamepad joystick pressed button right

ENUM: GamepadAxis
    GAMEPAD_AXIS_LEFT_X                ! Gamepad left stick X axis
    GAMEPAD_AXIS_LEFT_Y                ! Gamepad left stick Y axis
    GAMEPAD_AXIS_RIGHT_X               ! Gamepad right stick X axis
    GAMEPAD_AXIS_RIGHT_Y               ! Gamepad right stick Y axis
    GAMEPAD_AXIS_LEFT_TRIGGER          ! Gamepad back trigger left, pressure level: [1..-1]
    GAMEPAD_AXIS_RIGHT_TRIGGER ;       ! Gamepad back trigger right, pressure level: [1..-1]

ENUM: MaterialMapIndex
    MATERIAL_MAP_ALBEDO            ! Albedo material (same as: MATERIAL_MAP_DIFFUSE)
    MATERIAL_MAP_METALNESS         ! Metalness material (same as: MATERIAL_MAP_SPECULAR)
    MATERIAL_MAP_NORMAL            ! Normal material
    MATERIAL_MAP_ROUGHNESS         ! Roughness material
    MATERIAL_MAP_OCCLUSION         ! Ambient occlusion material
    MATERIAL_MAP_EMISSION          ! Emission material
    MATERIAL_MAP_HEIGHT            ! Heightmap material
    MATERIAL_MAP_CUBEMAP           ! Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_IRRADIANCE        ! Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_PREFILTER         ! Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_BRDF ;            ! Brdf material

ALIAS: MATERIAL_MAP_DIFFUSE MATERIAL_MAP_ALBEDO
ALIAS: MATERIAL_MAP_SPECULAR MATERIAL_MAP_METALNESS

ENUM: ShaderLocationIndex
    SHADER_LOC_VERTEX_POSITION     ! Shader location: vertex attribute: position
    SHADER_LOC_VERTEX_TEXCOORD01   ! Shader location: vertex attribute: texcoord01
    SHADER_LOC_VERTEX_TEXCOORD02   ! Shader location: vertex attribute: texcoord02
    SHADER_LOC_VERTEX_NORMAL       ! Shader location: vertex attribute: normal
    SHADER_LOC_VERTEX_TANGENT      ! Shader location: vertex attribute: tangent
    SHADER_LOC_VERTEX_COLOR        ! Shader location: vertex attribute: color
    SHADER_LOC_MATRIX_MVP          ! Shader location: matrix uniform: model-view-projection
    SHADER_LOC_MATRIX_VIEW         ! Shader location: matrix uniform: view (camera transform)
    SHADER_LOC_MATRIX_PROJECTION   ! Shader location: matrix uniform: projection
    SHADER_LOC_MATRIX_MODEL        ! Shader location: matrix uniform: model (transform)
    SHADER_LOC_MATRIX_NORMAL       ! Shader location: matrix uniform: normal
    SHADER_LOC_VECTOR_VIEW         ! Shader location: vector uniform: view
    SHADER_LOC_COLOR_DIFFUSE       ! Shader location: vector uniform: diffuse color
    SHADER_LOC_COLOR_SPECULAR      ! Shader location: vector uniform: specular color
    SHADER_LOC_COLOR_AMBIENT       ! Shader location: vector uniform: ambient color
    SHADER_LOC_MAP_ALBEDO          ! Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
    SHADER_LOC_MAP_METALNESS       ! Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
    SHADER_LOC_MAP_NORMAL          ! Shader location: sampler2d texture: normal
    SHADER_LOC_MAP_ROUGHNESS       ! Shader location: sampler2d texture: roughness
    SHADER_LOC_MAP_OCCLUSION       ! Shader location: sampler2d texture: occlusion
    SHADER_LOC_MAP_EMISSION        ! Shader location: sampler2d texture: emission
    SHADER_LOC_MAP_HEIGHT          ! Shader location: sampler2d texture: height
    SHADER_LOC_MAP_CUBEMAP         ! Shader location: samplerCube texture: cubemap
    SHADER_LOC_MAP_IRRADIANCE      ! Shader location: samplerCube texture: irradiance
    SHADER_LOC_MAP_PREFILTER       ! Shader location: samplerCube texture: prefilter
    SHADER_LOC_MAP_BRDF ;          ! Shader location: sampler2d texture: brdf

ENUM: ShaderUniformDataType
    SHADER_UNIFORM_FLOAT           ! Shader uniform type: float
    SHADER_UNIFORM_VEC2            ! Shader uniform type: vec2 (2 float)
    SHADER_UNIFORM_VEC3            ! Shader uniform type: vec3 (3 float)
    SHADER_UNIFORM_VEC4            ! Shader uniform type: vec4 (4 float)
    SHADER_UNIFORM_INT             ! Shader uniform type: int
    SHADER_UNIFORM_IVEC2           ! Shader uniform type: ivec2 (2 int)
    SHADER_UNIFORM_IVEC3           ! Shader uniform type: ivec3 (3 int)
    SHADER_UNIFORM_IVEC4           ! Shader uniform type: ivec4 (4 int)
    SHADER_UNIFORM_SAMPLER2D ;     ! Shader uniform type: sampler2d

ALIAS: SHADER_LOC_MAP_DIFFUSE SHADER_LOC_MAP_ALBEDO
ALIAS: SHADER_LOC_MAP_SPECULAR SHADER_LOC_MAP_METALNESS

ENUM: ShaderAttributeDataType
    SHADER_ATTRIB_FLOAT            ! Shader attribute type: float
    SHADER_ATTRIB_VEC2             ! Shader attribute type: vec2 (2 float)
    SHADER_ATTRIB_VEC3             ! Shader attribute type: vec3 (3 float)
    SHADER_ATTRIB_VEC4 ;           ! Shader attribute type: vec4 (4 float)

! Pixel formats
! NOTE: Support depends on OpenGL version and platform
ENUM: PixelFormat
    { PIXELFORMAT_UNCOMPRESSED_GRAYSCALE 1 } ! 8 bit per pixel (no alpha)
    PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA      ! 8*2 bpp (2 channels)
    PIXELFORMAT_UNCOMPRESSED_R5G6B5          ! 16 bpp
    PIXELFORMAT_UNCOMPRESSED_R8G8B8          ! 24 bpp
    PIXELFORMAT_UNCOMPRESSED_R5G5B5A1        ! 16 bpp (1 bit alpha)
    PIXELFORMAT_UNCOMPRESSED_R4G4B4A4        ! 16 bpp (4 bit alpha)
    PIXELFORMAT_UNCOMPRESSED_R8G8B8A8        ! 32 bpp
    PIXELFORMAT_UNCOMPRESSED_R32             ! 32 bpp (1 channel - float)
    PIXELFORMAT_UNCOMPRESSED_R32G32B32       ! 32*3 bpp (3 channels - float)
    PIXELFORMAT_UNCOMPRESSED_R32G32B32A32    ! 32*4 bpp (4 channels - float)
    PIXELFORMAT_COMPRESSED_DXT1_RGB          ! 4 bpp (no alpha)
    PIXELFORMAT_COMPRESSED_DXT1_RGBA         ! 4 bpp (1 bit alpha)
    PIXELFORMAT_COMPRESSED_DXT3_RGBA         ! 8 bpp
    PIXELFORMAT_COMPRESSED_DXT5_RGBA         ! 8 bpp
    PIXELFORMAT_COMPRESSED_ETC1_RGB          ! 4 bpp
    PIXELFORMAT_COMPRESSED_ETC2_RGB          ! 4 bpp
    PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA     ! 8 bpp
    PIXELFORMAT_COMPRESSED_PVRT_RGB          ! 4 bpp
    PIXELFORMAT_COMPRESSED_PVRT_RGBA         ! 4 bpp
    PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA     ! 8 bpp
    PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA ;   ! 2 bpp

! Texture parameters: filter mode
! NOTE 1: Filtering considers mipmaps if available in the texture
! NOTE 2: Filter is accordingly set for minification and magnification
ENUM: TextureFilterMode
    TEXTURE_FILTER_POINT                   ! No filter just pixel aproximation
    TEXTURE_FILTER_BILINEAR                ! Linear filtering
    TEXTURE_FILTER_TRILINEAR               ! Trilinear filtering (linear with mipmaps)
    TEXTURE_FILTER_ANISOTROPIC_4X          ! Anisotropic filtering 4x
    TEXTURE_FILTER_ANISOTROPIC_8X          ! Anisotropic filtering 8x
    TEXTURE_FILTER_ANISOTROPIC_16X ;       ! Anisotropic filtering 16x

! Texture parameters: wrap mode
ENUM: TextureWrapMode
    TEXTURE_WRAP_REPEAT
    TEXTURE_WRAP_CLAMP
    TEXTURE_WRAP_MIRROR_REPEAT
    TEXTURE_WRAP_MIRROR_CLAMP ;

! Cubemap layouts
ENUM: CubemapLayout
    CUBEMAP_LAYOUT_AUTO_DETECT             ! Automatically detect layout type
    CUBEMAP_LAYOUT_LINE_VERTICAL           ! Layout is defined by a vertical line with faces
    CUBEMAP_LAYOUT_LINE_HORIZONTAL         ! Layout is defined by an horizontal line with faces
    CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR     ! Layout is defined by a 3x4 cross with cubemap faces
    CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE     ! Layout is defined by a 4x3 cross with cubemap faces
    CUBEMAP_LAYOUT_PANORAMA ;              ! Layout is defined by a panorama image (equirectangular map)

! Font type, defines generation method
ENUM: FontType
    FONT_DEFAULT               ! Default font generation, anti-aliased
    FONT_BITMAP                ! Bitmap font generation, no anti-aliasing
    FONT_SDF ;                 ! SDF font generation, requires external shader

! Color blending modes (pre-defined)
ENUM: BlendMode
    BLEND_ALPHA                    ! Blend textures considering alpha (default)
    BLEND_ADDITIVE                 ! Blend textures adding colors
    BLEND_MULTIPLIED               ! Blend textures multiplying colors
    BLEND_ADD_COLORS               ! Blend textures adding colors (alternative)
    BLEND_SUBTRACT_COLORS          ! Blend textures subtracting colors (alternative)
    BLEND_ALPHA_PREMULTIPLY        ! Blend premultiplied textures considering alpha
    BLEND_CUSTOM                   ! Belnd textures using custom src/dst factors (use rlSetBlendFactors())
    BLEND_CUSTOM_SEPARATE ;        ! Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())

! Gestures type
! NOTE: Provided as bit-wise flags to enable only desired gestures
ENUM: Gestures
    { GESTURE_NONE          0 }
    { GESTURE_TAP           1 }
    { GESTURE_DOUBLETAP     2 }
    { GESTURE_HOLD          4 }
    { GESTURE_DRAG          8 }
    { GESTURE_SWIPE_RIGHT   16 }
    { GESTURE_SWIPE_LEFT    32 }
    { GESTURE_SWIPE_UP      64 }
    { GESTURE_SWIPE_DOWN    128 }
    { GESTURE_PINCH_IN      256 }
    { GESTURE_PINCH_OUT     512 } ;

! Camera system modes
ENUM: CameraMode
    CAMERA_CUSTOM
    CAMERA_FREE
    CAMERA_ORBITAL
    CAMERA_FIRST_PERSON
    CAMERA_THIRD_PERSON ;

! Camera projection
ENUM: CameraProjection
    CAMERA_PERSPECTIVE
    CAMERA_ORTHOGRAPHIC ;

ENUM: NPatchLayout
    NPATCH_NINE_PATCH               ! Npatch layout: 3x3 tiles
    NPATCH_THREE_PATCH_VERTICAL     ! Npatch layout: 1x3 tiles
    NPATCH_THREE_PATCH_HORIZONTAL ; ! Npatch layout: 3x1 tiles

! Structs ----------------------------------------------------------------

STRUCT: Vector2
    { x float }
    { y float } ;

STRUCT: Vector3
    { x float }
    { y float }
    { z float } ;

STRUCT: Vector4
    { x float }
    { y float }
    { z float }
    { w float } ;

TYPEDEF: Vector4 Quaternion ! Same as Vector4

ERROR: invalid-vector-length obj exemplar ;

: <Vector2> ( x y -- obj ) Vector2 <struct-boa> ; inline
INSTANCE: Vector2 sequence
M: Vector2 length drop 2 ; inline
M: Vector2 nth-unsafe
    swap 0 = [ x>> ] [ y>> ] if ;
M: Vector2 set-nth-unsafe
    swap 0 = [ x<< ] [ y<< ] if ;
M: Vector2 like
    over length 2 =
    [ drop dup Vector2?
      [ first2 <Vector2> ] unless
    ] [ invalid-vector-length ] if ; inline
M: Vector2 new-sequence
    over 2 = [
        2drop Vector2 (struct)
    ] [ invalid-vector-length ] if ; inline

: <Vector3> ( x y z -- obj ) Vector3 <struct-boa> ; inline
INSTANCE: Vector3 sequence
M: Vector3 length drop 3 ; inline
M: Vector3 nth-unsafe
    swap { { 0 [ x>> ] }
           { 1 [ y>> ] }
           { 2 [ z>> ] } } case ;
M: Vector3 set-nth-unsafe
    swap { { 0 [ x<< ] }
           { 1 [ y<< ] }
           { 2 [ z<< ] } } case ;
M: Vector3 like
    over length 3 =
    [ drop dup Vector3?
      [ first3 <Vector3> ] unless
    ] [ invalid-vector-length ] if ; inline
M: Vector3 new-sequence
    over 3 = [
        2drop Vector3 (struct)
    ] [ invalid-vector-length ] if ; inline

: <Vector4> ( x y z w -- obj ) Vector4 <struct-boa> ; inline
INSTANCE: Vector4 sequence
M: Vector4 length drop 4 ; inline
M: Vector4 nth-unsafe
    swap { { 0 [ x>> ] }
           { 1 [ y>> ] }
           { 2 [ z>> ] }
           { 3 [ w>> ] } } case ;
M: Vector4 set-nth-unsafe
    swap { { 0 [ x<< ] }
           { 1 [ y<< ] }
           { 2 [ z<< ] }
           { 3 [ w<< ] } } case ;
M: Vector4 like
    over length 4 =
    [ drop dup Vector4?
      [ first4 <Vector4> ] unless
    ] [ invalid-vector-length ] if ; inline
M: Vector4 new-sequence
    over 4 = [
        2drop Vector4 (struct)
    ] [ invalid-vector-length ] if ; inline

! Matrix type (OpenGL style 4x4 - right handed, column major)
STRUCT: Matrix
    { m0 float } { m4 float } { m8 float } { m12 float }
    { m1 float } { m5 float } { m9 float } { m13 float }
    { m2 float } { m6 float } { m10 float } { m14 float }
    { m3 float } { m7 float } { m11 float } { m15 float } ;

STRUCT: Color
    { r uchar }
    { g uchar }
    { b uchar }
    { a uchar } ;

STRUCT: Rectangle
    { x float }
    { y float }
    { width float }
    { height float } ;

! Image type, bpp always RGBA (32bit)
! NOTE: Data Stored in CPU Memory (RAM)
STRUCT: Image
    { data void* }                     ! Image raw data
    { width int }                      ! Image base width
    { height int }                     ! Image base height
    { mipmaps int }                    ! Mipmap levels, 1 by default
    { format PixelFormat } ;           ! Data format (PixelFormat type)

STRUCT: Texture2D
    { id uint }                        ! OpenGL Texture ID
    { width int }                      ! Texture Base Width
    { height int }                     ! Texture Base Height
    { mipmaps int }                    ! Mipmap Levels, 1 by default
    { format PixelFormat } ;           ! Data Format (PixelFormat type)
TYPEDEF: Texture2D Texture             ! Texture type same as Texture2D
TYPEDEF: Texture2D TextureCubemap      ! Actually same as Texture2D

STRUCT: RenderTexture2D
    { id uint }                        ! OpenGL Framebuffer Object (FBO) id
    { texture Texture2D }              ! Color buffer attachment texture
    { depth Texture2D } ;              ! Depth buffer attachment texture

TYPEDEF: RenderTexture2D RenderTexture ! Same as RenderTexture2D

STRUCT: NPatchInfo
    { source Rectangle }
    { left int }
    { top int }
    { right int }
    { bottom int }
    { layout int } ;

STRUCT: GlyphInfo
    { value int }                      ! Character value (Unicode)
    { offsetX int }                    ! Character offset X when drawing
    { offsetY int }                    ! Character offset Y when drawing
    { advanceX int }                   ! Character advance position X
    { image Image } ;                  ! Character image data

STRUCT: Font
    { baseSize int }        ! Base Size (default chars height)
    { glyphCount int }      ! Number of glyph characters
    { glyphPadding int }    ! Padding around the glyph characters
    { texture Texture2D }   ! Texture atlas containing the glyphs
    { recs Rectangle* }     ! Rectangles in texture for the glyphs
    { glyphs GlyphInfo* } ; ! Glyphs info data

TYPEDEF: Font SpriteFont

STRUCT: Camera3D
    { position Vector3 }  ! Camera postion
    { target Vector3 }    ! Camera target it looks-at
    { up Vector3 }        ! Camera up vector (rotation over its axis)
    { fovy float }        ! Camera field-of-view aperature in Y (degrees) in perspective, used as near plane width in orthographic
    { projection CameraProjection } ;  ! Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

STRUCT: Camera2D
    { offset Vector2 }    ! Camera offset (displacement from target)
    { target Vector2 }    ! Camera target (rotation and zoom origin)
    { rotation float }    ! Camera rotation in degrees
    { zoom float } ;      ! Camera zoom (scaling), should be 1.0f by default
TYPEDEF: Camera3D Camera  ! Default to 3D Camera

STRUCT: Mesh
    { vertexCount int }    ! Number of vertices stored in arrays
    { triangleCount int }  ! Number of triangles stored (indexed or not )
    { _vertices float* }   ! Vertex position (XYZ - 3 components per vertex)
    { _texcoords float* }  ! Vertex texture coordinates (UV - 2 components per vertex )
    { _texcoords2 float* } ! Vertex second texture coordinates (useful for lightmaps)
    { _normals float* }    ! Vertex normals (XYZ - 3 components per vertex)
    { tangents float* }    ! Vertex tangents (XYZW - 4 components per vertex )
    { colors uchar* }      ! Vertex colors (RGBA - 4 components per vertex)
    { indices ushort* }    ! Vertex indices (in case vertex data comes indexed)
    { animVertices float* }
    { animNormals float* }
    { boneIds uchar* }
    { boneWeights float* }
    { vaoId uint }         ! OpenGL Vertex Array Object id
    { vboId uint* } ;      ! OpenGL Vertex Buffer Objects id (7  types of vertex data)

ARRAY-SLOT: Mesh Vector3 _vertices [ vertexCount>> ] vertices
ARRAY-SLOT: Mesh Vector2 _texcoords [ vertexCount>> ] texcoords
ARRAY-SLOT: Mesh Vector2 _texcoords2 [ vertexCount>> ] texcoords2
ARRAY-SLOT: Mesh Vector3 _normals [ vertexCount>> ] normals

STRUCT: Shader
    { id uint }              ! Shader program id
    { locs int* } ;          ! Shader locations array
                             ! This is dependant on MAX_SHADER_LOCATIONS.  Default is 32
STRUCT: MaterialMap
    { texture Texture2D }    ! Material map Texture
    { color Color }          ! Material map color
    { value float } ;        ! Material map value

CONSTANT: MAX_MATERIAL_MAPS 12 ! NOTE: This seems to be a compile-time constant!
STRUCT: Material
    { shader Shader }        ! Material shader
    { _maps MaterialMap* }   ! Material maps.  Uses MAX_MATERIAL_MAPS.
    { params float[4] } ;    ! Material generic parameters (if required)

ARRAY-SLOT: Material MaterialMap _maps [ drop 12 ] maps

STRUCT: Transform
    { translation Vector3 }
    { rotation Quaternion }
    { scale Vector3 } ;

STRUCT: BoneInfo
    { name char[32] }        ! Bone Name
    { parent int } ;         ! Bone parent

STRUCT: Model
    { transform Matrix }
    { meshCount int }
    { materialCount int }
    { _meshes void* }
    { _materials void* }
    { meshMaterial int* }
    { boneCount int }
    { _bones void* }
    { bindPose void* } ;

ARRAY-SLOT: Model Material _materials [ materialCount>> ] materials
ARRAY-SLOT: Model Mesh _meshes [ meshCount>> ] meshes
ARRAY-SLOT: Model BoneInfo _bones [ boneCount>> ] bones

STRUCT: ModelAnimation
    { boneCount int }
    { frameCount int }
    { _bones BoneInfo* }
    { framePoses Transform** } ;

ARRAY-SLOT: ModelAnimation BoneInfo _bones [ boneCount>> ] bones

STRUCT: Ray
    { position Vector3 }    ! Ray position (origin)
    { direction Vector3 } ; ! Ray direction

STRUCT: RayCollision
    { hit bool }            ! Did the ray hit something?
    { distance float }      ! Distance to nearest hit
    { point Vector3 }       ! Point of nearest hit
    { normal Vector3 } ;    ! Surface normal of hit

STRUCT: BoundingBox
    { min Vector3 }       ! Minimum vertex box-corner
    { max Vector3 } ;     ! Maximum vertex box-corner

STRUCT: Wave
    { frameCount uint }     ! Total number of frames (considering channels)
    { sampleRate uint }     ! Frequency (samples per second)
    { sampleSize uint }     ! Bit depth (bits per sample): 8,16,32
    { channels uint }       ! Number of channels (1-mono, 2-stereo)
    { data void* } ;        ! Buffer data pointer

STRUCT: AudioStream
    { buffer void* }    ! Pointer to internal data used by the audio system
    { processor void* } ! Pointer to internal data processor, useful for audio effects
    { sampleRate uint } ! Frequency (samples per second)
    { sampleSize uint } ! Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    { channels uint } ; ! Number of channels (1-mono, 2-stereo)

STRUCT: Sound
    { stream AudioStream } ! Audio stream
    { frameCount uint } ;  ! Total number of frames (considering channels)

STRUCT: Music
    { stream  AudioStream }     ! Audio stream
    { frameCount uint }         ! Total number of frames (considering channels)
    { looping bool }            ! Music looping enable
    { ctxType int }             ! Type of music context (audio filetype)
    { ctxData void* } ;         ! Audio context data, depends on type

STRUCT: VrDeviceInfo
    { hResolution int }               ! HMD horizontal resolution in pixels
    { vResolution int }               ! HMD verticle resolution in pixels
    { hScreenSize float }             ! HMD horizontal size in meters
    { vScreenSize float }             ! HMD verticle size in meters
    { vScreenCenter float }           ! HMD screen center in meters
    { eyeToScreenDistance float }     ! HMD distance between eye and display in meters
    { lensSeparationDistance float }  ! HMD lens separation distance in meters
    { interpupillaryDistance float }  ! HMD IPD in meters
    { lensDistortionValues float[4] } ! HMD lens distortion constant parameters
    { chromaAbCorrection float[4] } ; ! HMD chromatic abberation correction parameters

STRUCT: VrStereoConfig
    { projection Matrix[2] }          ! VR projection matrices (per eye)
    { viewOffset Matrix[2] }          ! VR view offset matrices (per eye)
    { leftLensCenter float[2] }       ! VR left lens center
    { rightLensCenter float[2] }      ! VR right lens center
    { leftScreenCenter float[2] }     ! VR left screen center
    { rightScreenCenter float[2] }    ! VR right screen center
    { scale float[2] }                ! VR distortion scale
    { scaleIn float[2] } ;            ! VR distortion scale in

STRUCT: FilePathList
    { capacity uint }                 ! Filepaths max entries
    { count uint }                    ! Filepaths entries count
    { _paths c-string* } ;             ! Filepaths entries

ARRAY-SLOT: FilePathList c-string _paths [ count>> ] paths

! Constants ----------------------------------------------------------------

CONSTANT: LIGHTGRAY  S{ Color f 200  200  200  255  } ! Light Gray
CONSTANT: GRAY       S{ Color f 130  130  130  255  } ! Gray
CONSTANT: DARKGRAY   S{ Color f 80  80  80  255     } ! Dark Gray
CONSTANT: YELLOW     S{ Color f 253  249  0  255    } ! Yellow
CONSTANT: GOLD       S{ Color f 255  203  0  255    } ! Gold
CONSTANT: ORANGE     S{ Color f 255  161  0  255    } ! Orange
CONSTANT: PINK       S{ Color f 255  109  194  255  } ! Pink
CONSTANT: RED        S{ Color f 230  41  55  255    } ! Red
CONSTANT: MAROON     S{ Color f 190  33  55  255    } ! Maroon
CONSTANT: GREEN      S{ Color f 0  228  48  255     } ! Green
CONSTANT: LIME       S{ Color f 0  158  47  255     } ! Lime
CONSTANT: DARKGREEN  S{ Color f 0  117  44  255     } ! Dark Green
CONSTANT: SKYBLUE    S{ Color f 102  191  255  255  } ! Sky Blue
CONSTANT: BLUE       S{ Color f 0  121  241  255    } ! Blue
CONSTANT: DARKBLUE   S{ Color f 0  82  172  255     } ! Dark Blue
CONSTANT: PURPLE     S{ Color f 200  122  255  255  } ! Purple
CONSTANT: VIOLET     S{ Color f 135  60  190  255   } ! Violet
CONSTANT: DARKPURPLE S{ Color f 112  31  126  255   } ! Dark Purple
CONSTANT: BEIGE      S{ Color f 211  176  131  255  } ! Beige
CONSTANT: BROWN      S{ Color f 127  106  79  255   } ! Brown
CONSTANT: DARKBROWN  S{ Color f 76  63  47  255     } ! Dark Brown

CONSTANT: WHITE      S{ Color f 255  255  255  255  } ! White
CONSTANT: BLACK      S{ Color f 0  0  0  255        } ! Black
CONSTANT: BLANK      S{ Color f 0  0  0  0          } ! Blank (Transparent)
CONSTANT: MAGENTA    S{ Color f 255  0  255  255    } ! Magenta
CONSTANT: RAYWHITE   S{ Color f 245  245  245  255  } ! My own White (raylib logo)

! Functions ---------------------------------------------------------------

! Window-related functions
FUNCTION-ALIAS: init-window void InitWindow ( int width, int height, c-string title )    ! Initialize window and OpenGL context
FUNCTION-ALIAS: window-should-close bool WindowShouldClose ( )                           ! Check if KEY_ESCAPE pressed or Close icon pressed
FUNCTION-ALIAS: close-window void CloseWindow ( )                                        ! Close window and unload OpenGL context
FUNCTION-ALIAS: is-window-ready bool IsWindowReady ( )                                   ! Check if window has been initialized successfully
FUNCTION-ALIAS: is-window-fullscreen bool IsWindowFullscreen ( )                         ! Check if window is currently fullscreen
FUNCTION-ALIAS: is-window-hidden bool IsWindowHidden ( )                                 ! Check if window is currently hidden (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: is-window-minimized bool IsWindowMinimized ( )                           ! Check if window is currently minimized (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: is-window-maximized bool IsWindowMaximized ( )                           ! Check if window is currently maximized (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: is-window-focused bool IsWindowFocused ( )                               ! Check if window is currently focused (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: is-window-resized bool IsWindowResized ( )                               ! Check if window has been resized last frame
FUNCTION-ALIAS: is-window-state bool IsWindowState ( uint flag )                         ! Check if one specific window flag is enabled
FUNCTION-ALIAS: set-window-state void SetWindowState ( uint flags )                      ! Set window configuration state using flags
FUNCTION-ALIAS: clear-window-state void ClearWindowState ( uint flags )                  ! Clear window configuration state flags
FUNCTION-ALIAS: toggle-fullscreen void ToggleFullscreen ( )                              ! Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: maximize-window void MaximizeWindow ( )                                  ! Set window state: maximized, if resizable (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: minimize-window void MinimizeWindow ( )                                  ! Set window state: minimized, if resizable (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: restore-window void RestoreWindow ( )                                    ! Set window state: not minimized/maximized (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: set-window-icon void SetWindowIcon ( Image image )                       ! Set icon for window (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: set-window-icons void SetWindowIcons ( Image* images, int count )
FUNCTION-ALIAS: set-window-title void SetWindowTitle ( c-string title )                  ! Set title for window (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: set-window-position void SetWindowPosition ( int x, int y )              ! Set window position on screen (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: set-window-monitor void SetWindowMonitor ( int monitor )                 ! Set monitor for the current window (fullscreen mode)
FUNCTION-ALIAS: set-window-min-size void SetWindowMinSize ( int width, int height )      ! Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
FUNCTION-ALIAS: set-window-size void SetWindowSize ( int width, int height )             ! Set window dimensions
FUNCTION-ALIAS: set-window-opacity void SetWindowOpacity ( float opacity )               ! Set window opacity [0.0f..1.0f] (only PLATFORM_DESKTOP)
FUNCTION-ALIAS: get-window-handle void* GetWindowHandle ( )                              ! Get native window handle
FUNCTION-ALIAS: get-screen-width int GetScreenWidth ( )                                  ! Get current screen width
FUNCTION-ALIAS: get-screen-height int GetScreenHeight ( )                                ! Get current screen height
FUNCTION-ALIAS: get-render-width int GetRenderWidth ( )                                  ! Get current render width (it considers HiDPI)
FUNCTION-ALIAS: get-render-height int GetRenderHeight ( )                                ! Get current render height (it considers HiDPI)
FUNCTION-ALIAS: get-monitor-count int GetMonitorCount ( )                                ! Get number of connected monitors
FUNCTION-ALIAS: get-current-monitor int GetCurrentMonitor ( )                            ! Get current connected monitor
FUNCTION-ALIAS: get-monitor-position Vector2 GetMonitorPosition ( int monitor )          ! Get specified monitor position
FUNCTION-ALIAS: get-monitor-width int GetMonitorWidth ( int monitor )                    ! Get specified monitor width (max available by monitor)
FUNCTION-ALIAS: get-monitor-height int GetMonitorHeight ( int monitor )                  ! Get specified monitor height (max available by monitor)
FUNCTION-ALIAS: get-monitor-physical-width int GetMonitorPhysicalWidth ( int monitor )   ! Get specified monitor physical width in millimetres
FUNCTION-ALIAS: get-monitor-physical-height int GetMonitorPhysicalHeight ( int monitor ) ! Get specified monitor physical height in millimetres
FUNCTION-ALIAS: get-monitor-refresh-rate int GetMonitorRefreshRate ( int monitor )       ! Get specified monitor refresh rate
FUNCTION-ALIAS: get-window-position Vector2 GetWindowPosition ( )                        ! Get window position XY on monitor
FUNCTION-ALIAS: get-window-scale-dpi Vector2 GetWindowScaleDPI ( )                       ! Get window scale DPI factor
FUNCTION-ALIAS: get-monitor-name c-string GetMonitorName ( int monitor )                 ! Get the human-readable, UTF-8 encoded name of the primary monitor
FUNCTION-ALIAS: set-clipboard-text void SetClipboardText ( c-string text )               ! Set clipboard text content
FUNCTION-ALIAS: get-clipboard-text c-string GetClipboardText ( )                         ! Get clipboard text content
FUNCTION-ALIAS: enable-event-waiting void EnableEventWaiting ( )                         ! Enable waiting for events on EndDrawing(), no automatic event polling
FUNCTION-ALIAS: disable-event-waiting void DisableEventWaiting ( )                       ! Disable waiting for events on EndDrawing(), automatic events polling

! Custom frame control functions
! NOTE: Those functions are intended for advance users that want full control over the frame processing
! By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timming + PollInputEvents()
! To avoid that behavior and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
FUNCTION-ALIAS: swap-screen-buffer void SwapScreenBuffer ( )                             ! Swap back buffer with front buffer (screen drawing)
FUNCTION-ALIAS: poll-input-events void PollInputEvents ( )                               ! Register all input events
FUNCTION-ALIAS: wait-time void WaitTime ( double seconds )                               ! Wait for some milliseconds (halt program execution)

! Cursor-related functions
FUNCTION-ALIAS: show-cursor void ShowCursor ( )                                          ! Shows cursor
FUNCTION-ALIAS: hide-cursor void HideCursor ( )                                          ! Hides cursor
FUNCTION-ALIAS: is-cursor-hidden bool IsCursorHidden ( )                                 ! Check if cursor is not visible
FUNCTION-ALIAS: enable-cursor void EnableCursor ( )                                      ! Enables cursor (unlock cursor)
FUNCTION-ALIAS: disable-cursor void DisableCursor ( )                                    ! Disables cursor (lock cursor)
FUNCTION-ALIAS: is-cursor-on-screen bool IsCursorOnScreen ( )                            ! Check if cursor is on the screen

! Drawing-related functions
FUNCTION-ALIAS: clear-background void ClearBackground ( Color color )                    ! Set background color (framebuffer clear color)
FUNCTION-ALIAS: begin-drawing void BeginDrawing ( )                                      ! Setup canvas (framebuffer) to start drawing
FUNCTION-ALIAS: end-drawing void EndDrawing ( )                                          ! End canvas drawing and swap buffers (double buffering)
FUNCTION-ALIAS: begin-mode-2d void BeginMode2D ( Camera2D camera )                       ! Begin 2D mode with custom camera (2D)
FUNCTION-ALIAS: end-mode-2d void EndMode2D ( )                                           ! Ends 2D mode with custom camera
FUNCTION-ALIAS: begin-mode-3d void BeginMode3D ( Camera3D camera )                       ! Begin 3D mode with custom camera (3D)
FUNCTION-ALIAS: end-mode-3d void EndMode3D ( )                                           ! Ends 3D mode and returns to default 2D orthographic mode
FUNCTION-ALIAS: begin-texture-mode void BeginTextureMode ( RenderTexture2D target )      ! Begin drawing to render texture
FUNCTION-ALIAS: end-texture-mode void EndTextureMode ( )                                 ! Ends drawing to render texture
FUNCTION-ALIAS: begin-shader-mode void BeginShaderMode ( Shader shader )                 ! Begin custom shader drawing
FUNCTION-ALIAS: end-shader-mode void EndShaderMode ( )                                   ! End custom shader drawing (use default shader)
FUNCTION-ALIAS: begin-blend-mode void BeginBlendMode ( BlendMode mode )                  ! Begin blending mode (alpha, additive, multiplied, subtract, custom)
FUNCTION-ALIAS: end-blend-mode void EndBlendMode ( )                                     ! End blending mode (reset to default: alpha blending)
FUNCTION-ALIAS: begin-scissor-mode void BeginScissorMode ( int x, int y, int width, int height ) ! Begin scissor mode (define screen area for following drawing)
FUNCTION-ALIAS: end-scissor-mode void EndScissorMode ( )                                 ! End scissor mode
FUNCTION-ALIAS: begin-vr-stereo-mode void BeginVrStereoMode ( VrStereoConfig config )    ! Begin stereo rendering (requires VR simulator)
FUNCTION-ALIAS: end-vr-stereo-mode void EndVrStereoMode ( )                              ! End stereo rendering (requires VR simulator)

! VR stereo config functions for VR simulator
FUNCTION-ALIAS: load-vr-stereo-config VrStereoConfig LoadVrStereoConfig ( VrDeviceInfo device ) ! Load VR stereo config for VR simulator device parameters
FUNCTION-ALIAS: unload-vr-stereo-config void UnloadVrStereoConfig ( VrStereoConfig config )     ! Unload VR stereo config

! Shader management functions
! NOTE: Shader functionality is not available on OpenGL 1.1
FUNCTION-ALIAS: load-shader Shader LoadShader ( c-string vsFileName, c-string fsFileName )                                       ! Load shader from files and bind default locations
FUNCTION-ALIAS: load-shader-from-memory Shader LoadShaderFromMemory ( c-string vsCode, c-string fsCode )                         ! Load shader from code strings and bind default locations
FUNCTION-ALIAS: is-shader-ready bool IsShaderReady ( Shader shader )                                                             ! Check if a shader is ready
FUNCTION-ALIAS: get-shader-location int GetShaderLocation ( Shader shader, c-string uniformName )                                ! Get shader uniform location
FUNCTION-ALIAS: get-shader-location-attrib int GetShaderLocationAttrib ( Shader shader, c-string attribName )                    ! Get shader attribute location
FUNCTION-ALIAS: set-shader-value void SetShaderValue ( Shader shader, int locIndex, void* value, ShaderUniformDataType uniformType ) ! Set shader uniform value
FUNCTION-ALIAS: set-shader-value-v void SetShaderValueV ( Shader shader, int locIndex, void* value, ShaderUniformDataType uniformType, int count ) ! Set shader uniform value vector
FUNCTION-ALIAS: set-shader-value-matrix void SetShaderValueMatrix ( Shader shader, int locIndex, Matrix mat )                    ! Set shader uniform value (matrix 4x4)
FUNCTION-ALIAS: set-shader-value-texture void SetShaderValueTexture ( Shader shader, int locIndex, Texture2D texture )           ! Set shader uniform value for texture (sampler2d)
FUNCTION-ALIAS: unload-shader void UnloadShader ( Shader shader )                                                                ! Unload shader from GPU memory (VRAM)

! Screen-space-related functions
FUNCTION-ALIAS: get-mouse-ray Ray GetMouseRay ( Vector2 mousePosition, Camera camera )                                        ! Get a ray trace from mouse position
FUNCTION-ALIAS: get-camera-matrix Matrix GetCameraMatrix ( Camera camera )                                                    ! Get camera transform matrix (view matrix)
FUNCTION-ALIAS: get-camera-matrix-2d Matrix GetCameraMatrix2D ( Camera2D camera )                                             ! Get camera 2d transform matrix
FUNCTION-ALIAS: get-world-to-screen Vector2 GetWorldToScreen ( Vector3 position, Camera camera )                              ! Get the screen space position for a 3d world space position
FUNCTION-ALIAS: get-world-to-screen-2d Vector2 GetWorldToScreen2D ( Vector2 position, Camera2D camera )                       ! Get the screen space position for a 2d camera world space position
FUNCTION-ALIAS: get-world-to-screen-ex Vector2 GetWorldToScreenEx ( Vector3 position, Camera camera, int width, int height )  ! Get size position for a 3d world space position
FUNCTION-ALIAS: get-screen-to-world-2d Vector2 GetScreenToWorld2D ( Vector2 position, Camera2D camera )                       ! Get the world space position for a 2d camera screen space position

! Timing-related functions
FUNCTION-ALIAS: set-target-fps void SetTargetFPS ( int fps )                             ! Set target FPS (maximum)
FUNCTION-ALIAS: get-fps int GetFPS ( )                                                   ! Get current FPS
FUNCTION-ALIAS: get-frame-time float GetFrameTime ( )                                    ! Get time in seconds for last frame drawn (delta time)
FUNCTION-ALIAS: get-time double GetTime ( )                                              ! Get elapsed time in seconds since InitWindow()

! Misc. functions
FUNCTION-ALIAS: get-random-value int GetRandomValue ( int min, int max )                 ! Get a random value between min and max (both included)
FUNCTION-ALIAS: set-random-seed void SetRandomSeed ( uint seed )                         ! Set the seed for the random number generator
FUNCTION-ALIAS: take-screenshot void TakeScreenshot ( c-string fileName )                ! Takes a screenshot of current screen (filename extension defines format)
FUNCTION-ALIAS: set-config-flags void SetConfigFlags ( uint flags )                      ! Setup init configuration flags (view FLAGS)

! FUNCTION: void TraceLog ( int logLevel, c-string text, ... )                           ! Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
FUNCTION-ALIAS: set-trace-log-level void SetTraceLogLevel ( int logLevel )               ! Set the current threshold (minimum) log level
FUNCTION-ALIAS: mem-alloc void* MemAlloc ( uint size )                                    ! Internal memory allocator
FUNCTION-ALIAS: mem-realloc void* MemRealloc ( void* ptr, uint size )                     ! Internal memory reallocator
FUNCTION-ALIAS: mem-free void MemFree ( void* ptr )                                      ! Internal memory free

FUNCTION-ALIAS: open-url void OpenURL ( c-string url )                                   ! Open URL with default system browser (if available)

! Set custom callbacks
! WARNING: Callbacks setup is intended for advance users
! FUNCTION: void SetTraceLogCallback ( TraceLogCallback callback )          ! Set custom trace log
! FUNCTION: void SetLoadFileDataCallback ( LoadFileDataCallback callback )  ! Set custom file binary data loader
! FUNCTION: void SetSaveFileDataCallback ( SaveFileDataCallback callback )  ! Set custom file binary data saver
! FUNCTION: void SetLoadFileTextCallback ( LoadFileTextCallback callback )  ! Set custom file text data loader
! FUNCTION: void SetSaveFileTextCallback ( SaveFileTextCallback callback )  ! Set custom file text data saver

! Files management functions
FUNCTION-ALIAS: load-file-data c-string LoadFileData ( c-string fileName, uint* bytesRead )           ! Load file data as byte array (read)
FUNCTION-ALIAS: unload-file-data void UnloadFileData ( c-string data )                                ! Unload file data allocated by LoadFileData()
FUNCTION-ALIAS: save-file-data bool SaveFileData ( c-string fileName, void* data, uint bytesToWrite ) ! Save data to file from byte array (write), returns true on success
FUNCTION-ALIAS: export-data-as-code bool ExportDataAsCode ( uchar* data, uint size, c-string fileName ) ! Export data to code (.h), returns true on success
FUNCTION-ALIAS: load-file-text c-string LoadFileText ( c-string fileName )                            ! Load text data from file (read), returns a ' ' terminated string
FUNCTION-ALIAS: unload-file-text void UnloadFileText ( c-string text )                                ! Unload file text data allocated by LoadFileText()
FUNCTION-ALIAS: save-file-text bool SaveFileText ( c-string fileName, c-string text )                 ! Save text data to file (write), string must be ' ' terminated, returns true on success
FUNCTION-ALIAS: file-exists bool FileExists ( c-string fileName )                                     ! Check if file exists
FUNCTION-ALIAS: directory-exists bool DirectoryExists ( c-string dirPath )                            ! Check if a directory path exists
FUNCTION-ALIAS: is-file-extension bool IsFileExtension ( c-string fileName, c-string ext )            ! Check file extension (including point: .png, .wav)
FUNCTION-ALIAS: get-file-length int GetFileLength ( c-string fileName )                               ! Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
FUNCTION-ALIAS: get-file-extension c-string GetFileExtension ( c-string fileName )                    ! Get pointer to extension for a filename string (includes dot: '.png')
FUNCTION-ALIAS: get-file-name c-string GetFileName ( c-string filePath )                              ! Get pointer to filename for a path string
FUNCTION-ALIAS: get-file-name-without-ext c-string GetFileNameWithoutExt ( c-string filePath )        ! Get filename string without extension (uses static string)
FUNCTION-ALIAS: get-directory-path c-string GetDirectoryPath ( c-string filePath )                    ! Get full path for a given fileName with path (uses static string)
FUNCTION-ALIAS: get-prev-directory-path c-string GetPrevDirectoryPath ( c-string dirPath )            ! Get previous directory path for a given path (uses static string)
FUNCTION-ALIAS: get-working-directory c-string GetWorkingDirectory ( )                                ! Get current working directory (uses static string)
FUNCTION-ALIAS: get-application-directory c-string GetApplicationDirectory ( )                        ! Get the directory if the running application (uses static string)
FUNCTION-ALIAS: change-directory bool ChangeDirectory ( c-string dir )                                ! Change working directory, return true on success
FUNCTION-ALIAS: is-path-file bool IsPathFile ( c-string path )                                        ! Check if a given path is a file or a directory
FUNCTION-ALIAS: load-directory-files FilePathList LoadDirectoryFiles ( c-string dirPath )       ! Get filenames in a directory path (memory should be freed)
FUNCTION-ALIAS: load-directory-files-ex FilePathList LoadDirectoryFilesEx ( c-string dirPath, c-string filter, bool scanSubDirs )       ! Get filenames in a directory path (memory should be freed)
FUNCTION-ALIAS: unload-directory-files void UnloadDirectoryFiles ( FilePathList files )               ! Clear directory files paths buffers (free memory)
FUNCTION-ALIAS: is-file-dropped bool IsFileDropped ( )                                                ! Check if a file has been dropped into window
FUNCTION-ALIAS: load-dropped-files FilePathList LoadDroppedFiles ( )                          ! Get dropped files names (memory should be freed)
FUNCTION-ALIAS: unload-dropped-files void UnloadDroppedFiles ( FilePathList files )                                      ! Clear dropped files paths buffer (free memory)
FUNCTION-ALIAS: get-file-mod-time long GetFileModTime ( c-string fileName )                           ! Get file modification time (last write time)

! Compression/Encoding functionality
FUNCTION-ALIAS: compress-data uchar* CompressData ( uchar* data, int dataLength, int* compDataLength )          ! Compress data (DEFLATE algorithm)
FUNCTION-ALIAS: decompress-data uchar* DecompressData ( uchar* compData, int compDataLength, int* dataLength )  ! Decompress data (DEFLATE algorithm)
FUNCTION-ALIAS: encode-data-base64 c-string EncodeDataBase64 ( uchar* data, int dataLength, int* outputLength ) ! Encode data to Base64 string
FUNCTION-ALIAS: decode-data-base64 uchar* DecodeDataBase64 ( uchar* data, int* outputLength )                   ! Decode Base64 string data

! ------------------------------------------------------------------------------------
! Input Handling Functions (Module: core)
! ------------------------------------------------------------------------------------

! Input-related functions: keyboard
FUNCTION-ALIAS: is-key-pressed bool IsKeyPressed ( KeyboardKey key )                     ! Check if a key has been pressed once
FUNCTION-ALIAS: is-key-down bool IsKeyDown ( KeyboardKey key )                           ! Check if a key is being pressed
FUNCTION-ALIAS: is-key-released bool IsKeyReleased ( KeyboardKey key )                   ! Check if a key has been released once
FUNCTION-ALIAS: is-key-up bool IsKeyUp ( KeyboardKey key )                               ! Check if a key is NOT being pressed
FUNCTION-ALIAS: set-exit-key void SetExitKey ( KeyboardKey key )                         ! Set a custom key to exit program (default is ESC)
FUNCTION-ALIAS: get-key-pressed KeyboardKey GetKeyPressed ( )                            ! Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
FUNCTION-ALIAS: get-char-pressed int GetCharPressed ( )                                  ! Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty

! Input-related functions: gamepads
FUNCTION-ALIAS: is-gamepad-available bool IsGamepadAvailable ( int gamepad )                                  ! Check if a gamepad is available
FUNCTION-ALIAS: get-gamepad-name c-string GetGamepadName ( int gamepad )                                      ! Get gamepad internal name id
FUNCTION-ALIAS: is-gamepad-button-pressed bool IsGamepadButtonPressed ( int gamepad, GamepadButton button )   ! Check if a gamepad button has been pressed once
FUNCTION-ALIAS: is-gamepad-button-down bool IsGamepadButtonDown ( int gamepad, GamepadButton button )         ! Check if a gamepad button is being pressed
FUNCTION-ALIAS: is-gamepad-button-released bool IsGamepadButtonReleased ( int gamepad, GamepadButton button ) ! Check if a gamepad button has been released once
FUNCTION-ALIAS: is-gamepad-button-up bool IsGamepadButtonUp ( int gamepad, GamepadButton button )             ! Check if a gamepad button is NOT being pressed
FUNCTION-ALIAS: get-gamepad-button-pressed int GetGamepadButtonPressed ( )                                    ! Get the last gamepad button pressed
FUNCTION-ALIAS: get-gamepad-axis-count int GetGamepadAxisCount ( int gamepad )                                ! Get gamepad axis count for a gamepad
FUNCTION-ALIAS: get-gamepad-axis-movement float GetGamepadAxisMovement ( int gamepad, GamepadAxis axis )      ! Get axis movement value for a gamepad axis
FUNCTION-ALIAS: set-gamepad-mappings int SetGamepadMappings ( c-string mappings )                             ! Set internal gamepad mappings (SDL_GameControllerDB)

! Input-related functions: mouse
FUNCTION-ALIAS: is-mouse-button-pressed bool IsMouseButtonPressed ( MouseButton button )   ! Check if a mouse button has been pressed once
FUNCTION-ALIAS: is-mouse-button-down bool IsMouseButtonDown ( MouseButton button )         ! Check if a mouse button is being pressed
FUNCTION-ALIAS: is-mouse-button-released bool IsMouseButtonReleased ( MouseButton button ) ! Check if a mouse button has been released once
FUNCTION-ALIAS: is-mouse-button-up bool IsMouseButtonUp ( MouseButton button )             ! Check if a mouse button is NOT being pressed
FUNCTION-ALIAS: get-mouse-x int GetMouseX ( )                                              ! Get mouse position X
FUNCTION-ALIAS: get-mouse-y int GetMouseY ( )                                              ! Get mouse position Y
FUNCTION-ALIAS: get-mouse-position Vector2 GetMousePosition ( )                            ! Get mouse position XY
FUNCTION-ALIAS: get-mouse-delta Vector2 GetMouseDelta ( )                                  ! Get mouse delta between frames
FUNCTION-ALIAS: set-mouse-position void SetMousePosition ( int x, int y )                  ! Set mouse position XY
FUNCTION-ALIAS: set-mouse-offset void SetMouseOffset ( int offsetX, int offsetY )          ! Set mouse offset
FUNCTION-ALIAS: set-mouse-scale void SetMouseScale ( float scaleX, float scaleY )          ! Set mouse scaling
FUNCTION-ALIAS: get-mouse-wheel-move float GetMouseWheelMove ( )                           ! Get mouse wheel movement Y
FUNCTION-ALIAS: get-mouse-wheel-move-v Vector2 GetMouseWheelMoveV ( )                      ! Get mouse wheel movement for both X and Y
FUNCTION-ALIAS: set-mouse-cursor void SetMouseCursor ( MouseCursor cursor )                ! Set mouse cursor

! Input-related functions: touch
FUNCTION-ALIAS: get-touch-x int GetTouchX ( )                                            ! Get touch position X for touch point 0 (relative to screen size)
FUNCTION-ALIAS: get-touch-y int GetTouchY ( )                                            ! Get touch position Y for touch point 0 (relative to screen size)
FUNCTION-ALIAS: get-touch-position Vector2 GetTouchPosition ( int index )                ! Get touch position XY for a touch point index (relative to screen size)
FUNCTION-ALIAS: get-touch-point-id int GetTouchPointId ( int index )                     ! Get touch point identifier for given index
FUNCTION-ALIAS: get-touch-point-count int GetTouchPointCount ( )                         ! Get number of touch points

! ------------------------------------------------------------------------------------
! Gestures and Touch Handling Functions (Module: rgestures)
! ------------------------------------------------------------------------------------
FUNCTION-ALIAS: set-gestures-enabled void SetGesturesEnabled ( uint flags )              ! Enable a set of gestures using flags
FUNCTION-ALIAS: is-gesture-detected bool IsGestureDetected ( Gestures gesture )          ! Check if a gesture have been detected
FUNCTION-ALIAS: get-gesture-detected int GetGestureDetected ( )                          ! Get latest detected gesture
FUNCTION-ALIAS: get-gesture-hold-duration float GetGestureHoldDuration ( )               ! Get gesture hold time in milliseconds
FUNCTION-ALIAS: get-gesture-drag-vector Vector2 GetGestureDragVector ( )                 ! Get gesture drag vector
FUNCTION-ALIAS: get-gesture-drag-angle float GetGestureDragAngle ( )                     ! Get gesture drag angle
FUNCTION-ALIAS: get-gesture-pinch-vector Vector2 GetGesturePinchVector ( )               ! Get gesture pinch delta
FUNCTION-ALIAS: get-gesture-pinch-angle float GetGesturePinchAngle ( )                   ! Get gesture pinch angle

! ------------------------------------------------------------------------------------
! Camera System Functions (Module: rcamera)
! ------------------------------------------------------------------------------------

FUNCTION-ALIAS: update-camera void UpdateCamera ( Camera *camera, CameraMode mode )      ! Update camera position for selected mode
FUNCTION-ALIAS: update-camera-pro void UpdateCameraPro ( Camera *camera, Vector3 movement, Vector3 rotation, float zoom ) ! Update camera movement/rotation

! ------------------------------------------------------------------------------------
! Basic Shapes Drawing Functions (Module: shapes)
! ------------------------------------------------------------------------------------
! Set texture and rectangle to be used on shapes drawing
! NOTE: It can be useful when using basic shapes and one single font,
! defining a font char white rectangle would allow drawing everything in a single draw call
FUNCTION-ALIAS: set-shapes-texture void SetShapesTexture ( Texture2D texture, Rectangle source ) ! Set texture and rectangle to be used on shapes drawing

! Basic shapes drawing functions
FUNCTION-ALIAS: draw-pixel void DrawPixel ( int posX, int posY, Color color )                                                    ! Draw a pixel
FUNCTION-ALIAS: draw-pixel-v void DrawPixelV ( Vector2 position, Color color )                                                   ! Draw a pixel (Vector version)
FUNCTION-ALIAS: draw-line void DrawLine ( int startPosX, int startPosY, int endPosX, int endPosY, Color color )                  ! Draw a line
FUNCTION-ALIAS: draw-line-v void DrawLineV ( Vector2 startPos, Vector2 endPos, Color color )                                     ! Draw a line (Vector version)
FUNCTION-ALIAS: draw-line-ex void DrawLineEx ( Vector2 startPos, Vector2 endPos, float thick, Color color )                      ! Draw a line defining thickness
FUNCTION-ALIAS: draw-line-bezier void DrawLineBezier ( Vector2 startPos, Vector2 endPos, float thick, Color color )              ! Draw a line using cubic-bezier curves in-out
FUNCTION-ALIAS: draw-line-bezier-quad void DrawLineBezierQuad ( Vector2 startPos, Vector2 endPos, Vector2 controlPos, float thick, Color color )  ! Draw line using quadratic bezier curves with a control point
FUNCTION-ALIAS: draw-line-bezier-cubic void DrawLineBezierCubic ( Vector2 startPos, Vector2 endPos, Vector2 startControlPos, Vector2 endControlPos, float thick, Color color )  ! Draw line using cubic bezier curves with 2 control points
FUNCTION-ALIAS: draw-line-strip void DrawLineStrip ( Vector2* points, int pointCount, Color color )                              ! Draw lines sequence
FUNCTION-ALIAS: draw-circle void DrawCircle ( int centerX, int centerY, float radius, Color color )                              ! Draw a color-filled circle
FUNCTION-ALIAS: draw-circle-sector void DrawCircleSector ( Vector2 center, float radius, float startAngle, float endAngle, int segments, Color color )       ! Draw a piece of a circle
FUNCTION-ALIAS: draw-circle-sector-lines void DrawCircleSectorLines ( Vector2 center, float radius, float startAngle, float endAngle, int segments, Color color )  ! Draw circle sector outline
FUNCTION-ALIAS: draw-circle-gradient void DrawCircleGradient ( int centerX, int centerY, float radius, Color color1, Color color2 )        ! Draw a gradient-filled circle
FUNCTION-ALIAS: draw-circle-v void DrawCircleV ( Vector2 center, float radius, Color color )                                     ! Draw a color-filled circle (Vector version)
FUNCTION-ALIAS: draw-circle-lines void DrawCircleLines ( int centerX, int centerY, float radius, Color color )                   ! Draw circle outline
FUNCTION-ALIAS: draw-ellipse void DrawEllipse ( int centerX, int centerY, float radiusH, float radiusV, Color color )            ! Draw ellipse
FUNCTION-ALIAS: draw-ellipse-lines void DrawEllipseLines ( int centerX, int centerY, float radiusH, float radiusV, Color color ) ! Draw ellipse outline
FUNCTION-ALIAS: draw-ring void DrawRing ( Vector2 center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, Color color )  ! Draw ring
FUNCTION-ALIAS: draw-ring-lines void DrawRingLines ( Vector2 center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, Color color )     ! Draw ring outline
FUNCTION-ALIAS: draw-rectangle void DrawRectangle ( int posX, int posY, int width, int height, Color color )                     ! Draw a color-filled rectangle
FUNCTION-ALIAS: draw-rectangle-v void DrawRectangleV ( Vector2 position, Vector2 size, Color color )                             ! Draw a color-filled rectangle (Vector version)
FUNCTION-ALIAS: draw-rectangle-rec void DrawRectangleRec ( Rectangle rec, Color color )                                          ! Draw a color-filled rectangle
FUNCTION-ALIAS: draw-rectangle-pro void DrawRectanglePro ( Rectangle rec, Vector2 origin, float rotation, Color color )          ! Draw a color-filled rectangle with pro parameters
FUNCTION-ALIAS: draw-rectangle-gradient-v void DrawRectangleGradientV ( int posX, int posY, int width, int height, Color color1, Color color2 ) ! Draw a vertical-gradient-filled rectangle
FUNCTION-ALIAS: draw-rectangle-gradient-h void DrawRectangleGradientH ( int posX, int posY, int width, int height, Color color1, Color color2 ) ! Draw a horizontal-gradient-filled rectangle
FUNCTION-ALIAS: draw-rectangle-gradient-ex void DrawRectangleGradientEx ( Rectangle rec, Color col1, Color col2, Color col3, Color col4 )        ! Draw a gradient-filled rectangle with custom vertex colors
FUNCTION-ALIAS: draw-rectangle-lines void DrawRectangleLines ( int posX, int posY, int width, int height, Color color )          ! Draw rectangle outline
FUNCTION-ALIAS: draw-rectangle-lines-ex void DrawRectangleLinesEx ( Rectangle rec, float lineThick, Color color )                ! Draw rectangle outline with extended parameters
FUNCTION-ALIAS: draw-rectangle-rounded void DrawRectangleRounded ( Rectangle rec, float roundness, int segments, Color color )   ! Draw rectangle with rounded edges
FUNCTION-ALIAS: draw-rectangle-rounded-lines void DrawRectangleRoundedLines ( Rectangle rec, float roundness, int segments, float lineThick, Color color )  ! Draw rectangle with rounded edges outline
FUNCTION-ALIAS: draw-triangle void DrawTriangle ( Vector2 v1, Vector2 v2, Vector2 v3, Color color )                              ! Draw a color-filled triangle (vertex in counter-clockwise order!)
FUNCTION-ALIAS: draw-triangle-lines void DrawTriangleLines ( Vector2 v1, Vector2 v2, Vector2 v3, Color color )                   ! Draw triangle outline (vertex in counter-clockwise order!)
FUNCTION-ALIAS: draw-triangle-fan void DrawTriangleFan ( Vector2* points, int pointCount, Color color )                          ! Draw a triangle fan defined by points (first vertex is the center)
FUNCTION-ALIAS: draw-triangle-strip void DrawTriangleStrip ( Vector2* points, int pointCount, Color color )                      ! Draw a triangle strip defined by points
FUNCTION-ALIAS: draw-poly void DrawPoly ( Vector2 center, int sides, float radius, float rotation, Color color )                 ! Draw a regular polygon (Vector version)
FUNCTION-ALIAS: draw-poly-lines void DrawPolyLines ( Vector2 center, int sides, float radius, float rotation, Color color )      ! Draw a polygon outline of n sides
FUNCTION-ALIAS: draw-poly-lines-ex void DrawPolyLinesEx ( Vector2 center, int sides, float radius, float rotation, float lineThick, Color color )  ! Draw a polygon outline of n sides with extended parameters

! Basic shapes collision detection functions
FUNCTION-ALIAS: check-collision-recs bool CheckCollisionRecs ( Rectangle rec1, Rectangle rec2 )                                  ! Check collision between two rectangles
FUNCTION-ALIAS: check-collision-circles bool CheckCollisionCircles ( Vector2 center1, float radius1, Vector2 center2, float radius2 ) ! Check collision between two circles
FUNCTION-ALIAS: check-collision-circle-rec bool CheckCollisionCircleRec ( Vector2 center, float radius, Rectangle rec )          ! Check collision between circle and rectangle
FUNCTION-ALIAS: check-collision-point-rec bool CheckCollisionPointRec ( Vector2 point, Rectangle rec )                           ! Check if point is inside rectangle
FUNCTION-ALIAS: check-collision-point-circle bool CheckCollisionPointCircle ( Vector2 point, Vector2 center, float radius )      ! Check if point is inside circle
FUNCTION-ALIAS: check-collision-point-triangle bool CheckCollisionPointTriangle ( Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3 ) ! Check if point is inside a triangle
FUNCTION-ALIAS: check-collision-point-poly bool CheckCollisionPointPoly ( Vector2 point, Vector2* points, int pointCount ) ! Check if point is within a polygon described by array of vertices
FUNCTION-ALIAS: check-collision-lines bool CheckCollisionLines ( Vector2 startPos1, Vector2 endPos1, Vector2 startPos2, Vector2 endPos2, Vector2* collisionPoint )  ! Check the collision between two lines defined by two points each, returns collision point by reference
FUNCTION-ALIAS: check-collision-point-line bool CheckCollisionPointLine ( Vector2 point, Vector2 p1, Vector2 p2, int threshold ) ! Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
FUNCTION-ALIAS: get-collision-rec Rectangle GetCollisionRec ( Rectangle rec1, Rectangle rec2 )                                   ! Get collision rectangle for two rectangles collision

! ------------------------------------------------------------------------------------
! Texture Loading and Drawing Functions (Module: textures)
! ------------------------------------------------------------------------------------

! Image loading functions
! NOTE: This functions do not require GPU access
FUNCTION-ALIAS: load-image Image LoadImage ( c-string fileName )                                                                 ! Load image from file into CPU memory (RAM)
FUNCTION-ALIAS: load-image-raw Image LoadImageRaw ( c-string fileName, int width, int height, int format, int headerSize )       ! Load image from RAW file data
FUNCTION-ALIAS: load-image-anim Image LoadImageAnim ( c-string fileName, int* frames )                                           ! Load image sequence from file (frames appended to image.data)
FUNCTION-ALIAS: load-image-from-memory Image LoadImageFromMemory ( c-string fileType, c-string fileData, int dataSize )          ! Load image from memory buffer, fileType refers to extension: i.e. '.png'
FUNCTION-ALIAS: load-image-from-texture Image LoadImageFromTexture ( Texture2D texture )                                         ! Load image from GPU texture data
FUNCTION-ALIAS: load-image-from-screen Image LoadImageFromScreen ( )                                                             ! Load image from screen buffer and (screenshot)
FUNCTION-ALIAS: is-image-ready bool IsImageReady ( Image image )                                                                 ! Check if an image is ready
FUNCTION-ALIAS: unload-image void UnloadImage ( Image image )                                                                    ! Unload image from CPU memory (RAM)
FUNCTION-ALIAS: export-image bool ExportImage ( Image image, c-string fileName )                                                 ! Export image data to file, returns true on success
FUNCTION-ALIAS: export-image-as-code bool ExportImageAsCode ( Image image, c-string fileName )                                   ! Export image as code file defining an array of bytes, returns true on success

! Image generation functions
FUNCTION-ALIAS: gen-image-color Image GenImageColor ( int width, int height, Color color )                                       ! Generate image: plain color
FUNCTION-ALIAS: gen-image-gradient-v Image GenImageGradientV ( int width, int height, Color top, Color bottom )                  ! Generate image: vertical gradient
FUNCTION-ALIAS: gen-image-gradient-h Image GenImageGradientH ( int width, int height, Color left, Color right )                  ! Generate image: horizontal gradient
FUNCTION-ALIAS: gen-image-gradient-radial Image GenImageGradientRadial ( int width, int height, float density, Color inner, Color outer ) ! Generate image: radial gradient
FUNCTION-ALIAS: gen-image-checked Image GenImageChecked ( int width, int height, int checksX, int checksY, Color col1, Color col2 ) ! Generate image: checked
FUNCTION-ALIAS: gen-image-white-noise Image GenImageWhiteNoise ( int width, int height, float factor )                           ! Generate image: white noise
FUNCTION-ALIAS: gen-image-perlin-noise Image GenImagePerlinNoise ( int width, int height, int offsetX, int offsetY, float scale ) ! Generate image: perlin noise
FUNCTION-ALIAS: gen-image-cellular Image GenImageCellular ( int width, int height, int tileSize )                                ! Generate image: cellular algorithm, bigger tileSize means bigger cells
FUNCTION-ALIAS: gen-image-text Image GenImageText ( int width, int height, c-string text )                                       ! Generate image: text

! Image manipulation functions
FUNCTION-ALIAS: image-copy Image ImageCopy ( Image image )                                                                       ! Create an image duplicate (useful for transformations)
FUNCTION-ALIAS: image-from-image Image ImageFromImage ( Image image, Rectangle rec )                                             ! Create an image from another image piece
FUNCTION-ALIAS: image-text Image ImageText ( c-string text, int fontSize, Color color )                                          ! Create an image from text (default font)
FUNCTION-ALIAS: image-text-ex Image ImageTextEx ( Font font, c-string text, float fontSize, float spacing, Color tint )          ! Create an image from text (custom sprite font)
FUNCTION-ALIAS: image-format void ImageFormat ( Image* image, int newformat )                                                    ! Convert image data to desired format
FUNCTION-ALIAS: image-to-pot void ImageToPOT ( Image* image, Color fill )                                                        ! Convert image to POT (power-of-two)
FUNCTION-ALIAS: image-crop void ImageCrop ( Image* image, Rectangle crop )                                                       ! Crop an image to a defined rectangle
FUNCTION-ALIAS: image-alpha-crop void ImageAlphaCrop ( Image* image, float threshold )                                           ! Crop image depending on alpha value
FUNCTION-ALIAS: image-alpha-clear void ImageAlphaClear ( Image* image, Color color, float threshold )                            ! Clear alpha channel to desired color
FUNCTION-ALIAS: image-alpha-mask void ImageAlphaMask ( Image* image, Image alphaMask )                                           ! Apply alpha mask to image
FUNCTION-ALIAS: image-alpha-premultiply void ImageAlphaPremultiply ( Image* image )                                              ! Premultiply alpha channel
FUNCTION-ALIAS: image-blur-gaussian void ImageBlurGaussian ( Image* image, int blurSize )                                        ! Blur image with gaussian
FUNCTION-ALIAS: image-resize void ImageResize ( Image* image, int newWidth, int newHeight )                                      ! Resize image (Bicubic scaling algorithm)
FUNCTION-ALIAS: image-resize-nn void ImageResizeNN ( Image* image, int newWidth, int newHeight )                                 ! Resize image (Nearest-Neighbor scaling algorithm)
FUNCTION-ALIAS: image-resize-canvas void ImageResizeCanvas ( Image* image, int newWidth, int newHeight, int offsetX, int offsetY, Color fill )  ! Resize canvas and fill with color
FUNCTION-ALIAS: image-mipmaps void ImageMipmaps ( Image* image )                                                                 ! Compute all mipmap levels for a provided image
FUNCTION-ALIAS: image-dither void ImageDither ( Image* image, int rBpp, int gBpp, int bBpp, int aBpp )                           ! Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
FUNCTION-ALIAS: image-flip-vertical void ImageFlipVertical ( Image* image )                                                      ! Flip image vertically
FUNCTION-ALIAS: image-flip-horizontal void ImageFlipHorizontal ( Image* image )                                                  ! Flip image horizontally
FUNCTION-ALIAS: image-rotate-cw void ImageRotateCW ( Image* image )                                                              ! Rotate image clockwise 90deg
FUNCTION-ALIAS: image-rotate-ccw void ImageRotateCCW ( Image* image )                                                            ! Rotate image counter-clockwise 90deg
FUNCTION-ALIAS: image-color-tint void ImageColorTint ( Image* image, Color color )                                               ! Modify image color: tint
FUNCTION-ALIAS: image-color-invert void ImageColorInvert ( Image* image )                                                        ! Modify image color: invert
FUNCTION-ALIAS: image-color-grayscale void ImageColorGrayscale ( Image* image )                                                  ! Modify image color: grayscale
FUNCTION-ALIAS: image-color-contrast void ImageColorContrast ( Image* image, float contrast )                                    ! Modify image color: contrast (-100 to 100)
FUNCTION-ALIAS: image-color-brightness void ImageColorBrightness ( Image* image, int brightness )                                ! Modify image color: brightness (-255 to 255)
FUNCTION-ALIAS: image-color-replace void ImageColorReplace ( Image* image, Color color, Color replace )                          ! Modify image color: replace color
FUNCTION-ALIAS: load-image-colors Color* LoadImageColors ( Image image )                                                         ! Load color data from image as a Color array (RGBA - 32bit)
FUNCTION-ALIAS: load-image-palette Color* LoadImagePalette ( Image image, int maxPaletteSize, int* colorCount )                  ! Load colors palette from image as a Color array (RGBA - 32bit)
FUNCTION-ALIAS: unload-image-colors void UnloadImageColors ( Color* colors )                                                     ! Unload color data loaded with LoadImageColors()
FUNCTION-ALIAS: unload-image-palette void UnloadImagePalette ( Color* colors )                                                   ! Unload colors palette loaded with LoadImagePalette()
FUNCTION-ALIAS: get-image-alpha-border Rectangle GetImageAlphaBorder ( Image image, float threshold )                            ! Get image alpha border rectangle
FUNCTION-ALIAS: get-image-color Color GetImageColor ( Image image, int x, int y )                                                ! Get image pixel color at (x, y) position

! Image drawing functions
! NOTE: Image software-rendering functions (CPU)
FUNCTION-ALIAS: image-clear-background void ImageClearBackground ( Image* dst, Color color )                                     ! Clear image background with given color
FUNCTION-ALIAS: image-draw-pixel void ImageDrawPixel ( Image* dst, int posX, int posY, Color color )                             ! Draw pixel within an image
FUNCTION-ALIAS: image-draw-pixel-v void ImageDrawPixelV ( Image* dst, Vector2 position, Color color )                            ! Draw pixel within an image (Vector version)
FUNCTION-ALIAS: image-draw-line void ImageDrawLine ( Image* dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color ) ! Draw line within an image
FUNCTION-ALIAS: image-draw-line-v void ImageDrawLineV ( Image* dst, Vector2 start, Vector2 end, Color color )                    ! Draw line within an image (Vector version)
FUNCTION-ALIAS: image-draw-circle void ImageDrawCircle ( Image* dst, int centerX, int centerY, int radius, Color color )         ! Draw circle within an image
FUNCTION-ALIAS: image-draw-circle-v void ImageDrawCircleV ( Image* dst, Vector2 center, int radius, Color color )                ! Draw circle within an image (Vector version)
FUNCTION-ALIAS: image-draw-circle-lines void ImageDrawCircleLines ( Image* dst, int centerX, int centerY, int radius, Color color )         ! Draw circle within an image
FUNCTION-ALIAS: image-draw-circle-lines-v void ImageDrawCircleLinesV ( Image* dst, Vector2 center, int radius, Color color )                ! Draw circle within an image (Vector version)
FUNCTION-ALIAS: image-draw-rectangle void ImageDrawRectangle ( Image* dst, int posX, int posY, int width, int height, Color color ) ! Draw rectangle within an image
FUNCTION-ALIAS: image-draw-rectangle-v void ImageDrawRectangleV ( Image* dst, Vector2 position, Vector2 size, Color color )      ! Draw rectangle within an image (Vector version)
FUNCTION-ALIAS: image-draw-rectangle-rec void ImageDrawRectangleRec ( Image* dst, Rectangle rec, Color color )                   ! Draw rectangle within an image
FUNCTION-ALIAS: image-draw-rectangle-lines void ImageDrawRectangleLines ( Image* dst, Rectangle rec, int thick, Color color )    ! Draw rectangle lines within an image
FUNCTION-ALIAS: image-draw void ImageDraw ( Image* dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint )              ! Draw a source image within a destination image (tint applied to source)
FUNCTION-ALIAS: image-draw-text void ImageDrawText ( Image* dst, c-string text, int posX, int posY, int fontSize, Color color )  ! Draw text (using default font) within an image (destination)
FUNCTION-ALIAS: image-draw-text-ex void ImageDrawTextEx ( Image* dst, Font font, c-string text, Vector2 position, float fontSize, float spacing, Color tint )  ! Draw text (custom sprite font) within an image (destination)

! Texture loading functions
! NOTE: These functions require GPU access
FUNCTION-ALIAS: load-texture Texture2D LoadTexture ( c-string fileName )                                                         ! Load texture from file into GPU memory (VRAM)
FUNCTION-ALIAS: load-texture-from-image Texture2D LoadTextureFromImage ( Image image )                                           ! Load texture from image data
FUNCTION-ALIAS: load-texture-cubemap TextureCubemap LoadTextureCubemap ( Image image, CubemapLayout layout )                     ! Load cubemap from image, multiple image cubemap layouts supported
FUNCTION-ALIAS: load-render-texture RenderTexture2D LoadRenderTexture ( int width, int height )                                  ! Load texture for rendering (framebuffer)
FUNCTION-ALIAS: is-texture-ready bool IsTextureReady ( Texture2D texture )                                                            ! Check if a texture is ready
FUNCTION-ALIAS: unload-texture void UnloadTexture ( Texture2D texture )                                                          ! Unload texture from GPU memory (VRAM)
FUNCTION-ALIAS: is-render-texture-ready void IsRenderTextureReady ( RenderTexture2D target )                                     ! Check if a render texture is ready
FUNCTION-ALIAS: unload-render-texture void UnloadRenderTexture ( RenderTexture2D target )                                        ! Unload render texture from GPU memory (VRAM)
FUNCTION-ALIAS: update-texture void UpdateTexture ( Texture2D texture, void* pixels )                                            ! Update GPU texture with new data
FUNCTION-ALIAS: update-texture-rec void UpdateTextureRec ( Texture2D texture, Rectangle rec, void* pixels )                      ! Update GPU texture rectangle with new data

! Texture configuration functions
FUNCTION-ALIAS: gen-texture-mipmaps void GenTextureMipmaps ( Texture2D* texture )                                                ! Generate GPU mipmaps for a texture
FUNCTION-ALIAS: set-texture-filter void SetTextureFilter ( Texture2D texture, TextureFilterMode filter )                         ! Set texture scaling filter mode
FUNCTION-ALIAS: set-texture-wrap void SetTextureWrap ( Texture2D texture, TextureWrapMode wrap )                                 ! Set texture wrapping mode

! Texture drawing functions
FUNCTION-ALIAS: draw-texture void DrawTexture ( Texture2D texture, int posX, int posY, Color tint )                              ! Draw a Texture2D
FUNCTION-ALIAS: draw-texture-v void DrawTextureV ( Texture2D texture, Vector2 position, Color tint )                             ! Draw a Texture2D with position defined as Vector2
FUNCTION-ALIAS: draw-texture-ex void DrawTextureEx ( Texture2D texture, Vector2 position, float rotation, float scale, Color tint ) ! Draw a Texture2D with extended parameters
FUNCTION-ALIAS: draw-texture-rec void DrawTextureRec ( Texture2D texture, Rectangle source, Vector2 position, Color tint )       ! Draw a part of a texture defined by a rectangle
FUNCTION-ALIAS: draw-texture-pro void DrawTexturePro ( Texture2D texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, Color tint ) ! Draw a part of a texture defined by a rectangle with 'pro' parameters
FUNCTION-ALIAS: draw-texture-npatch void DrawTextureNPatch ( Texture2D texture, NPatchInfo nPatchInfo, Rectangle dest, Vector2 origin, float rotation, Color tint ) ! Draws a texture (or part of it) that stretches or shrinks nicely

! Color/pixel related functions
FUNCTION-ALIAS: fade Color Fade ( Color color, float alpha )                                   ! Get color with alpha applied, alpha goes from 0.0f to 1.0f
FUNCTION-ALIAS: color-to-int int ColorToInt ( Color color )                                    ! Get hexadecimal value for a Color
FUNCTION-ALIAS: color-normalize Vector4 ColorNormalize ( Color color )                         ! Get Color normalized as float [0..1]
FUNCTION-ALIAS: color-from-normalized Color ColorFromNormalized ( Vector4 normalized )         ! Get Color from normalized values [0..1]
FUNCTION-ALIAS: color-to-hsv Vector3 ColorToHSV ( Color color )                                ! Get HSV values for a Color, hue [0..360], saturation/value [0..1]
FUNCTION-ALIAS: color-from-hsv Color ColorFromHSV ( float hue, float saturation, float value ) ! Get a Color from HSV values, hue [0..360], saturation/value [0..1]
FUNCTION-ALIAS: color-tint Color ColorTint ( Color color, Color tint )                         ! Get color with tint
FUNCTION-ALIAS: color-brightness Color ColorBrightness ( Color color, float factor )           ! Get color with brightness
FUNCTION-ALIAS: color-contrast Color ColorContrast ( Color color, float contrast )             ! Get color with contrast
FUNCTION-ALIAS: color-alpha Color ColorAlpha ( Color color, float alpha )                      ! Get color with alpha applied, alpha goes from 0.0f to 1.0f
FUNCTION-ALIAS: color-alpha-blend Color ColorAlphaBlend ( Color dst, Color src, Color tint )   ! Get src alpha-blended into dst color with tint
FUNCTION-ALIAS: get-color Color GetColor ( uint hexValue )                                     ! Get Color structure from hexadecimal value
FUNCTION-ALIAS: get-pixel-color Color GetPixelColor ( void* srcPtr, PixelFormat format )               ! Get Color from a source pixel pointer of certain format
FUNCTION-ALIAS: set-pixel-color void SetPixelColor ( void* dstPtr, Color color, PixelFormat format )   ! Set color formatted into destination pixel pointer
FUNCTION-ALIAS: get-pixel-data-size int GetPixelDataSize ( int width, int height, PixelFormat format ) ! Get pixel data size in bytes for certain format

! ------------------------------------------------------------------------------------
! Font Loading and Text Drawing Functions (Module: text)
! ------------------------------------------------------------------------------------

! Font loading/unloading functions
FUNCTION-ALIAS: get-font-default Font GetFontDefault ( )                                                             ! Get the default Font
FUNCTION-ALIAS: load-font Font LoadFont ( c-string fileName )                                                        ! Load font from file into GPU memory (VRAM)
FUNCTION-ALIAS: load-font-ex Font LoadFontEx ( c-string fileName, int fontSize, int* fontChars, int glyphCount )     ! Load font from file with extended parameters, use NULL for fontChars and 0 for glyphCount to load the default character set
FUNCTION-ALIAS: load-font-from-image Font LoadFontFromImage ( Image image, Color key, int firstChar )                ! Load font from Image (XNA style)
FUNCTION-ALIAS: load-font-from-memory Font LoadFontFromMemory ( c-string fileType, c-string fileData, int dataSize, int fontSize, int* fontChars, int glyphCount )  ! Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
FUNCTION-ALIAS: is-font-ready bool IsFontReady ( Font font )                                                         ! Check if a font is ready
FUNCTION-ALIAS: load-font-data GlyphInfo* LoadFontData ( c-string  fileData, int dataSize, int fontSize, int* fontChars, int glyphCount, FontType type )  ! Load font data for further use
FUNCTION-ALIAS: gen-image-font-atlas Image GenImageFontAtlas ( GlyphInfo* chars, Rectangle** recs, int glyphCount, int fontSize, int padding, int packMethod )  ! Generate image font atlas using chars info
FUNCTION-ALIAS: unload-font-data void UnloadFontData ( GlyphInfo* chars, int glyphCount )                            ! Unload font chars info data (RAM)
FUNCTION-ALIAS: unload-font void UnloadFont ( Font font )                                                            ! Unload Font from GPU memory (VRAM)
FUNCTION-ALIAS: export-font-as-code bool ExportFontAsCode ( Font font, c-string fileName )                           ! Export font as code file, returns true on success

! Text drawing functions
FUNCTION-ALIAS: draw-fps void DrawFPS ( int posX, int posY )                                                         ! Draw current FPS
FUNCTION-ALIAS: draw-text void DrawText ( c-string text, int posX, int posY, int fontSize, Color color )             ! Draw text (using default font)
FUNCTION-ALIAS: draw-text-ex void DrawTextEx ( Font font, c-string text, Vector2 position, float fontSize, float spacing, Color tint )  ! Draw text using font and additional parameters
FUNCTION-ALIAS: draw-text-pro void DrawTextPro ( Font font, c-string text, Vector2 position, Vector2 origin, float rotation, float fontSize, float spacing, Color tint )  ! Draw text using Font and pro parameters (rotation)
FUNCTION-ALIAS: draw-text-codepoint void DrawTextCodepoint ( Font font, int codepoint, Vector2 position, float fontSize, Color tint )  ! Draw one character (codepoint)
FUNCTION-ALIAS: draw-text-codepoints void DrawTextCodepoints ( Font font, int* codepoint, int count, Vector2 position, float fontSize, float spacing,  Color tint )  ! Draw multiple character (codepoint)

! Text font info functions
FUNCTION-ALIAS: measure-text int MeasureText ( c-string text, int fontSize )                                         ! Measure string width for default font
FUNCTION-ALIAS: measure-text-ex Vector2 MeasureTextEx ( Font font, c-string text, float fontSize, float spacing )    ! Measure string size for Font
FUNCTION-ALIAS: get-glyph-index int GetGlyphIndex ( Font font, int codepoint )                                       ! Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
FUNCTION-ALIAS: get-glyph-info GlyphInfo GetGlyphInfo ( Font font, int codepoint )                                   ! Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
FUNCTION-ALIAS: get-glyph-atlas-rec Rectangle GetGlyphAtlasRec ( Font font, int codepoint )                          ! Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found

! Text codepoints management functions (unicode characters)
FUNCTION-ALIAS: load-utf8 c-string LoadUTF8 ( int *codepoints, int length )                     ! Load UTF-8 text encoded from codepoints array
FUNCTION-ALIAS: unload-utf8 void UnloadUTF8 ( c-string text )                                   ! Unload UTF-8 text encoded from codepoints array
FUNCTION-ALIAS: load-codepoints int* LoadCodepoints ( c-string text, int* count )                     ! Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
FUNCTION-ALIAS: unload-codepoints void UnloadCodepoints ( int* codepoints )                           ! Unload codepoints data from memory
FUNCTION-ALIAS: get-codepoint-count int GetCodepointCount ( c-string text )                           ! Get total number of codepoints in a UTF-8 encoded string
FUNCTION-ALIAS: get-codepoint int GetCodepoint ( c-string text, int* bytesProcessed )                 ! Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
FUNCTION-ALIAS: get-codepoint-next int GetCodepointNext ( c-string text, int* codepointSize )         ! Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
FUNCTION-ALIAS: get-codepoint-previous int GetCodepointPrevious ( c-string text, int* codepointSize ) ! Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
FUNCTION-ALIAS: codepoint-to-utf8 c-string CodepointToUTF8 ( int codepoint, int* byteSize )           ! Encode one codepoint into UTF-8 byte array (array length returned as parameter)

! Text strings management functions (no UTF-8 strings, only byte chars)
! NOTE: Some strings allocate memory internally for returned strings, just be careful!
FUNCTION-ALIAS: text-copy int TextCopy ( c-string  dst, c-string src )                                ! Copy one string to another, returns bytes copied
FUNCTION-ALIAS: text-is-equal bool TextIsEqual ( c-string text1, c-string text2 )                     ! Check if two text string are equal
FUNCTION-ALIAS: text-length uint TextLength ( c-string text )                                         ! Get text length, checks for '\0' ending
! FUNCTION: c-string TextFormat ( c-string text, ... )                                                  ! Text formatting with variables (sprintf() style)
FUNCTION-ALIAS: text-subtext c-string TextSubtext ( c-string text, int position, int length )         ! Get a piece of a text string
FUNCTION-ALIAS: text-replace c-string TextReplace ( c-string  text, c-string replace, c-string by )   ! Replace text string (WARNING: memory must be freed!)
FUNCTION-ALIAS: text-insert c-string TextInsert ( c-string text, c-string insert, int position )      ! Insert text in a position (WARNING: memory must be freed!)
FUNCTION-ALIAS: text-join c-string TextJoin ( c-string* textList, int count, c-string delimiter )     ! Join text strings with delimiter
FUNCTION-ALIAS: text-split c-string* TextSplit ( c-string text, char delimiter, int* count )          ! Split text into multiple strings
FUNCTION-ALIAS: text-append void TextAppend ( c-string text, c-string append, int* position )         ! Append text at specific position and move cursor!
FUNCTION-ALIAS: text-find-index int TextFindIndex ( c-string text, c-string find )                    ! Find first text occurrence within a string
FUNCTION-ALIAS: text-to-upper c-string TextToUpper ( c-string text )                                  ! Get upper case version of provided string
FUNCTION-ALIAS: text-to-lower c-string TextToLower ( c-string text )                                  ! Get lower case version of provided string
FUNCTION-ALIAS: text-to-pascal c-string TextToPascal ( c-string text )                                ! Get Pascal case notation version of provided string
FUNCTION-ALIAS: text-to-integer int TextToInteger ( c-string text )                                   ! Get integer value from text (negative values not supported)

! ------------------------------------------------------------------------------------
! Basic 3d Shapes Drawing Functions (Module: models)
! ------------------------------------------------------------------------------------

! Basic geometric 3D shapes drawing functions
FUNCTION-ALIAS: draw-line-3d void DrawLine3D ( Vector3 startPos, Vector3 endPos, Color color )        ! Draw a line in 3D world space
FUNCTION-ALIAS: draw-point-3d void DrawPoint3D ( Vector3 position, Color color )                      ! Draw a point in 3D space, actually a small line
FUNCTION-ALIAS: draw-circle-3d void DrawCircle3D ( Vector3 center, float radius, Vector3 rotationAxis, float rotationAngle, Color color )  ! Draw a circle in 3D world space
FUNCTION-ALIAS: draw-triangle-3d void DrawTriangle3D ( Vector3 v1, Vector3 v2, Vector3 v3, Color color ) ! Draw a color-filled triangle (vertex in counter-clockwise order!)
FUNCTION-ALIAS: draw-triangle-strip-3d void DrawTriangleStrip3D ( Vector3* points, int pointCount, Color color ) ! Draw a triangle strip defined by points
FUNCTION-ALIAS: draw-cube void DrawCube ( Vector3 position, float width, float height, float length, Color color ) ! Draw cube
FUNCTION-ALIAS: draw-cube-v void DrawCubeV ( Vector3 position, Vector3 size, Color color )            ! Draw cube (Vector version)
FUNCTION-ALIAS: draw-cube-wires void DrawCubeWires ( Vector3 position, float width, float height, float length, Color color ) ! Draw cube wires
FUNCTION-ALIAS: draw-cube-wires-v void DrawCubeWiresV ( Vector3 position, Vector3 size, Color color ) ! Draw cube wires (Vector version)
FUNCTION-ALIAS: draw-sphere void DrawSphere ( Vector3 centerPos, float radius, Color color )          ! Draw sphere
FUNCTION-ALIAS: draw-sphere-ex void DrawSphereEx ( Vector3 centerPos, float radius, int rings, int slices, Color color ) ! Draw sphere with extended parameters
FUNCTION-ALIAS: draw-sphere-wires void DrawSphereWires ( Vector3 centerPos, float radius, int rings, int slices, Color color ) ! Draw sphere wires
FUNCTION-ALIAS: draw-cylinder void DrawCylinder ( Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color )  ! Draw a cylinder/cone
FUNCTION-ALIAS: draw-cylinder-ex void DrawCylinderEx ( Vector3 startPos, Vector3 endPos, float startRadius, float endRadius, int sides, Color color )  ! Draw a cylinder with base at startPos and top at endPos
FUNCTION-ALIAS: draw-cylinder-wires void DrawCylinderWires ( Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color )  ! Draw a cylinder/cone wires
FUNCTION-ALIAS: draw-cylinder-wires-ex void DrawCylinderWiresEx ( Vector3 startPos, Vector3 endPos, float startRadius, float endRadius, int sides, Color color )  ! Draw a cylinder wires with base at startPos and top at endPos
FUNCTION-ALIAS: draw-capsule void DrawCapsule ( Vector3 startPos, Vector3 endPos, float radius, int slices, int rings, Color color )  ! Draw a capsule with the center of its sphere caps at startPos and endPos
FUNCTION-ALIAS: draw-capsule-wires void DrawCapsuleWires ( Vector3 startPos, Vector3 endPos, float radius, int slices, int rings, Color color )  ! Draw capsule wireframe with the center of its sphere caps at startPos and endPos
FUNCTION-ALIAS: draw-plane void DrawPlane ( Vector3 centerPos, Vector2 size, Color color )            ! Draw a plane XZ
FUNCTION-ALIAS: draw-ray void DrawRay ( Ray ray, Color color )                                        ! Draw a ray line
FUNCTION-ALIAS: draw-grid void DrawGrid ( int slices, float spacing )                                 ! Draw a grid (centered at (0, 0, 0))

! ------------------------------------------------------------------------------------
! Model 3d Loading and Drawing Functions (Module: models)
! ------------------------------------------------------------------------------------

! Model management functions
FUNCTION-ALIAS: load-model Model LoadModel ( c-string fileName )                                      ! Load model from files (meshes and materials)
FUNCTION-ALIAS: load-model-from-mesh Model LoadModelFromMesh ( Mesh mesh )                            ! Load model from generated mesh (default material)
FUNCTION-ALIAS: is-model-ready bool IsModelReady ( Model model )                                      ! Check if a model is ready
FUNCTION-ALIAS: unload-model void UnloadModel ( Model model )                                         ! Unload model (including meshes) from memory (RAM and/or VRAM)
FUNCTION-ALIAS: get-model-bounding-box BoundingBox GetModelBoundingBox ( Model model )                ! Compute model bounding box limits (considers all meshes)

! Model drawing functions
FUNCTION-ALIAS: draw-model void DrawModel ( Model model, Vector3 position, float scale, Color tint )  ! Draw a model (with texture if set)
FUNCTION-ALIAS: draw-model-ex void DrawModelEx ( Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint )  ! Draw a model with extended parameters
FUNCTION-ALIAS: draw-model-wires void DrawModelWires ( Model model, Vector3 position, float scale, Color tint ) ! Draw a model wires (with texture if set)
FUNCTION-ALIAS: draw-model-wires-ex void DrawModelWiresEx ( Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint )  ! Draw a model wires (with texture if set) with extended parameters
FUNCTION-ALIAS: draw-bounding-box void DrawBoundingBox ( BoundingBox box, Color color )               ! Draw bounding box (wires)
FUNCTION-ALIAS: draw-billboard void DrawBillboard ( Camera camera, Texture2D texture, Vector3 position, float size, Color tint ) ! Draw a billboard texture
FUNCTION-ALIAS: draw-billboard-rec void DrawBillboardRec ( Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector2 size, Color tint )  ! Draw a billboard texture defined by source
FUNCTION-ALIAS: draw-billboard-pro void DrawBillboardPro ( Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector3 up, Vector2 size, Vector2 origin, float rotation, Color tint )  ! Draw a billboard texture defined by source and rotation

! Mesh management functions
FUNCTION-ALIAS: upload-mesh void UploadMesh ( Mesh* mesh, bool dynamic )                              ! Upload mesh vertex data in GPU and provide VAO/VBO ids
FUNCTION-ALIAS: update-mesh-buffer void UpdateMeshBuffer ( Mesh mesh, int index, void* data, int dataSize, int offset ) ! Update mesh vertex data in GPU for a specific buffer index
FUNCTION-ALIAS: unload-mesh void UnloadMesh ( Mesh mesh )                                             ! Unload mesh data from CPU and GPU
FUNCTION-ALIAS: draw-mesh void DrawMesh ( Mesh mesh, Material material, Matrix transform )            ! Draw a 3d mesh with material and transform
FUNCTION-ALIAS: draw-mesh-instanced void DrawMeshInstanced ( Mesh mesh, Material material, Matrix* transforms, int instances )  ! Draw multiple mesh instances with material and different transforms
FUNCTION-ALIAS: export-mesh bool ExportMesh ( Mesh mesh, c-string fileName )                          ! Export mesh data to file, returns true on success
FUNCTION-ALIAS: get-mesh-bounding-box BoundingBox GetMeshBoundingBox ( Mesh mesh )                    ! Compute mesh bounding box limits
FUNCTION-ALIAS: gen-mesh-tangents void GenMeshTangents ( Mesh* mesh )                                 ! Compute mesh tangents

! Mesh generation functions
FUNCTION-ALIAS: gen-mesh-poly Mesh GenMeshPoly ( int sides, float radius )                            ! Generate polygonal mesh
FUNCTION-ALIAS: gen-mesh-plane Mesh GenMeshPlane ( float width, float length, int resX, int resZ )    ! Generate plane mesh (with subdivisions)
FUNCTION-ALIAS: gen-mesh-cube Mesh GenMeshCube ( float width, float height, float length )            ! Generate cuboid mesh
FUNCTION-ALIAS: gen-mesh-sphere Mesh GenMeshSphere ( float radius, int rings, int slices )            ! Generate sphere mesh (standard sphere)
FUNCTION-ALIAS: gen-mesh-hemi-sphere Mesh GenMeshHemiSphere ( float radius, int rings, int slices )   ! Generate half-sphere mesh (no bottom cap)
FUNCTION-ALIAS: gen-mesh-cylinder Mesh GenMeshCylinder ( float radius, float height, int slices )     ! Generate cylinder mesh
FUNCTION-ALIAS: gen-mesh-cone Mesh GenMeshCone ( float radius, float height, int slices )             ! Generate cone/pyramid mesh
FUNCTION-ALIAS: gen-mesh-torus Mesh GenMeshTorus ( float radius, float size, int radSeg, int sides )  ! Generate torus mesh
FUNCTION-ALIAS: gen-mesh-knot Mesh GenMeshKnot ( float radius, float size, int radSeg, int sides )    ! Generate trefoil knot mesh
FUNCTION-ALIAS: gen-mesh-heightmap Mesh GenMeshHeightmap ( Image heightmap, Vector3 size )            ! Generate heightmap mesh from image data
FUNCTION-ALIAS: gen-mesh-cubicmap Mesh GenMeshCubicmap ( Image cubicmap, Vector3 cubeSize )           ! Generate cubes-based map mesh from image data

! Material loading/unloading functions
FUNCTION-ALIAS: load-materials Material* LoadMaterials ( c-string fileName, int* materialCount )      ! Load materials from model file
FUNCTION-ALIAS: load-material-default Material LoadMaterialDefault ( )                                ! Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
FUNCTION-ALIAS: is-material-ready bool IsMaterialReady ( Material material )                          ! check if a material is ready
FUNCTION-ALIAS: unload-material void UnloadMaterial ( Material material )                             ! Unload material from GPU memory (VRAM)
FUNCTION-ALIAS: set-material-texture void SetMaterialTexture ( Material* material, int mapType, Texture2D texture ) ! Set texture for a material map type  ( Material_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
FUNCTION-ALIAS: set-model-mesh-material void SetModelMeshMaterial ( Model* model, int meshId, int materialId ) ! Set material for a mesh

! Model animations loading/unloading functions
FUNCTION-ALIAS: load-model-animations ModelAnimation* LoadModelAnimations ( c-string fileName, uint* animCount ) ! Load model animations from file
FUNCTION-ALIAS: update-model-animation void UpdateModelAnimation ( Model model, ModelAnimation anim, int frame ) ! Update model animation pose
FUNCTION-ALIAS: unload-model-animation void UnloadModelAnimation ( ModelAnimation anim )                         ! Unload animation data
FUNCTION-ALIAS: unload-model-animations void UnloadModelAnimations ( ModelAnimation* animations, uint count )    ! Unload animation array data
FUNCTION-ALIAS: is-model-animation-valid bool IsModelAnimationValid ( Model model, ModelAnimation anim )         ! Check model animation skeleton match

! Collision detection functions
FUNCTION-ALIAS: check-collision-spheres bool CheckCollisionSpheres ( Vector3 center1, float radius1, Vector3 center2, float radius2 ) ! Check collision between two spheres
FUNCTION-ALIAS: check-collision-boxes bool CheckCollisionBoxes ( BoundingBox box1, BoundingBox box2 )                                 ! Check collision between two bounding boxes
FUNCTION-ALIAS: check-collision-box-sphere bool CheckCollisionBoxSphere ( BoundingBox box, Vector3 center, float radius )             ! Check collision between box and sphere
FUNCTION-ALIAS: get-ray-collision-sphere RayCollision GetRayCollisionSphere ( Ray ray, Vector3 center, float radius )                 ! Get collision info between ray and sphere
FUNCTION-ALIAS: get-ray-collision-box RayCollision GetRayCollisionBox ( Ray ray, BoundingBox box )                                    ! Get collision info between ray and box
FUNCTION-ALIAS: get-ray-collision-mesh RayCollision GetRayCollisionMesh ( Ray ray, Mesh mesh, Matrix transform )                      ! Get collision info between ray and mesh
FUNCTION-ALIAS: get-ray-collision-triangle RayCollision GetRayCollisionTriangle ( Ray ray, Vector3 p1, Vector3 p2, Vector3 p3 )       ! Get collision info between ray and triangle
FUNCTION-ALIAS: get-ray-collision-quad RayCollision GetRayCollisionQuad ( Ray ray, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4 )   ! Get collision info between ray and quad

: get-ray-collision-model ( ray model -- ray-collision )
    [ RayCollision <struct> ] 2dip dup meshCount>> [
        swap dup
        [ _meshes>> <displaced-alien> ] [ transform>> ] bi*
        get-ray-collision-mesh dup hit>> [
            over hit>> [ 2dup [ distance>> ] bi@ < ] [ t ] if
            [ nip ] [ drop ] if
        ] [ drop ] if
    ] 2with each-integer ;

<PRIVATE
: Vector3Add ( v1 v2 -- v3 )
    [ [ x>> ] bi@ + ] [ [ y>> ] bi@ + ] [ [ z>> ] bi@ + ] 2tri
    Vector3 boa ;
: Vector3Scale ( v scalar -- r )
    [ [ x>> ] [ y>> ] [ z>> ] tri ] dip '[ _ * ] tri@ Vector3 boa ;
PRIVATE>

:: get-ray-collision-ground ( ray ground-height -- ray-collision )
    RayCollision <struct>
    ray direction>> y>> abs 0.000001 > [
        ray position>> y>> ground-height -
        ray direction>> y>> neg / :> distance
        distance 0.0 >= [
            t >>hit
            distance >>distance
            dup normal>> 1.0 >>y drop
            ray position>>
            ray direction>> distance Vector3Scale
            Vector3Add ground-height >>y >>point
        ] when
    ] when ;


! ------------------------------------------------------------------------------------
! Audio Loading and Playing Functions (Module: audio)
! ------------------------------------------------------------------------------------

CALLBACK: void AudioCallback ( void* bufferData, int frames )

! Audio device management functions
FUNCTION-ALIAS: init-audio-device void InitAudioDevice ( )                                      ! Initialize audio device and context
FUNCTION-ALIAS: close-audio-device void CloseAudioDevice ( )                                    ! Close the audio device and context
FUNCTION-ALIAS: is-audio-device-ready bool IsAudioDeviceReady ( )                               ! Check if audio device has been initialized successfully
FUNCTION-ALIAS: set-master-volume void SetMasterVolume ( float volume )                         ! Set master volume (listener)

! Wave/Sound loading/unloading functions
FUNCTION-ALIAS: load-wave Wave LoadWave ( c-string fileName )                                   ! Load wave data from file
FUNCTION-ALIAS: load-wave-from-memory Wave LoadWaveFromMemory ( c-string fileType, c-string fileData, int dataSize )  ! Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
FUNCTION-ALIAS: is-wave-ready bool IsWaveReady ( Wave wave )                                    ! Checks if wave data is ready
FUNCTION-ALIAS: load-sound Sound LoadSound ( c-string fileName )                                ! Load sound from file
FUNCTION-ALIAS: load-sound-from-wave Sound LoadSoundFromWave ( Wave wave )                      ! Load sound from wave data
FUNCTION-ALIAS: is-sound-ready bool IsSoundReady ( Sound sound )                                ! Checks if a sound is ready
FUNCTION-ALIAS: update-sound void UpdateSound ( Sound sound, void* data, int sampleCount )      ! Update sound buffer with new data
FUNCTION-ALIAS: unload-wave void UnloadWave ( Wave wave )                                       ! Unload wave data
FUNCTION-ALIAS: unload-sound void UnloadSound ( Sound sound )                                   ! Unload sound
FUNCTION-ALIAS: export-wave bool ExportWave ( Wave wave, c-string fileName )                    ! Export wave data to file, returns true on success
FUNCTION-ALIAS: export-wave-as-code bool ExportWaveAsCode ( Wave wave, c-string fileName )      ! Export wave sample data to code (.h), returns true on success

! Wave/Sound management functions
FUNCTION-ALIAS: play-sound void PlaySound ( Sound sound )                                       ! Play a sound
FUNCTION-ALIAS: stop-sound void StopSound ( Sound sound )                                       ! Stop playing a sound
FUNCTION-ALIAS: pause-sound void PauseSound ( Sound sound )                                     ! Pause a sound
FUNCTION-ALIAS: resume-sound void ResumeSound ( Sound sound )                                   ! Resume a paused sound
FUNCTION-ALIAS: is-sound-playing bool IsSoundPlaying ( Sound sound )                            ! Check if a sound is currently playing
FUNCTION-ALIAS: set-sound-volume void SetSoundVolume ( Sound sound, float volume )              ! Set volume for a sound (1.0 is max level)
FUNCTION-ALIAS: set-sound-pitch void SetSoundPitch ( Sound sound, float pitch )                 ! Set pitch for a sound (1.0 is base level)
FUNCTION-ALIAS: set-sound-pan void SetSoundPan ( Sound sound, float pan )                       ! Set pan for a sound (0.5 is center)
FUNCTION-ALIAS: wave-copy Wave WaveCopy ( Wave wave )                                           ! Copy a wave to a new wave
FUNCTION-ALIAS: wave-crop void WaveCrop ( Wave* wave, int initSample, int finalSample )         ! Crop a wave to defined samples range
FUNCTION-ALIAS: wave-format void WaveFormat ( Wave* wave, int sampleRate, int sampleSize, int channels ) ! Convert wave data to desired format
FUNCTION-ALIAS: load-wave-samples float* LoadWaveSamples ( Wave wave )                          ! Load samples data from wave as a floats array
FUNCTION-ALIAS: unload-wave-samples void UnloadWaveSamples ( float* samples )                   ! Unload samples data loaded with LoadWaveSamples()

! Music management functions
FUNCTION-ALIAS: load-music-stream Music LoadMusicStream ( c-string fileName )                   ! Load music stream from file
FUNCTION-ALIAS: load-music-stream-from-memory Music LoadMusicStreamFromMemory ( c-string fileType, c-string data, int dataSize ) ! Load music stream from data
FUNCTION-ALIAS: is-music-ready bool IsMusicReady ( Music music )                                ! Checks if a music stream is ready
FUNCTION-ALIAS: unload-music-stream void UnloadMusicStream ( Music music )                      ! Unload music stream
FUNCTION-ALIAS: play-music-stream void PlayMusicStream ( Music music )                          ! Start music playing
FUNCTION-ALIAS: is-music-stream-playing bool IsMusicStreamPlaying ( Music music )               ! Check if music is playing
FUNCTION-ALIAS: update-music-stream void UpdateMusicStream ( Music music )                      ! Updates buffers for music streaming
FUNCTION-ALIAS: stop-music-stream void StopMusicStream ( Music music )                          ! Stop music playing
FUNCTION-ALIAS: pause-music-stream void PauseMusicStream ( Music music )                        ! Pause music playing
FUNCTION-ALIAS: resume-music-stream void ResumeMusicStream ( Music music )                      ! Resume playing paused music
FUNCTION-ALIAS: seek-music-stream void SeekMusicStream ( Music music, float position )          ! Seek music to a position (in seconds)
FUNCTION-ALIAS: set-music-volume void SetMusicVolume ( Music music, float volume )              ! Set volume for music (1.0 is max level)
FUNCTION-ALIAS: set-music-pitch void SetMusicPitch ( Music music, float pitch )                 ! Set pitch for a music (1.0 is base level)
FUNCTION-ALIAS: set-music-pan void SetMusicPan ( Music sound, float pan )                       ! Set pan for a music (0.5 is center)
FUNCTION-ALIAS: get-music-time-length float GetMusicTimeLength ( Music music )                  ! Get music time length (in seconds)
FUNCTION-ALIAS: get-music-time-played float GetMusicTimePlayed ( Music music )                  ! Get current music time played (in seconds)

! AudioStream management functions
FUNCTION-ALIAS: load-audio-stream AudioStream LoadAudioStream ( uint sampleRate, uint sampleSize, uint channels ) ! Load audio stream (to stream raw audio pcm data)
FUNCTION-ALIAS: is-audio-stream-ready AudioStream IsAudioStreamReady ( AudioStream stream )                       ! Checks if an audio stream is ready
FUNCTION-ALIAS: unload-audio-stream void UnloadAudioStream ( AudioStream stream )                                 ! Unload audio stream and free memory
FUNCTION-ALIAS: update-audio-stream void UpdateAudioStream ( AudioStream stream, void* data, int frameCount )     ! Update audio stream buffers with data
FUNCTION-ALIAS: is-audio-stream-processed bool IsAudioStreamProcessed ( AudioStream stream )                      ! Check if any audio stream buffers requires refill
FUNCTION-ALIAS: play-audio-stream void PlayAudioStream ( AudioStream stream )                                     ! Play audio stream
FUNCTION-ALIAS: pause-audio-stream void PauseAudioStream ( AudioStream stream )                                   ! Pause audio stream
FUNCTION-ALIAS: resume-audio-stream void ResumeAudioStream ( AudioStream stream )                                 ! Resume audio stream
FUNCTION-ALIAS: is-audio-stream-playing bool IsAudioStreamPlaying ( AudioStream stream )                          ! Check if audio stream is playing
FUNCTION-ALIAS: stop-audio-stream void StopAudioStream ( AudioStream stream )                                     ! Stop audio stream
FUNCTION-ALIAS: set-audio-stream-volume void SetAudioStreamVolume ( AudioStream stream, float volume )            ! Set volume for audio stream (1.0 is max level)
FUNCTION-ALIAS: set-audio-stream-pitch void SetAudioStreamPitch ( AudioStream stream, float pitch )               ! Set pitch for audio stream (1.0 is base level)
FUNCTION-ALIAS: set-audio-stream-pan void SetAudioStreamPan ( AudioStream stream, float pan )                     ! Set pan for audio stream (0.5 is center)
FUNCTION-ALIAS: set-audio-stream-buffer-size-default void SetAudioStreamBufferSizeDefault ( int size )            ! Default size for new audio streams
FUNCTION-ALIAS: set-audio-stream-callback void SetAudioStreamCallback ( AudioStream stream, AudioCallback callback ) ! Audio thread callback to request new data

FUNCTION-ALIAS: attach-audio-stream-processor void AttachAudioStreamProcessor ( AudioStream stream, AudioCallback processor ) ! Attach audio stream processor to stream
FUNCTION-ALIAS: detach-audio-stream-processor void DetachAudioStreamProcessor ( AudioStream stream, AudioCallback processor ) ! Detach audio stream processor from stream

FUNCTION-ALIAS: attach-audio-mixed-processor void AttachAudioMixedProcessor ( AudioCallback processor ) ! Attach audio stream processor to the entire audio pipeline
FUNCTION-ALIAS: detach-audio-mixed-processor void DetachAudioMixedProcessor ( AudioCallback processor ) ! Detach audio stream processor from the entire audio pipeline

! Destructors
DESTRUCTOR: unload-audio-stream
DESTRUCTOR: unload-file-data
DESTRUCTOR: unload-file-text
DESTRUCTOR: unload-font
DESTRUCTOR: unload-image
DESTRUCTOR: unload-image-colors
DESTRUCTOR: unload-image-palette
DESTRUCTOR: unload-material
DESTRUCTOR: unload-mesh
DESTRUCTOR: unload-model
DESTRUCTOR: unload-model-animation
DESTRUCTOR: unload-music-stream
DESTRUCTOR: unload-render-texture
DESTRUCTOR: unload-shader
DESTRUCTOR: unload-sound
DESTRUCTOR: unload-texture
DESTRUCTOR: unload-wave
