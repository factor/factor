! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
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
CONSTANT: CL_UINT_MAX         0xffffffff
CONSTANT: CL_LONG_MAX         0x7FFFFFFFFFFFFFFF
CONSTANT: CL_LONG_MIN         0x8000000000000000
CONSTANT: CL_ULONG_MAX        0xFFFFFFFFFFFFFFFF

CONSTANT: CL_FLT_DIG          6
CONSTANT: CL_FLT_MANT_DIG     24
CONSTANT: CL_FLT_MAX_10_EXP   38
CONSTANT: CL_FLT_MAX_EXP      128
CONSTANT: CL_FLT_MIN_10_EXP   -37
CONSTANT: CL_FLT_MIN_EXP      -125
CONSTANT: CL_FLT_RADIX        2
CONSTANT: CL_FLT_MAX          340282346638528859811704183484516925440.0
CONSTANT: CL_FLT_MIN          1.175494350822287507969e-38
CONSTANT: CL_FLT_EPSILON      0x1.0p-23

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

CONSTANT: CL_PLATFORM_PROFILE                         0x0900
CONSTANT: CL_PLATFORM_VERSION                         0x0901
CONSTANT: CL_PLATFORM_NAME                            0x0902
CONSTANT: CL_PLATFORM_VENDOR                          0x0903
CONSTANT: CL_PLATFORM_EXTENSIONS                      0x0904

CONSTANT: CL_DEVICE_TYPE_DEFAULT                      1
CONSTANT: CL_DEVICE_TYPE_CPU                          2
CONSTANT: CL_DEVICE_TYPE_GPU                          4
CONSTANT: CL_DEVICE_TYPE_ACCELERATOR                  8
CONSTANT: CL_DEVICE_TYPE_ALL                          0xFFFFFFFF

CONSTANT: CL_DEVICE_TYPE                              0x1000
CONSTANT: CL_DEVICE_VENDOR_ID                         0x1001
CONSTANT: CL_DEVICE_MAX_COMPUTE_UNITS                 0x1002
CONSTANT: CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS          0x1003
CONSTANT: CL_DEVICE_MAX_WORK_GROUP_SIZE               0x1004
CONSTANT: CL_DEVICE_MAX_WORK_ITEM_SIZES               0x1005
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR       0x1006
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT      0x1007
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT        0x1008
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG       0x1009
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT      0x100A
CONSTANT: CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE     0x100B
CONSTANT: CL_DEVICE_MAX_CLOCK_FREQUENCY               0x100C
CONSTANT: CL_DEVICE_ADDRESS_BITS                      0x100D
CONSTANT: CL_DEVICE_MAX_READ_IMAGE_ARGS               0x100E
CONSTANT: CL_DEVICE_MAX_WRITE_IMAGE_ARGS              0x100F
CONSTANT: CL_DEVICE_MAX_MEM_ALLOC_SIZE                0x1010
CONSTANT: CL_DEVICE_IMAGE2D_MAX_WIDTH                 0x1011
CONSTANT: CL_DEVICE_IMAGE2D_MAX_HEIGHT                0x1012
CONSTANT: CL_DEVICE_IMAGE3D_MAX_WIDTH                 0x1013
CONSTANT: CL_DEVICE_IMAGE3D_MAX_HEIGHT                0x1014
CONSTANT: CL_DEVICE_IMAGE3D_MAX_DEPTH                 0x1015
CONSTANT: CL_DEVICE_IMAGE_SUPPORT                     0x1016
CONSTANT: CL_DEVICE_MAX_PARAMETER_SIZE                0x1017
CONSTANT: CL_DEVICE_MAX_SAMPLERS                      0x1018
CONSTANT: CL_DEVICE_MEM_BASE_ADDR_ALIGN               0x1019
CONSTANT: CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE          0x101A
CONSTANT: CL_DEVICE_SINGLE_FP_CONFIG                  0x101B
CONSTANT: CL_DEVICE_GLOBAL_MEM_CACHE_TYPE             0x101C
CONSTANT: CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE         0x101D
CONSTANT: CL_DEVICE_GLOBAL_MEM_CACHE_SIZE             0x101E
CONSTANT: CL_DEVICE_GLOBAL_MEM_SIZE                   0x101F
CONSTANT: CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE          0x1020
CONSTANT: CL_DEVICE_MAX_CONSTANT_ARGS                 0x1021
CONSTANT: CL_DEVICE_LOCAL_MEM_TYPE                    0x1022
CONSTANT: CL_DEVICE_LOCAL_MEM_SIZE                    0x1023
CONSTANT: CL_DEVICE_ERROR_CORRECTION_SUPPORT          0x1024
CONSTANT: CL_DEVICE_PROFILING_TIMER_RESOLUTION        0x1025
CONSTANT: CL_DEVICE_ENDIAN_LITTLE                     0x1026
CONSTANT: CL_DEVICE_AVAILABLE                         0x1027
CONSTANT: CL_DEVICE_COMPILER_AVAILABLE                0x1028
CONSTANT: CL_DEVICE_EXECUTION_CAPABILITIES            0x1029
CONSTANT: CL_DEVICE_QUEUE_PROPERTIES                  0x102A
CONSTANT: CL_DEVICE_NAME                              0x102B
CONSTANT: CL_DEVICE_VENDOR                            0x102C
CONSTANT: CL_DRIVER_VERSION                           0x102D
CONSTANT: CL_DEVICE_PROFILE                           0x102E
CONSTANT: CL_DEVICE_VERSION                           0x102F
CONSTANT: CL_DEVICE_EXTENSIONS                        0x1030
CONSTANT: CL_DEVICE_PLATFORM                          0x1031

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

CONSTANT: CL_CONTEXT_REFERENCE_COUNT                  0x1080
CONSTANT: CL_CONTEXT_DEVICES                          0x1081
CONSTANT: CL_CONTEXT_PROPERTIES                       0x1082

CONSTANT: CL_CONTEXT_PLATFORM                         0x1084

CONSTANT: CL_QUEUE_CONTEXT                            0x1090
CONSTANT: CL_QUEUE_DEVICE                             0x1091
CONSTANT: CL_QUEUE_REFERENCE_COUNT                    0x1092
CONSTANT: CL_QUEUE_PROPERTIES                         0x1093

CONSTANT: CL_MEM_READ_WRITE                           1
CONSTANT: CL_MEM_WRITE_ONLY                           2
CONSTANT: CL_MEM_READ_ONLY                            4
CONSTANT: CL_MEM_USE_HOST_PTR                         8
CONSTANT: CL_MEM_ALLOC_HOST_PTR                       16
CONSTANT: CL_MEM_COPY_HOST_PTR                        32

CONSTANT: CL_R                                        0x10B0
CONSTANT: CL_A                                        0x10B1
CONSTANT: CL_RG                                       0x10B2
CONSTANT: CL_RA                                       0x10B3
CONSTANT: CL_RGB                                      0x10B4
CONSTANT: CL_RGBA                                     0x10B5
CONSTANT: CL_BGRA                                     0x10B6
CONSTANT: CL_ARGB                                     0x10B7
CONSTANT: CL_INTENSITY                                0x10B8
CONSTANT: CL_LUMINANCE                                0x10B9

CONSTANT: CL_SNORM_INT8                               0x10D0
CONSTANT: CL_SNORM_INT16                              0x10D1
CONSTANT: CL_UNORM_INT8                               0x10D2
CONSTANT: CL_UNORM_INT16                              0x10D3
CONSTANT: CL_UNORM_SHORT_565                          0x10D4
CONSTANT: CL_UNORM_SHORT_555                          0x10D5
CONSTANT: CL_UNORM_INT_101010                         0x10D6
CONSTANT: CL_SIGNED_INT8                              0x10D7
CONSTANT: CL_SIGNED_INT16                             0x10D8
CONSTANT: CL_SIGNED_INT32                             0x10D9
CONSTANT: CL_UNSIGNED_INT8                            0x10DA
CONSTANT: CL_UNSIGNED_INT16                           0x10DB
CONSTANT: CL_UNSIGNED_INT32                           0x10DC
CONSTANT: CL_HALF_FLOAT                               0x10DD
CONSTANT: CL_FLOAT                                    0x10DE

CONSTANT: CL_MEM_OBJECT_BUFFER                        0x10F0
CONSTANT: CL_MEM_OBJECT_IMAGE2D                       0x10F1
CONSTANT: CL_MEM_OBJECT_IMAGE3D                       0x10F2

CONSTANT: CL_MEM_TYPE                                 0x1100
CONSTANT: CL_MEM_FLAGS                                0x1101
CONSTANT: CL_MEM_SIZE                                 0x1102
CONSTANT: CL_MEM_HOST_PTR                             0x1103
CONSTANT: CL_MEM_MAP_COUNT                            0x1104
CONSTANT: CL_MEM_REFERENCE_COUNT                      0x1105
CONSTANT: CL_MEM_CONTEXT                              0x1106

CONSTANT: CL_IMAGE_FORMAT                             0x1110
CONSTANT: CL_IMAGE_ELEMENT_SIZE                       0x1111
CONSTANT: CL_IMAGE_ROW_PITCH                          0x1112
CONSTANT: CL_IMAGE_SLICE_PITCH                        0x1113
CONSTANT: CL_IMAGE_WIDTH                              0x1114
CONSTANT: CL_IMAGE_HEIGHT                             0x1115
CONSTANT: CL_IMAGE_DEPTH                              0x1116

CONSTANT: CL_ADDRESS_NONE                             0x1130
CONSTANT: CL_ADDRESS_CLAMP_TO_EDGE                    0x1131
CONSTANT: CL_ADDRESS_CLAMP                            0x1132
CONSTANT: CL_ADDRESS_REPEAT                           0x1133

CONSTANT: CL_FILTER_NEAREST                           0x1140
CONSTANT: CL_FILTER_LINEAR                            0x1141

CONSTANT: CL_SAMPLER_REFERENCE_COUNT                  0x1150
CONSTANT: CL_SAMPLER_CONTEXT                          0x1151
CONSTANT: CL_SAMPLER_NORMALIZED_COORDS                0x1152
CONSTANT: CL_SAMPLER_ADDRESSING_MODE                  0x1153
CONSTANT: CL_SAMPLER_FILTER_MODE                      0x1154

CONSTANT: CL_MAP_READ                                 1
CONSTANT: CL_MAP_WRITE                                2

CONSTANT: CL_PROGRAM_REFERENCE_COUNT                  0x1160
CONSTANT: CL_PROGRAM_CONTEXT                          0x1161
CONSTANT: CL_PROGRAM_NUM_DEVICES                      0x1162
CONSTANT: CL_PROGRAM_DEVICES                          0x1163
CONSTANT: CL_PROGRAM_SOURCE                           0x1164
CONSTANT: CL_PROGRAM_BINARY_SIZES                     0x1165
CONSTANT: CL_PROGRAM_BINARIES                         0x1166

CONSTANT: CL_PROGRAM_BUILD_STATUS                     0x1181
CONSTANT: CL_PROGRAM_BUILD_OPTIONS                    0x1182
CONSTANT: CL_PROGRAM_BUILD_LOG                        0x1183

CONSTANT: CL_BUILD_SUCCESS                            0
CONSTANT: CL_BUILD_NONE                               -1
CONSTANT: CL_BUILD_ERROR                              -2
CONSTANT: CL_BUILD_IN_PROGRESS                        -3

CONSTANT: CL_KERNEL_FUNCTION_NAME                     0x1190
CONSTANT: CL_KERNEL_NUM_ARGS                          0x1191
CONSTANT: CL_KERNEL_REFERENCE_COUNT                   0x1192
CONSTANT: CL_KERNEL_CONTEXT                           0x1193
CONSTANT: CL_KERNEL_PROGRAM                           0x1194

CONSTANT: CL_KERNEL_WORK_GROUP_SIZE                   0x11B0
CONSTANT: CL_KERNEL_COMPILE_WORK_GROUP_SIZE           0x11B1
CONSTANT: CL_KERNEL_LOCAL_MEM_SIZE                    0x11B2

CONSTANT: CL_EVENT_COMMAND_QUEUE                      0x11D0
CONSTANT: CL_EVENT_COMMAND_TYPE                       0x11D1
CONSTANT: CL_EVENT_REFERENCE_COUNT                    0x11D2
CONSTANT: CL_EVENT_COMMAND_EXECUTION_STATUS           0x11D3

CONSTANT: CL_COMMAND_NDRANGE_KERNEL                   0x11F0
CONSTANT: CL_COMMAND_TASK                             0x11F1
CONSTANT: CL_COMMAND_NATIVE_KERNEL                    0x11F2
CONSTANT: CL_COMMAND_READ_BUFFER                      0x11F3
CONSTANT: CL_COMMAND_WRITE_BUFFER                     0x11F4
CONSTANT: CL_COMMAND_COPY_BUFFER                      0x11F5
CONSTANT: CL_COMMAND_READ_IMAGE                       0x11F6
CONSTANT: CL_COMMAND_WRITE_IMAGE                      0x11F7
CONSTANT: CL_COMMAND_COPY_IMAGE                       0x11F8
CONSTANT: CL_COMMAND_COPY_IMAGE_TO_BUFFER             0x11F9
CONSTANT: CL_COMMAND_COPY_BUFFER_TO_IMAGE             0x11FA
CONSTANT: CL_COMMAND_MAP_BUFFER                       0x11FB
CONSTANT: CL_COMMAND_MAP_IMAGE                        0x11FC
CONSTANT: CL_COMMAND_UNMAP_MEM_OBJECT                 0x11FD
CONSTANT: CL_COMMAND_MARKER                           0x11FE
CONSTANT: CL_COMMAND_ACQUIRE_GL_OBJECTS               0x11FF
CONSTANT: CL_COMMAND_RELEASE_GL_OBJECTS               0x1200

CONSTANT: CL_COMPLETE                                 0x0
CONSTANT: CL_RUNNING                                  0x1
CONSTANT: CL_SUBMITTED                                0x2
CONSTANT: CL_QUEUED                                   0x3

CONSTANT: CL_PROFILING_COMMAND_QUEUED                 0x1280
CONSTANT: CL_PROFILING_COMMAND_SUBMIT                 0x1281
CONSTANT: CL_PROFILING_COMMAND_START                  0x1282
CONSTANT: CL_PROFILING_COMMAND_END                    0x1283

FUNCTION: cl_int clGetPlatformIDs ( cl_uint num_entries, cl_platform_id* platforms, cl_uint* num_platforms )
FUNCTION: cl_int clGetPlatformInfo ( cl_platform_id platform, cl_platform_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clGetDeviceIDs ( cl_platform_id platform, cl_device_type device_type, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices )
FUNCTION: cl_int clGetDeviceInfo ( cl_device_id device, cl_device_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
CALLBACK: void cl_create_context_cb ( char* a, void* b, size_t s, void* c )
FUNCTION: cl_context clCreateContext ( cl_context_properties* properties, cl_uint num_devices, cl_device_id* devices, cl_create_context_cb pfn_notify, void* user_data, cl_int* errcode_ret )
FUNCTION: cl_context clCreateContextFromType ( cl_context_properties* properties, cl_device_type device_type, cl_create_context_cb pfn_notify, void* user_data, cl_int* errcode_ret )
FUNCTION: cl_int clRetainContext ( cl_context context )
FUNCTION: cl_int clReleaseContext ( cl_context context )
FUNCTION: cl_int clGetContextInfo ( cl_context context, cl_context_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_command_queue clCreateCommandQueue ( cl_context context, cl_device_id device, cl_command_queue_properties properties, cl_int* errcode_ret )
FUNCTION: cl_int clRetainCommandQueue ( cl_command_queue command_queue )
FUNCTION: cl_int clReleaseCommandQueue ( cl_command_queue command_queue )
FUNCTION: cl_int clGetCommandQueueInfo ( cl_command_queue command_queue, cl_command_queue_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clSetCommandQueueProperty ( cl_command_queue command_queue, cl_command_queue_properties properties, cl_bool enable, cl_command_queue_properties* old_properties )
FUNCTION: cl_mem clCreateBuffer ( cl_context context, cl_mem_flags flags, size_t size, void* host_ptr, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateImage2D ( cl_context context, cl_mem_flags flags, cl_image_format* image_format, size_t image_width, size_t image_height, size_t image_row_pitch, void* host_ptr, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateImage3D ( cl_context context, cl_mem_flags flags, cl_image_format* image_format, size_t image_width, size_t image_height, size_t image_depth, size_t image_row_pitch, size_t image_slice_pitch, void* host_ptr, cl_int* errcode_ret )
FUNCTION: cl_int clRetainMemObject ( cl_mem memobj )
FUNCTION: cl_int clReleaseMemObject ( cl_mem memobj )
FUNCTION: cl_int clGetSupportedImageFormats ( cl_context context, cl_mem_flags flags, cl_mem_object_type image_type, cl_uint num_entries, cl_image_format* image_formats, cl_uint* num_image_formats )
FUNCTION: cl_int clGetMemObjectInfo ( cl_mem memobj, cl_mem_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clGetImageInfo ( cl_mem image, cl_image_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_sampler clCreateSampler ( cl_context context, cl_bool normalized_coords, cl_addressing_mode addressing_mode, cl_filter_mode filter_mode, cl_int* errcode_ret )
FUNCTION: cl_int clRetainSampler ( cl_sampler sampler )
FUNCTION: cl_int clReleaseSampler ( cl_sampler sampler )
FUNCTION: cl_int clGetSamplerInfo ( cl_sampler sampler, cl_sampler_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_program clCreateProgramWithSource ( cl_context context, cl_uint count, char** strings, size_t* lengths, cl_int* errcode_ret )
FUNCTION: cl_program clCreateProgramWithBinary ( cl_context context, cl_uint num_devices, cl_device_id* device_list, size_t* lengths, char** binaries, cl_int* binary_status, cl_int* errcode_ret )
FUNCTION: cl_int clRetainProgram ( cl_program program )
FUNCTION: cl_int clReleaseProgram ( cl_program program )
CALLBACK: void cl_build_program_cb ( cl_program program, void* user_data )
FUNCTION: cl_int clBuildProgram ( cl_program program, cl_uint num_devices, cl_device_id* device_list, char* options, cl_build_program_cb pfn_notify, void* user_data )
FUNCTION: cl_int clUnloadCompiler ( )
FUNCTION: cl_int clGetProgramInfo ( cl_program program, cl_program_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clGetProgramBuildInfo ( cl_program program, cl_device_id device, cl_program_build_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_kernel clCreateKernel ( cl_program program, char* kernel_name, cl_int* errcode_ret )
FUNCTION: cl_int clCreateKernelsInProgram ( cl_program program, cl_uint num_kernels, cl_kernel* kernels, cl_uint* num_kernels_ret )
FUNCTION: cl_int clRetainKernel ( cl_kernel kernel )
FUNCTION: cl_int clReleaseKernel ( cl_kernel kernel )
FUNCTION: cl_int clSetKernelArg ( cl_kernel kernel, cl_uint arg_index, size_t arg_size, void* arg_value )
FUNCTION: cl_int clGetKernelInfo ( cl_kernel kernel, cl_kernel_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clGetKernelWorkGroupInfo ( cl_kernel kernel, cl_device_id device, cl_kernel_work_group_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clWaitForEvents ( cl_uint num_events, cl_event* event_list )
FUNCTION: cl_int clGetEventInfo ( cl_event event, cl_event_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clRetainEvent ( cl_event event )
FUNCTION: cl_int clReleaseEvent ( cl_event event )
FUNCTION: cl_int clGetEventProfilingInfo ( cl_event event, cl_profiling_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clFlush ( cl_command_queue command_queue )
FUNCTION: cl_int clFinish ( cl_command_queue command_queue )
FUNCTION: cl_int clEnqueueReadBuffer ( cl_command_queue command_queue, cl_mem buffer, cl_bool blocking_read, size_t offset, size_t cb, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueWriteBuffer ( cl_command_queue command_queue, cl_mem buffer, cl_bool blocking_write, size_t offset, size_t cb, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueCopyBuffer ( cl_command_queue command_queue, cl_mem src_buffer, cl_mem dst_buffer, size_t src_offset, size_t dst_offset, size_t cb, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueReadImage ( cl_command_queue command_queue, cl_mem image, cl_bool blocking_read, size_t** origin, size_t** region, size_t row_pitch, size_t slice_pitch, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueWriteImage ( cl_command_queue command_queue, cl_mem image, cl_bool blocking_write, size_t** origin, size_t** region, size_t input_row_pitch, size_t input_slice_pitch, void* ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueCopyImage ( cl_command_queue command_queue, cl_mem src_image, cl_mem dst_image, size_t** src_origin, size_t** dst_origin, size_t** region, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueCopyImageToBuffer ( cl_command_queue command_queue, cl_mem src_image, cl_mem dst_buffer, size_t** src_origin, size_t** region, size_t dst_offset, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueCopyBufferToImage ( cl_command_queue command_queue, cl_mem src_buffer, cl_mem dst_image, size_t src_offset, size_t** dst_origin, size_t** region, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: void* clEnqueueMapBuffer ( cl_command_queue command_queue, cl_mem buffer, cl_bool blocking_map, cl_map_flags map_flags, size_t offset, size_t cb, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event, cl_int* errcode_ret )
FUNCTION: void* clEnqueueMapImage ( cl_command_queue command_queue, cl_mem image, cl_bool blocking_map, cl_map_flags map_flags, size_t** origin, size_t** region, size_t* image_row_pitch, size_t* image_slice_pitch, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event, cl_int* errcode_ret )
FUNCTION: cl_int clEnqueueUnmapMemObject ( cl_command_queue command_queue, cl_mem memobj, void* mapped_ptr, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueNDRangeKernel ( cl_command_queue command_queue, cl_kernel kernel, cl_uint work_dim, size_t* global_work_offset, size_t* global_work_size, size_t* local_work_size, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
CALLBACK: void cl_enqueue_task_cb ( void* args )
FUNCTION: cl_int clEnqueueTask ( cl_command_queue command_queue, cl_kernel kernel, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueNativeKernel ( cl_command_queue command_queue, cl_enqueue_task_cb user_func, void* args, size_t cb_args, cl_uint num_mem_objects, cl_mem* mem_list, void** args_mem_loc, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueMarker ( cl_command_queue command_queue, cl_event* event )
FUNCTION: cl_int clEnqueueWaitForEvents ( cl_command_queue command_queue, cl_uint num_events, cl_event* event_list )
FUNCTION: cl_int clEnqueueBarrier ( cl_command_queue command_queue )
FUNCTION: void* clGetExtensionFunctionAddress ( char* func_name )

! cl_ext.h
CONSTANT: CL_DEVICE_DOUBLE_FP_CONFIG 0x1032
CONSTANT: CL_DEVICE_HALF_FP_CONFIG   0x1033

! cl_khr_icd.txt
CONSTANT: CL_PLATFORM_ICD_SUFFIX_KHR 0x0920
CONSTANT: CL_PLATFORM_NOT_FOUND_KHR  -1001

FUNCTION: cl_int clIcdGetPlatformIDsKHR ( cl_uint num_entries, cl_platform_id* platforms, cl_uint* num_platforms )

! cl_gl.h
TYPEDEF: cl_uint cl_gl_object_type
TYPEDEF: cl_uint cl_gl_texture_info
TYPEDEF: cl_uint cl_gl_platform_info

CONSTANT: CL_GL_OBJECT_BUFFER             0x2000
CONSTANT: CL_GL_OBJECT_TEXTURE2D          0x2001
CONSTANT: CL_GL_OBJECT_TEXTURE3D          0x2002
CONSTANT: CL_GL_OBJECT_RENDERBUFFER       0x2003
CONSTANT: CL_GL_TEXTURE_TARGET            0x2004
CONSTANT: CL_GL_MIPMAP_LEVEL              0x2005

FUNCTION: cl_mem clCreateFromGLBuffer ( cl_context context, cl_mem_flags flags, cl_GLuint bufobj, int* errcode_ret )
FUNCTION: cl_mem clCreateFromGLTexture2D ( cl_context context, cl_mem_flags flags, cl_GLenum target, cl_GLint miplevel, cl_GLuint texture, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromGLTexture3D ( cl_context context, cl_mem_flags flags, cl_GLenum target, cl_GLint miplevel, cl_GLuint texture, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromGLRenderbuffer ( cl_context context, cl_mem_flags flags, cl_GLuint renderbuffer, cl_int* errcode_ret )
FUNCTION: cl_int clGetGLObjectInfo ( cl_mem memobj, cl_gl_object_type* gl_object_type, cl_GLuint* gl_object_name )
FUNCTION: cl_int clGetGLTextureInfo ( cl_mem memobj, cl_gl_texture_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )
FUNCTION: cl_int clEnqueueAcquireGLObjects ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueReleaseGLObjects ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )

! cl_khr_gl_sharing.txt
TYPEDEF: cl_uint cl_gl_context_info

CONSTANT: CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR  -1000
CONSTANT: CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR    0x2006
CONSTANT: CL_DEVICES_FOR_GL_CONTEXT_KHR           0x2007
CONSTANT: CL_GL_CONTEXT_KHR                       0x2008
CONSTANT: CL_EGL_DISPLAY_KHR                      0x2009
CONSTANT: CL_GLX_DISPLAY_KHR                      0x200A
CONSTANT: CL_WGL_HDC_KHR                          0x200B
CONSTANT: CL_CGL_SHAREGROUP_KHR                   0x200C

FUNCTION: cl_int clGetGLContextInfoKHR ( cl_context_properties* properties, cl_gl_context_info param_name, size_t param_value_size, void* param_value, size_t* param_value_size_ret )

! cl_nv_d3d9_sharing.txt
CONSTANT: CL_D3D9_DEVICE_NV                     0x4022
CONSTANT: CL_D3D9_ADAPTER_NAME_NV               0x4023
CONSTANT: CL_PREFERRED_DEVICES_FOR_D3D9_NV      0x4024
CONSTANT: CL_ALL_DEVICES_FOR_D3D9_NV            0x4025
CONSTANT: CL_CONTEXT_D3D9_DEVICE_NV             0x4026
CONSTANT: CL_MEM_D3D9_RESOURCE_NV               0x4027
CONSTANT: CL_IMAGE_D3D9_FACE_NV                 0x4028
CONSTANT: CL_IMAGE_D3D9_LEVEL_NV                0x4029
CONSTANT: CL_COMMAND_ACQUIRE_D3D9_OBJECTS_NV    0x402A
CONSTANT: CL_COMMAND_RELEASE_D3D9_OBJECTS_NV    0x402B
CONSTANT: CL_INVALID_D3D9_DEVICE_NV             -1010
CONSTANT: CL_INVALID_D3D9_RESOURCE_NV           -1011
CONSTANT: CL_D3D9_RESOURCE_ALREADY_ACQUIRED_NV  -1012
CONSTANT: CL_D3D9_RESOURCE_NOT_ACQUIRED_NV      -1013

TYPEDEF: void* cl_d3d9_device_source_nv
TYPEDEF: void* cl_d3d9_device_set_nv

FUNCTION: cl_int clGetDeviceIDsFromD3D9NV ( cl_platform_id platform, cl_d3d9_device_source_nv d3d_device_source, void* d3d_object, cl_d3d9_device_set_nv d3d_device_set, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices )
FUNCTION: cl_mem clCreateFromD3D9VertexBufferNV ( cl_context context, cl_mem_flags flags, void* id3dvb9_resource, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D9IndexBufferNV ( cl_context context, cl_mem_flags flags, void* id3dib9_resource, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D9SurfaceNV ( cl_context context, cl_mem_flags flags, void* id3dsurface9_resource, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D9TextureNV ( cl_context context, cl_mem_flags flags, void* id3dtexture9_resource, uint miplevel, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D9CubeTextureNV ( cl_context context, cl_mem_flags flags, void* id3dct9_resource, int facetype, uint miplevel, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D9VolumeTextureNV ( cl_context context, cl_mem_flags flags, void* id3dvt9-resource, uint miplevel, cl_int* errcode_ret )
FUNCTION: cl_int clEnqueueAcquireD3D9ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueReleaseD3D9ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )

! cl_nv_d3d10_sharing.txt
CONSTANT: CL_D3D10_DEVICE_NV                     0x4010
CONSTANT: CL_D3D10_DXGI_ADAPTER_NV               0x4011
CONSTANT: CL_PREFERRED_DEVICES_FOR_D3D10_NV      0x4012
CONSTANT: CL_ALL_DEVICES_FOR_D3D10_NV            0x4013
CONSTANT: CL_CONTEXT_D3D10_DEVICE_NV             0x4014
CONSTANT: CL_MEM_D3D10_RESOURCE_NV               0x4015
CONSTANT: CL_IMAGE_D3D10_SUBRESOURCE_NV          0x4016
CONSTANT: CL_COMMAND_ACQUIRE_D3D10_OBJECTS_NV    0x4017
CONSTANT: CL_COMMAND_RELEASE_D3D10_OBJECTS_NV    0x4018
CONSTANT: CL_INVALID_D3D10_DEVICE_NV             -1002
CONSTANT: CL_INVALID_D3D10_RESOURCE_NV           -1003
CONSTANT: CL_D3D10_RESOURCE_ALREADY_ACQUIRED_NV  -1004
CONSTANT: CL_D3D10_RESOURCE_NOT_ACQUIRED_NV      -1005

TYPEDEF: void* cl_d3d10_device_source_nv
TYPEDEF: void* cl_d3d10_device_set_nv

FUNCTION: cl_int clGetDeviceIDsFromD3D10NV ( cl_platform_id platform, cl_d3d10_device_source_nv d3d_device_source, void* d3d_object, cl_d3d10_device_set_nv d3d_device_set, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices )
FUNCTION: cl_mem clCreateFromD3D10BufferNV ( cl_context context, cl_mem_flags flags, void* id3d10buffer_resource, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D10Texture2DNV ( cl_context context, cl_mem_flags flags, void* id3d10texture2d_resource, uint subresource, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D10Texture3DNV ( cl_context context, cl_mem_flags flags, void* id3d10texture3d_resource, uint subresource, cl_int* errcode_ret )
FUNCTION: cl_int clEnqueueAcquireD3D10ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueReleaseD3D10ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )

! cl_nv_d3d11_sharing.txt
CONSTANT: CL_D3D11_DEVICE_NV                     0x4019
CONSTANT: CL_D3D11_DXGI_ADAPTER_NV               0x401A
CONSTANT: CL_PREFERRED_DEVICES_FOR_D3D11_NV      0x401B
CONSTANT: CL_ALL_DEVICES_FOR_D3D11_NV            0x401C
CONSTANT: CL_CONTEXT_D3D11_DEVICE_NV             0x401D
CONSTANT: CL_MEM_D3D11_RESOURCE_NV               0x401E
CONSTANT: CL_IMAGE_D3D11_SUBRESOURCE_NV          0x401F
CONSTANT: CL_COMMAND_ACQUIRE_D3D11_OBJECTS_NV    0x4020
CONSTANT: CL_COMMAND_RELEASE_D3D11_OBJECTS_NV    0x4021
CONSTANT: CL_INVALID_D3D11_DEVICE_NV             -1006
CONSTANT: CL_INVALID_D3D11_RESOURCE_NV           -1007
CONSTANT: CL_D3D11_RESOURCE_ALREADY_ACQUIRED_NV  -1008
CONSTANT: CL_D3D11_RESOURCE_NOT_ACQUIRED_NV      -1009

TYPEDEF: void* cl_d3d11_device_source_nv
TYPEDEF: void* cl_d3d11_device_set_nv

FUNCTION: cl_int clGetDeviceIDsFromD3D11NV ( cl_platform_id platform, cl_d3d11_device_source_nv d3d_device_source, void* d3d_object, cl_d3d11_device_set_nv d3d_device_set, cl_uint num_entries, cl_device_id* devices, cl_uint* num_devices )
FUNCTION: cl_mem clCreateFromD3D11BufferNV ( cl_context context, cl_mem_flags flags, void* id3d11buffer_resource, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D11Texture2DNV ( cl_context context, cl_mem_flags flags, void* id3d11texture2d_resource, uint subresource, cl_int* errcode_ret )
FUNCTION: cl_mem clCreateFromD3D11Texture3DNV ( cl_context context, cl_mem_flags flags, void* id3dtexture3d_resource, uint subresource, cl_int* errcode_ret )
FUNCTION: cl_int clEnqueueAcquireD3D11ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
FUNCTION: cl_int clEnqueueReleaseD3D11ObjectsNV ( cl_command_queue command_queue, cl_uint num_objects, cl_mem* mem_objects, cl_uint num_events_in_wait_list, cl_event* event_wait_list, cl_event* event )
