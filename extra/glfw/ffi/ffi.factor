! Copyright (C) 2023 Sebastian Strobl.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax combinators system classes.struct ;
QUALIFIED-WITH: math m

IN: glfw.ffi

<<
"glfw" {
    { [ os windows? ] [ "glfw3.dll" ] }
    { [ os macosx? ] [ "glfw3.dylib" ] }
    { [ os unix? ] [ "libglfw3.so" ] }
} cond cdecl add-library
>>

LIBRARY: glfw

CONSTANT: GLFW_FALSE 0
CONSTANT: GLFW_TRUE 1
CONSTANT: GLFW_RELEASE 0
CONSTANT: GLFW_PRESS 1
CONSTANT: GLFW_REPEAT 2

CONSTANT: GLFW_KEY_UNKNOWN -1
CONSTANT: GLFW_KEY_SPACE 32
CONSTANT: GLFW_KEY_APOSTROPHE 39
CONSTANT: GLFW_KEY_COMMA 44
CONSTANT: GLFW_KEY_MINUS 45
CONSTANT: GLFW_KEY_PERIOD 46
CONSTANT: GLFW_KEY_SLASH 47
CONSTANT: GLFW_KEY_0 48
CONSTANT: GLFW_KEY_1 49
CONSTANT: GLFW_KEY_2 50
CONSTANT: GLFW_KEY_3 51
CONSTANT: GLFW_KEY_4 52
CONSTANT: GLFW_KEY_5 53
CONSTANT: GLFW_KEY_6 54
CONSTANT: GLFW_KEY_7 55
CONSTANT: GLFW_KEY_8 56
CONSTANT: GLFW_KEY_9 57
CONSTANT: GLFW_KEY_SEMICOLON 59
CONSTANT: GLFW_KEY_EQUAL 61
CONSTANT: GLFW_KEY_A 65
CONSTANT: GLFW_KEY_B 66
CONSTANT: GLFW_KEY_C 67
CONSTANT: GLFW_KEY_D 68
CONSTANT: GLFW_KEY_E 69
CONSTANT: GLFW_KEY_F 70
CONSTANT: GLFW_KEY_G 71
CONSTANT: GLFW_KEY_H 72
CONSTANT: GLFW_KEY_I 73
CONSTANT: GLFW_KEY_J 74
CONSTANT: GLFW_KEY_K 75
CONSTANT: GLFW_KEY_L 76
CONSTANT: GLFW_KEY_M 77
CONSTANT: GLFW_KEY_N 78
CONSTANT: GLFW_KEY_O 79
CONSTANT: GLFW_KEY_P 80
CONSTANT: GLFW_KEY_Q 81
CONSTANT: GLFW_KEY_R 82
CONSTANT: GLFW_KEY_S 83
CONSTANT: GLFW_KEY_T 84
CONSTANT: GLFW_KEY_U 85
CONSTANT: GLFW_KEY_V 86
CONSTANT: GLFW_KEY_W 87
CONSTANT: GLFW_KEY_X 88
CONSTANT: GLFW_KEY_Y 89
CONSTANT: GLFW_KEY_Z 90
CONSTANT: GLFW_KEY_LEFT_BRACKET 91
CONSTANT: GLFW_KEY_BACKSLASH 92
CONSTANT: GLFW_KEY_RIGHT_BRACKET 93
CONSTANT: GLFW_KEY_GRAVE_ACCENT 96
CONSTANT: GLFW_KEY_WORLD_1 161
CONSTANT: GLFW_KEY_WORLD_2 162
CONSTANT: GLFW_KEY_ESCAPE 256
CONSTANT: GLFW_KEY_ENTER 257
CONSTANT: GLFW_KEY_TAB 258
CONSTANT: GLFW_KEY_BACKSPACE 259
CONSTANT: GLFW_KEY_INSERT 260
CONSTANT: GLFW_KEY_DELETE 261
CONSTANT: GLFW_KEY_RIGHT 262
CONSTANT: GLFW_KEY_LEFT 263
CONSTANT: GLFW_KEY_DOWN 264
CONSTANT: GLFW_KEY_UP 265
CONSTANT: GLFW_KEY_PAGE_UP 266
CONSTANT: GLFW_KEY_PAGE_DOWN 267
CONSTANT: GLFW_KEY_HOME 268
CONSTANT: GLFW_KEY_END 269
CONSTANT: GLFW_KEY_CAPS_LOCK 280
CONSTANT: GLFW_KEY_SCROLL_LOCK 281
CONSTANT: GLFW_KEY_NUM_LOCK 282
CONSTANT: GLFW_KEY_PRINT_SCREEN 283
CONSTANT: GLFW_KEY_PAUSE 284
CONSTANT: GLFW_KEY_F1 290
CONSTANT: GLFW_KEY_F2 291
CONSTANT: GLFW_KEY_F3 292
CONSTANT: GLFW_KEY_F4 293
CONSTANT: GLFW_KEY_F5 294
CONSTANT: GLFW_KEY_F6 295
CONSTANT: GLFW_KEY_F7 296
CONSTANT: GLFW_KEY_F8 297
CONSTANT: GLFW_KEY_F9 298
CONSTANT: GLFW_KEY_F10 299
CONSTANT: GLFW_KEY_F11 300
CONSTANT: GLFW_KEY_F12 301
CONSTANT: GLFW_KEY_F13 302
CONSTANT: GLFW_KEY_F14 303
CONSTANT: GLFW_KEY_F15 304
CONSTANT: GLFW_KEY_F16 305
CONSTANT: GLFW_KEY_F17 306
CONSTANT: GLFW_KEY_F18 307
CONSTANT: GLFW_KEY_F19 308
CONSTANT: GLFW_KEY_F20 309
CONSTANT: GLFW_KEY_F21 310
CONSTANT: GLFW_KEY_F22 311
CONSTANT: GLFW_KEY_F23 312
CONSTANT: GLFW_KEY_F24 313
CONSTANT: GLFW_KEY_F25 314
CONSTANT: GLFW_KEY_KP_0 320
CONSTANT: GLFW_KEY_KP_1 321
CONSTANT: GLFW_KEY_KP_2 322
CONSTANT: GLFW_KEY_KP_3 323
CONSTANT: GLFW_KEY_KP_4 324
CONSTANT: GLFW_KEY_KP_5 325
CONSTANT: GLFW_KEY_KP_6 326
CONSTANT: GLFW_KEY_KP_7 327
CONSTANT: GLFW_KEY_KP_8 328
CONSTANT: GLFW_KEY_KP_9 329
CONSTANT: GLFW_KEY_KP_DECIMAL 330
CONSTANT: GLFW_KEY_KP_DIVIDE 331
CONSTANT: GLFW_KEY_KP_MULTIPLY 332
CONSTANT: GLFW_KEY_KP_SUBTRACT 333
CONSTANT: GLFW_KEY_KP_ADD 334
CONSTANT: GLFW_KEY_KP_ENTER 335
CONSTANT: GLFW_KEY_KP_EQUAL 336
CONSTANT: GLFW_KEY_LEFT_SHIFT 340
CONSTANT: GLFW_KEY_LEFT_CONTROL 341
CONSTANT: GLFW_KEY_LEFT_ALT 342
CONSTANT: GLFW_KEY_LEFT_SUPER 343
CONSTANT: GLFW_KEY_RIGHT_SHIFT 344
CONSTANT: GLFW_KEY_RIGHT_CONTROL 345
CONSTANT: GLFW_KEY_RIGHT_ALT 346
CONSTANT: GLFW_KEY_RIGHT_SUPER 347
CONSTANT: GLFW_KEY_MENU 348
CONSTANT: GLFW_KEY_LAST GLFW_KEY_MENU

CONSTANT: GLFW_MOD_SHIFT 0x0001
CONSTANT: GLFW_MOD_CONTROL 0x0002
CONSTANT: GLFW_MOD_ALT 0x0004
CONSTANT: GLFW_MOD_SUPER 0x0008
CONSTANT: GLFW_MOD_CAPS_LOCK 0x0010
CONSTANT: GLFW_MOD_NUM_LOCK 0x0020

CONSTANT: GLFW_JOYSTICK_1 0
CONSTANT: GLFW_JOYSTICK_2 1
CONSTANT: GLFW_JOYSTICK_3 2
CONSTANT: GLFW_JOYSTICK_4 3
CONSTANT: GLFW_JOYSTICK_5 4
CONSTANT: GLFW_JOYSTICK_6 5
CONSTANT: GLFW_JOYSTICK_7 6
CONSTANT: GLFW_JOYSTICK_8 7
CONSTANT: GLFW_JOYSTICK_9 8
CONSTANT: GLFW_JOYSTICK_10 9
CONSTANT: GLFW_JOYSTICK_11 10
CONSTANT: GLFW_JOYSTICK_12 11
CONSTANT: GLFW_JOYSTICK_13 12
CONSTANT: GLFW_JOYSTICK_14 13
CONSTANT: GLFW_JOYSTICK_15 14
CONSTANT: GLFW_JOYSTICK_16 15
CONSTANT: GLFW_JOYSTICK_LAST GLFW_JOYSTICK_16

CONSTANT: GLFW_MOUSE_BUTTON_1 0
CONSTANT: GLFW_MOUSE_BUTTON_2 1
CONSTANT: GLFW_MOUSE_BUTTON_3 2
CONSTANT: GLFW_MOUSE_BUTTON_4 3
CONSTANT: GLFW_MOUSE_BUTTON_5 4
CONSTANT: GLFW_MOUSE_BUTTON_6 5
CONSTANT: GLFW_MOUSE_BUTTON_7 6
CONSTANT: GLFW_MOUSE_BUTTON_8 7
CONSTANT: GLFW_MOUSE_BUTTON_LEFT GLFW_MOUSE_BUTTON_1
CONSTANT: GLFW_MOUSE_BUTTON_RIGHT GLFW_MOUSE_BUTTON_2
CONSTANT: GLFW_MOUSE_BUTTON_MIDDLE GLFW_MOUSE_BUTTON_3
CONSTANT: GLFW_MOUSE_BUTTON_LAST GLFW_MOUSE_BUTTON_8

CONSTANT: GLFW_HAT_CENTERED 0x0000
CONSTANT: GLFW_HAT_UP 0x0001
CONSTANT: GLFW_HAT_RIGHT 0x0002
CONSTANT: GLFW_HAT_DOWN 0x0004
CONSTANT: GLFW_HAT_LEFT 0x0008
: GLFW_HAT_RIGHT_UP ( -- val ) GLFW_HAT_RIGHT GLFW_HAT_UP m:bitor ; inline foldable
: GLFW_HAT_RIGHT_DOWN ( -- val ) GLFW_HAT_RIGHT GLFW_HAT_DOWN m:bitor ; inline foldable
: GLFW_HAT_LEFT_UP ( -- val ) GLFW_HAT_LEFT GLFW_HAT_UP m:bitor ; inline foldable
: GLFW_HAT_LEFT_DOWN ( -- val ) GLFW_HAT_LEFT GLFW_HAT_DOWN m:bitor ; inline foldable

CONSTANT: GLFW_GAMEPAD_BUTTON_A 0
CONSTANT: GLFW_GAMEPAD_BUTTON_B 1
CONSTANT: GLFW_GAMEPAD_BUTTON_X 2
CONSTANT: GLFW_GAMEPAD_BUTTON_Y 3
CONSTANT: GLFW_GAMEPAD_BUTTON_LEFT_BUMPER 4
CONSTANT: GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER 5
CONSTANT: GLFW_GAMEPAD_BUTTON_BACK 6
CONSTANT: GLFW_GAMEPAD_BUTTON_START 7
CONSTANT: GLFW_GAMEPAD_BUTTON_GUIDE 8
CONSTANT: GLFW_GAMEPAD_BUTTON_LEFT_THUMB 9
CONSTANT: GLFW_GAMEPAD_BUTTON_RIGHT_THUMB 10
CONSTANT: GLFW_GAMEPAD_BUTTON_DPAD_UP 11
CONSTANT: GLFW_GAMEPAD_BUTTON_DPAD_RIGHT 12
CONSTANT: GLFW_GAMEPAD_BUTTON_DPAD_DOWN 13
CONSTANT: GLFW_GAMEPAD_BUTTON_DPAD_LEFT 14
CONSTANT: GLFW_GAMEPAD_BUTTON_LAST GLFW_GAMEPAD_BUTTON_DPAD_LEFT
CONSTANT: GLFW_GAMEPAD_BUTTON_CROSS GLFW_GAMEPAD_BUTTON_A
CONSTANT: GLFW_GAMEPAD_BUTTON_CIRCLE GLFW_GAMEPAD_BUTTON_B
CONSTANT: GLFW_GAMEPAD_BUTTON_SQUARE GLFW_GAMEPAD_BUTTON_X
CONSTANT: GLFW_GAMEPAD_BUTTON_TRIANGLE GLFW_GAMEPAD_BUTTON_Y

CONSTANT: GLFW_GAMEPAD_AXIS_LEFT_X 0
CONSTANT: GLFW_GAMEPAD_AXIS_LEFT_Y 1
CONSTANT: GLFW_GAMEPAD_AXIS_RIGHT_X 2
CONSTANT: GLFW_GAMEPAD_AXIS_RIGHT_Y 3
CONSTANT: GLFW_GAMEPAD_AXIS_LEFT_TRIGGER 4
CONSTANT: GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER 5
CONSTANT: GLFW_GAMEPAD_AXIS_LAST GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER

CONSTANT: GLFW_NO_ERROR 0
CONSTANT: GLFW_NOT_INITIALIZED 0x00010001
CONSTANT: GLFW_NO_CURRENT_CONTEXT 0x00010002
CONSTANT: GLFW_INVALID_ENUM 0x00010003
CONSTANT: GLFW_INVALID_VALUE 0x00010004
CONSTANT: GLFW_OUT_OF_MEMORY 0x00010005
CONSTANT: GLFW_API_UNAVAILABLE 0x00010006
CONSTANT: GLFW_VERSION_UNAVAILABLE 0x00010007
CONSTANT: GLFW_PLATFORM_ERROR 0x00010008
CONSTANT: GLFW_FORMAT_UNAVAILABLE 0x00010009
CONSTANT: GLFW_NO_WINDOW_CONTEXT 0x0001000A

CONSTANT: GLFW_FOCUSED 0x00020001
CONSTANT: GLFW_ICONIFIED 0x00020002
CONSTANT: GLFW_RESIZABLE 0x00020003
CONSTANT: GLFW_VISIBLE 0x00020004
CONSTANT: GLFW_DECORATED 0x00020005
CONSTANT: GLFW_AUTO_ICONIFY 0x00020006
CONSTANT: GLFW_FLOATING 0x00020007
CONSTANT: GLFW_MAXIMIZED 0x00020008
CONSTANT: GLFW_CENTER_CURSOR 0x00020009
CONSTANT: GLFW_TRANSPARENT_FRAMEBUFFER 0x0002000A
CONSTANT: GLFW_HOVERED 0x0002000B
CONSTANT: GLFW_FOCUS_ON_SHOW 0x0002000C

CONSTANT: GLFW_RED_BITS 0x00021001
CONSTANT: GLFW_GREEN_BITS 0x00021002
CONSTANT: GLFW_BLUE_BITS 0x00021003
CONSTANT: GLFW_ALPHA_BITS 0x00021004
CONSTANT: GLFW_DEPTH_BITS 0x00021005
CONSTANT: GLFW_STENCIL_BITS 0x00021006
CONSTANT: GLFW_ACCUM_RED_BITS 0x00021007
CONSTANT: GLFW_ACCUM_GREEN_BITS 0x00021008
CONSTANT: GLFW_ACCUM_BLUE_BITS 0x00021009
CONSTANT: GLFW_ACCUM_ALPHA_BITS 0x0002100A
CONSTANT: GLFW_AUX_BUFFERS 0x0002100B
CONSTANT: GLFW_STEREO 0x0002100C
CONSTANT: GLFW_SAMPLES 0x0002100D
CONSTANT: GLFW_SRGB_CAPABLE 0x0002100E
CONSTANT: GLFW_REFRESH_RATE 0x0002100F
CONSTANT: GLFW_DOUBLEBUFFER 0x00021010

CONSTANT: GLFW_CLIENT_API 0x00022001
CONSTANT: GLFW_CONTEXT_VERSION_MAJOR 0x00022002
CONSTANT: GLFW_CONTEXT_VERSION_MINOR 0x00022003
CONSTANT: GLFW_CONTEXT_REVISION 0x00022004
CONSTANT: GLFW_CONTEXT_ROBUSTNESS 0x00022005
CONSTANT: GLFW_OPENGL_FORWARD_COMPAT 0x00022006
CONSTANT: GLFW_OPENGL_DEBUG_CONTEXT 0x00022007
CONSTANT: GLFW_OPENGL_PROFILE 0x00022008
CONSTANT: GLFW_CONTEXT_RELEASE_BEHAVIOR 0x00022009
CONSTANT: GLFW_CONTEXT_NO_ERROR 0x0002200A
CONSTANT: GLFW_CONTEXT_CREATION_API 0x0002200B
CONSTANT: GLFW_SCALE_TO_MONITOR 0x0002200C

CONSTANT: GLFW_COCOA_RETINA_FRAMEBUFFER 0x00023001
CONSTANT: GLFW_COCOA_FRAME_NAME 0x00023002
CONSTANT: GLFW_COCOA_GRAPHICS_SWITCHING 0x00023003

CONSTANT: GLFW_X11_CLASS_NAME 0x00024001
CONSTANT: GLFW_X11_INSTANCE_NAME 0x00024002

CONSTANT: GLFW_NO_API 0x00000000
CONSTANT: GLFW_OPENGL_API 0x00030001
CONSTANT: GLFW_OPENGL_ES_API 0x00030002

CONSTANT: GLFW_NO_ROBUSTNESS 0x00000000
CONSTANT: GLFW_NO_RESET_NOTIFICATION 0x00031001
CONSTANT: GLFW_LOSE_CONTEXT_ON_RESET 0x00031002

CONSTANT: GLFW_OPENGL_ANY_PROFILE 0x00000000
CONSTANT: GLFW_OPENGL_CORE_PROFILE 0x00032001
CONSTANT: GLFW_OPENGL_COMPAT_PROFILE 0x00032002

CONSTANT: GLFW_CURSOR 0x00033001
CONSTANT: GLFW_STICKY_KEYS 0x00033002
CONSTANT: GLFW_STICKY_MOUSE_BUTTONS 0x00033003
CONSTANT: GLFW_LOCK_KEY_MODS 0x00033004
CONSTANT: GLFW_RAW_MOUSE_MOTION 0x00033005

CONSTANT: GLFW_CURSOR_NORMAL 0x00034001
CONSTANT: GLFW_CURSOR_HIDDEN 0x00034002
CONSTANT: GLFW_CURSOR_DISABLED 0x00034003

CONSTANT: GLFW_ANY_RELEASE_BEHAVIOR 0
CONSTANT: GLFW_RELEASE_BEHAVIOR_FLUSH 0x00035001
CONSTANT: GLFW_RELEASE_BEHAVIOR_NONE 0x00035002

CONSTANT: GLFW_NATIVE_CONTEXT_API 0x00036001
CONSTANT: GLFW_EGL_CONTEXT_API 0x00036002
CONSTANT: GLFW_OSMESA_CONTEXT_API 0x00036003

CONSTANT: GLFW_ARROW_CURSOR 0x00036001
CONSTANT: GLFW_IBEAM_CURSOR 0x00036002
CONSTANT: GLFW_CROSSHAIR_CURSOR 0x00036003
CONSTANT: GLFW_HAND_CURSOR 0x00036004
CONSTANT: GLFW_HRESIZE_CURSOR 0x00036005
CONSTANT: GLFW_VRESIZE_CURSOR 0x00036006

CONSTANT: GLFW_CONNECTED 0x00040001
CONSTANT: GLFW_DISCONNECTED 0x00040002

CONSTANT: GLFW_DONT_CARE -1 

CONSTANT: GLFW_JOYSTICK_HAT_BUTTONS 0x00050001
CONSTANT: GLFW_COCOA_CHDIR_RESOURCES 0x00051001
CONSTANT: GLFW_COCOA_MENUBAR 0x00051002


TYPEDEF: void* GLFWwindow
TYPEDEF: void* GLFWmonitor
TYPEDEF: void* GLFWcursor

TYPEDEF: void* GLFWglproc 
TYPEDEF: void* GLFWvkproc

CALLBACK: void* GLFWallocatefun ( size_t size, void* user )
CALLBACK: void* GLFWreallocatefun ( void* block, size_t size, void* user )
CALLBACK: void* GLFWdeallocatefun ( void* block, void* user )
CALLBACK: void GLFWerrorfun ( int error_code, char* description )

CALLBACK: void GLFWwindowposfun ( GLFWwindow window, int xpos, int ypos )
CALLBACK: void GLFWwindowsizefun ( GLFWwindow window, int width, int height )
CALLBACK: void GLFWwindowclosefun ( GLFWwindow window )
CALLBACK: void GLFWwindowrefreshfun ( GLFWwindow window )
CALLBACK: void GLFWwindowfocusfun ( GLFWwindow window, int focused )
CALLBACK: void GLFWwindowiconifyfun ( GLFWwindow window, int iconified )
CALLBACK: void GLFWwindowmaximizefun ( GLFWwindow window, int maximized )
CALLBACK: void GLFWframebuffersizefun ( GLFWwindow window, int width, int height )
CALLBACK: void GLFWwindowcontentscalefun ( GLFWwindow window, float xscale, float yscale )

CALLBACK: void GLFWmousebuttonfun ( GLFWwindow window, int button, int action, int mods )
CALLBACK: void GLFWcursorposfun ( GLFWwindow window, double xpos, double ypos )
CALLBACK: void GLFWcursorenterfun ( GLFWwindow window, int entered )
CALLBACK: void GLFWscrollfun ( GLFWwindow window, double xoffset, double yoffset )
CALLBACK: void GLFWkeyfun ( GLFWwindow window, int key, int scancode, int action, int mode )
CALLBACK: void GLFWcharfun ( GLFWwindow window, uint codepoint )
CALLBACK: void GLFWcharmodsfun ( GLFWwindow window, uint codepoint, int mods )
CALLBACK: void GLFWdropfun ( GLFWwindow window, int path_count, char** paths )
CALLBACK: void GLFWmonitorfun ( GLFWmonitor monitor, int event )
CALLBACK: void GLFWjoystickfun ( int jid, int event )

STRUCT: GLFWvidmode
    { width int }
    { height int }
    { redBits int }
    { greenBits int }
    { blueBits int }
    { refreshRate int } ;

STRUCT: GLFWgammaramp
    { red short* }
    { green short* }
    { blue short }
    { size int } ;

STRUCT: GLFWimage
    { width int }
    { height int }
    { pixels uchar* } ;

STRUCT: GLFWgamepadstate
    { buttons uchar[15] }
    { axes float[6] } ;

STRUCT: GLFWallocator
    { allocate GLFWallocatefun }
    { reallocate GLFWreallocatefun }
    { deallocate GLFWdeallocatefun }
    { user void* } ;

FUNCTION: int glfwInit ( )
FUNCTION: void glfwTerminate ( )
FUNCTION: void glfwGetVersion ( int major, int minor, int rev )
FUNCTION: char* glfwGetVersionString ( )

FUNCTION: GLFWerrorfun glfwSetErrorCallback ( GLFWerrorfun cbfun )

FUNCTION: GLFWmonitor glfwGetMonitors ( int count )
FUNCTION: GLFWmonitor glfwGetPrimaryMonitor ( )
FUNCTION: void glfwGetMonitorPos ( GLFWmonitor monitor, int* xpos, int* ypos )
FUNCTION: void glfwGetMonitorPhysicalSize ( GLFWmonitor monitor, int* width, int* height )
FUNCTION: char* glfwGetMonitorName ( GLFWmonitor*  monitor ) 
FUNCTION: void glfwSetMonitorUserPointer ( GLFWmonitor*  monitor, void*  pointer ) 
FUNCTION: void* glfwGetMonitorUserPointer ( GLFWmonitor*  monitor )

FUNCTION: GLFWvidmode* glfwGetVideoModes ( GLFWmonitor* monitor, int* count )
FUNCTION: GLFWvidmode* glfwGetVideoMode ( GLFWmonitor* monitor )
FUNCTION: void glfwSetGamma ( GLFWmonitor* monitor, float gamma )
FUNCTION: GLFWgammaramp* glfwGetGammaRamp ( GLFWmonitor* monitor )
FUNCTION: void glfwSetGammaRamp ( GLFWmonitor* monitor, GLFWgammaramp* ramp )

FUNCTION: void glfwDefaultWindowHints ( )
FUNCTION: void glfwWindowHint ( int hint, int value )
FUNCTION: void glfwWindowHintString ( int hint, char* value )
FUNCTION: GLFWwindow* glfwCreateWindow ( int width, int height, char* title, GLFWmonitor* monitor, GLFWwindow* share )

FUNCTION: void glfwDestroyWindow ( GLFWwindow* window )
FUNCTION: int glfwWindowShouldClose ( GLFWwindow* window )
FUNCTION: void glfwSetWindowShouldClose ( GLFWwindow* window, int value )
FUNCTION: void glfwSetWindowTitle ( GLFWwindow* window, char* title )
FUNCTION: void glfwSetWindowIcon ( GLFWwindow* window, int count, GLFWimage* images )
FUNCTION: void glfwGetWindowPos ( GLFWwindow* window, int* xpos, int* ypos )
FUNCTION: void glfwSetWindowPos ( GLFWwindow* window, int xpos, int ypos )
FUNCTION: void glfwGetWindowSize ( GLFWwindow* window, int* width, int* height )
FUNCTION: void glfwSetWindowSizeLimits ( GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight )
FUNCTION: void glfwSetWindowAspectRatio ( GLFWwindow* window, int numer, int denom )
FUNCTION: void glfwSetWindowSize ( GLFWwindow* window, int width, int height )
FUNCTION: void glfwGetFramebufferSize ( GLFWwindow* window, int* width, int* height )
FUNCTION: void glfwGetWindowFrameSize ( GLFWwindow* window, int* left, int* top, int* right, int* bottom )
FUNCTION: void glfwGetWindowContentScale ( GLFWwindow* window, float* xscale, float* yscale )
FUNCTION: float glfwGetWindowOpacity ( GLFWwindow* window )
FUNCTION: void glfwSetWindowOpacity ( GLFWwindow* window, float opacity )
FUNCTION: void glfwIconifyWindow ( GLFWwindow* window )
FUNCTION: void glfwRestoreWindow ( GLFWwindow* window )
FUNCTION: void glfwMaximizeWindow ( GLFWwindow* window )
FUNCTION: void glfwShowWindow ( GLFWwindow* window )
FUNCTION: void glfwHideWindow ( GLFWwindow* window )
FUNCTION: void glfwFocusWindow ( GLFWwindow* window )
FUNCTION: void glfwRequestWindowAttention ( GLFWwindow* window )
FUNCTION: GLFWmonitor* glfwGetWindowMonitor ( GLFWwindow* window )
FUNCTION: void glfwSetWindowMonitor ( GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate )
FUNCTION: int glfwGetWindowAttrib ( GLFWwindow* window, int attrib )
FUNCTION: void glfwSetWindowAttrib ( GLFWwindow* window, int attrib, int value )
FUNCTION: void glfwSetWindowUserPointer ( GLFWwindow* window, void* pointer )
FUNCTION: void* glfwGetWindowUserPointer ( GLFWwindow* window )

FUNCTION: GLFWwindowposfun glfwSetWindowPosCallback ( GLFWwindow* window, GLFWwindowposfun callback )
FUNCTION: GLFWwindowsizefun glfwSetWindowSizeCallback ( GLFWwindow* window, GLFWwindowsizefun callback )
FUNCTION: GLFWwindowclosefun glfwSetWindowCloseCallback ( GLFWwindow* window, GLFWwindowclosefun callback )
FUNCTION: GLFWwindowrefreshfun glfwSetWindowRefreshCallback ( GLFWwindow* window, GLFWwindowrefreshfun callback )
FUNCTION: GLFWwindowfocusfun glfwSetWindowFocusCallback ( GLFWwindow* window, GLFWwindowfocusfun callback )
FUNCTION: GLFWwindowiconifyfun glfwSetWindowIconifyCallback ( GLFWwindow* window, GLFWwindowiconifyfun callback )
FUNCTION: GLFWwindowmaximizefun glfwSetWindowMaximizeCallback ( GLFWwindow* window, GLFWwindowmaximizefun callback )
FUNCTION: GLFWframebuffersizefun glfwSetFramebufferSizeCallback ( GLFWwindow* window, GLFWframebuffersizefun callback )
FUNCTION: GLFWwindowcontentscalefun glfwSetWindowContentScaleCallback ( GLFWwindow* window, GLFWwindowcontentscalefun callback )

FUNCTION: void glfwPollEvents ( )
FUNCTION: void glfwWaitEvents ( )
FUNCTION: void glfwWaitEventsTimeout ( double timeout )
FUNCTION: void glfwPostEmptyEvent ( )

FUNCTION: int glfwGetInputMode ( GLFWwindow* window, int mode )
FUNCTION: void glfwSetInputMode ( GLFWwindow* window, int mode, int value )
FUNCTION: int glfwRawMouseMotionSupported ( )
FUNCTION: char* glfwGetKeyName ( int key, int scancode )
FUNCTION: int glfwGetKeyScancode ( int key )
FUNCTION: int glfwGetKey ( GLFWwindow* window, int key )
FUNCTION: int glfwGetMouseButton ( GLFWwindow* window, int button )
FUNCTION: void glfwGetCursorPos ( GLFWwindow* window, double* xpos, double* ypos )
FUNCTION: void glfwSetCursorPos ( GLFWwindow* window, double xpos, double ypos )
FUNCTION: GLFWcursor* glfwCreateCursor ( GLFWimage* image, int xhot, int yhot )
FUNCTION: GLFWcursor* glfwCreateStandardCursor ( int shape )
FUNCTION: void glfwDestroyCursor ( GLFWcursor* cursor )
FUNCTION: void glfwSetCursor ( GLFWwindow* window, GLFWcursor* cursor )

FUNCTION: GLFWkeyfun glfwSetKeyCallback ( GLFWwindow* window, GLFWkeyfun callback )
FUNCTION: GLFWcharfun glfwSetCharCallback ( GLFWwindow* window, GLFWcharfun callback )
FUNCTION: GLFWcharmodsfun glfwSetCharModsCallback ( GLFWwindow* window, GLFWcharmodsfun callback )
FUNCTION: GLFWmousebuttonfun glfwSetMouseButtonCallback ( GLFWwindow* window, GLFWmousebuttonfun callback )
FUNCTION: GLFWcursorposfun glfwSetCursorPosCallback ( GLFWwindow* window, GLFWcursorposfun callback )
FUNCTION: GLFWcursorenterfun glfwSetCursorEnterCallback ( GLFWwindow* window, GLFWcursorenterfun callback )
FUNCTION: GLFWscrollfun glfwSetScrollCallback ( GLFWwindow* window, GLFWscrollfun callback )
FUNCTION: GLFWdropfun glfwSetDropCallback ( GLFWwindow* window, GLFWdropfun callback )
FUNCTION: int glfwJoystickPresent ( int jid )
FUNCTION: float* glfwGetJoystickAxes ( int jid, int* count )
FUNCTION: uchar* glfwGetJoystickButtons ( int jid, int* count )
FUNCTION: uchar* glfwGetJoystickHats ( int jid, int* count )
FUNCTION: char* glfwGetJoystickName ( int jid )
FUNCTION: char* glfwGetJoystickGUID ( int jid )
FUNCTION: void glfwSetJoystickUserPointer ( int jid, void* pointer )
FUNCTION: void* glfwGetJoystickUserPointer ( int jid )
FUNCTION: int glfwJoystickIsGamepad ( int jid )
FUNCTION: GLFWjoystickfun glfwSetJoystickCallback ( GLFWjoystickfun callback )
FUNCTION: int glfwUpdateGamepadMappings ( char* string )
FUNCTION: char* glfwGetGamepadName ( int jid )
FUNCTION: int glfwGetGamepadState ( int jid, GLFWgamepadstate* state )
FUNCTION: void glfwSetClipboardString ( GLFWwindow* window, char* string )
FUNCTION: char* glfwGetClipboardString ( GLFWwindow* window )
FUNCTION: double glfwGetTime ( )
FUNCTION: void glfwSetTime ( double time )
FUNCTION: uint64_t glfwGetTimerValue ( )
FUNCTION: uint64_t glfwGetTimerFrequency ( )
FUNCTION: void glfwMakeContextCurrent ( GLFWwindow* window )
FUNCTION: GLFWwindow* glfwGetCurrentContext ( )
FUNCTION: void glfwSwapBuffers ( GLFWwindow* window )
FUNCTION: void glfwSwapInterval ( int interval )
FUNCTION: int glfwExtensionSupported ( char* extension )
FUNCTION: GLFWglproc glfwGetProcAddress ( char* procname )
FUNCTION: int glfwVulkanSupported (  )
FUNCTION: char** glfwGetRequiredInstanceExtensions ( uint32_t* count )
FUNCTION: void glfwInitHint ( int hint, int value )
FUNCTION: int glfwGetError ( char** description )
FUNCTION: void glfwGetMonitorWorkarea ( GLFWmonitor* monitor, int* xpos, int* ypos, int* width, int* height )
FUNCTION: void glfwGetMonitorContentScale ( GLFWmonitor* monitor, float* xscale, float* yscale )




FUNCTION: void* glfwGetWin32Window ( GLFWwindow* window )
FUNCTION: void* glfwGetWGLContext ( GLFWwindow* window )

FUNCTION: void* glfwGetCocoaWindow ( GLFWwindow* window )
FUNCTION: void* glfwGetNSGLContext ( GLFWwindow* window )

FUNCTION: void* glfwGetX11Window ( GLFWwindow* window )
FUNCTION: void* glfwGetX11Display ( )

FUNCTION: void* glfwGetGLXContext ( GLFWwindow* window )

FUNCTION: void* glfwGetWaylandWindow ( GLFWwindow* window )
FUNCTION: void* glfwGetWaylandDisplay ( )
