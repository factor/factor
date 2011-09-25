! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.libraries alien.syntax
classes.struct combinators system alien.accessors byte-arrays
kernel ;
IN: opencl.ffi

<< "opencl" {
        { [ os windows? ] [ "OpenCL.dll" stdcall ] }
        { [ os macosx? ] [ "/System/Library/Frameworks/OpenCL.framework/OpenCL" cdecl ] }
        { [ os unix? ] [ "libOpenCL.so" cdecl ] }
    } cond add-library >>
LIBRARY: opencl

! cl_platform.h
TYPEDEF: char      cl_char
TYPEDEF: uchar     cl_uchar
TYPEDEF: short     cl_short
TYPEDEF: ushort    cl_ushort
TYPEDEF: int       cl_int
TYPEDEF: uint      cl_uint
TYPEDEF: longlong  cl_long
TYPEDEF: ulonglong cl_ulong
TYPEDEF: ushort    cl_half
TYPEDEF: float     cl_float
TYPEDEF: double    cl_double

CONSTANT: CL_CHAR_BIT         8
CONSTANT: CL_SCHAR_MAX        127
CONSTANT: CL_SCHAR_MIN        -128
CONSTANT: CL_CHAR_MAX         127
CONSTANT: CL_CHAR_MIN         -128
CONSTANT: CL_UCHAR_MAX        255
CONSTANT: CL_SHRT_MAX         32767
CONSTANT: CL_SHRT_MIN         -32768
CONSTANT: CL_USHRT_MAX        65535
CONSTANT: CL_INT_MAX          2147483647
CONSTANT: CL_INT_MIN          -2147483648
CONSTANT: CL_UINT_MAX         HEX: ffffffff
CONSTANT: CL_LONG_MAX         HEX: 7FFFFFFFFFFFFFFF
CONSTANT: CL_LONG_MIN         HEX: 8000000000000000
CONSTANT: CL_ULONG_MAX        HEX: FFFFFFFFFFFFFFFF

CONSTANT: CL_FLT_DIG          6
CONSTANT: CL_FLT_MANT_DIG     24
CONSTANT: CL_FLT_MAX_10_EXP   38
CONSTANT: CL_FLT_MAX_EXP      128
CONSTANT: CL_FLT_MIN_10_EXP   -37
CONSTANT: CL_FLT_MIN_EXP      -125
CONSTANT: CL_FLT_RADIX        2
CONSTANT: CL_FLT_MAX          340282346638528859811704183484516925440.0
CONSTANT: CL_FLT_MIN          1.175494350822287507969e-38
CONSTANT: CL_FLT_EPSILON      HEX: 1.0p-23

CONSTANT: CL_DBL_DIG          15
CONSTANT: CL_DBL_MANT_DIG     53
CONSTANT: CL_DBL_MAX_10_EXP   308
CONSTANT: CL_DBL_MAX_EXP      1024
CONSTANT: CL_DBL_MIN_10_EXP   -307
CONSTANT: CL_DBL_MIN_EXP      -1021
CONSTANT: CL_DBL_RADIX        2
CONSTANT: CL_DBL_MAX          179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.0
CONSTANT: CL_DBL_MIN          2.225073858507201383090e-308
CONSTANT: CL_DBL_EPSILON      2.220446049250313080847e-16

CONSTANT: CL_NAN              NAN: 0
CONSTANT: CL_HUGE_VALF        1.0e50
CONSTANT: CL_HUGE_VAL         1.0e500
CONSTANT: CL_MAXFLOAT         340282346638528859811704183484516925440.0
CONSTANT: CL_INFINITY         1.0e50

TYPEDEF: uint cl_GLuint
TYPEDEF: int  cl_GLint
TYPEDEF: uint cl_GLenum

! cl.h
C-TYPE: _cl_platform_id
C-TYPE: _cl_device_id
C-TYPE: _cl_context
C-TYPE: _cl_command_queue
C-TYPE: _cl_mem
C-TYPE: _cl_program
C-TYPE: _cl_kernel
C-TYPE: _cl_event
C-TYPE: _cl_sampler

TYPEDEF: _cl_platform_id*    cl_platform_id
TYPEDEF: _cl_device_id*      cl_device_id
TYPEDEF: _cl_context*        cl_context
TYPEDEF: _cl_command_queue*  cl_command_queue
TYPEDEF: _cl_mem*            cl_mem
TYPEDEF: _cl_program*        cl_program
TYPEDEF: _cl_kernel*         cl_kernel
TYPEDEF: _cl_event*          cl_event
TYPEDEF: _cl_sampler*        cl_sampler

TYPEDEF: cl_uint             cl_bool
TYPEDEF: cl_ulong            cl_bitfield
TYPEDEF: cl_bitfield         cl_device_type
TYPEDEF: cl_uint             cl_platform_info
TYPEDEF: cl_uint             cl_device_info
TYPEDEF: cl_bitfield         cl_device_address_info
TYPEDEF: cl_bitfield         cl_device_fp_config
TYPEDEF: cl_uint             cl_device_mem_cache_type
TYPEDEF: cl_uint             cl_device_local_mem_type
TYPEDEF: cl_bitfield         cl_device_exec_capabilities
TYPEDEF: cl_bitfield         cl_command_queue_properties

TYPEDEF: intptr_t            cl_context_properties
TYPEDEF: cl_uint             cl_context_info
TYPEDEF: cl_uint             cl_command_queue_info
TYPEDEF: cl_uint             cl_channel_order
TYPEDEF: cl_uint             cl_channel_type
TYPEDEF: cl_bitfield         cl_mem_flags
TYPEDEF: cl_uint             cl_mem_object_type
TYPEDEF: cl_uint             cl_mem_info
TYPEDEF: cl_uint             cl_image_info
TYPEDEF: cl_uint             cl_addressing_mode
TYPEDEF: cl_uint             cl_filter_mode
TYPEDEF: cl_uint             cl_sampler_info
TYPEDEF: cl_bitfield         cl_map_flags
TYPEDEF: cl_uint             cl_program_info
TYPEDEF: cl_uint             cl_program_build_info
TYPEDEF: cl_int              cl_build_status
TYPEDEF: cl_uint             cl_kernel_info
TYPEDEF: cl_uint             cl_kernel_work_group_info
TYPEDEF: cl_uint             cl_event_info
TYPEDEF: cl_uint             cl_command_type
TYPEDEF: cl_uint             cl_profiling_info

STRUCT: cl_image_format
    { image_channel_order        cl_channel_order }
    { image_channel_data_type    cl_channel_type  } ;

CONSTANT: CL_SUCCESS                                  0
CONSTANT: CL_DEVICE_NOT_FOUND                         -1
CONSTANT: CL_DEVICE_NOT_AVAILABLE                     -2
CONSTANT: CL_COMPILER_NOT_AVAILABLE                   -3
CONSTANT: CL_MEM_OBJECT_ALLOCATION_FAILURE            -4
CONSTANT: CL_OUT_OF_RESOURCES                         -5
CONSTANT: CL_OUT_OF_HOST_MEMORY                       -6
CONSTANT: CL_PROFILING_INFO_NOT_AVAILABLE             -7
CONSTANT: CL_MEM_COPY_OVERLAP                         -8
CONSTANT: CL_IMAGE_FORMAT_MISMATCH                    -9
CONSTANT: CL_IMAGE_FORMAT_NOT_SUPPORTED               -10
CONSTANT: CL_BUILD_PROGRAM_FAILURE                    -11
CONSTANT: CL_MAP_FAILURE                              -12

CONSTANT: CL_INVALID_VALUE                            -30
CONSTANT: CL_INVALID_DEVICE_TYPE                      -31
CONSTANT: CL_INVALID_PLATFORM                         -32
CONSTANT: CL_INVALID_DEVICE                           -33
CONSTANT: CL_INVALID_CONTEXT                          -34
CONSTANT: CL_INVALID_QUEUE_PROPERTIES                 -35
CONSTANT: CL_INVALID_COMMAND_QUEUE                    -36
CONSTANT: CL_INVALID_HOST_PTR                         -37
CONSTANT: CL_INVALID_MEM_OBJECT                       -38
CONSTANT: CL_INVALID_IMAGE_FORMAT_DESCRIPTOR          -39
CONSTANT: CL_INVALID_IMAGE_SIZE                       -40
CONSTANT: CL_INVALID_SAMPLER                          -41
CONSTANT: CL_INVALID_BINARY                           -42
CONSTANT: CL_INVALID_BUILD_OPTIONS                    -43
CONSTANT: CL_INVALID_PROGRAM                          -44
CONSTANT: CL_INVALID_PROGRAM_EXECUTABLE               -45
CONSTANT: CL_INVALID_KERNEL_NAME                      -46
CONSTANT: CL_INVALID_KERNEL_DEFINITION                -47
CONSTANT: CL_INVALID_KERNEL                           -48
CONSTANT: CL_INVALID_ARG_INDEX                        -49
CONSTANT: CL_INVALID_ARG_VALUE                        -50
CONSTANT: CL_INVALID_ARG_SIZE                         -51
CONSTANT: CL_INVALID_KERNEL_ARGS                      -52
CONSTANT: CL_INVALID_WORK_DIMENSION                   -53
CONSTANT: CL_INVALID_WORK_GROUP_SIZE                  -54
CONSTANT: CL_INVALID_WORK_ITEM_SIZE                   -55
CONSTANT: CL_INVALID_GLOBAL_OFFSET                    -56
CONSTANT: CL_INVALID_EVENT_WAIT_LIST                  -57
CONSTANT: CL_INVALID_EVENT                            -58
CONSTANT: CL_INVALID_OPERATION                        -59
CONSTANT: CL_INVALID_GL_OBJECT                        -60
CONSTANT: CL_INVALID_BUFFER_SIZE                      -61
CONSTANT: CL_INVALID_MIP_LEVEL                        -62
CONSTANT: CL_INVALID_GLOBAL_WORK_SIZE                 -63

CONSTANT: CL_VERSION_1_0                              1

CONSTANT: CL_FALSE                                    0
CONSTANT: CL_TRUE                                     1

CONSTANT: CL_PLATFORM_PROFILE                         HEX: 0900
CONSTANT: CL_PLATFORM_VERSION                         HEX: 0901
CONSTANT: CL_PLATFORM_NAME                            HEX: 0902
CONSTANT: CL_PLATFORM_VENDOR                          HEX: 0903
CONSTANT: CL_PLATFORM_EXTENSIONS                      HEX: 0904

CONSTANT: CL_DEVICE_TYPE_DEFAULT                      1
CONSTANT: CL_DEVICE_TYPE_CPU                          2
CONSTANT: CL_DEVICE_TYPE_GPU                          4
CONSTANT: CL_DEVICE_TYPE_ACCELERATOR                  8
CONSTANT: CL_DEVICE_TYPE_ALL                          HEX: FFFFFFFF

CONSTANT: CL_DEVICE_TYPE                              HEX: 1000
CONSTANT: CL_DEVICE_VENDOR_ID                         HEX: 1001
CONSTANT: CL_DEVICE_MAX_COMPUTE_UNITS                 HEX: 1002
CONSTANT: CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS          HEX: 1003
CONSTANT: CL_DEVICE_MAX_WORK_GROUP_SIZE               HEX: 1004
CONSTANT: CL_DEVICE_MAX_WORK_ITEM_SIZES               HEX: 1005
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR       HEX: 1006
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT      HEX: 1007
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT        HEX: 1008
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG       HEX: 1009
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT      HEX: 100A
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE     HEX: 100B
CONSTANT: CL_DEVICE_MAX_CLOCK_FREQUENCY               HEX: 100C
CONSTANT: CL_DEVICE_ADDRESS_BITS                      HEX: 100D
CONSTANT: CL_DEVICE_MAX_READ_IMAGE_ARGS               HEX: 100E
CONSTANT: CL_DEVICE_MAX_WRITE_IMAGE_ARGS              HEX: 100F
CONSTANT: CL_DEVICE_MAX_MEM_ALLOC_SIZE                HEX: 1010
CONSTANT: CL_DEVICE_IMAGE2D_MAX_WIDTH                 HEX: 1011
CONSTANT: CL_DEVICE_IMAGE2D_MAX_HEIGHT                HEX: 1012
CONSTANT: CL_DEVICE_IMAGE3D_MAX_WIDTH                 HEX: 1013
CONSTANT: CL_DEVICE_IMAGE3D_MAX_HEIGHT                HEX: 1014
CONSTANT: CL_DEVICE_IMAGE3D_MAX_DEPTH                 HEX: 1015
CONSTANT: CL_DEVICE_IMAGE_SUPPORT                     HEX: 1016
CONSTANT: CL_DEVICE_MAX_PARAMETER_SIZE                HEX: 1017
CONSTANT: CL_DEVICE_MAX_SAMPLERS                      HEX: 1018
CONSTANT: CL_DEVICE_MEM_BASE_ADDR_ALIGN               HEX: 1019
CONSTANT: CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE          HEX: 101A
CONSTANT: CL_DEVICE_SINGLE_FP_CONFIG                  HEX: 101B
CONSTANT: CL_DEVICE_GLOBAL_MEM_CACHE_TYPE             HEX: 101C
CONSTANT: CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE         HEX: 101D
CONSTANT: CL_DEVICE_GLOBAL_MEM_CACHE_SIZE             HEX: 101E
CONSTANT: CL_DEVICE_GLOBAL_MEM_SIZE                   HEX: 101F
CONSTANT: CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE          HEX: 1020
CONSTANT: CL_DEVICE_MAX_CONSTANT_ARGS                 HEX: 1021
CONSTANT: CL_DEVICE_LOCAL_MEM_TYPE                    HEX: 1022
CONSTANT: CL_DEVICE_LOCAL_MEM_SIZE                    HEX: 1023
CONSTANT: CL_DEVICE_ERROR_CORRECTION_SUPPORT          HEX: 1024
CONSTANT: CL_DEVICE_PROFILING_TIMER_RESOLUTION        HEX: 1025
CONSTANT: CL_DEVICE_ENDIAN_LITTLE                     HEX: 1026
CONSTANT: CL_DEVICE_AVAILABLE                         HEX: 1027
CONSTANT: CL_DEVICE_COMPILER_AVAILABLE                HEX: 1028
CONSTANT: CL_DEVICE_EXECUTION_CAPABILITIES            HEX: 1029
CONSTANT: CL_DEVICE_QUEUE_PROPERTIES                  HEX: 102A
CONSTANT: CL_DEVICE_NAME                              HEX: 102B
CONSTANT: CL_DEVICE_VENDOR                            HEX: 102C
CONSTANT: CL_DRIVER_VERSION                           HEX: 102D
CONSTANT: CL_DEVICE_PROFILE                           HEX: 102E
CONSTANT: CL_DEVICE_VERSION                           HEX: 102F
CONSTANT: CL_DEVICE_EXTENSIONS                        HEX: 1030
CONSTANT: CL_DEVICE_PLATFORM                          HEX: 1031

CONSTANT: CL_FP_DENORM                                1
CONSTANT: CL_FP_INF_NAN                               2
CONSTANT: CL_FP_ROUND_TO_NEAREST                      4
CONSTANT: CL_FP_ROUND_TO_ZERO                         8
CONSTANT: CL_FP_ROUND_TO_INF                          16
CONSTANT: CL_FP_FMA                                   32

CONSTANT: CL_NONE                                     0
CONSTANT: CL_READ_ONLY_CACHE                          1
CONSTANT: CL_READ_WRITE_CACHE                         2

CONSTANT: CL_LOCAL                                    1
CONSTANT: CL_GLOBAL                                   2

CONSTANT: CL_EXEC_KERNEL                              1
CONSTANT: CL_EXEC_NATIVE_KERNEL                       2

CONSTANT: CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE      1
CONSTANT: CL_QUEUE_PROFILING_ENABLE                   2

CONSTANT: CL_CONTEXT_REFERENCE_COUNT                  HEX: 1080
CONSTANT: CL_CONTEXT_DEVICES                          HEX: 1081
CONSTANT: CL_CONTEXT_PROPERTIES                       HEX: 1082

CONSTANT: CL_CONTEXT_PLATFORM                         HEX: 1084

CONSTANT: CL_QUEUE_CONTEXT                            HEX: 1090
CONSTANT: CL_QUEUE_DEVICE                             HEX: 1091
CONSTANT: CL_QUEUE_REFERENCE_COUNT                    HEX: 1092
CONSTANT: CL_QUEUE_PROPERTIES                         HEX: 1093

CONSTANT: CL_MEM_READ_WRITE                           1
CONSTANT: CL_MEM_WRITE_ONLY                           2
CONSTANT: CL_MEM_READ_ONLY                            4
CONSTANT: CL_MEM_USE_HOST_PTR                         8
CONSTANT: CL_MEM_ALLOC_HOST_PTR                       16
CONSTANT: CL_MEM_COPY_HOST_PTR                        32

CONSTANT: CL_R                                        HEX: 10B0
CONSTANT: CL_A                                        HEX: 10B1
CONSTANT: CL_RG                                       HEX: 10B2
CONSTANT: CL_RA                                       HEX: 10B3
CONSTANT: CL_RGB                                      HEX: 10B4
CONSTANT: CL_RGBA                                     HEX: 10B5
CONSTANT: CL_BGRA                                     HEX: 10B6
CONSTANT: CL_ARGB                                     HEX: 10B7
CONSTANT: CL_INTENSITY                                HEX: 10B8
CONSTANT: CL_LUMINANCE                                HEX: 10B9

CONSTANT: CL_SNORM_INT8                               HEX: 10D0
CONSTANT: CL_SNORM_INT16                              HEX: 10D1
CONSTANT: CL_UNORM_INT8                               HEX: 10D2
CONSTANT: CL_UNORM_INT16                              HEX: 10D3
CONSTANT: CL_UNORM_SHORT_565                          HEX: 10D4
CONSTANT: CL_UNORM_SHORT_555                          HEX: 10D5
CONSTANT: CL_UNORM_INT_101010                         HEX: 10D6
CONSTANT: CL_SIGNED_INT8                              HEX: 10D7
CONSTANT: CL_SIGNED_INT16                             HEX: 10D8
CONSTANT: CL_SIGNED_INT32                             HEX: 10D9
CONSTANT: CL_UNSIGNED_INT8                            HEX: 10DA
CONSTANT: CL_UNSIGNED_INT16                           HEX: 10DB
CONSTANT: CL_UNSIGNED_INT32                           HEX: 10DC
CONSTANT: CL_HALF_FLOAT                               HEX: 10DD
CONSTANT: CL_FLOAT                                    HEX: 10DE

CONSTANT: CL_MEM_OBJECT_BUFFER                        HEX: 10F0
CONSTANT: CL_MEM_OBJECT_IMAGE2D                       HEX: 10F1
CONSTANT: CL_MEM_OBJECT_IMAGE3D                       HEX: 10F2

CONSTANT: CL_MEM_TYPE                                 HEX: 1100
CONSTANT: CL_MEM_FLAGS                                HEX: 1101
CONSTANT: CL_MEM_SIZE                                 HEX: 1102
CONSTANT: CL_MEM_HOST_PTR                             HEX: 1103
CONSTANT: CL_MEM_MAP_COUNT                            HEX: 1104
CONSTANT: CL_MEM_REFERENCE_COUNT                      HEX: 1105
CONSTANT: CL_MEM_CONTEXT                              HEX: 1106

CONSTANT: CL_IMAGE_FORMAT                             HEX: 1110
CONSTANT: CL_IMAGE_ELEMENT_SIZE                       HEX: 1111
CONSTANT: CL_IMAGE_ROW_PITCH                          HEX: 1112
CONSTANT: CL_IMAGE_SLICE_PITCH                        HEX: 1113
CONSTANT: CL_IMAGE_WIDTH                              HEX: 1114
CONSTANT: CL_IMAGE_HEIGHT                             HEX: 1115
CONSTANT: CL_IMAGE_DEPTH                              HEX: 1116

CONSTANT: CL_ADDRESS_NONE                             HEX: 1130
CONSTANT: CL_ADDRESS_CLAMP_TO_EDGE                    HEX: 1131
CONSTANT: CL_ADDRESS_CLAMP                            HEX: 1132
CONSTANT: CL_ADDRESS_REPEAT                           HEX: 1133

CONSTANT: CL_FILTER_NEAREST                           HEX: 1140
CONSTANT: CL_FILTER_LINEAR                            HEX: 1141

CONSTANT: CL_SAMPLER_REFERENCE_COUNT                  HEX: 1150
CONSTANT: CL_SAMPLER_CONTEXT                          HEX: 1151
CONSTANT: CL_SAMPLER_NORMALIZED_COORDS                HEX: 1152
CONSTANT: CL_SAMPLER_ADDRESSING_MODE                  HEX: 1153
CONSTANT: CL_SAMPLER_FILTER_MODE                      HEX: 1154

CONSTANT: CL_MAP_READ                                 1
CONSTANT: CL_MAP_WRITE                                2

CONSTANT: CL_PROGRAM_REFERENCE_COUNT                  HEX: 1160
CONSTANT: CL_PROGRAM_CONTEXT                          HEX: 1161
CONSTANT: CL_PROGRAM_NUM_DEVICES                      HEX: 1162
CONSTANT: CL_PROGRAM_DEVICES                          HEX: 1163
CONSTANT: CL_PROGRAM_SOURCE                           HEX: 1164
CONSTANT: CL_PROGRAM_BINARY_SIZES                     HEX: 1165
CONSTANT: CL_PROGRAM_BINARIES                         HEX: 1166

CONSTANT: CL_PROGRAM_BUILD_STATUS                     HEX: 1181
CONSTANT: CL_PROGRAM_BUILD_OPTIONS                    HEX: 1182
CONSTANT: CL_PROGRAM_BUILD_LOG                        HEX: 1183

CONSTANT: CL_BUILD_SUCCESS                            0
CONSTANT: CL_BUILD_NONE                               -1
CONSTANT: CL_BUILD_ERROR                              -2
CONSTANT: CL_BUILD_IN_PROGRESS                        -3

CONSTANT: CL_KERNEL_FUNCTION_NAME                     HEX: 1190
CONSTANT: CL_KERNEL_NUM_ARGS                          HEX: 1191
CONSTANT: CL_KERNEL_REFERENCE_COUNT                   HEX: 1192
CONSTANT: CL_KERNEL_CONTEXT                           HEX: 1193
CONSTANT: CL_KERNEL_PROGRAM                           HEX: 1194

CONSTANT: CL_KERNEL_WORK_GROUP_SIZE                   HEX: 11B0
CONSTANT: CL_KERNEL_COMPILE_WORK_GROUP_SIZE           HEX: 11B1
CONSTANT: CL_KERNEL_LOCAL_MEM_SIZE                    HEX: 11B2

CONSTANT: CL_EVENT_COMMAND_QUEUE                      HEX: 11D0
CONSTANT: CL_EVENT_COMMAND_TYPE                       HEX: 11D1
CONSTANT: CL_EVENT_REFERENCE_COUNT                    HEX: 11D2
CONSTANT: CL_EVENT_COMMAND_EXECUTION_STATUS           HEX: 11D3

CONSTANT: CL_COMMAND_NDRANGE_KERNEL                   HEX: 11F0
CONSTANT: CL_COMMAND_TASK                             HEX: 11F1
CONSTANT: CL_COMMAND_NATIVE_KERNEL                    HEX: 11F2
CONSTANT: CL_COMMAND_READ_BUFFER                      HEX: 11F3
CONSTANT: CL_COMMAND_WRITE_BUFFER                     HEX: 11F4
CONSTANT: CL_COMMAND_COPY_BUFFER                      HEX: 11F5
CONSTANT: CL_COMMAND_READ_IMAGE                       HEX: 11F6
CONSTANT: CL_COMMAND_WRITE_IMAGE                      HEX: 11F7
CONSTANT: CL_COMMAND_COPY_IMAGE                       HEX: 11F8
CONSTANT: CL_COMMAND_COPY_IMAGE_TO_BUFFER             HEX: 11F9
CONSTANT: CL_COMMAND_COPY_BUFFER_TO_IMAGE             HEX: 11FA
CONSTANT: CL_COMMAND_MAP_BUFFER                       HEX: 11FB
CONSTANT: CL_COMMAND_MAP_IMAGE                        HEX: 11FC
CONSTANT: CL_COMMAND_UNMAP_MEM_OBJECT                 HEX: 11FD
CONSTANT: CL_COMMAND_MARKER                           HEX: 11FE
CONSTANT: CL_COMMAND_ACQUIRE_GL_OBJECTS               HEX: 11FF
CONSTANT: CL_COMMAND_RELEASE_GL_OBJECTS               HEX: 1200

CONSTANT: CL_COMPLETE                                 HEX: 0
CONSTANT: CL_RUNNING                                  HEX: 1
CONSTANT: CL_SUBMITTED                                HEX: 2
CONSTANT: CL_QUEUED                                   HEX: 3

CONSTANT: CL_PROFILING_COMMAND_QUEUED                 HEX: 1280
CONSTANT: CL_PROFILING_COMMAND_SUBMIT                 HEX: 1281
CONSTANT: CL_PROFILING_COMMAND_START                  HEX: 1282
CONSTANT: CL_PROFILING_COMMAND_END                    HEX: 1283

FUNCTION: cl_int clGetPlatformIDs ( cl_uint num_entries, cl_platform_id* platforms, cl_uint* num_platforms ) ;
FUNCTION: cl_int clGetPlatformInfo ( cl_platform_id platform, cl_platform_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clGetDeviceIDs ( cl_platform_id platform, cl_device_type device_type, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices ) ;
FUNCTION: cl_int clGetDeviceInfo ( cl_device_id device, cl_device_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
CALLBACK: void cl_create_context_cb ( char* a, void* b, size_t s, void* c ) ;
FUNCTION: cl_context clCreateContext ( cl_context_properties*  properties, cl_uint num_devices, cl_device_id* devices, cl_create_context_cb pfn_notify, void* user_data, cl_int* errcode_ret ) ;
FUNCTION: cl_context clCreateContextFromType ( cl_context_properties* properties, cl_device_type device_type, cl_create_context_cb pfn_notify, void* user_data, cl_int* errcode_ret ) ;
FUNCTION: cl_int clRetainContext ( cl_context context ) ;
FUNCTION: cl_int clReleaseContext ( cl_context context ) ;
FUNCTION: cl_int clGetContextInfo ( cl_context context, cl_context_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_command_queue clCreateCommandQueue ( cl_context context, cl_device_id device, cl_command_queue_properties properties, cl_int* errcode_ret ) ;
FUNCTION: cl_int clRetainCommandQueue ( cl_command_queue command_queue ) ;
FUNCTION: cl_int clReleaseCommandQueue ( cl_command_queue command_queue ) ;
FUNCTION: cl_int clGetCommandQueueInfo ( cl_command_queue command_queue, cl_command_queue_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clSetCommandQueueProperty ( cl_command_queue command_queue, cl_command_queue_properties properties, cl_bool enable, cl_command_queue_properties* old_properties ) ;
FUNCTION: cl_mem clCreateBuffer ( cl_context context, cl_mem_flags flags, size_t size, void* host_ptr, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateImage2D ( cl_context context, cl_mem_flags flags, cl_image_format* image_format, size_t image_width, size_t image_height, size_t image_row_pitch, void* host_ptr, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateImage3D ( cl_context context, cl_mem_flags flags, cl_image_format* image_format, size_t image_width, size_t image_height, size_t image_depth, size_t image_row_pitch, size_t image_slice_pitch, void* host_ptr, cl_int* errcode_ret ) ;
FUNCTION: cl_int clRetainMemObject ( cl_mem memobj ) ;
FUNCTION: cl_int clReleaseMemObject ( cl_mem memobj ) ;
FUNCTION: cl_int clGetSupportedImageFormats ( cl_context context, cl_mem_flags flags, cl_mem_object_type image_type, cl_uint num_entries, cl_image_format* image_formats, cl_uint* num_image_formats ) ;
FUNCTION: cl_int clGetMemObjectInfo ( cl_mem memobj, cl_mem_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clGetImageInfo ( cl_mem image, cl_image_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_sampler clCreateSampler ( cl_context context, cl_bool normalized_coords, cl_addressing_mode addressing_mode, cl_filter_mode filter_mode, cl_int* errcode_ret ) ;
FUNCTION: cl_int clRetainSampler ( cl_sampler sampler ) ;
FUNCTION: cl_int clReleaseSampler ( cl_sampler sampler ) ;
FUNCTION: cl_int clGetSamplerInfo ( cl_sampler sampler, cl_sampler_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_program clCreateProgramWithSource ( cl_context context, cl_uint count, char** strings, size_t* lengths, cl_int* errcode_ret ) ;
FUNCTION: cl_program clCreateProgramWithBinary ( cl_context context, cl_uint num_devices, cl_device_id* device_list, size_t* lengths, char** binaries, cl_int* binary_status, cl_int* errcode_ret ) ;
FUNCTION: cl_int clRetainProgram ( cl_program  program ) ;
FUNCTION: cl_int clReleaseProgram ( cl_program  program ) ;
CALLBACK: void cl_build_program_cb ( cl_program program, void* user_data ) ;
FUNCTION: cl_int clBuildProgram ( cl_program program, cl_uint num_devices, cl_device_id* device_list, char* options, cl_build_program_cb pfn_notify, void* user_data ) ;
FUNCTION: cl_int clUnloadCompiler ( ) ;
FUNCTION: cl_int clGetProgramInfo ( cl_program program, cl_program_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clGetProgramBuildInfo ( cl_program program, cl_device_id device, cl_program_build_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_kernel clCreateKernel ( cl_program program, char* kernel_name, cl_int* errcode_ret ) ;
FUNCTION: cl_int clCreateKernelsInProgram ( cl_program program, cl_uint num_kernels, cl_kernel* kernels, cl_uint* num_kernels_ret ) ;
FUNCTION: cl_int clRetainKernel ( cl_kernel kernel ) ;
FUNCTION: cl_int clReleaseKernel ( cl_kernel kernel ) ;
FUNCTION: cl_int clSetKernelArg ( cl_kernel kernel, cl_uint arg_index, size_t arg_size, void* arg_value ) ;
FUNCTION: cl_int clGetKernelInfo ( cl_kernel kernel, cl_kernel_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clGetKernelWorkGroupInfo ( cl_kernel kernel, cl_device_id device, cl_kernel_work_group_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clWaitForEvents ( cl_uint num_events, cl_event* event_list ) ;
FUNCTION: cl_int clGetEventInfo ( cl_event event, cl_event_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clRetainEvent ( cl_event  event ) ;
FUNCTION: cl_int clReleaseEvent ( cl_event  event ) ;
FUNCTION: cl_int clGetEventProfilingInfo ( cl_event event, cl_profiling_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clFlush ( cl_command_queue command_queue ) ;
FUNCTION: cl_int clFinish ( cl_command_queue command_queue ) ;
FUNCTION: cl_int clEnqueueReadBuffer ( cl_command_queue command_queue, cl_mem buffer, cl_bool blocking_read, size_t offset, size_t cb, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueWriteBuffer ( cl_command_queue command_queue, cl_mem buffer, cl_bool blocking_write, size_t offset, size_t cb, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueCopyBuffer ( cl_command_queue command_queue, cl_mem src_buffer, cl_mem dst_buffer, size_t src_offset, size_t dst_offset, size_t cb, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueReadImage ( cl_command_queue command_queue, cl_mem image, cl_bool blocking_read, size_t** origin, size_t** region, size_t row_pitch, size_t slice_pitch, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueWriteImage ( cl_command_queue command_queue, cl_mem image, cl_bool blocking_write, size_t** origin, size_t** region, size_t input_row_pitch, size_t input_slice_pitch, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueCopyImage ( cl_command_queue command_queue, cl_mem src_image, cl_mem dst_image, size_t** src_origin, size_t** dst_origin, size_t** region, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueCopyImageToBuffer ( cl_command_queue command_queue, cl_mem src_image, cl_mem dst_buffer, size_t** src_origin, size_t** region, size_t dst_offset, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueCopyBufferToImage ( cl_command_queue  command_queue, cl_mem src_buffer, cl_mem dst_image, size_t src_offset, size_t** dst_origin, size_t** region, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: void* clEnqueueMapBuffer ( cl_command_queue  command_queue, cl_mem buffer, cl_bool blocking_map, cl_map_flags map_flags, size_t offset, size_t cb, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event, cl_int* errcode_ret ) ;
FUNCTION: void* clEnqueueMapImage ( cl_command_queue command_queue, cl_mem image, cl_bool blocking_map, cl_map_flags map_flags, size_t** origin, size_t** region, size_t* image_row_pitch, size_t* image_slice_pitch, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event, cl_int* errcode_ret ) ;
FUNCTION: cl_int clEnqueueUnmapMemObject ( cl_command_queue  command_queue, cl_mem memobj, void* mapped_ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueNDRangeKernel ( cl_command_queue command_queue, cl_kernel kernel, cl_uint work_dim, size_t* global_work_offset, size_t* global_work_size, size_t* local_work_size, cl_uint num_events_in_wait_list, cl_event*  event_wait_list, cl_event* event ) ;
CALLBACK: void cl_enqueue_task_cb ( void* args ) ;
FUNCTION: cl_int clEnqueueTask ( cl_command_queue command_queue, cl_kernel kernel, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueNativeKernel ( cl_command_queue command_queue, cl_enqueue_task_cb user_func, void* args, size_t cb_args, cl_uint num_mem_objects, cl_mem* mem_list, void** args_mem_loc, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueMarker ( cl_command_queue command_queue, cl_event* event ) ;
FUNCTION: cl_int clEnqueueWaitForEvents ( cl_command_queue command_queue, cl_uint num_events, cl_event* event_list ) ;
FUNCTION: cl_int clEnqueueBarrier ( cl_command_queue command_queue ) ;
FUNCTION: void* clGetExtensionFunctionAddress ( char* func_name ) ;

! cl_ext.h
CONSTANT: CL_DEVICE_DOUBLE_FP_CONFIG HEX: 1032
CONSTANT: CL_DEVICE_HALF_FP_CONFIG   HEX: 1033

! cl_khr_icd.txt
CONSTANT: CL_PLATFORM_ICD_SUFFIX_KHR HEX: 0920
CONSTANT: CL_PLATFORM_NOT_FOUND_KHR  -1001

FUNCTION: cl_int clIcdGetPlatformIDsKHR ( cl_uint num_entries, cl_platform_id* platforms, cl_uint* num_platforms ) ;

! cl_gl.h
TYPEDEF: cl_uint cl_gl_object_type
TYPEDEF: cl_uint cl_gl_texture_info
TYPEDEF: cl_uint cl_gl_platform_info

CONSTANT: CL_GL_OBJECT_BUFFER             HEX: 2000
CONSTANT: CL_GL_OBJECT_TEXTURE2D          HEX: 2001
CONSTANT: CL_GL_OBJECT_TEXTURE3D          HEX: 2002
CONSTANT: CL_GL_OBJECT_RENDERBUFFER       HEX: 2003
CONSTANT: CL_GL_TEXTURE_TARGET            HEX: 2004
CONSTANT: CL_GL_MIPMAP_LEVEL              HEX: 2005

FUNCTION: cl_mem clCreateFromGLBuffer ( cl_context context, cl_mem_flags flags, cl_GLuint bufobj, int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromGLTexture2D ( cl_context context, cl_mem_flags flags, cl_GLenum target, cl_GLint miplevel, cl_GLuint texture, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromGLTexture3D ( cl_context context, cl_mem_flags flags, cl_GLenum target, cl_GLint miplevel, cl_GLuint texture, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromGLRenderbuffer ( cl_context context, cl_mem_flags flags, cl_GLuint renderbuffer, cl_int* errcode_ret ) ;
FUNCTION: cl_int clGetGLObjectInfo ( cl_mem memobj, cl_gl_object_type* gl_object_type, cl_GLuint* gl_object_name ) ;
FUNCTION: cl_int clGetGLTextureInfo ( cl_mem memobj, cl_gl_texture_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;
FUNCTION: cl_int clEnqueueAcquireGLObjects ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueReleaseGLObjects ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;

! cl_khr_gl_sharing.txt
TYPEDEF: cl_uint cl_gl_context_info

CONSTANT: CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR  -1000
CONSTANT: CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR    HEX: 2006
CONSTANT: CL_DEVICES_FOR_GL_CONTEXT_KHR           HEX: 2007
CONSTANT: CL_GL_CONTEXT_KHR                       HEX: 2008
CONSTANT: CL_EGL_DISPLAY_KHR                      HEX: 2009
CONSTANT: CL_GLX_DISPLAY_KHR                      HEX: 200A
CONSTANT: CL_WGL_HDC_KHR                          HEX: 200B
CONSTANT: CL_CGL_SHAREGROUP_KHR                   HEX: 200C

FUNCTION: cl_int clGetGLContextInfoKHR ( cl_context_properties* properties, cl_gl_context_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret ) ;

! cl_nv_d3d9_sharing.txt
CONSTANT: CL_D3D9_DEVICE_NV                     HEX: 4022
CONSTANT: CL_D3D9_ADAPTER_NAME_NV               HEX: 4023
CONSTANT: CL_PREFERRED_DEVICES_FOR_D3D9_NV      HEX: 4024
CONSTANT: CL_ALL_DEVICES_FOR_D3D9_NV            HEX: 4025
CONSTANT: CL_CONTEXT_D3D9_DEVICE_NV             HEX: 4026
CONSTANT: CL_MEM_D3D9_RESOURCE_NV               HEX: 4027
CONSTANT: CL_IMAGE_D3D9_FACE_NV                 HEX: 4028
CONSTANT: CL_IMAGE_D3D9_LEVEL_NV                HEX: 4029
CONSTANT: CL_COMMAND_ACQUIRE_D3D9_OBJECTS_NV    HEX: 402A
CONSTANT: CL_COMMAND_RELEASE_D3D9_OBJECTS_NV    HEX: 402B
CONSTANT: CL_INVALID_D3D9_DEVICE_NV             -1010
CONSTANT: CL_INVALID_D3D9_RESOURCE_NV           -1011
CONSTANT: CL_D3D9_RESOURCE_ALREADY_ACQUIRED_NV  -1012
CONSTANT: CL_D3D9_RESOURCE_NOT_ACQUIRED_NV      -1013

TYPEDEF: void* cl_d3d9_device_source_nv 
TYPEDEF: void* cl_d3d9_device_set_nv 

FUNCTION: cl_int clGetDeviceIDsFromD3D9NV ( cl_platform_id platform, cl_d3d9_device_source_nv d3d_device_source, void* d3d_object, cl_d3d9_device_set_nv d3d_device_set, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices ) ;
FUNCTION: cl_mem clCreateFromD3D9VertexBufferNV ( cl_context context, cl_mem_flags flags, void* id3dvb9_resource, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D9IndexBufferNV ( cl_context context, cl_mem_flags flags, void* id3dib9_resource, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D9SurfaceNV ( cl_context context, cl_mem_flags flags, void* id3dsurface9_resource, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D9TextureNV ( cl_context context, cl_mem_flags flags, void* id3dtexture9_resource, uint miplevel, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D9CubeTextureNV ( cl_context context, cl_mem_flags flags, void* id3dct9_resource, int facetype, uint miplevel, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D9VolumeTextureNV ( cl_context context, cl_mem_flags flags, void* id3dvt9-resource, uint miplevel, cl_int* errcode_ret ) ;
FUNCTION: cl_int clEnqueueAcquireD3D9ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueReleaseD3D9ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;

! cl_nv_d3d10_sharing.txt
CONSTANT: CL_D3D10_DEVICE_NV                     HEX: 4010
CONSTANT: CL_D3D10_DXGI_ADAPTER_NV               HEX: 4011
CONSTANT: CL_PREFERRED_DEVICES_FOR_D3D10_NV      HEX: 4012
CONSTANT: CL_ALL_DEVICES_FOR_D3D10_NV            HEX: 4013
CONSTANT: CL_CONTEXT_D3D10_DEVICE_NV             HEX: 4014
CONSTANT: CL_MEM_D3D10_RESOURCE_NV               HEX: 4015
CONSTANT: CL_IMAGE_D3D10_SUBRESOURCE_NV          HEX: 4016
CONSTANT: CL_COMMAND_ACQUIRE_D3D10_OBJECTS_NV    HEX: 4017
CONSTANT: CL_COMMAND_RELEASE_D3D10_OBJECTS_NV    HEX: 4018
CONSTANT: CL_INVALID_D3D10_DEVICE_NV             -1002
CONSTANT: CL_INVALID_D3D10_RESOURCE_NV           -1003
CONSTANT: CL_D3D10_RESOURCE_ALREADY_ACQUIRED_NV  -1004
CONSTANT: CL_D3D10_RESOURCE_NOT_ACQUIRED_NV      -1005

TYPEDEF: void* cl_d3d10_device_source_nv 
TYPEDEF: void* cl_d3d10_device_set_nv 

FUNCTION: cl_int clGetDeviceIDsFromD3D10NV ( cl_platform_id platform, cl_d3d10_device_source_nv d3d_device_source, void* d3d_object, cl_d3d10_device_set_nv d3d_device_set, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices ) ;
FUNCTION: cl_mem clCreateFromD3D10BufferNV ( cl_context context, cl_mem_flags flags, void* id3d10buffer_resource, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D10Texture2DNV ( cl_context context, cl_mem_flags flags, void* id3d10texture2d_resource, uint subresource, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D10Texture3DNV ( cl_context context, cl_mem_flags flags, void* id3d10texture3d_resource, uint subresource, cl_int* errcode_ret ) ;
FUNCTION: cl_int clEnqueueAcquireD3D10ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueReleaseD3D10ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;

! cl_nv_d3d11_sharing.txt
CONSTANT: CL_D3D11_DEVICE_NV                     HEX: 4019
CONSTANT: CL_D3D11_DXGI_ADAPTER_NV               HEX: 401A
CONSTANT: CL_PREFERRED_DEVICES_FOR_D3D11_NV      HEX: 401B
CONSTANT: CL_ALL_DEVICES_FOR_D3D11_NV            HEX: 401C
CONSTANT: CL_CONTEXT_D3D11_DEVICE_NV             HEX: 401D
CONSTANT: CL_MEM_D3D11_RESOURCE_NV               HEX: 401E
CONSTANT: CL_IMAGE_D3D11_SUBRESOURCE_NV          HEX: 401F
CONSTANT: CL_COMMAND_ACQUIRE_D3D11_OBJECTS_NV    HEX: 4020
CONSTANT: CL_COMMAND_RELEASE_D3D11_OBJECTS_NV    HEX: 4021
CONSTANT: CL_INVALID_D3D11_DEVICE_NV             -1006
CONSTANT: CL_INVALID_D3D11_RESOURCE_NV           -1007
CONSTANT: CL_D3D11_RESOURCE_ALREADY_ACQUIRED_NV  -1008
CONSTANT: CL_D3D11_RESOURCE_NOT_ACQUIRED_NV      -1009

TYPEDEF: void* cl_d3d11_device_source_nv 
TYPEDEF: void* cl_d3d11_device_set_nv 

FUNCTION: cl_int clGetDeviceIDsFromD3D11NV ( cl_platform_id platform, cl_d3d11_device_source_nv d3d_device_source, void* d3d_object, cl_d3d11_device_set_nv d3d_device_set, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices ) ;
FUNCTION: cl_mem clCreateFromD3D11BufferNV ( cl_context context, cl_mem_flags flags, void* id3d11buffer_resource, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D11Texture2DNV ( cl_context context, cl_mem_flags flags, void* id3d11texture2d_resource, uint subresource, cl_int* errcode_ret ) ;
FUNCTION: cl_mem clCreateFromD3D11Texture3DNV ( cl_context context, cl_mem_flags flags, void* id3dtexture3d_resource, uint subresource, cl_int* errcode_ret ) ;
FUNCTION: cl_int clEnqueueAcquireD3D11ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;
FUNCTION: cl_int clEnqueueReleaseD3D11ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event ) ;

! Utility words needed for working with the API
: *size_t ( c-ptr -- value )
    size_t heap-size {
        { 4 [ 0 alien-unsigned-4 ] }
        { 8 [ 0 alien-unsigned-8 ] }
    } case ; inline

: <size_t> ( value -- c-ptr )
    size_t heap-size [ (byte-array) ] keep {
        { 4 [ [ 0 set-alien-unsigned-4 ] keep ] }
        { 8 [ [ 0 set-alien-unsigned-8 ] keep ] }
    } case ; inline
