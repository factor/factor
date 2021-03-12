! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
! These should be complete bindings to the Raylib library. (v2.5)
! Most of the comments are included from the original header
! for your convenience.
USING: accessors alien alien.c-types alien.enums alien.libraries
alien.syntax classes.struct combinators kernel quotations system
vocabs ;
IN: raylib.ffi
<<
"raylib" {
    { [ os windows? ] [ "raylib.dll" ] }
    { [ os macosx? ] [ "libraylib.dylib" ] }
    { [ os unix? ] [ "libraylib.so" ] }
} cond cdecl add-library 

"raylib" deploy-library
>>

LIBRARY: raylib

! Structs ----------------------------------------------------------------
STRUCT: Color
    { r uchar }
    { g uchar }
    { b uchar }
    { a uchar } ;

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
    { format int } ;                   ! Data format (PixelFormat type)

STRUCT: Texture2D
    { id uint }                        ! OpenGL Texture ID
    { width int }                      ! Texture Base Width
    { height int }                     ! Texture Base Height
    { mipmaps int }                    ! Mipmap Levels, 1 by default
    { format int } ;                   ! Data Format (PixelFormat type)
TYPEDEF: Texture2D Texture             ! Texture type same as Texture2D
TYPEDEF: Texture2D TextureCubemap      ! Actually same as Texture2D

STRUCT: RenderTexture2D
    { id uint }                        ! OpenGL Framebuffer Object (FBO) id
    { texture Texture2D }              ! Color buffer attachment texture
    { depth Texture2D } ;              ! Depth buffer attachment texture
 
TYPEDEF: RenderTexture2D RenderTexture ! Same as RenderTexture2D

STRUCT: NPatchInfo
    { sourceRec Rectangle }
    { left int }
    { top int }
    { right int }
    { bottom int }
    { type int } ;

STRUCT: CharInfo
    { value int }                      ! Character value (Unicode)
    { offsetX int }                    ! Character offset X when drawing
    { offsetY int }                    ! Character offset Y when drawing
    { advanceX int }                   ! Character advance position X
    { image Image } ;                  ! Character image data
    
STRUCT: Font
    { baseSize int }      ! Base Size (default chars height)
    { charsCount int }    ! Number of characters
    { texture Texture2D } ! Characters texture atlas
    { recs Rectangle* }   ! Characters rectangles in texture
    { chars CharInfo* } ; ! Characters info data
    
STRUCT: Camera3D
    { position Vector3 }  ! Camera postion
    { target Vector3 }    ! Camera target it looks-at
    { up Vector3 }        ! Camera up vector (rotation over its axis)
    { fovy float }        ! camera field-of-view apperature in Y (degrees) in perspective, used as near plane width in orthographic
    { type int } ;        ! Camera type, defines projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

STRUCT: Camera2D
    { offset Vector2 }    ! Camera offset (displacement from target)
    { target Vector2 }    ! Camera target (rotation and zoom origin)
    { rotation float }    ! Camera rotation in degrees
    { zoom float } ;      ! Camera zoom (scaling), should be 1.0f by default
TYPEDEF: Camera3D Camera  ! Default to 3D Camera

STRUCT: BoundingBox
    { min Vector3 }       ! Minimum vertex box-corner
    { max Vector3 } ;     ! Maximum vertex box-corner

STRUCT: Mesh
    { vertexCount int }   ! Number of verticles stored in arrays
    { triangleCount int } ! Number of triangles stored (indexed or not )
    { verticles float* }  ! Vertex position (XYZ - 3 components per vertex)
    { texcoords float* }  ! Vertex texture coordinates (UV - 2 components per vertex )
    { texcoords2 float* } ! Vertex second texture coordinates (useful for lightmaps)
    { normals float* }    ! Vertex normals (XYZ - 3 components per vertex)
    { tangents float* }   ! Vertex tangents (XYZW - 4 components per vertex )
    { colors uchar* }     ! Vertex colors (RGBA - 4 components per vertex)
    { indices ushort* }   ! Vertex indices (in case vertex data comes indexed)
    { animVerticles float* }
    { animNormals float* }
    { boneIds int* }
    { boneWeights float* }
    { vaoId uint }        ! OpenGL Vertex Array Object id
    { vboId uint* } ;     ! OpenGL Vertex Buffer Objects id (7  types of vertex data)


STRUCT: Shader
    { id uint }              ! Shader program id
    { locs int* } ;          ! Shader locations array
                             ! This is dependant on MAX_SHADER_LOCATIONS.  Default is 32

STRUCT: MaterialMap
    { texture Texture2D }    ! Material map Texture
    { color Color }          ! Material map color
    { value float } ;        ! Material map value

STRUCT: Material
    { shader Shader }        ! Material shader
    { maps MaterialMap* } ! Material maps.  Uses MAX_MATERIAL_MAPS.
    { params float* } ;      ! Material generic parameters (if required)

STRUCT: Transform
    { translation Vector3 }
    { rotation Quaternion }
    { scale Vector3 } ;

STRUCT: BoneInfo
    { name char[32] }        ! Bone Name
    { parent int } ;         ! Bone parent

! Matrix type (OpenGL style 4x4 - right handed, column major)
STRUCT: Matrix
    { m0 float } { m4 float } { m8 float } { m12 float }
    { m1 float } { m5 float } { m9 float } { m13 float }
    { m2 float } { m6 float } { m10 float } { m14 float }
    { m3 float } { m7 float } { m11 float } { m15 float } ;

STRUCT: Model
    { transform Matrix }
    { meshCount int }
    { materialCount int }
    { meshes Mesh* }
    { materials Material* }
    { meshMaterial int* }
    { boneCount int }
    { bones BoneInfo* }
    { bindPose Transform* } ;

STRUCT: ModelAnimation
    { boneCount int }
    { bones BoneInfo* }
    { frameCount int }
    { framePoses Transform** } ;

STRUCT: Ray
    { position Vector3 }    ! Ray position (origin)
    { direction Vector3 } ; ! Ray direction

STRUCT: RayHitInfo
    { hit bool }            ! Did the ray hit something?
    { distance float }      ! Distance to nearest hit
    { position Vector3 }    ! Position of nearest hit
    { normal Vector3 } ;    ! Surface normal of hit

STRUCT: Wave
    { sampleCount uint }    ! Number of samples
    { sampleRate uint }     ! Frequency (samples per second)
    { sampleSize uint }     ! Bit depth (bits per sample): 8,16,32
    { channels uint }       ! Number of channels (1-mono, 2-stereo)
    { data void* } ;        ! Buffer data pointer

STRUCT: AudioStream
    { buffer void* }    ! Pointer to internal data used by the audio system
    { sampleRate uint } ! Frequency (samples per second)
    { sampleSize uint } ! Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    { channels uint } ; ! Number of channels (1-mono, 2-stereo)

STRUCT: Sound
    { stream AudioStream } ! Audio stream
    { sampleCount uint } ; ! Total number of samples

STRUCT: Music
    { stream  AudioStream }     ! Audio stream
    { sampleCount uint }        ! Total number of samples
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

! Enumerations ---------------------------------------------------------

! Putting some of the #define's as enums.
ENUM: raylibConfigFlags
    {  FLAG_SHOW_LOGO              1   }   !  Set to show raylib logo at startup
    {  FLAG_FULLSCREEN_MODE        2   }   !  Set to run program in fullscreen
    {  FLAG_WINDOW_RESIZABLE       4   }   !  Set to allow resizable window
    {  FLAG_WINDOW_UNDECORATED     8   }   !  Set to disable window decoration (frame and buttons)
    {  FLAG_WINDOW_TRANSPARENT    16   }   !  Set to allow transparent window
    {  FLAG_WINDOW_HIDDEN        128   }
    {  FLAG_MSAA_4X_HINT          32   }   !  Set to try enabling MSAA 4X
    {  FLAG_VSYNC_HINT            64   } ; !  Set to try enabling V-Sync on GPU
    
ENUM: KeyboardFunctionKeys
    {  KEY_SPACE            32 } 
    {  KEY_ESCAPE          256 } 
    {  KEY_ENTER           257 } 
    {  KEY_TAB             258 } 
    {  KEY_BACKSPACE       259 } 
    {  KEY_INSERT          260 } 
    {  KEY_DELETE          261 } 
    {  KEY_RIGHT           262 } 
    {  KEY_LEFT            263 } 
    {  KEY_DOWN            264 } 
    {  KEY_UP              265 } 
    {  KEY_PAGE_UP         266 } 
    {  KEY_PAGE_DOWN       267 } 
    {  KEY_HOME            268 } 
    {  KEY_END             269 } 
    {  KEY_CAPS_LOCK       280 } 
    {  KEY_SCROLL_LOCK     281 } 
    {  KEY_NUM_LOCK        282 } 
    {  KEY_PRINT_SCREEN    283 } 
    {  KEY_PAUSE           284 } 
    {  KEY_F1              290 } 
    {  KEY_F2              291 } 
    {  KEY_F3              292 } 
    {  KEY_F4              293 } 
    {  KEY_F5              294 } 
    {  KEY_F6              295 } 
    {  KEY_F7              296 } 
    {  KEY_F8              297 } 
    {  KEY_F9              298 } 
    {  KEY_F10             299 } 
    {  KEY_F11             300 } 
    {  KEY_F12             301 } 
    {  KEY_LEFT_SHIFT      340 } 
    {  KEY_LEFT_CONTROL    341 } 
    {  KEY_LEFT_ALT        342 } 
    {  KEY_RIGHT_SHIFT     344 } 
    {  KEY_RIGHT_CONTROL   345 } 
    {  KEY_RIGHT_ALT       346 } 
    {  KEY_GRAVE            96 } 
    {  KEY_SLASH            47 } 
    {  KEY_BACKSLASH        92 } ;

ENUM: KeyboardAlphaNumericKeys  
    {  KEY_ZERO             48 } 
    {  KEY_ONE              49 } 
    {  KEY_TWO              50 } 
    {  KEY_THREE            51 } 
    {  KEY_FOUR             52 } 
    {  KEY_FIVE             53 } 
    {  KEY_SIX              54 } 
    {  KEY_SEVEN            55 } 
    {  KEY_EIGHT            56 } 
    {  KEY_NINE             57 } 
    {  KEY_A                65 } 
    {  KEY_B                66 } 
    {  KEY_C                67 } 
    {  KEY_D                68 } 
    {  KEY_E                69 } 
    {  KEY_F                70 } 
    {  KEY_G                71 } 
    {  KEY_H                72 } 
    {  KEY_I                73 } 
    {  KEY_J                74 } 
    {  KEY_K                75 } 
    {  KEY_L                76 } 
    {  KEY_M                77 } 
    {  KEY_N                78 } 
    {  KEY_O                79 } 
    {  KEY_P                80 } 
    {  KEY_Q                81 } 
    {  KEY_R                82 } 
    {  KEY_S                83 } 
    {  KEY_T                84 } 
    {  KEY_U                85 } 
    {  KEY_V                86 } 
    {  KEY_W                87 } 
    {  KEY_X                88 } 
    {  KEY_Y                89 } 
    {  KEY_Z                90 } ;

: LIGHTGRAY  ( -- Color ) 200  200  200  255 Color <struct-boa> ; !  Light Gray
: GRAY       ( -- Color ) 130  130  130  255 Color <struct-boa> ; !  Gray
: DARKGRAY   ( -- Color ) 80  80  80  255 Color <struct-boa>    ; !  Dark Gray
: YELLOW     ( -- Color ) 253  249  0  255 Color <struct-boa>   ; !  Yellow
: GOLD       ( -- Color ) 255  203  0  255 Color <struct-boa>   ; !  Gold
: ORANGE     ( -- Color ) 255  161  0  255 Color <struct-boa>   ; !  Orange
: PINK       ( -- Color ) 255  109  194  255 Color <struct-boa> ; !  Pink
: RED        ( -- Color ) 230  41  55  255 Color <struct-boa>   ; !  Red
: MAROON     ( -- Color ) 190  33  55  255 Color <struct-boa>   ; !  Maroon
: GREEN      ( -- Color ) 0  228  48  255 Color <struct-boa>    ; !  Green
: LIME       ( -- Color ) 0  158  47  255 Color <struct-boa>    ; !  Lime
: DARKGREEN  ( -- Color ) 0  117  44  255 Color <struct-boa>    ; !  Dark Green
: SKYBLUE    ( -- Color ) 102  191  255  255 Color <struct-boa> ; !  Sky Blue
: BLUE       ( -- Color ) 0  121  241  255 Color <struct-boa>   ; !  Blue
: DARKBLUE   ( -- Color ) 0  82  172  255 Color <struct-boa>    ; !  Dark Blue
: PURPLE     ( -- Color ) 200  122  255  255 Color <struct-boa> ; !  Purple
: VIOLET     ( -- Color ) 135  60  190  255 Color <struct-boa>  ; !  Violet
: DARKPURPLE ( -- Color ) 112  31  126  255 Color <struct-boa>  ; !  Dark Purple
: BEIGE      ( -- Color ) 211  176  131  255 Color <struct-boa> ; !  Beige
: BROWN      ( -- Color ) 127  106  79  255 Color <struct-boa>  ; !  Brown
: DARKBROWN  ( -- Color ) 76  63  47  255 Color <struct-boa>    ; !  Dark Brown

: WHITE      ( -- Color ) 255  255  255  255 Color <struct-boa> ; !  White
: BLACK      ( -- Color ) 0  0  0  255 Color <struct-boa>       ; !  Black
: BLANK      ( -- Color ) 0  0  0  0 Color <struct-boa>         ; !  Blank (Transparent)
: MAGENTA    ( -- Color ) 255  0  255  255 Color <struct-boa>   ; !  Magenta
: RAYWHITE   ( -- Color ) 245  245  245  255 Color <struct-boa> ; !  My own White (raylib logo)

! Leaving Android Enum out because Factor doesn't run on it
ENUM: MouseButtons
    MOUSE_LEFT_BUTTON
    MOUSE_RIGHT_BUTTON
    MOUSE_MIDDLE_BUTTON ;

ENUM: GamepadNumber
    GAMEPAD_PLAYER1
    GAMEPAD_PLAYER2
    GAMEPAD_PLAYER3
    GAMEPAD_PLAYER4 ;

! Trace log type
ENUM: LogType
    { LOG_INFO 1 }
    { LOG_WARNING 2 }
    { LOG_ERROR 4 }
    { LOG_DEBUG 8 }
    { LOG_OTHER 16 } ;

! Shader location point type
ENUM: ShaderLocationIndex
    LOC_VERTEX_POSITION
    LOC_VERTEX_TEXCOORD01
    LOC_VERTEX_TEXCOORD02
    LOC_VERTEX_NORMAL
    LOC_VERTEX_TANGENT
    LOC_VERTEX_COLOR
    LOC_MATRIX_MVP
    LOC_MATRIX_MODEL
    LOC_MATRIX_VIEW
    LOC_MATRIX_PROJECTION
    LOC_VECTOR_VIEW
    LOC_COLOR_DIFFUSE
    LOC_COLOR_SPECULAR
    LOC_COLOR_AMBIENT
    LOC_MAP_ALBEDO         
    LOC_MAP_METALNESS      
    LOC_MAP_NORMAL
    LOC_MAP_ROUGHNESS
    LOC_MAP_OCCLUSION
    LOC_MAP_EMISSION
    LOC_MAP_HEIGHT
    LOC_MAP_CUBEMAP
    LOC_MAP_IRRADIANCE
    LOC_MAP_PREFILTER
    LOC_MAP_BRDF ;

ENUM: ShaderUniformDataType
    UNIFORM_FLOAT
    UNIFORM_VEC2
    UNIFORM_VEC3
    UNIFORM_VEC4
    UNIFORM_INT
    UNIFORM_IVEC2
    UNIFORM_IVEC3
    UNIFORM_IVEC4
    UNIFORM_SAMPLER2D ;
    
! Material map type
ENUM: TexmapIndex
    MAP_ALBEDO    
    MAP_METALNESS 
    MAP_NORMAL    
    MAP_ROUGHNESS 
    MAP_OCCLUSION
    MAP_EMISSION
    MAP_HEIGHT
    MAP_CUBEMAP             
    MAP_IRRADIANCE          
    MAP_PREFILTER           
    MAP_BRDF ;

! Pixel formats
! NOTE: Support depends on OpenGL version and platform
ENUM: PixelFormat
    { UNCOMPRESSED_GRAYSCALE   1 }      ! 8 bit per pixel (no alpha)
    UNCOMPRESSED_GRAY_ALPHA        ! 8*2 bpp (2 channels)
    UNCOMPRESSED_R5G6B5            ! 16 bpp
    UNCOMPRESSED_R8G8B8            ! 24 bpp
    UNCOMPRESSED_R5G5B5A1          ! 16 bpp (1 bit alpha)
    UNCOMPRESSED_R4G4B4A4          ! 16 bpp (4 bit alpha)
    UNCOMPRESSED_R8G8B8A8          ! 32 bpp
    UNCOMPRESSED_R32               ! 32 bpp (1 channel - float)
    UNCOMPRESSED_R32G32B32         ! 32*3 bpp (3 channels - float)
    UNCOMPRESSED_R32G32B32A32      ! 32*4 bpp (4 channels - float)
    COMPRESSED_DXT1_RGB            ! 4 bpp (no alpha)
    COMPRESSED_DXT1_RGBA           ! 4 bpp (1 bit alpha)
    COMPRESSED_DXT3_RGBA           ! 8 bpp
    COMPRESSED_DXT5_RGBA           ! 8 bpp
    COMPRESSED_ETC1_RGB            ! 4 bpp
    COMPRESSED_ETC2_RGB            ! 4 bpp
    COMPRESSED_ETC2_EAC_RGBA       ! 8 bpp
    COMPRESSED_PVRT_RGB            ! 4 bpp
    COMPRESSED_PVRT_RGBA           ! 4 bpp
    COMPRESSED_ASTC_4x4_RGBA       ! 8 bpp
    COMPRESSED_ASTC_8x8_RGBA ;     ! 2 bpp

! Texture parameters: filter mode
! NOTE 1: Filtering considers mipmaps if available in the texture
! NOTE 2: Filter is accordingly set for minification and magnification
ENUM: TextureFilterMode
    FILTER_POINT                   ! No filter just pixel aproximation
    FILTER_BILINEAR                ! Linear filtering
    FILTER_TRILINEAR               ! Trilinear filtering (linear with mipmaps)
    FILTER_ANISOTROPIC_4X          ! Anisotropic filtering 4x
    FILTER_ANISOTROPIC_8X          ! Anisotropic filtering 8x
    FILTER_ANISOTROPIC_16X ;       ! Anisotropic filtering 16x

! Texture parameters: wrap mode
ENUM: TextureWrapMode
    WRAP_REPEAT
    WRAP_CLAMP
    WRAP_MIRROR_REPEAT
    WRAP_MIRROR_CLAMP ;

! Color blending modes (pre-defined)
ENUM: BlendMode
    BLEND_ALPHA
    BLEND_ADDITIVE
    BLEND_MULTIPLIED ;

! Gestures type
! NOTE: IT could be used as flags to enable only some gestures
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

! Camera projection modes
ENUM: CameraType
    CAMERA_PERSPECTIVE
    CAMERA_ORTHOGRAPHIC ;

ENUM: NPatchType
    NPT_9PATCH
    NPT_3PATCH_VERTICAL
    NPT_3PATCH_HORIZONTAL ;

! Head Mounted Display devices
ENUM: VrDeviceType
    HMD_DEFAULT_DEVICE
    HMD_OCULUS_RIFT_DK2
    HMD_OCULUS_RIFT_CV1
    HMD_OCULUS_GO
    HMD_VALVE_HTC_VIVE
    HMD_SONY_PSVR ;

! Functions ---------------------------------------------------------------

! Windowing Functions
FUNCTION-ALIAS:  init-window void InitWindow ( int width, int height, c-string title )    ! Initialize window and OpenGL context
FUNCTION-ALIAS:  close-window void CloseWindow ( )                                        ! Close window and unload OpenGL context
FUNCTION-ALIAS:  is-window-ready bool IsWindowReady ( )                                   ! Check if window has been initialized successfully
FUNCTION-ALIAS:  window-should-close bool WindowShouldClose ( )                           ! Check if KEY_ESCAPE pressed or Close icon pressed
FUNCTION-ALIAS:  is-window-minimized bool IsWindowMinimized ( )                           ! Check if window has been minimized  ( or lost focus )
FUNCTION-ALIAS:  is-window-resized bool IsWindowResized ( )                               ! Check if window has been resized
FUNCTION-ALIAS:  is-window-hidden bool IsWindowHidden ( )                                 ! Check if window is currently hidden
FUNCTION-ALIAS:  unhide-window void UnhideWindow ( )                                      ! Show the window
FUNCTION-ALIAS:  hide-window void HideWindow ( )                                          ! Hide the window
FUNCTION-ALIAS:  toggle-fullscreen void ToggleFullscreen ( )                              ! Toggle fullscreen mode  ( only PLATFORM_DESKTOP ) 
FUNCTION-ALIAS:  set-window-icon void SetWindowIcon ( Image image )                       ! Set icon for window  ( only PLATFORM_DESKTOP ) 
FUNCTION-ALIAS:  set-window-title void SetWindowTitle ( c-string title )                  ! Set title for window  ( only PLATFORM_DESKTOP ) 
FUNCTION-ALIAS:  set-window-position void SetWindowPosition ( int x, int y )              ! Set window position on screen  ( only PLATFORM_DESKTOP ) 
FUNCTION-ALIAS:  set-window-monitor void SetWindowMonitor ( int monitor )                 ! Set monitor for the current window  ( fullscreen mode ) 
FUNCTION-ALIAS:  set-window-min-size void SetWindowMinSize ( int width, int height )      ! Set window minimum dimensions  ( for FLAG_WINDOW_RESIZABLE ) 
FUNCTION-ALIAS:  set-window-size void SetWindowSize ( int width, int height )             ! Set window dimensions
FUNCTION-ALIAS:  get-screen-width int GetScreenWidth ( )                                  ! Get current screen width
FUNCTION-ALIAS:  get-screen-height int GetScreenHeight ( )                                ! Get current screen height
FUNCTION-ALIAS:  get-window-handle void* GetWindowHandle ( )                              ! Get native window handle
FUNCTION-ALIAS:  get-monitor-count int GetMonitorCount ( )                                ! Get number of connected monitors
FUNCTION-ALIAS:  get-monitor-width int GetMonitorWidth ( int monitor )                    ! Get primary monitor width
FUNCTION-ALIAS:  get-monitor-height int GetMonitorHeight ( int monitor )                  ! Get primary monitor height
FUNCTION-ALIAS:  get-monitor-physical-width int GetMonitorPhysicalWidth ( int monitor )   ! Get primary monitor physical width in millimetres
FUNCTION-ALIAS:  get-monitor-physical-height int GetMonitorPhysicalHeight ( int monitor ) ! Get primary monitor physical height in millimetres
FUNCTION-ALIAS:  get-monitor-name c-string GetMonitorName ( int monitor )                 ! Get the human-readable, UTF-8 encoded name of the primary monitor
FUNCTION-ALIAS:  get-clipboard-text c-string GetClipboardText ( )                         ! Get clipboard text content
FUNCTION-ALIAS:  set-clipboard-text void SetClipboardText ( c-string text )               ! Set clipboard text content

! 2.5 -> 3.5 Additions
FUNCTION-ALIAS:  get-window-scale-dpi Vector2 GetWindowScaleDPI ( )                     ! Get window scale DPI factor
FUNCTION-ALIAS:  is-window-maximized bool IsWindowMaximized ( )                    ! Check if window is currently maximized  ( only PLATFORM_DESKTOP)
FUNCTION-ALIAS:  is-window-focused bool IsWindowFocused ( )                        ! Check if window is currently focused  ( only PLATFORM_DESKTOP)
FUNCTION-ALIAS:  is-window-state bool IsWindowState ( uint flag )                       ! Check if one specific window flag is enabled
FUNCTION-ALIAS:  set-window-state void SetWindowState ( uint flags )                    ! Set window configuration state using flags
FUNCTION-ALIAS:  clear-window-state void ClearWindowState ( uint flags )                ! Clear window configuration state flags
FUNCTION-ALIAS:  maximized-window void MaximizeWindow ( )                          ! Set window state: maximized, if resizable  ( only PLATFORM_DESKTOP)
FUNCTION-ALIAS:  minimize-window void MinimizeWindow (  )                           ! Set window state: minimized, if resizable  ( only PLATFORM_DESKTOP)
FUNCTION-ALIAS:  restore-window void RestoreWindow ( )                             ! Set window state: not minimized/maximized  ( only PLATFORM_DESKTOP)
FUNCTION-ALIAS:  get-current-monitor int GetCurrentMonitor ( )                     ! Get current connected monitor
FUNCTION-ALIAS:  get-monitor-position Vector2 GetMonitorPosition ( int monitor )        ! Get specified monitor position
FUNCTION-ALIAS:  get-monitor-refresh-rate int GetMonitorRefreshRate ( int monitor )     ! Get specified monitor refresh rate
FUNCTION-ALIAS:  get-window-position Vector2 GetWindowPosition ( )                 ! Get window position XY on monitor


! Cursor-related functions
FUNCTION-ALIAS:  show-cursor void ShowCursor ( )                                                  ! Shows cursor
FUNCTION-ALIAS:  hide-cursor void HideCursor ( )                                                  ! Hides cursor
FUNCTION-ALIAS:  is-cursor-hidden bool IsCursorHidden ( )                                         ! Check if cursor is not visible
FUNCTION-ALIAS:  enable-cursor void EnableCursor ( )                                              ! Enables cursor  ( unlock cursor ) 
FUNCTION-ALIAS:  disable-cursor void DisableCursor ( )                                            ! Disables cursor  ( lock cursor ) 
FUNCTION-ALIAS:   is-cursor-on-screen  bool IsCursorOnScreen ( )                                   ! Check if cursor is on the current screen.

! Drawing-related functions
FUNCTION-ALIAS:  clear-background void ClearBackground ( Color color )                            ! Set background color  ( framebuffer clear color ) 
FUNCTION-ALIAS:  begin-drawing void BeginDrawing ( )                                              ! Setup canvas  ( framebuffer )  to start drawing
FUNCTION-ALIAS:  end-drawing void EndDrawing ( )                                                  ! End canvas drawing and swap buffers  ( double buffering ) 
FUNCTION-ALIAS:  begin-mode-2d void BeginMode2D ( Camera2D camera )                               ! Initialize 2D mode with custom camera  ( 2D ) 
FUNCTION-ALIAS:  end-mode-2d void EndMode2D ( )                                                   ! Ends 2D mode with custom camera
FUNCTION-ALIAS:  begin-mode-3d void BeginMode3D ( Camera3D camera )                               ! Initializes 3D mode with custom camera  ( 3D ) 
FUNCTION-ALIAS:  end-mode-3d void EndMode3D ( )                                                   ! Ends 3D mode and returns to default 2D orthographic mode
FUNCTION-ALIAS:  begin-texture-mode void BeginTextureMode ( RenderTexture2D target )              ! Initializes render texture for drawing
FUNCTION-ALIAS:  end-texture-mode void EndTextureMode ( )                                         ! Ends drawing to render texture
FUNCTION-ALIAS:  begin-scissor-mode void BeginScissorMode ( int x, int y, int width, int height ) ! Begin scissor mode  ( define screen area for following drawing)
FUNCTION-ALIAS:  end-scissor-mode void EndScissorMode ( )                                         ! End scissor mode

! Screen-space-related functions
FUNCTION-ALIAS:  get-mouse-ray Ray GetMouseRay ( Vector2 mousePosition, Camera camera )           ! Returns a ray trace from mouse position
FUNCTION-ALIAS:  get-world-to-screen Vector2 GetWorldToScreen ( Vector3 position, Camera camera ) ! Returns the screen space position for a 3d world space position
FUNCTION-ALIAS:  get-camera-matrix Matrix GetCameraMatrix ( Camera camera )                       ! Returns camera transform matrix  ( view matrix ) 

! Timing-related functions
FUNCTION-ALIAS:  set-target-fps void SetTargetFPS ( int fps )                                     ! Set target FPS  ( maximum ) 
FUNCTION-ALIAS:  get-fps int GetFPS ( )                                                           ! Returns current FPS
FUNCTION-ALIAS:  get-frame-time float GetFrameTime ( )                                            ! Returns time in seconds for last frame drawn
FUNCTION-ALIAS:  get-time double GetTime ( )                                                      ! Returns elapsed time in seconds since InitWindow () 

! Misc. functions
FUNCTION-ALIAS:  set-config-flags void SetConfigFlags ( uchar flags )                      ! Setup window configuration flags  (view FLAGS) 
FUNCTION-ALIAS:  set-trace-log-level void SetTraceLogLevel ( int logType )                 ! Set the current threshold  (minimum)  log level
FUNCTION-ALIAS:  set-trace-log-exit void SetTraceLogExit ( int logType )                   ! Set the exit threshold  (minimum)  log level
FUNCTION-ALIAS:  take-screenshot void TakeScreenshot ( c-string fileName )                 ! Takes a screenshot of current screen  ( saved a .png ) 
FUNCTION-ALIAS:  get-random-value int GetRandomValue ( int min, int max )                  ! Returns a random value between min and max  ( both included ) 

! Files management functions
FUNCTION-ALIAS:  load-file-data c-string LoadFileData ( c-string fileName, uint* bytesRead )                    ! Load file data as byte array  ( read)
FUNCTION-ALIAS:  unload-file-data void UnloadFileData ( c-string data )                                ! Unload file data allocated by LoadFileData ( )
FUNCTION-ALIAS:  save-file-data bool SaveFileData ( c-string fileName, void *data, uint bytesToWrite )  ! Save data to file from byte array  ( write), returns true on success
FUNCTION-ALIAS:  load-file-text c-string LoadFileText ( c-string fileName )                                     ! Load text data from file  ( read), returns a '\0' terminated string
FUNCTION-ALIAS:  unload-file-text void UnloadFileText ( c-string text )                                ! Unload file text data allocated by LoadFileText ( )
FUNCTION-ALIAS:  save-file-text bool SaveFileText ( c-string fileName, c-string text )                          ! Save text data to file  ( write), string must be '\0' terminated, returns true on success
FUNCTION-ALIAS:  file-exists bool FileExists ( c-string fileName )                                              ! Check if file exists
FUNCTION-ALIAS:  directory-exists bool DirectoryExists ( c-string dirPath )                                     ! Check if a directory path exists
FUNCTION-ALIAS:  is-file-extension bool IsFileExtension ( c-string fileName, c-string ext )                     ! Check file extension  ( including point: .png, .wav)
FUNCTION-ALIAS:  get-file-extension c-string GetFileExtension ( c-string fileName )                             ! Get pointer to extension for a filename string  ( including point: ".png")
FUNCTION-ALIAS:  get-file-name c-string GetFileName ( c-string filePath )                                       ! Get pointer to filename for a path string
FUNCTION-ALIAS:  get-file-name-without-ext c-string GetFileNameWithoutExt ( c-string filePath )                 ! Get filename string without extension  ( uses static string)
FUNCTION-ALIAS:  get-directory-path c-string GetDirectoryPath ( c-string filePath )                             ! Get full path for a given fileName with path  ( uses static string)
FUNCTION-ALIAS:  get-prev-directory-path c-string GetPrevDirectoryPath ( c-string dirPath )                     ! Get previous directory path for a given path  ( uses static string)
FUNCTION-ALIAS:  get-working-directory c-string GetWorkingDirectory ( )                                    ! Get current working directory  ( uses static string)
FUNCTION-ALIAS:  get-directory-files char** GetDirectoryFiles ( c-string dirPath, int *count )                  ! Get filenames in a directory path  ( memory should be freed)
FUNCTION-ALIAS:  clear-directory-files void ClearDirectoryFiles ( )                                        ! Clear directory files paths buffers  ( free memory)
FUNCTION-ALIAS:  change-directory bool ChangeDirectory ( c-string dir )                                         ! Change working directory, return true on success
FUNCTION-ALIAS:  is-file-dropped bool IsFileDropped ( )                                                    ! Check if a file has been dropped into window
FUNCTION-ALIAS:  get-dropped-files char** GetDroppedFiles ( int *count )                                        ! Get dropped files names  ( memory should be freed)
FUNCTION-ALIAS:  clear-dropped-files void ClearDroppedFiles ( )                                            ! Clear dropped files paths buffer  ( free memory)
FUNCTION-ALIAS:  get-file-mod-time long GetFileModTime ( c-string fileName )                                    ! Get file modification time  ( last write time)

! Persistent storage management
FUNCTION-ALIAS:  storage-save-value void StorageSaveValue ( int position, int value )             ! Save integer value to storage file  ( to defined position ) 
FUNCTION-ALIAS:  storage-load-value int StorageLoadValue ( int position )                         ! Load integer value from storage file  ( from defined position ) 
FUNCTION-ALIAS:  open-url void OpenURL ( c-string url )                                           ! Open URL with default system browser  ( if available ) 
! ------------------------------------------------------------------------------------
! Input Handling Functions  ( Module: core ) 
! ------------------------------------------------------------------------------------

! Input-related functions: keyboard
FUNCTION-ALIAS:  is-key-pressed bool IsKeyPressed ( int key )                                        ! Detect if a key has been pressed once
FUNCTION-ALIAS:  is-key-down bool IsKeyDown ( int key )                                              ! Detect if a key is being pressed
FUNCTION-ALIAS:  is-key-released bool IsKeyReleased ( int key )                                      ! Detect if a key has been released once
FUNCTION-ALIAS:  is-key-up bool IsKeyUp ( int key )                                                  ! Detect if a key is NOT being pressed
FUNCTION-ALIAS:  get-key-pressed int GetKeyPressed ( )                                               ! Get latest key pressed
FUNCTION-ALIAS:  set-exit-key void SetExitKey ( int key )                                            ! Set a custom key to exit program  ( default is ESC ) 

! Input-related functions: gamepads
FUNCTION-ALIAS:  is-gamepad-available bool IsGamepadAvailable ( int gamepad )                        ! Detect if a gamepad is available
FUNCTION-ALIAS:  is-gamepad-name bool IsGamepadName ( int gamepad, c-string name )                   ! Check gamepad name  ( if available ) 
FUNCTION-ALIAS:  get-gamepad-name c-string GetGamepadName ( int gamepad )                            ! Return gamepad internal name id
FUNCTION-ALIAS:  is-gamepad-button-pressed bool IsGamepadButtonPressed ( int gamepad, int button )   ! Detect if a gamepad button has been pressed once
FUNCTION-ALIAS:  is-gamepad-button-down bool IsGamepadButtonDown ( int gamepad, int button )         ! Detect if a gamepad button is being pressed
FUNCTION-ALIAS:  is-gamepad-button-released bool IsGamepadButtonReleased ( int gamepad, int button ) ! Detect if a gamepad button has been released once
FUNCTION-ALIAS:  is-gamepad-button-up bool IsGamepadButtonUp ( int gamepad, int button )             ! Detect if a gamepad button is NOT being pressed
FUNCTION-ALIAS:  get-gamepad-button-pressed int GetGamepadButtonPressed ( )                          ! Get the last gamepad button pressed
FUNCTION-ALIAS:  get-gamepad-axis-count int GetGamepadAxisCount ( int gamepad )                      ! Return gamepad axis count for a gamepad
FUNCTION-ALIAS:  get-gamepad-axis-movement float GetGamepadAxisMovement ( int gamepad, int axis )    ! Return axis movement value for a gamepad axis

! Input-related functions: mouse
FUNCTION-ALIAS:  is-mouse-button-pressed bool IsMouseButtonPressed ( int button )                    ! Detect if a mouse button has been pressed once
FUNCTION-ALIAS:  is-mouse-button-down bool IsMouseButtonDown ( int button )                          ! Detect if a mouse button is being pressed
FUNCTION-ALIAS:  is-mouse-button-released bool IsMouseButtonReleased ( int button )                  ! Detect if a mouse button has been released once
FUNCTION-ALIAS:  is-mouse-button-up bool IsMouseButtonUp ( int button )                              ! Detect if a mouse button is NOT being pressed
FUNCTION-ALIAS:  get-mouse-x int GetMouseX ( )                                                       ! Returns mouse position X
FUNCTION-ALIAS:  get-mouse-y int GetMouseY ( )                                                       ! Returns mouse position Y
FUNCTION-ALIAS:  get-mouse-position Vector2 GetMousePosition ( )                                     ! Returns mouse position XY
FUNCTION-ALIAS:  set-mouse-position void SetMousePosition ( int x, int y )                           ! Set mouse position XY
FUNCTION-ALIAS:  set-mouse-offset void SetMouseOffset ( int offsetX, int offsetY )                   ! Set mouse offset
FUNCTION-ALIAS:  set-mouse-scale void SetMouseScale ( float scale )                                  ! Set mouse scaling
FUNCTION-ALIAS:  get-mouse-wheel-move int GetMouseWheelMove ( )                                      ! Returns mouse wheel movement Y

! Input-related functions: touch
FUNCTION-ALIAS:  get-touch-x int GetTouchX ( )                                                       ! Returns touch position X for touch point 0  ( relative to screen size ) 
FUNCTION-ALIAS:  get-touch-y int GetTouchY ( )                                                       ! Returns touch position Y for touch point 0  ( relative to screen size ) 
FUNCTION-ALIAS:  get-touch-position Vector2 GetTouchPosition ( int index )                           ! Returns touch position XY for a touch point index  ( relative to screen size ) 

! ------------------------------------------------------------------------------------
! Gestures and Touch Handling Functions  ( Module: gestures ) 
! ------------------------------------------------------------------------------------
FUNCTION-ALIAS:  set-gestures-enabled void SetGesturesEnabled ( uint gestureFlags ) ! Enable a set of gestures using flags
FUNCTION-ALIAS:  is-gesture-detected bool IsGestureDetected ( int gesture )         ! Check if a gesture have been detected
FUNCTION-ALIAS:  get-gesture-detected int GetGestureDetected ( )                    ! Get latest detected gesture
FUNCTION-ALIAS:  get-touch-points-count int GetTouchPointsCount ( )                 ! Get touch points count
FUNCTION-ALIAS:  get-gesture-hold-duration float GetGestureHoldDuration ( )         ! Get gesture hold time in milliseconds
FUNCTION-ALIAS:  get-gesture-drag-vector Vector2 GetGestureDragVector ( )           ! Get gesture drag vector
FUNCTION-ALIAS:  get-gesture-drag-angle float GetGestureDragAngle ( )               ! Get gesture drag angle
FUNCTION-ALIAS:  get-gesture-pinch-vector Vector2 GetGesturePinchVector ( )         ! Get gesture pinch delta
FUNCTION-ALIAS:  get-gesture-pinch-angle float GetGesturePinchAngle ( )             ! Get gesture pinch angle

! ------------------------------------------------------------------------------------ 
! Camera System Functions  ( Module: camera ) 
! ------------------------------------------------------------------------------------
FUNCTION-ALIAS:  set-camera-mode void SetCameraMode ( Camera camera, int mode )                                                                       ! Set camera mode  ( multiple camera modes available ) 
FUNCTION-ALIAS:  update-camera void UpdateCamera ( Camera* camera )                                                                                   ! Update camera position for selected mode
FUNCTION-ALIAS:  set-camera-pan-control void SetCameraPanControl ( int panKey )                                                                       ! Set camera pan key to combine with mouse movement  ( free camera ) 
FUNCTION-ALIAS:  set-camera-alt-control void SetCameraAltControl ( int altKey )                                                                       ! Set camera alt key to combine with mouse movement  ( free camera ) 
FUNCTION-ALIAS:  set-camera-smooth-zoom-control void SetCameraSmoothZoomControl ( int szKey )                                                         ! Set camera smooth zoom key to combine with mouse  ( free camera ) 
FUNCTION-ALIAS:  set-camera-move-controls void SetCameraMoveControls ( int frontKey, int backKey, int rightKey, int leftKey, int upKey, int downKey ) ! Set camera move controls  ( 1st person and 3rd person cameras ) 

! ------------------------------------------------------------------------------------
! Basic Shapes Drawing Functions  ( Module: shapes ) 
! ------------------------------------------------------------------------------------

                                                                                                                                                                      ! Basic shapes drawing functions
FUNCTION-ALIAS:  draw-pixel void DrawPixel ( int posX, int posY, Color color )                                                                                        ! Draw a pixel
FUNCTION-ALIAS:  draw-pixel-lv void DrawPixelV ( Vector2 position, Color color )                                                                                      ! Draw a pixel  ( Vector version ) 
FUNCTION-ALIAS:  draw-line void DrawLine ( int startPosX, int startPosY, int endPosX, int endPosY, Color color )                                                      ! Draw a line
FUNCTION-ALIAS:  draw-line-v void DrawLineV ( Vector2 startPos, Vector2 endPos, Color color )                                                                         ! Draw a line  ( Vector version ) 
FUNCTION-ALIAS:  draw-line-ex void DrawLineEx ( Vector2 startPos, Vector2 endPos, float thick, Color color )                                                          ! Draw a line defining thickness
FUNCTION-ALIAS:  draw-line-bezier void DrawLineBezier ( Vector2 startPos, Vector2 endPos, float thick, Color color )                                                  ! Draw a line using cubic-bezier curves in-out
FUNCTION-ALIAS:  draw-circle void DrawCircle ( int centerX, int centerY, float radius, Color color )                                                                  ! Draw a color-filled circle
FUNCTION-ALIAS:  draw-circle-sector void DrawCircleSector ( Vector2 center, float radius, int startAngle, int endAngle, int segments, Color color )                   ! Draw a piece of a circle
FUNCTION-ALIAS:  draw-circle-sector-lines void DrawCircleSectorLines ( Vector2 center, float radius, int startAngle, int endAngle, int segments, Color color )        ! Draw circle sector outline
FUNCTION-ALIAS:  draw-circle-gradient void DrawCircleGradient ( int centerX, int centerY, float radius, Color color1, Color color2 )                                  ! Draw a gradient-filled circle
FUNCTION-ALIAS:  draw-circle-v void DrawCircleV ( Vector2 center, float radius, Color color )                                                                         ! Draw a color-filled circle  ( Vector version ) 
FUNCTION-ALIAS:  draw-circle-lines void DrawCircleLines ( int centerX, int centerY, float radius, Color color )                                                       ! Draw circle outline
FUNCTION-ALIAS:  draw-ring void DrawRing ( Vector2 center, float innerRadius, float outerRadius, int startAngle, int endAngle, int segments, Color color )            ! Draw ring
FUNCTION-ALIAS:  draw-ring-lines void DrawRingLines ( Vector2 center, float innerRadius, float outerRadius, int startAngle, int endAngle, int segments, Color color ) ! Draw ring outline
FUNCTION-ALIAS:  draw-rectangle void DrawRectangle ( int posX, int posY, int width, int height, Color color )                                                         ! Draw a color-filled rectangle
FUNCTION-ALIAS:  draw-rectangle-v void DrawRectangleV ( Vector2 position, Vector2 size, Color color )                                                                 ! Draw a color-filled rectangle  ( Vector version ) 
FUNCTION-ALIAS:  draw-rectangle-rec void DrawRectangleRec ( Rectangle rec, Color color )                                                                              ! Draw a color-filled rectangle
FUNCTION-ALIAS:  draw-rectangle-pro void DrawRectanglePro ( Rectangle rec, Vector2 origin, float rotation, Color color )                                              ! Draw a color-filled rectangle with pro parameters
FUNCTION-ALIAS:  draw-rectangle-gradient-v void DrawRectangleGradientV ( int posX, int posY, int width, int height, Color color1, Color color2 )                      ! Draw a vertical-gradient-filled rectangle
FUNCTION-ALIAS:  draw-rectangle-graident-h void DrawRectangleGradientH ( int posX, int posY, int width, int height, Color color1, Color color2 )                      ! Draw a horizontal-gradient-filled rectangle
FUNCTION-ALIAS:  draw-rectangle-gradient-ex void DrawRectangleGradientEx ( Rectangle rec, Color col1, Color col2, Color col3, Color col4 )                            ! Draw a gradient-filled rectangle with custom vertex colors
FUNCTION-ALIAS:  draw-rectangle-lines void DrawRectangleLines ( int posX, int posY, int width, int height, Color color )                                              ! Draw rectangle outline
FUNCTION-ALIAS:  draw-rectangle-lines-ex void DrawRectangleLinesEx ( Rectangle rec, int lineThick, Color color )                                                      ! Draw rectangle outline with extended parameters
FUNCTION-ALIAS:  draw-rectangle-rounded void DrawRectangleRounded ( Rectangle rec, float roundness, int segments, Color color )                                       ! Draw rectangle with rounded edges
FUNCTION-ALIAS:  draw-rectangle-rounded-lines void DrawRectangleRoundedLines ( Rectangle rec, float roundness, int segments, int lineThick, Color color )             ! Draw rectangle with rounded edges outline
FUNCTION-ALIAS:  draw-triangle void DrawTriangle ( Vector2 v1, Vector2 v2, Vector2 v3, Color color )                                                                  ! Draw a color-filled triangle
FUNCTION-ALIAS:  draw-triangle-lines void DrawTriangleLines ( Vector2 v1, Vector2 v2, Vector2 v3, Color color )                                                       ! Draw triangle outline
FUNCTION-ALIAS:  draw-poly void DrawPoly ( Vector2 center, int sides, float radius, float rotation, Color color )                                                     ! Draw a regular polygon  ( Vector version ) 
FUNCTION-ALIAS:  draw-poly-ex void DrawPolyEx ( Vector2* points, int numPoints, Color color )                                                                         ! Draw a closed polygon defined by points
FUNCTION-ALIAS:  draw-poly-ex-lines void DrawPolyExLines ( Vector2* points, int numPoints, Color color )                                                              ! Draw polygon lines
FUNCTION-ALIAS:  set-shapes-texture void SetShapesTexture ( Texture2D texture, Rectangle source )                                                                     ! Define default texture used to draw shapes

! Basic shapes collision detection functions
FUNCTION-ALIAS:  check-collision-recs bool CheckCollisionRecs ( Rectangle rec1, Rectangle rec2 )                                       ! Check collision between two rectangles
FUNCTION-ALIAS:  check-collision-circles bool CheckCollisionCircles ( Vector2 center1, float radius1, Vector2 center2, float radius2 ) ! Check collision between two circles
FUNCTION-ALIAS:  check-collision-circle-rec bool CheckCollisionCircleRec ( Vector2 center, float radius, Rectangle rec )               ! Check collision between circle and rectangle
FUNCTION-ALIAS:  get-collision-rec Rectangle GetCollisionRec ( Rectangle rec1, Rectangle rec2 )                                        ! Get collision rectangle for two rectangles collision
FUNCTION-ALIAS:  check-collision-point-rec bool CheckCollisionPointRec ( Vector2 point, Rectangle rec )                                ! Check if point is inside rectangle
FUNCTION-ALIAS:  check-collision-point-circle bool CheckCollisionPointCircle ( Vector2 point, Vector2 center, float radius )           ! Check if point is inside circle
FUNCTION-ALIAS:  check-collision-point-triangle bool CheckCollisionPointTriangle ( Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3 ) ! Check if point is inside a triangle

! ------------------------------------------------------------------------------------
! Texture Loading and Drawing Functions  ( Module: textures ) 
! ------------------------------------------------------------------------------------

! Image/Texture2D data loading/unloading/saving functions
FUNCTION-ALIAS:  load-image Image LoadImage ( c-string fileName )                                                           ! Load image from file into CPU memory  ( RAM ) 
FUNCTION-ALIAS:  load-image-raw Image LoadImageRaw ( c-string fileName, int width, int height, int format, int headerSize ) ! Load image from RAW file data
FUNCTION-ALIAS:  export-image void ExportImage ( c-string fileName, Image image )                                           ! Export image as a PNG file
FUNCTION-ALIAS:  export-image-as-code void ExportImageAsCode ( Image image, c-string fileName )                             ! Export image as code file defining an array of bytes
FUNCTION-ALIAS:  load-texture Texture2D LoadTexture ( c-string fileName )                                                   ! Load texture from file into GPU memory  ( VRAM ) 
FUNCTION-ALIAS:  load-texture-from-image Texture2D LoadTextureFromImage ( Image image )                                     ! Load texture from image data
FUNCTION-ALIAS:  load-render-texture RenderTexture2D LoadRenderTexture ( int width, int height )                            ! Load texture for rendering  ( framebuffer ) 
FUNCTION-ALIAS:  unload-image void UnloadImage ( Image image )                                                              ! Unload image from CPU memory  ( RAM ) 
FUNCTION-ALIAS:  unload-texture void UnloadTexture ( Texture2D texture )                                                    ! Unload texture from GPU memory  ( VRAM ) 
FUNCTION-ALIAS:  unload-render-texture void UnloadRenderTexture ( RenderTexture2D target )                                  ! Unload render texture from GPU memory  ( VRAM ) 
FUNCTION-ALIAS:  get-image-data Color* GetImageData ( Image image )                                                         ! Get pixel data from image as a Color struct array
FUNCTION-ALIAS:  get-image-data-normalized Vector4* GetImageDataNormalized ( Image image )                                  ! Get pixel data from image as Vector4 array  ( float normalized ) 
FUNCTION-ALIAS:  get-pixel-datasize int GetPixelDataSize ( int width, int height, int format )                              ! Get pixel data size in bytes  ( image or texture ) 
FUNCTION-ALIAS:  get-texture-data Image GetTextureData ( Texture2D texture )                                                ! Get pixel data from GPU texture and return an Image
FUNCTION-ALIAS:  get-screen-data Image GetScreenData ( )                                                                    ! Get pixel data from screen buffer and return an Image  ( screenshot ) 
FUNCTION-ALIAS:  update-texture void UpdateTexture ( Texture2D texture, void* pixels )                                      ! Update GPU texture with new data
! FIX: Const Void *

! Image manipulation functions
FUNCTION-ALIAS:  image-copy Image ImageCopy ( Image image )                                                                                                     ! Create an image duplicate  ( useful for transformations ) 
FUNCTION-ALIAS:  image-to-pot void ImageToPOT ( Image* image, Color fillColor )                                                                                 ! Convert image to POT  ( power-of-two ) 
FUNCTION-ALIAS:  image-format void ImageFormat ( Image* image, int newFormat )                                                                                  ! Convert image data to desired format
FUNCTION-ALIAS:  image-alpha-mask void ImageAlphaMask ( Image* image, Image alphaMask )                                                                         ! Apply alpha mask to image
FUNCTION-ALIAS:  image-alpha-clear void ImageAlphaClear ( Image* image, Color color, float threshold )                                                          ! Clear alpha channel to desired color
FUNCTION-ALIAS:  image-alpha-crop void ImageAlphaCrop ( Image* image, float threshold )                                                                         ! Crop image depending on alpha value
FUNCTION-ALIAS:  image-alpha-premultiply void ImageAlphaPremultiply ( Image* image )                                                                            ! Premultiply alpha channel
FUNCTION-ALIAS:  image-crop void ImageCrop ( Image* image, Rectangle crop )                                                                                     ! Crop an image to a defined rectangle
FUNCTION-ALIAS:  image-resize void ImageResize ( Image* image, int newWidth, int newHeight )                                                                    ! Resize image  ( bilinear filtering ) 
FUNCTION-ALIAS:  image-resize-nn void ImageResizeNN ( Image* image, int newWidth, int newHeight )                                                                ! Resize image  ( Nearest-Neighbor scaling algorithm ) 
FUNCTION-ALIAS:  image-resize-canvas void ImageResizeCanvas ( Image* image, int newWidth, int newHeight, int offsetX, int offsetY, Color color )                ! Resize canvas and fill with color
FUNCTION-ALIAS:  image-mipmaps void ImageMipmaps ( Image* image )                                                                                               ! Generate all mipmap levels for a provided image
FUNCTION-ALIAS:  image-dither void ImageDither ( Image* image, int rBpp, int gBpp, int bBpp, int aBpp )                                                         ! Dither image data to 16bpp or lower  ( Floyd-Steinberg dithering ) 
FUNCTION-ALIAS:  image-text Image ImageText ( c-string text, int fontSize, Color color )                                                                        ! Create an image from text  ( default font ) 
FUNCTION-ALIAS:  image-text-ex Image ImageTextEx ( Font font, c-string text, float fontSize, float spacing, Color tint )                                        ! Create an image from text  ( custom sprite font ) 
FUNCTION-ALIAS:  image-draw-rectangle void ImageDrawRectangle ( Image* dst, Vector2 position, Rectangle rec, Color color )                                      ! Draw rectangle within an image
FUNCTION-ALIAS:  image-draw-rectangle-lines void ImageDrawRectangleLines ( Image *dst, Rectangle rec, int thick, Color color )                                  ! Draw rectangle lines within an image
FUNCTION-ALIAS:  image-flip-vertical void ImageFlipVertical ( Image* image )                                                                                    ! Flip image vertically
FUNCTION-ALIAS:  image-flip-horizontal void ImageFlipHorizontal ( Image* image )                                                                                ! Flip image horizontally
FUNCTION-ALIAS:  image-rotate-cw void ImageRotateCW ( Image* image )                                                                                            ! Rotate image clockwise 90deg
FUNCTION-ALIAS:  image-rotate-ccw void ImageRotateCCW ( Image* image )                                                                                          ! Rotate image counter-clockwise 90deg
FUNCTION-ALIAS:  image-color-tint void ImageColorTint ( Image* image, Color color )                                                                             ! Modify image color: tint
FUNCTION-ALIAS:  image-color-invert void ImageColorInvert ( Image* image )                                                                                      ! Modify image color: invert
FUNCTION-ALIAS:  image-color-grayscale void ImageColorGrayscale ( Image* image )                                                                                ! Modify image color: grayscale
FUNCTION-ALIAS:  image-color-contrast void ImageColorContrast ( Image* image, float contrast )                                                                  ! Modify image color: contrast  ( -100 to 100 ) 
FUNCTION-ALIAS:  image-color-brightness void ImageColorBrightness ( Image* image, int brightness )                                                              ! Modify image color: brightness  ( -255 to 255 ) 
FUNCTION-ALIAS:  image-color-replace void ImageColorReplace ( Image* image, Color color, Color replace )                                                        ! Modify image color: replace color

! Image generation functions
FUNCTION-ALIAS:  gen-image-color Image GenImageColor ( int width, int height, Color color )                                                ! Generate image: plain color
FUNCTION-ALIAS:  gen-image-gradient-v Image GenImageGradientV ( int width, int height, Color top, Color bottom )                           ! Generate image: vertical gradient
FUNCTION-ALIAS:  get-image-gradient-h Image GenImageGradientH ( int width, int height, Color left, Color right )                           ! Generate image: horizontal gradient
FUNCTION-ALIAS:  gen-image-gradient-radial Image GenImageGradientRadial ( int width, int height, float density, Color inner, Color outer ) ! Generate image: radial gradient
FUNCTION-ALIAS:  get-image-checked Image GenImageChecked ( int width, int height, int checksX, int checksY, Color col1, Color col2 )       ! Generate image: checked
FUNCTION-ALIAS:  get-image-white-noise Image GenImageWhiteNoise ( int width, int height, float factor )                                    ! Generate image: white noise
FUNCTION-ALIAS:  get-image-perlin-noise Image GenImagePerlinNoise ( int width, int height, int offsetX, int offsetY, float scale )         ! Generate image: perlin noise
FUNCTION-ALIAS:  get-image-cellular Image GenImageCellular ( int width, int height, int tileSize )                                         ! Generate image: cellular algorithm. Bigger tileSize means bigger cells

! Texture2D configuration functions
FUNCTION-ALIAS:  gen-texture-mipmaps void GenTextureMipmaps ( Texture2D* texture )              ! Generate GPU mipmaps for a texture
FUNCTION-ALIAS:  set-texture-filter void SetTextureFilter ( Texture2D texture, int filterMode ) ! Set texture scaling filter mode
FUNCTION-ALIAS:  set-texture-wrap void SetTextureWrap ( Texture2D texture, int wrapMode )       ! Set texture wrapping mode

! Texture2D drawing functions
FUNCTION-ALIAS:  draw-texture void DrawTexture ( Texture2D texture, int posX, int posY, Color tint )                                                            ! Draw a Texture2D
FUNCTION-ALIAS:  draw-texture-v void DrawTextureV ( Texture2D texture, Vector2 position, Color tint )                                                           ! Draw a Texture2D with position defined as Vector2
FUNCTION-ALIAS:  draw-texture-ex void DrawTextureEx ( Texture2D texture, Vector2 position, float rotation, float scale, Color tint )                            ! Draw a Texture2D with extended parameters
FUNCTION-ALIAS:  draw-texture-rec void DrawTextureRec ( Texture2D texture, Rectangle sourceRec, Vector2 position, Color tint )                                  ! Draw a part of a texture defined by a rectangle
FUNCTION-ALIAS:  draw-texture-quad void DrawTextureQuad ( Texture2D texture, Vector2 tiling, Vector2 offset, Rectangle quad, Color tint )                       ! Draw texture quad with tiling and offset parameters
FUNCTION-ALIAS:  draw-texture-pro void DrawTexturePro ( Texture2D texture, Rectangle sourceRec, Rectangle destRec, Vector2 origin, float rotation, Color tint ) ! Draw a part of a texture defined by a rectangle with 'pro' parameters
FUNCTION-ALIAS:  draw-texture-n-patch void DrawTextureNPatch ( Texture2D texture, NPatchInfo nPatchInfo, Rectangle destRec, Vector2 origin, float rotation, Color tint )   ! Draws a texture  ( or part of it )  that stretches or shrinks nicely
! ------------------------------------------------------------------------------------
! Font Loading and Text Drawing Functions  ( Module: text ) 
! ------------------------------------------------------------------------------------

! Font loading/unloading functions
FUNCTION-ALIAS:  get-font-default Font GetFontDefault ( )                                                                                    ! Get the default Font
FUNCTION-ALIAS:  load-font Font LoadFont ( c-string fileName )                                                                               ! Load font from file into GPU memory  ( VRAM ) 
FUNCTION-ALIAS:  load-font-ex Font LoadFontEx ( c-string fileName, int fontSize, int charsCount, int* fontChars )                            ! Load font from file with extended parameters
FUNCTION-ALIAS:  load-font-data CharInfo* LoadFontData ( c-string fileName, int fontSize, int* fontChars, int charsCount, bool sdf )         ! Load font data for further use
FUNCTION-ALIAS:  gen-image-font-atlas Image GenImageFontAtlas ( CharInfo* chars, int fontSize, int charsCount, int padding, int packMethod ) ! Generate image font atlas using chars info
FUNCTION-ALIAS:  unload-font void UnloadFont ( Font font )                                                                                   ! Unload Font from GPU memory  ( VRAM ) 

! Text drawing functions
FUNCTION-ALIAS:  draw-fps void DrawFPS ( int posX, int posY )                                                                                         ! Shows current FPS
FUNCTION-ALIAS:  draw-text void DrawText ( c-string text, int posX, int posY, int fontSize, Color color )                                             ! Draw text  ( using default font ) 
FUNCTION-ALIAS:  draw-text-ex void DrawTextEx ( Font font, c-string text, Vector2 position, float fontSize, float spacing, Color tint )               ! Draw text using font and additional parameters
FUNCTION-ALIAS:  draw-text-rec void DrawTextRec ( Font font, c-string text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint ) ! Draw text using font inside rectangle limits
FUNCTION-ALIAS:  draw-text-rec-ex void DrawTextRecEx ( Font font, c-string text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectText, Color selectBack )                                                               ! Draw text using font inside rectangle limits with support for text selection

! Text misc. functions
FUNCTION-ALIAS:  measure-text int MeasureText ( c-string text, int fontSize )                                      ! Measure string width for default font
FUNCTION-ALIAS:  measure-text-ex Vector2 MeasureTextEx ( Font font, c-string text, float fontSize, float spacing ) ! Measure string size for Font
FUNCTION-ALIAS:  get-glyph-index int GetGlyphIndex ( Font font, int character )                                    ! Get index position for a unicode character on font

! Text strings management functions
! Some of these aren't included because Factor should be able to handle most of this
FUNCTION-ALIAS:  text-is-equal bool TextIsEqual ( c-string text1, c-string text2 )                  ! Check if two text string are equal
FUNCTION-ALIAS:  text-length uint TextLength ( c-string text )                                      ! Get text length, checks for '\0' ending
FUNCTION-ALIAS:  text-subtext c-string TextSubtext ( c-string text, int position, int length )      ! Get a piece of a text string
FUNCTION-ALIAS:  text-replace c-string TextReplace ( c-string text, c-string replace, c-string by ) ! Replace text string
FUNCTION-ALIAS:  text-insert c-string TextInsert ( c-string text, c-string insert, int position )   ! Insert text in a position 
FUNCTION-ALIAS:  text-split c-string* TextSplit ( c-string text, char delimiter, int* count )       ! Split text into multiple strings
FUNCTION-ALIAS:  text-append void TextAppend ( c-string text, c-string append, int* position )      ! Append text at specific position and move cursor!
FUNCTION-ALIAS:  text-find-index int TextFindIndex ( c-string text, c-string find )                 ! Find first text occurrence within a string
FUNCTION-ALIAS:  text-to-upper c-string TextToUpper ( c-string text )                               ! Get upper case version of provided string
FUNCTION-ALIAS:  text-to-lower c-string TextToLower ( c-string text )                               ! Get lower case version of provided string
FUNCTION-ALIAS:  text-to-pascal c-string TextToPascal ( c-string text )                             ! Get Pascal case notation version of provided string
FUNCTION-ALIAS:  text-to-integer int TextToInteger ( c-string text )                                ! Get integer value from text  ( negative values not supported ) 
! ------------------------------------------------------------------------------------
! Basic 3d Shapes Drawing Functions  ( Module: models ) 
! ------------------------------------------------------------------------------------

! Basic geometric 3D shapes drawing functions
FUNCTION-ALIAS:  draw-line-3d void DrawLine3D ( Vector3 startPos, Vector3 endPos, Color color )                                                              ! Draw a line in 3D world space
FUNCTION-ALIAS:  draw-circle-3d void DrawCircle3D ( Vector3 center, float radius, Vector3 rotationAxis, float rotationAngle, Color color )                   ! Draw a circle in 3D world space
FUNCTION-ALIAS:  draw-cube void DrawCube ( Vector3 position, float width, float height, float length, Color color )                                          ! Draw cube
FUNCTION-ALIAS:  draw-cube-v void DrawCubeV ( Vector3 position, Vector3 size, Color color )                                                                  ! Draw cube  ( Vector version ) 
FUNCTION-ALIAS:  draw-cube-wires void DrawCubeWires ( Vector3 position, float width, float height, float length, Color color )                               ! Draw cube wires
FUNCTION-ALIAS:  draw-cube-wires-v void DrawCubeWiresV ( Vector3 position, Vector3 size, Color color )                                                         ! Draw cube wires  ( Vector version ) 
FUNCTION-ALIAS:  draw-cube-texture void DrawCubeTexture ( Texture2D texture, Vector3 position, float width, float height, float length, Color color )        ! Draw cube textured
FUNCTION-ALIAS:  draw-sphere void DrawSphere ( Vector3 centerPos, float radius, Color color )                                                                ! Draw sphere
FUNCTION-ALIAS:  draw-sphere-ex void DrawSphereEx ( Vector3 centerPos, float radius, int rings, int slices, Color color )                                    ! Draw sphere with extended parameters
FUNCTION-ALIAS:  draw-sphere-wires void DrawSphereWires ( Vector3 centerPos, float radius, int rings, int slices, Color color )                              ! Draw sphere wires
FUNCTION-ALIAS:  draw-cylinder void DrawCylinder ( Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color )            ! Draw a cylinder/cone
FUNCTION-ALIAS:  draw-cylinder-wires void DrawCylinderWires ( Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color ) ! Draw a cylinder/cone wires
FUNCTION-ALIAS:  draw-plane void DrawPlane ( Vector3 centerPos, Vector2 size, Color color )                                                                  ! Draw a plane XZ
FUNCTION-ALIAS:  draw-ray void DrawRay ( Ray ray, Color color )                                                                                              ! Draw a ray line
FUNCTION-ALIAS:  draw-grid void DrawGrid ( int slices, float spacing )                                                                                       ! Draw a grid  ( centered at  ( 0, 0, 0 )  ) 
FUNCTION-ALIAS:  draw-gizmo void DrawGizmo ( Vector3 position )                                                                                              ! Draw simple gizmo


! ------------------------------------------------------------------------------------
! Model 3d Loading and Drawing Functions  ( Module: models ) 
! ------------------------------------------------------------------------------------

! Model loading/unloading functions
FUNCTION-ALIAS:  load-model Model LoadModel ( c-string fileName )           ! Load model from files  ( mesh and material ) 
FUNCTION-ALIAS:  load-model-from-mesh Model LoadModelFromMesh ( Mesh mesh ) ! Load model from generated mesh
FUNCTION-ALIAS:  unload-model void UnloadModel ( Model model )              ! Unload model from memory  ( RAM and/or VRAM ) 

! Mesh loading/unloading functions
FUNCTION-ALIAS:  load-mesh Mesh* LoadMeshes ( c-string fileName, int* meshCount  )                ! Load meshes from model file
FUNCTION-ALIAS:  unload-mesh void UnloadMesh ( Mesh* mesh )                                       ! Unload mesh from memory  ( RAM and/or VRAM ) 
FUNCTION-ALIAS:  export-mesh void ExportMesh ( c-string fileName, Mesh mesh )                     ! Export mesh as an OBJ file

! Mesh manipulation functions
FUNCTION-ALIAS:  mesh-bounding-box BoundingBox MeshBoundingBox ( Mesh mesh ) ! Compute mesh bounding box limits
FUNCTION-ALIAS:  mesh-tangents void MeshTangents ( Mesh* mesh )              ! Compute mesh tangents
FUNCTION-ALIAS:  mesh-binormals void MeshBinormals ( Mesh* mesh )            ! Compute mesh binormals

! Mesh generation functions
FUNCTION-ALIAS:  gen-mesh-poly Mesh GenMeshPoly ( int sides, float radius )                           ! Generate polygonal mesh
FUNCTION-ALIAS:  gen-mesh-plane Mesh GenMeshPlane ( float width, float length, int resX, int resZ )   ! Generate plane mesh  ( with subdivisions ) 
FUNCTION-ALIAS:  gen-mesh-cube Mesh GenMeshCube ( float width, float height, float length )           ! Generate cuboid mesh
FUNCTION-ALIAS:  gen-mesh-sphere Mesh GenMeshSphere ( float radius, int rings, int slices )           ! Generate sphere mesh  ( standard sphere ) 
FUNCTION-ALIAS:  gen-mesh-hemisphere Mesh GenMeshHemiSphere ( float radius, int rings, int slices )   ! Generate half-sphere mesh  ( no bottom cap ) 
FUNCTION-ALIAS:  gen-mesh-cylinder Mesh GenMeshCylinder ( float radius, float height, int slices )    ! Generate cylinder mesh
FUNCTION-ALIAS:  gen-mesh-torus Mesh GenMeshTorus ( float radius, float size, int radSeg, int sides ) ! Generate torus mesh
FUNCTION-ALIAS:  gen-mesh-knot Mesh GenMeshKnot ( float radius, float size, int radSeg, int sides )   ! Generate trefoil knot mesh
FUNCTION-ALIAS:  gen-mesh-heightmap Mesh GenMeshHeightmap ( Image heightmap, Vector3 size )           ! Generate heightmap mesh from image data
FUNCTION-ALIAS:  gen-mesh-cubicmap Mesh GenMeshCubicmap ( Image cubicmap, Vector3 cubeSize )          ! Generate cubes-based map mesh from image data

! Material loading/unloading functions
FUNCTION-ALIAS:  load-material Material LoadMaterial ( c-string fileName )                                           ! Load material from file
FUNCTION-ALIAS:  load-material-default Material LoadMaterialDefault ( )                                              ! Load default material  ( Supports: DIFFUSE, SPECULAR, NORMAL maps ) 
FUNCTION-ALIAS:  unload-material void UnloadMaterial ( Material material )                                           ! Unload material from GPU memory  ( VRAM ) 
FUNCTION-ALIAS:  set-material-texture void SetMaterialTexture ( Material *material, int mapType, Texture2D texture ) ! Set texture for a material map type  ( MAP_DIFFUSE, MAP_SPECULAR... ) 
FUNCTION-ALIAS:  set-model-mesh-material void SetModelMeshMaterial ( Model *model, int meshId, int materialId )      ! Set material for a mesh

! Model animations loading/unloading functions
FUNCTION-ALIAS:  load-model-animations ModelAnimation* LoadModelAnimations ( c-string fileName, int* animsCount ) ! Load model animations from file
FUNCTION-ALIAS:  update-model-animation void UpdateModelAnimation ( Model model, ModelAnimation anim, int frame ) ! Update model animation pose
FUNCTION-ALIAS:  unload-model-animation void UnloadModelAnimation ( ModelAnimation anim )                         ! Unload animation data
FUNCTION-ALIAS:  is-model-animation-valid bool IsModelAnimationValid ( Model model, ModelAnimation anim )         ! Check model animation skeleton match

! Model drawing functions
FUNCTION-ALIAS:  draw-model void DrawModel ( Model model, Vector3 position, float scale, Color tint )                                                              ! Draw a model  ( with texture if set ) 
FUNCTION-ALIAS:  draw-model-ex void DrawModelEx ( Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint )            ! Draw a model with extended parameters
FUNCTION-ALIAS:  draw-model-wires void DrawModelWires ( Model model, Vector3 position, float scale, Color tint )                                                   ! Draw a model wires  ( with texture if set ) 
FUNCTION-ALIAS:  draw-model-wires-ex void DrawModelWiresEx ( Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint ) ! Draw a model wires  ( with texture if set )  with extended parameters
FUNCTION-ALIAS:  draw-bounding-box void DrawBoundingBox ( BoundingBox box, Color color )                                                                           ! Draw bounding box  ( wires ) 
FUNCTION-ALIAS:  draw-billboard void DrawBillboard ( Camera camera, Texture2D texture, Vector3 center, float size, Color tint )                                    ! Draw a billboard texture
FUNCTION-ALIAS:  draw-billboard-rec void DrawBillboardRec ( Camera camera, Texture2D texture, Rectangle sourceRec, Vector3 center, float size, Color tint )        ! Draw a billboard texture defined by sourceRec

! Collision detection functions
FUNCTION-ALIAS:  check-collision-spheres bool CheckCollisionSpheres ( Vector3 centerA, float radiusA, Vector3 centerB, float radiusB )                         ! Detect collision between two spheres
FUNCTION-ALIAS:  check-collision-boxes bool CheckCollisionBoxes ( BoundingBox box1, BoundingBox box2 )                                                         ! Detect collision between two bounding boxes
FUNCTION-ALIAS:  check-collision-box-sphere bool CheckCollisionBoxSphere ( BoundingBox box, Vector3 centerSphere, float radiusSphere )                         ! Detect collision between box and sphere
FUNCTION-ALIAS:  check-collision-ray-sphere bool CheckCollisionRaySphere ( Ray ray, Vector3 spherePosition, float sphereRadius )                               ! Detect collision between ray and sphere
FUNCTION-ALIAS:  check-collision-ray-sphere-ex bool CheckCollisionRaySphereEx ( Ray ray, Vector3 spherePosition, float sphereRadius, Vector3* collisionPoint ) ! Detect collision between ray and sphere, returns collision point
FUNCTION-ALIAS:  check-collision-ray-box bool CheckCollisionRayBox ( Ray ray, BoundingBox box )                                                                ! Detect collision between ray and box
FUNCTION-ALIAS:  get-collision-ray-model RayHitInfo GetCollisionRayModel ( Ray ray, Model* model )                                                             ! Get collision info between ray and model
FUNCTION-ALIAS:  get-collision-ray-triangle RayHitInfo GetCollisionRayTriangle ( Ray ray, Vector3 p1, Vector3 p2, Vector3 p3 )                                 ! Get collision info between ray and triangle
FUNCTION-ALIAS:  get-collision-ray-ground RayHitInfo GetCollisionRayGround ( Ray ray, float groundHeight )                                                     ! Get collision info between ray and ground plane  ( Y-normal plane ) 

! ------------------------------------------------------------------------------------
! Shaders System Functions  ( Module: rlgl ) 
! NOTE: This functions are useless when using OpenGL 1.1
! ------------------------------------------------------------------------------------

! Shader loading/unloading functions
FUNCTION-ALIAS:  load-text c-string LoadText ( c-string fileName )                          ! Load chars array from text file
FUNCTION-ALIAS:  load-shader Shader LoadShader ( c-string vsFileName, c-string fsFileName ) ! Load shader from files and bind default locations
FUNCTION-ALIAS:  load-shader-code Shader LoadShaderCode ( c-string vsCode, c-string fsCode )      ! Load shader from code strings and bind default locations
FUNCTION-ALIAS:  unload-shader void UnloadShader ( Shader shader )                          ! Unload shader from GPU memory  ( VRAM ) 
FUNCTION-ALIAS:  get-shader-default Shader GetShaderDefault ( )                             ! Get default shader
FUNCTION-ALIAS:  get-texture-default Texture2D GetTextureDefault ( )                        ! Get default texture

! Shader configuration functions
FUNCTION-ALIAS:  get-shader-location int GetShaderLocation ( Shader shader, c-string uniformName )                                  ! Get shader uniform location
FUNCTION-ALIAS:  set-shader-value void SetShaderValue ( Shader shader, int uniformLoc, void* value, int uniformType )               ! Set shader uniform value
FUNCTION-ALIAS:  set-shader-value-v void SetShaderValueV ( Shader shader, int uniformLoc, void* value, int uniformType, int count ) ! Set shader uniform value vector
FUNCTION-ALIAS:  set-shader-value-matrix void SetShaderValueMatrix ( Shader shader, int uniformLoc, Matrix mat )                    ! Set shader uniform value  ( matrix 4x4 ) 
FUNCTION-ALIAS:  set-shader-value-texture void SetShaderValueTexture ( Shader shader, int uniformLoc, Texture2D texture )           ! Set shader uniform value for texture
FUNCTION-ALIAS:  set-matrix-projection void SetMatrixProjection ( Matrix proj )                                                     ! Set a custom projection matrix  ( replaces internal projection matrix ) 
FUNCTION-ALIAS:  set-matrix-model-view void SetMatrixModelview ( Matrix view )                                                      ! Set a custom modelview matrix  ( replaces internal modelview matrix ) 
FUNCTION-ALIAS:  get-matrix-model-view Matrix GetMatrixModelview (  )                                                               ! Get internal modelview matrix

! Texture maps generation  ( PBR ) 
! NOTE: Required shaders should be provided
FUNCTION-ALIAS:  gen-texture-cubemap Texture2D GenTextureCubemap ( Shader shader, Texture2D skyHDR, int size )        ! Generate cubemap texture from HDR texture
FUNCTION-ALIAS:  gen-texture-irradiance Texture2D GenTextureIrradiance ( Shader shader, Texture2D cubemap, int size ) ! Generate irradiance texture using cubemap data
FUNCTION-ALIAS:  gen-texture-prefilter Texture2D GenTexturePrefilter ( Shader shader, Texture2D cubemap, int size )   ! Generate prefilter texture using cubemap data
FUNCTION-ALIAS:  gen-texture-brdf Texture2D GenTextureBRDF ( Shader shader, Texture2D cubemap, int size )             ! Generate BRDF texture using cubemap data

! Shading begin/end functions
FUNCTION-ALIAS:  begin-shader-mode void BeginShaderMode ( Shader shader )                         ! Begin custom shader drawing
FUNCTION-ALIAS:  end-shader-mode void EndShaderMode ( )                                           ! End custom shader drawing  ( use default shader ) 
FUNCTION-ALIAS:  begin-blend-mode void BeginBlendMode ( int mode )                                ! Begin blending mode  ( alpha, additive, multiplied ) 
FUNCTION-ALIAS:  end-blend-mode void EndBlendMode ( )                                             ! End blending mode  ( reset to default: alpha blending ) 

! VR control functions
FUNCTION-ALIAS:  init-vr-simulator void InitVrSimulator ( )                                            ! Init VR simulator for selected device parameters
FUNCTION-ALIAS:  close-vr-simulator void CloseVrSimulator ( )                                          ! Close VR simulator for current device
FUNCTION-ALIAS:  update-vr-tracking void UpdateVrTracking ( Camera *camera )                           ! Update VR tracking  ( position and orientation )  and camera
FUNCTION-ALIAS:  set-vr-configuration void SetVrConfiguration ( VrDeviceInfo info, Shader distortion ) ! Set stereo rendering configuration parameters 
FUNCTION-ALIAS:  is-vr-simulator-ready bool IsVrSimulatorReady ( )                                     ! Detect if VR simulator is ready
FUNCTION-ALIAS:  toggle-vr-mode void ToggleVrMode ( )                                                  ! Enable/Disable VR experience
FUNCTION-ALIAS:  begin-vr-drawing void BeginVrDrawing ( )                                              ! Begin VR simulator stereo rendering
FUNCTION-ALIAS:  end-vr-drawing void EndVrDrawing ( )                                                  ! End VR simulator stereo rendering

! ------------------------------------------------------------------------------------
! Audio Loading and Playing Functions  ( Module: audio ) 
! ------------------------------------------------------------------------------------

! Audio device management functions
FUNCTION-ALIAS:  init-audio-device void InitAudioDevice ( )              ! Initialize audio device and context
FUNCTION-ALIAS:  close-audio-device void CloseAudioDevice ( )            ! Close the audio device and context
FUNCTION-ALIAS:  is-audio-device-ready bool IsAudioDeviceReady ( )       ! Check if audio device has been initialized successfully
FUNCTION-ALIAS:  set-master-volume void SetMasterVolume ( float volume ) ! Set master volume  ( listener ) 

! Wave/Sound loading/unloading functions
FUNCTION-ALIAS:  load-wave Wave LoadWave ( c-string fileName )                                                              ! Load wave data from file
FUNCTION-ALIAS:  load-wave-ex Wave LoadWaveEx ( void* data, int sampleCount, int sampleRate, int sampleSize, int channels ) ! Load wave data from raw array data
FUNCTION-ALIAS:  load-sound Sound LoadSound ( c-string fileName )                                                           ! Load sound from file
FUNCTION-ALIAS:  load-sound-from-wave Sound LoadSoundFromWave ( Wave wave )                                                 ! Load sound from wave data
FUNCTION-ALIAS:  update-sound void UpdateSound ( Sound sound, void* data, int samplesCount )                                ! Update sound buffer with new data
FUNCTION-ALIAS:  unload-wave void UnloadWave ( Wave wave )                                                                  ! Unload wave data
FUNCTION-ALIAS:  unload-sound void UnloadSound ( Sound sound )                                                              ! Unload sound
FUNCTION-ALIAS:  export-wave void ExportWave ( Wave wave, c-string fileName )                                               ! Export wave data to file
FUNCTION-ALIAS:  export-wave-as-code void ExportWaveAsCode ( Wave wave, c-string fileName )                                 ! Export wave sample data to code  ( .h ) 

! Wave/Sound management functions
FUNCTION-ALIAS:  play-sound void PlaySound ( Sound sound )                                                ! Play a sound
FUNCTION-ALIAS:  pause-sound void PauseSound ( Sound sound )                                              ! Pause a sound
FUNCTION-ALIAS:  resume-sound void ResumeSound ( Sound sound )                                            ! Resume a paused sound
FUNCTION-ALIAS:  stop-sound void StopSound ( Sound sound )                                                ! Stop playing a sound
FUNCTION-ALIAS:  is-sound-playing bool IsSoundPlaying ( Sound sound )                                     ! Check if a sound is currently playing
FUNCTION-ALIAS:  set-sound-volume void SetSoundVolume ( Sound sound, float volume )                       ! Set volume for a sound  ( 1.0 is max level ) 
FUNCTION-ALIAS:  set-sound-pitch void SetSoundPitch ( Sound sound, float pitch )                          ! Set pitch for a sound  ( 1.0 is base level ) 
FUNCTION-ALIAS:  wave-format void WaveFormat ( Wave* wave, int sampleRate, int sampleSize, int channels ) ! Convert wave data to desired format
FUNCTION-ALIAS:  wave-copy Wave WaveCopy ( Wave wave )                                                    ! Copy a wave to a new wave
FUNCTION-ALIAS:  wave-crop void WaveCrop ( Wave* wave, int initSample, int finalSample )                  ! Crop a wave to defined samples range
FUNCTION-ALIAS:  get-wave-data float* GetWaveData ( Wave wave )                                           ! Get samples data from wave as a floats array

! Music management functions
FUNCTION-ALIAS:  load-music-stream Music LoadMusicStream ( c-string fileName )          ! Load music stream from file
FUNCTION-ALIAS:  unload-music-stream void UnloadMusicStream ( Music music )             ! Unload music stream
FUNCTION-ALIAS:  play-music-stream void PlayMusicStream ( Music music )                 ! Start music playing
FUNCTION-ALIAS:  update-music-stream void UpdateMusicStream ( Music music )             ! Updates buffers for music streaming
FUNCTION-ALIAS:  stop-music-stream void StopMusicStream ( Music music )                 ! Stop music playing
FUNCTION-ALIAS:  pause-music-stream void PauseMusicStream ( Music music )               ! Pause music playing
FUNCTION-ALIAS:  resume-music-stream void ResumeMusicStream ( Music music )             ! Resume playing paused music
FUNCTION-ALIAS:  is-music-playing bool IsMusicPlaying ( Music music )                   ! Check if music is playing
FUNCTION-ALIAS:  set-music-volume void SetMusicVolume ( Music music, float volume )     ! Set volume for music  ( 1.0 is max level ) 
FUNCTION-ALIAS:  set-music-pitch void SetMusicPitch ( Music music, float pitch )        ! Set pitch for a music  ( 1.0 is base level ) 
FUNCTION-ALIAS:  set-music-loop-count void SetMusicLoopCount ( Music music, int count ) ! Set music loop count  ( loop repeats ) 
FUNCTION-ALIAS:  get-music-time-length float GetMusicTimeLength ( Music music )         ! Get music time length  ( in seconds ) 
FUNCTION-ALIAS:  get-music-time-played float GetMusicTimePlayed ( Music music )         ! Get current music time played  ( in seconds ) 

! AudioStream management functions
FUNCTION-ALIAS:  init-audio-stream AudioStream InitAudioStream ( uint sampleRate, uint sampleSize, uint channels )                 ! Init audio stream  ( to stream raw audio pcm data ) 
FUNCTION-ALIAS:  update-audio-stream void UpdateAudioStream ( AudioStream stream, void* data, int samplesCount )                   ! Update audio stream buffers with data
FUNCTION-ALIAS:  close-audio-stream void CloseAudioStream ( AudioStream stream )                                                   ! Close audio stream and free memory
FUNCTION-ALIAS:  is-audio-buffer-processed bool IsAudioBufferProcessed ( AudioStream stream )                                      ! Check if any audio stream buffers requires refill
FUNCTION-ALIAS:  play-audio-stream void PlayAudioStream ( AudioStream stream )                                                     ! Play audio stream
FUNCTION-ALIAS:  pause-audio-stream void PauseAudioStream ( AudioStream stream )                                                   ! Pause audio stream
FUNCTION-ALIAS:  resume-audio-stream void ResumeAudioStream ( AudioStream stream )                                                 ! Resume audio stream
FUNCTION-ALIAS:  is-audio-stream-playing bool IsAudioStreamPlaying ( AudioStream stream )                                          ! Check if audio stream is playing
FUNCTION-ALIAS:  stop-audio-stream void StopAudioStream ( AudioStream stream )                                                     ! Stop audio stream
FUNCTION-ALIAS:  set-audio-stream-volume void SetAudioStreamVolume ( AudioStream stream, float volume )                            ! Set volume for audio stream  ( 1.0 is max level ) 
FUNCTION-ALIAS:  set-audio-stream-pitch void SetAudioStreamPitch ( AudioStream stream, float pitch )                               ! Set pitch for audio stream  ( 1.0 is base level ) 



! ------------------------------
! New or updated from 2.5 -> 3.5
! ------------------------------

FUNCTION-ALIAS:  get-world-to-screen-ex Vector2 GetWorldToScreenEx ( Vector3 position, Camera camera, int width, int height )                                           ! Returns size position for a 3d world space position
FUNCTION-ALIAS:  get-world-to-screen-2d Vector2 GetWorldToScreen2D ( Vector2 position, Camera2D camera )                                                                ! Returns the screen space position for a 2d camera world space position
FUNCTION-ALIAS:  get-screen-to-world2d Vector2 GetScreenToWorld2D ( Vector2 position, Camera2D camera )                                                                 ! Returns the world space position for a 2d camera screen space position
FUNCTION-ALIAS:  compress-data uchar*  CompressData ( uchar*  data, int dataLength, int* compDataLength )                                                               ! Compress data  ( DEFLATE algorithm)
FUNCTION-ALIAS:  decompress-data uchar*  DecompressData ( uchar*  compData, int compDataLength, int* dataLength )                                                       ! Decompress data  ( DEFLATE algorithm)
FUNCTION-ALIAS:  get-char-pressed int GetCharPressed ( )                                                                                                           ! Get char pressed  ( unicode), call it multiple times for chars queued
FUNCTION-ALIAS:  get-mouse-cursor int GetMouseCursor ( )                                                                                                           ! Returns mouse cursor if  ( MouseCursor enum)
FUNCTION-ALIAS:  set-mouse-cursor void SetMouseCursor ( int cursor )                                                                                                    ! Set mouse cursor
FUNCTION-ALIAS:  check-collision-lines bool CheckCollisionLines ( Vector2 startPos1, Vector2 endPos1, Vector2 startPos2, Vector2 endPos2, Vector2 *collisionPoint )     ! Check the collision between two lines defined by two points each, returns collision point by reference
FUNCTION-ALIAS:  load-image-anim Image LoadImageAnim ( char* fileName, int* frames )                                                                                    ! Load image sequence from file  ( frames appended to image.data)
FUNCTION-ALIAS:  load-image-from-memory Image LoadImageFromMemory ( char* fileType, uchar*  fileData, int dataSize )                                              ! Load image from memory buffer, fileType refers to extension: i.e. "png"
FUNCTION-ALIAS:  load-image-colors Color* LoadImageColors ( Image image )                                                                                               ! Load color data from image as a Color array  ( RGBA - 32bit)
FUNCTION-ALIAS:  load-image-palette Color* LoadImagePalette ( Image image, int maxPaletteSize, int* colorsCount )                                                       ! Load colors palette from image as a Color array  ( RGBA - 32bit)
FUNCTION-ALIAS:  unload-image-colors void UnloadImageColors ( Color* colors )                                                                                           ! Unload color data loaded with LoadImageColors ( )
FUNCTION-ALIAS:  unload-image-palette void UnloadImagePalette ( Color* colors )                                                                                         ! Unload colors palette loaded with LoadImagePalette ( )
FUNCTION-ALIAS:  get-image-alpha-border Rectangle GetImageAlphaBorder ( Image image, float threshold )                                                                  ! Get image alpha border rectangle


! Image drawing functions
! NOTE: Image software-rendering functions  (CPU)
FUNCTION-ALIAS:  image-clear-background void ImageClearBackground ( Image* dst, Color color )                                                                   ! Clear image background with given color
FUNCTION-ALIAS:  image-draw-pixel void ImageDrawPixel ( Image* dst, int posX, int posY, Color color )                                                           ! Draw pixel within an image
FUNCTION-ALIAS:  image-draw-pixel-v void ImageDrawPixelV ( Image* dst, Vector2 position, Color color )                                                          ! Draw pixel within an image  ( Vector version)
FUNCTION-ALIAS:  image-draw-line void ImageDrawLine ( Image* dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color )                         ! Draw line within an image
FUNCTION-ALIAS:  image-draw-line-v void ImageDrawLineV ( Image* dst, Vector2 start, Vector2 end, Color color )                                                  ! Draw line within an image  ( Vector version)
FUNCTION-ALIAS:  image-draw-circle void ImageDrawCircle ( Image* dst, int centerX, int centerY, int radius, Color color )                                       ! Draw circle within an image
FUNCTION-ALIAS:  image-draw-circle-v void ImageDrawCircleV ( Image* dst, Vector2 center, int radius, Color color )                                              ! Draw circle within an image  ( Vector version)
FUNCTION-ALIAS:  image-draw-rectangle-v void ImageDrawRectangleV ( Image* dst, Vector2 position, Vector2 size, Color color )                                    ! Draw rectangle within an image  ( Vector version)
FUNCTION-ALIAS:  image-draw-rectangle-rec void ImageDrawRectangleRec ( Image* dst, Rectangle rec, Color color )                                                 ! Draw rectangle within an image
FUNCTION-ALIAS:  image-draw void ImageDraw ( Image* dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint )                                            ! Draw a source image within a destination image  ( tint applied to source)
FUNCTION-ALIAS:  image-draw-text void ImageDrawText ( Image* dst, char* text, int posX, int posY, int fontSize, Color color )                                   ! Draw text  ( using default font) within an image  ( destination)
FUNCTION-ALIAS:  image-draw-text-ex void ImageDrawTextEx ( Image* dst, Font font, char* text, Vector2 position, float fontSize, float spacing, Color tint )     ! Draw text  ( custom sprite font) within an image  ( destination)
! ----

FUNCTION-ALIAS:  update-texture-rec void UpdateTextureRec ( Texture2D texture, Rectangle rec, void* pixels )                        ! Update GPU texture rectangle with new data

! Color/pixel related functions
FUNCTION-ALIAS:  fade Color Fade ( Color color, float alpha )                                   ! Returns color with alpha applied, alpha goes from 0.0f to 1.0f
FUNCTION-ALIAS:  color-to-int int ColorToInt ( Color color )                                    ! Returns hexadecimal value for a Color
FUNCTION-ALIAS:  color-normalize Vector4 ColorNormalize ( Color color )                         ! Returns Color normalized as float [0..1]
FUNCTION-ALIAS:  color-from-normalized Color ColorFromNormalized ( Vector4 normalized )         ! Returns Color from normalized values [0..1]
FUNCTION-ALIAS:  color-to-hsv Vector3 ColorToHSV ( Color color )                                ! Returns HSV values for a Color
FUNCTION-ALIAS:  color-from-hsv Color ColorFromHSV ( float hue, float saturation, float value ) ! Returns a Color from HSV values
FUNCTION-ALIAS:  color-alpha Color ColorAlpha ( Color color, float alpha )                      ! Returns color with alpha applied, alpha goes from 0.0f to 1.0f
FUNCTION-ALIAS:  color-alpha-blend Color ColorAlphaBlend ( Color dst, Color src, Color tint )   ! Returns src alpha-blended into dst color with tint
FUNCTION-ALIAS:  get-color Color GetColor ( int hexValue )                                      ! Get Color structure from hexadecimal value
FUNCTION-ALIAS:  get-pixel-color Color GetPixelColor ( void* srcPtr, int format )               ! Get Color from a source pixel pointer of certain format
FUNCTION-ALIAS:  set-pixel-color void SetPixelColor ( void* dstPtr, Color color, int format )   ! Set color formatted into destination pixel pointer

! ---------

FUNCTION-ALIAS:  get-codepoints int* GetCodepoints ( char* text, int* count )                           ! Get all codepoints in a string, codepoints count returned by parameters
FUNCTION-ALIAS:  get-codepoints-count int GetCodepointsCount ( char* text )                             ! Get total number of characters  ( codepoints) in a UTF8 encoded string
FUNCTION-ALIAS:  get-next-codepoint int GetNextCodepoint ( char* text, int* bytesProcessed )            ! Returns next codepoint in a UTF8 encoded string; 0x3f ( '?') is returned on failure
FUNCTION-ALIAS:  codepoint-to-utf8 char* CodepointToUtf8 ( int codepoint, int* byteLength )             ! Encode codepoint into utf8 text  ( char array length returned as parameter)
FUNCTION-ALIAS:  mesh-normals-smooth void MeshNormalsSmooth ( Mesh *mesh )                              ! Smooth  ( average) vertex normals
FUNCTION-ALIAS:  get-shapes-texture Texture2D GetShapesTexture ( )                                      ! Get texture to draw shapes
FUNCTION-ALIAS:  get-shapes-texture-rec Rectangle GetShapesTextureRec ( )                               ! Get texture rectangle to draw shapes
FUNCTION-ALIAS:  get-matrix-projection Matrix GetMatrixProjection ( )                                   ! Get internal projection matrix
FUNCTION-ALIAS:  load-wave-samples float* LoadWaveSamples ( Wave wave )                                 ! Load samples data from wave as a floats array
FUNCTION-ALIAS:  unload-wave-samples void UnloadWaveSamples ( float* samples )                          ! Unload samples data loaded with LoadWaveSamples ( )
FUNCTION-ALIAS:  set-audiostream-buffersize-default void SetAudioStreamBufferSizeDefault ( int size )   ! Default size for new audio streams


! ------------------------------------------------------------
! Load modules depending on what the installed dll/so supports
! -----------------------------------------------------------
"raylib" lookup-library dll>> dup
! Check for ricons symbols
"DrawIcon" swap dlsym  [ "raylib.modules.ricons" require ] when
! Check for gui symbols
"GuiEnable" swap dlsym [ "raylib.modules.gui"    require ] when 


