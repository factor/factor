! Copyright (C) 2010 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct combinators kernel system ;
IN: cuda.ffi

<<
"cuda" {
    { [ os windows? ] [ "nvcuda.dll" stdcall ] }
    { [ os macosx? ] [ "/usr/local/cuda/lib/libcuda.dylib" cdecl ] }
    { [ os unix? ] [ "libcuda.so" cdecl ] }
} cond add-library
>>

LIBRARY: cuda

TYPEDEF: void* CUarray
TYPEDEF: void* CUcontext
TYPEDEF: int   CUdevice
TYPEDEF: ulonglong  CUdeviceptr
TYPEDEF: void* CUeglStreamConnection
TYPEDEF: void* CUevent
TYPEDEF: void* CUfunction
TYPEDEF: void* CUgraphicsResource
TYPEDEF: void* CUmipmappedArray
TYPEDEF: void* CUmodule
TYPEDEF: void* CUoccupancyB2DSize
TYPEDEF: void* CUstream
TYPEDEF: void* CUstreamCallback
TYPEDEF: void* CUsurfObject
TYPEDEF: void* CUsurfref
TYPEDEF: void* CUtexObject
TYPEDEF: void* CUtexref
TYPEDEF: void* CUlinkState
TYPEDEF: void* CUjitInputType

! versions of double and longlong that always 8-byte align

SYMBOLS: CUdouble CUlonglong CUulonglong ;

<<
: always-8-byte-align ( c-type -- c-type )
    8 >>align 8 >>align-first ;

longlong  lookup-c-type clone always-8-byte-align \ CUlonglong  typedef
ulonglong lookup-c-type clone always-8-byte-align \ CUulonglong typedef
double    lookup-c-type clone always-8-byte-align \ CUdouble    typedef
>>

STRUCT: CUuuid
    { bytes char[16] } ;

ENUM: CUctx_flags
    { CU_CTX_SCHED_AUTO  0 }
    { CU_CTX_SCHED_SPIN  1 }
    { CU_CTX_SCHED_YIELD 2 }
    { CU_CTX_SCHED_MASK  3 }
    { CU_CTX_BLOCKING_SYNC 4 }
    { CU_CTX_MAP_HOST      8 }
    { CU_CTX_LMEM_RESIZE_TO_MAX 16 }
    { CU_CTX_FLAGS_MASK  0x1f } ;

ENUM: CUevent_flags
    { CU_EVENT_DEFAULT       0 }
    { CU_EVENT_BLOCKING_SYNC 1 } ;

ENUM: CUarray_format
    { CU_AD_FORMAT_UNSIGNED_INT8  0x01 }
    { CU_AD_FORMAT_UNSIGNED_INT16 0x02 }
    { CU_AD_FORMAT_UNSIGNED_INT32 0x03 }
    { CU_AD_FORMAT_SIGNED_INT8    0x08 }
    { CU_AD_FORMAT_SIGNED_INT16   0x09 }
    { CU_AD_FORMAT_SIGNED_INT32   0x0a }
    { CU_AD_FORMAT_HALF           0x10 }
    { CU_AD_FORMAT_FLOAT          0x20 } ;

ENUM: CUaddress_mode
    { CU_TR_ADDRESS_MODE_WRAP   0 }
    { CU_TR_ADDRESS_MODE_CLAMP  1 }
    { CU_TR_ADDRESS_MODE_MIRROR 2 } ;

ENUM: CUfilter_mode
    { CU_TR_FILTER_MODE_POINT  0 }
    { CU_TR_FILTER_MODE_LINEAR 1 } ;

ENUM: CUdevice_attribute
    { CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK 1 }
    { CU_DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_X 2 }
    { CU_DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_Y 3 }
    { CU_DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_Z 4 }
    { CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X 5 }
    { CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_Y 6 }
    { CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_Z 7 }
    { CU_DEVICE_ATTRIBUTE_MAX_SHARED_MEMORY_PER_BLOCK 8 }
    { CU_DEVICE_ATTRIBUTE_SHARED_MEMORY_PER_BLOCK 8 }
    { CU_DEVICE_ATTRIBUTE_TOTAL_CONSTANT_MEMORY 9 }
    { CU_DEVICE_ATTRIBUTE_WARP_SIZE 10 }
    { CU_DEVICE_ATTRIBUTE_MAX_PITCH 11 }
    { CU_DEVICE_ATTRIBUTE_MAX_REGISTERS_PER_BLOCK 12 }
    { CU_DEVICE_ATTRIBUTE_REGISTERS_PER_BLOCK 12 }
    { CU_DEVICE_ATTRIBUTE_CLOCK_RATE 13 }
    { CU_DEVICE_ATTRIBUTE_TEXTURE_ALIGNMENT 14 }

    { CU_DEVICE_ATTRIBUTE_GPU_OVERLAP 15 }
    { CU_DEVICE_ATTRIBUTE_MULTIPROCESSOR_COUNT 16 }
    { CU_DEVICE_ATTRIBUTE_KERNEL_EXEC_TIMEOUT 17 }
    { CU_DEVICE_ATTRIBUTE_INTEGRATED 18 }
    { CU_DEVICE_ATTRIBUTE_CAN_MAP_HOST_MEMORY 19 }
    { CU_DEVICE_ATTRIBUTE_COMPUTE_MODE 20 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE1D_WIDTH 21 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE2D_WIDTH 22 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE2D_HEIGHT 23 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE3D_WIDTH 24 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE3D_HEIGHT 25 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE3D_DEPTH 26 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE2D_ARRAY_WIDTH 27 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE2D_ARRAY_HEIGHT 28 }
    { CU_DEVICE_ATTRIBUTE_MAXIMUM_TEXTURE2D_ARRAY_NUMSLICES 29 }
    { CU_DEVICE_ATTRIBUTE_SURFACE_ALIGNMENT 30 }
    { CU_DEVICE_ATTRIBUTE_CONCURRENT_KERNELS 31 }
    { CU_DEVICE_ATTRIBUTE_ECC_ENABLED 32 } ;

STRUCT: CUdevprop
    { maxThreadsPerBlock int }
    { maxThreadsDim int[3] }
    { maxGridSize int[3] }
    { sharedMemPerBlock int }
    { totalConstantMemory int }
    { SIMDWidth int }
    { memPitch int }
    { regsPerBlock int }
    { clockRate int }
    { textureAlign int } ;

ENUM: CUfunction_attribute
    { CU_FUNC_ATTRIBUTE_MAX_THREADS_PER_BLOCK 0 }
    { CU_FUNC_ATTRIBUTE_SHARED_SIZE_BYTES 1     }
    { CU_FUNC_ATTRIBUTE_CONST_SIZE_BYTES 2      }
    { CU_FUNC_ATTRIBUTE_LOCAL_SIZE_BYTES 3      }
    { CU_FUNC_ATTRIBUTE_NUM_REGS 4              }
    { CU_FUNC_ATTRIBUTE_PTX_VERSION 5           }
    { CU_FUNC_ATTRIBUTE_BINARY_VERSION 6        }
    CU_FUNC_ATTRIBUTE_MAX ;

ENUM: CUfunc_cache
    { CU_FUNC_CACHE_PREFER_NONE   0x00 }
    { CU_FUNC_CACHE_PREFER_SHARED 0x01 }
    { CU_FUNC_CACHE_PREFER_L1     0x02 } ;

ENUM: CUshared_carveout
    { CU_SHAREDMEM_CARVEOUT_DEFAULT -1 }
    { CU_SHAREDMEM_CARVEOUT_MAX_SHARED 100 }
    { CU_SHAREDMEM_CARVEOUT_MAX_L1 0 } ;

ENUM: CUsharedconfig
    { CU_SHARED_MEM_CONFIG_DEFAULT_BANK_SIZE 0x00 }
    { CU_SHARED_MEM_CONFIG_FOUR_BYTE_BANK_SIZE 0x01 }
    { CU_SHARED_MEM_CONFIG_EIGHT_BYTE_BANK_SIZE 0x02 } ;

ENUM: CUstreamBatchMemOpType
    { CU_STREAM_MEM_OP_WAIT_VALUE_32 1 }
    { CU_STREAM_MEM_OP_WRITE_VALUE_32 2 }
    { CU_STREAM_MEM_OP_WAIT_VALUE_64 4 }
    { CU_STREAM_MEM_OP_WRITE_VALUE_64 5 }
    { CU_STREAM_MEM_OP_FLUSH_REMOTE_WRITES 3 } ;

ENUM: CUstreamWaitValue_flags
    { CU_STREAM_WAIT_VALUE_GEQ 0x0 }
    { CU_STREAM_WAIT_VALUE_EQ 0x1 }
    { CU_STREAM_WAIT_VALUE_AND 0x2 }
    { CU_STREAM_WAIT_VALUE_NOR 0x3 }
    { CU_STREAM_WAIT_VALUE_FLUSH 0x40000000 } ;

ENUM: CUstreamWriteValue_flags
    { CU_STREAM_WRITE_VALUE_DEFAULT 0x0 }
    { CU_STREAM_WRITE_VALUE_NO_MEMORY_BARRIER 0x1 } ;

ENUM: CUstream_flags
    { CU_STREAM_DEFAULT 0x0 }
    { CU_STREAM_NON_BLOCKING 0x1 } ;

ENUM: CUlimit
    { CU_LIMIT_STACK_SIZE 0x00 }
    { CU_LIMIT_PRINTF_FIFO_SIZE 0x01 }
    { CU_LIMIT_MALLOC_HEAP_SIZE 0x02 }
    { CU_LIMIT_DEV_RUNTIME_SYNC_DEPTH 0x03 }
    { CU_LIMIT_DEV_RUNTIME_PENDING_LAUNCH_COUNT 0x04 }
    CU_LIMIT_MAX ;

ENUM: CUmemAttach_flags
    { CU_MEM_ATTACH_GLOBAL 0x1 }
    { CU_MEM_ATTACH_HOST 0x2 }
    { CU_MEM_ATTACH_SINGLE 0x4 } ;

ENUM: CUmem_advise
    { CU_MEM_ADVISE_SET_READ_MOSTLY 1 }
    { CU_MEM_ADVISE_UNSET_READ_MOSTLY 2 }
    { CU_MEM_ADVISE_SET_PREFERRED_LOCATION 3 }
    { CU_MEM_ADVISE_UNSET_PREFERRED_LOCATION 4 }
    { CU_MEM_ADVISE_SET_ACCESSED_BY 5 }
    { CU_MEM_ADVISE_UNSET_ACCESSED_BY 6 } ;

ENUM: CUmemorytype
    { CU_MEMORYTYPE_HOST   0x01 }
    { CU_MEMORYTYPE_DEVICE 0x02 }
    { CU_MEMORYTYPE_ARRAY  0x03 }
    { CU_MEMORYTYPE_UNIFIED 0x04 } ;

ENUM: CUoccupancy_flags
    { CU_OCCUPANCY_DEFAULT 0 }
    { CU_OCCUPANCY_DISABLE_CACHING_OVERRIDE 1 } ;

ENUM: CUpointer_attribute
    { CU_POINTER_ATTRIBUTE_CONTEXT 1 }
    { CU_POINTER_ATTRIBUTE_MEMORY_TYPE 2 }
    { CU_POINTER_ATTRIBUTE_DEVICE_POINTER 3 }
    { CU_POINTER_ATTRIBUTE_HOST_POINTER 4 }
    { CU_POINTER_ATTRIBUTE_P2P_TOKENS 5 }
    { CU_POINTER_ATTRIBUTE_SYNC_MEMOPS 6 }
    { CU_POINTER_ATTRIBUTE_BUFFER_ID 7 }
    { CU_POINTER_ATTRIBUTE_IS_MANAGED 8 } ;

ENUM: CUresourceViewFormat
    { CU_RES_VIEW_FORMAT_NONE 0x00 }
    { CU_RES_VIEW_FORMAT_UINT_1X8 0x01 }
    { CU_RES_VIEW_FORMAT_UINT_2X8 0x02 }
    { CU_RES_VIEW_FORMAT_UINT_4X8 0x03 }
    { CU_RES_VIEW_FORMAT_SINT_1X8 0x04 }
    { CU_RES_VIEW_FORMAT_SINT_2X8 0x05 }
    { CU_RES_VIEW_FORMAT_SINT_4X8 0x06 }
    { CU_RES_VIEW_FORMAT_UINT_1X16 0x07 }
    { CU_RES_VIEW_FORMAT_UINT_2X16 0x08 }
    { CU_RES_VIEW_FORMAT_UINT_4X16 0x09 }
    { CU_RES_VIEW_FORMAT_SINT_1X16 0x0a }
    { CU_RES_VIEW_FORMAT_SINT_2X16 0x0b }
    { CU_RES_VIEW_FORMAT_SINT_4X16 0x0c }
    { CU_RES_VIEW_FORMAT_UINT_1X32 0x0d }
    { CU_RES_VIEW_FORMAT_UINT_2X32 0x0e }
    { CU_RES_VIEW_FORMAT_UINT_4X32 0x0f }
    { CU_RES_VIEW_FORMAT_SINT_1X32 0x10 }
    { CU_RES_VIEW_FORMAT_SINT_2X32 0x11 }
    { CU_RES_VIEW_FORMAT_SINT_4X32 0x12 }
    { CU_RES_VIEW_FORMAT_FLOAT_1X16 0x13 }
    { CU_RES_VIEW_FORMAT_FLOAT_2X16 0x14 }
    { CU_RES_VIEW_FORMAT_FLOAT_4X16 0x15 }
    { CU_RES_VIEW_FORMAT_FLOAT_1X32 0x16 }
    { CU_RES_VIEW_FORMAT_FLOAT_2X32 0x17 }
    { CU_RES_VIEW_FORMAT_FLOAT_4X32 0x18 }
    { CU_RES_VIEW_FORMAT_UNSIGNED_BC1 0x19 }
    { CU_RES_VIEW_FORMAT_UNSIGNED_BC2 0x1a }
    { CU_RES_VIEW_FORMAT_UNSIGNED_BC3 0x1b }
    { CU_RES_VIEW_FORMAT_UNSIGNED_BC4 0x1c }
    { CU_RES_VIEW_FORMAT_SIGNED_BC4 0x1d }
    { CU_RES_VIEW_FORMAT_UNSIGNED_BC5 0x1e }
    { CU_RES_VIEW_FORMAT_SIGNED_BC5 0x1f }
    { CU_RES_VIEW_FORMAT_UNSIGNED_BC6H 0x20 }
    { CU_RES_VIEW_FORMAT_SIGNED_BC6H 0x21 }
    { CU_RES_VIEW_FORMAT_UNSIGNED_BC7 0x22 } ;


ENUM: CUresourcetype
    { CU_RESOURCE_TYPE_ARRAY 0x00 }
    { CU_RESOURCE_TYPE_MIPMAPPED_ARRAY 0x01 }
    { CU_RESOURCE_TYPE_LINEAR 0x02 }
    { CU_RESOURCE_TYPE_PITCH2D 0x03 } ;

ENUM: CUcomputemode
    { CU_COMPUTEMODE_DEFAULT    0 }
    { CU_COMPUTEMODE_EXCLUSIVE  1 }
    { CU_COMPUTEMODE_PROHIBITED 2 } ;

ENUM: CUjit_option
    { CU_JIT_MAX_REGISTERS 0 }
    CU_JIT_THREADS_PER_BLOCK
    CU_JIT_WALL_TIME
    CU_JIT_INFO_LOG_BUFFER
    CU_JIT_INFO_LOG_BUFFER_SIZE_BYTES
    CU_JIT_ERROR_LOG_BUFFER
    CU_JIT_ERROR_LOG_BUFFER_SIZE_BYTES
    CU_JIT_OPTIMIZATION_LEVEL
    CU_JIT_TARGET_FROM_CUCONTEXT
    CU_JIT_TARGET
    CU_JIT_FALLBACK_STRATEGY
    CU_JIT_GENERATE_DEBUG_INFO
    CU_JIT_LOG_VERBOSE
    CU_JIT_GENERATE_LINE_INFO
    CU_JIT_CACHE_MODE
    CU_JIT_NEW_SM3X_OPT
    CU_JIT_FAST_COMPILE
    CU_JIT_NUM_OPTIONS ;

ENUM: CUjit_target
    { CU_TARGET_COMPUTE_10 0 }
    CU_TARGET_COMPUTE_11
    CU_TARGET_COMPUTE_12
    CU_TARGET_COMPUTE_13
    CU_TARGET_COMPUTE_20
    { CU_TARGET_COMPUTE_21 21 }
    { CU_TARGET_COMPUTE_30 30 }
    { CU_TARGET_COMPUTE_32 32 }
    { CU_TARGET_COMPUTE_35 35 }
    { CU_TARGET_COMPUTE_37 37 }
    { CU_TARGET_COMPUTE_50 50 }
    { CU_TARGET_COMPUTE_52 52 }
    { CU_TARGET_COMPUTE_53 53 }
    { CU_TARGET_COMPUTE_60 60 }
    { CU_TARGET_COMPUTE_61 61 }
    { CU_TARGET_COMPUTE_62 62 }
    { CU_TARGET_COMPUTE_70 70 } ;

ENUM: CUjit_fallback
    { CU_PREFER_PTX 0 }
    CU_PREFER_BINARY ;

ENUM: CUgraphicsRegisterFlags
    { CU_GRAPHICS_REGISTER_FLAGS_NONE 0 } ;

ENUM: CUgraphicsMapResourceFlags
    { CU_GRAPHICS_MAP_RESOURCE_FLAGS_NONE          0x00 }
    { CU_GRAPHICS_MAP_RESOURCE_FLAGS_READ_ONLY     0x01 }
    { CU_GRAPHICS_MAP_RESOURCE_FLAGS_WRITE_DISCARD 0x02 } ;

ENUM: CUarray_cubemap_face
    { CU_CUBEMAP_FACE_POSITIVE_X  0x00 }
    { CU_CUBEMAP_FACE_NEGATIVE_X  0x01 }
    { CU_CUBEMAP_FACE_POSITIVE_Y  0x02 }
    { CU_CUBEMAP_FACE_NEGATIVE_Y  0x03 }
    { CU_CUBEMAP_FACE_POSITIVE_Z  0x04 }
    { CU_CUBEMAP_FACE_NEGATIVE_Z  0x05 } ;

ENUM: CUresult
    { CUDA_SUCCESS                    0 }
    { CUDA_ERROR_INVALID_VALUE        1 }
    { CUDA_ERROR_OUT_OF_MEMORY        2 }
    { CUDA_ERROR_NOT_INITIALIZED      3 }
    { CUDA_ERROR_DEINITIALIZED        4 }
    { CUDA_ERROR_PROFILER_DISABLED    5 }
    { CUDA_ERROR_PROFILER_NOT_INITIALIZED 6 }
    { CUDA_ERROR_PROFILER_ALREADY_STARTED 7 }
    { CUDA_ERROR_PROFILER_ALREADY_STOPPED 8 }

    { CUDA_ERROR_NO_DEVICE            100 }
    { CUDA_ERROR_INVALID_DEVICE       101 }

    { CUDA_ERROR_INVALID_IMAGE        200 }
    { CUDA_ERROR_INVALID_CONTEXT      201 }
    { CUDA_ERROR_CONTEXT_ALREADY_CURRENT 202 }
    { CUDA_ERROR_MAP_FAILED           205 }
    { CUDA_ERROR_UNMAP_FAILED         206 }
    { CUDA_ERROR_ARRAY_IS_MAPPED      207 }
    { CUDA_ERROR_ALREADY_MAPPED       208 }
    { CUDA_ERROR_NO_BINARY_FOR_GPU    209 }
    { CUDA_ERROR_ALREADY_ACQUIRED     210 }
    { CUDA_ERROR_NOT_MAPPED           211 }
    { CUDA_ERROR_NOT_MAPPED_AS_ARRAY  212 }
    { CUDA_ERROR_NOT_MAPPED_AS_POINTER 213 }
    { CUDA_ERROR_ECC_UNCORRECTABLE    214 }
    { CUDA_ERROR_UNSUPPORTED_LIMIT 215 }
    { CUDA_ERROR_CONTEXT_ALREADY_IN_USE 216 }
    { CUDA_ERROR_PEER_ACCESS_UNSUPPORTED 217 }
    { CUDA_ERROR_INVALID_PTX 218 }
    { CUDA_ERROR_INVALID_GRAPHICS_CONTEXT 219 }
    { CUDA_ERROR_NVLINK_UNCORRECTABLE 220 }
    { CUDA_ERROR_JIT_COMPILER_NOT_FOUND 221 }

    { CUDA_ERROR_INVALID_SOURCE       300 }
    { CUDA_ERROR_FILE_NOT_FOUND       301 }
    { CUDA_ERROR_SHARED_OBJECT_SYMBOL_NOT_FOUND 302 }
    { CUDA_ERROR_SHARED_OBJECT_INIT_FAILED 303 }
    { CUDA_ERROR_OPERATING_SYSTEM 304 }

    { CUDA_ERROR_INVALID_HANDLE       400 }

    { CUDA_ERROR_NOT_FOUND            500 }

    { CUDA_ERROR_NOT_READY            600 }

    { CUDA_ERROR_ILLEGAL_ADDRESS        700 }
    { CUDA_ERROR_LAUNCH_OUT_OF_RESOURCES 701 }
    { CUDA_ERROR_LAUNCH_TIMEOUT       702 }
    { CUDA_ERROR_LAUNCH_INCOMPATIBLE_TEXTURING 703 }
    { CUDA_ERROR_PEER_ACCESS_ALREADY_ENABLED 704 }
    { CUDA_ERROR_PEER_ACCESS_NOT_ENABLED 705 }
    { CUDA_ERROR_PRIMARY_CONTEXT_ACTIVE 708 }
    { CUDA_ERROR_CONTEXT_IS_DESTROYED 709 }
    { CUDA_ERROR_ASSERT 710 }
    { CUDA_ERROR_TOO_MANY_PEERS 711 }
    { CUDA_ERROR_HOST_MEMORY_ALREADY_REGISTERED 712 }
    { CUDA_ERROR_HOST_MEMORY_NOT_REGISTERED 713 }
    { CUDA_ERROR_HARDWARE_STACK_ERROR 714 }
    { CUDA_ERROR_ILLEGAL_INSTRUCTION 715 }
    { CUDA_ERROR_MISALIGNED_ADDRESS 716 }
    { CUDA_ERROR_INVALID_ADDRESS_SPACE 717 }
    { CUDA_ERROR_INVALID_PC 718 }
    { CUDA_ERROR_LAUNCH_FAILED 719 }
    { CUDA_ERROR_COOPERATIVE_LAUNCH_TOO_LARGE 720 }

    { CUDA_ERROR_POINTER_IS_64BIT     800 }
    { CUDA_ERROR_SIZE_IS_64BIT        801 }

    { CUDA_ERROR_UNKNOWN              999 } ;

CONSTANT: CU_MEMHOSTALLOC_PORTABLE        0x01
CONSTANT: CU_MEMHOSTALLOC_DEVICEMAP       0x02
CONSTANT: CU_MEMHOSTALLOC_WRITECOMBINED   0x04

STRUCT: CUDA_MEMCPY2D
    { srcXInBytes size_t }
    { srcY        size_t }
    { srcMemoryType CUmemorytype }
    { srcHost void* }
    { srcDevice CUdeviceptr }
    { srcArray CUarray }
    { srcPitch size_t }
    { dstXInBytes size_t }
    { dstY size_t }
    { dstMemoryType CUmemorytype }
    { dstHost void* }
    { dstDevice CUdeviceptr }
    { dstArray CUarray }
    { dstPitch size_t }
    { WidthInBytes size_t }
    { Height size_t } ;

STRUCT: CUDA_MEMCPY3D
    { srcXInBytes size_t }
    { srcY        size_t }
    { srcZ        size_t }
    { srcLOD      size_t }
    { srcMemoryType CUmemorytype }
    { srcHost void* }
    { srcDevice CUdeviceptr }
    { srcArray CUarray }
    { reserved0 void* }
    { srcPitch size_t }
    { srcHeight size_t }
    { dstXInBytes size_t }
    { dstY size_t }
    { dstZ size_t }
    { dstLOD size_t }
    { dstMemoryType CUmemorytype }
    { dstHost void* }
    { dstDevice CUdeviceptr }
    { dstArray CUarray }
    { reserved1 void* }
    { dstPitch size_t }
    { dstHeight size_t }
    { WidthInBytes size_t }
    { Height size_t }
    { Depth size_t } ;

STRUCT: CUDA_ARRAY_DESCRIPTOR
    { Width size_t }
    { Height size_t }
    { Format CUarray_format }
    { NumChannels uint } ;

STRUCT: CUDA_ARRAY3D_DESCRIPTOR
    { Width size_t }
    { Height size_t }
    { Depth size_t }
    { Format CUarray_format }
    { NumChannels uint }
    { Flags uint } ;

CONSTANT: CUDA_ARRAY3D_2DARRAY    0x01
CONSTANT: CU_TRSA_OVERRIDE_FORMAT 0x01
CONSTANT: CU_TRSF_READ_AS_INTEGER         0x01
CONSTANT: CU_TRSF_NORMALIZED_COORDINATES  0x02
CONSTANT: CU_PARAM_TR_DEFAULT -1

FUNCTION: CUresult cuInit ( uint Flags )

FUNCTION: CUresult cuDriverGetVersion ( int* driverVersion )

FUNCTION: CUresult cuDeviceGet ( CUdevice* device, int ordinal )
FUNCTION: CUresult cuDeviceGetCount ( int* count )
FUNCTION: CUresult cuDeviceGetName ( char* name, int len, CUdevice dev )
FUNCTION: CUresult cuDeviceComputeCapability ( int* major, int* minor, CUdevice dev )
FUNCTION-ALIAS: cuDeviceTotalMem CUresult cuDeviceTotalMem_v2 ( size_t* bytes, CUdevice dev )
FUNCTION: CUresult cuDeviceGetProperties ( CUdevprop* prop, CUdevice dev )
FUNCTION: CUresult cuDeviceGetAttribute ( int* pi, CUdevice_attribute attrib, CUdevice dev )

! Deprecated
! FUNCTION: CUresult cuCtxAttach ( CUcontext* pctx, uint flags )
! FUNCTION: CUresult cuCtxDetach ( CUcontext ctx )

FUNCTION-ALIAS: cuCtxCreate CUresult cuCtxCreate_v2 ( CUcontext* pctx, uint flags, CUdevice dev )
FUNCTION-ALIAS: cuCtxDestroy CUresult cuCtxDestroy_v2 ( CUcontext ctx )
FUNCTION: CUresult cuCtxGetApiVersion ( CUcontext ctx, uint* version )
FUNCTION: CUresult cuCtxGetCacheConfig ( CUfunc_cache* pconfig )
FUNCTION: CUresult cuCtxGetCurrent ( CUcontext* pctx )
FUNCTION: CUresult cuCtxGetDevice ( CUdevice* device )
FUNCTION: CUresult cuCtxGetFlags ( uint* flags )
FUNCTION: CUresult cuCtxGetLimit ( size_t* pvalue, CUlimit limit )
FUNCTION: CUresult cuCtxGetSharedMemConfig ( CUsharedconfig* pConfig )
FUNCTION: CUresult cuCtxGetStreamPriorityRange ( int* leastPriority, int* greatestPriority )
FUNCTION-ALIAS: cuCtxPopCurrent CUresult cuCtxPopCurrent_v2 ( CUcontext* pctx )
FUNCTION-ALIAS: cuCtxPushCurrent CUresult cuCtxPushCurrent_v2 ( CUcontext ctx )
FUNCTION: CUresult cuCtxSetCacheConfig ( CUfunc_cache config )
FUNCTION: CUresult cuCtxSetCurrent ( CUcontext ctx )
FUNCTION: CUresult cuCtxSetLimit ( CUlimit limit, size_t value )
FUNCTION: CUresult cuCtxSetSharedMemConfig ( CUsharedconfig config )
FUNCTION: CUresult cuCtxSynchronize ( )

FUNCTION-ALIAS: cuLinkAddData CUresult cuLinkAddData_v2 ( CUlinkState state,
        CUjitInputType type, void *data, size_t size, char *name,
        uint numOptions, CUjit_option* options, void** optionValues )

FUNCTION-ALIAS: cuLinkAddFile CUresult cuLinkAddFile_v2 ( CUlinkState state,
        CUjitInputType type, char* path, uint numOptions,
        CUjit_option* options, void** optionValues )

FUNCTION: CUresult cuLinkComplete ( CUlinkState state, void** cubinOut, size_t* sizeOut )
FUNCTION-ALIAS: cuLinkCreate CUresult cuLinkCreate_v2 ( uint numOptions,
        CUjit_option* options, void** optionValues, CUlinkState* stateOut )
FUNCTION: CUresult cuLinkDestroy ( CUlinkState state )
FUNCTION: CUresult cuModuleGetFunction ( CUfunction* hfunc, CUmodule hmod, c-string name )
FUNCTION-ALIAS: cuModuleGetGlobal CUresult cuModuleGetGlobal_v2 ( CUdeviceptr* dptr, size_t* bytes, CUmodule hmod, char* name )
FUNCTION: CUresult cuModuleGetSurfRef ( CUsurfref* pSurfRef, CUmodule hmod, char* name )
FUNCTION: CUresult cuModuleGetTexRef ( CUtexref* pTexRef, CUmodule hmod, char* name )
FUNCTION: CUresult cuModuleLoad ( CUmodule* module, c-string fname )
FUNCTION: CUresult cuModuleLoadData ( CUmodule* module, void* image )
FUNCTION: CUresult cuModuleLoadDataEx ( CUmodule* module, void* image, uint numOptions, CUjit_option* options, void** optionValues )
FUNCTION: CUresult cuModuleLoadFatBinary ( CUmodule* module, void* fatCubin )
FUNCTION: CUresult cuModuleUnload ( CUmodule hmod )

FUNCTION-ALIAS: cuMemGetInfo CUresult cuMemGetInfo_v2 ( size_t* free, size_t* total )

FUNCTION-ALIAS: cuMemAlloc CUresult cuMemAlloc_v2 ( CUdeviceptr* dptr, size_t bytesize )
FUNCTION-ALIAS: cuMemAllocPitch CUresult cuMemAllocPitch_v2 ( CUdeviceptr* dptr,
                                      size_t* pPitch,
                                      size_t WidthInBytes,
                                      size_t Height,
                                      uint ElementSizeBytes
                                     )
FUNCTION-ALIAS: cuMemFree CUresult cuMemFree_v2 ( CUdeviceptr dptr )
FUNCTION-ALIAS: cuMemGetAddressRange CUresult cuMemGetAddressRange_v2 ( CUdeviceptr* pbase, size_t* psize, CUdeviceptr dptr )

FUNCTION-ALIAS: cuMemAllocHost CUresult cuMemAllocHost_v2 ( void** pp, size_t bytesize )
FUNCTION: CUresult cuMemFreeHost ( void* p )

FUNCTION: CUresult cuMemHostAlloc ( void** pp, size_t bytesize, uint Flags )

FUNCTION-ALIAS: cuMemHostGetDevicePointer CUresult cuMemHostGetDevicePointer_v2 ( CUdeviceptr* pdptr, void* p, uint Flags )
FUNCTION: CUresult cuMemHostGetFlags ( uint* pFlags, void* p )

FUNCTION-ALIAS: cuMemHostRegister CUresult cuMemHostRegister_v2_params ( void* p, size_t bytesize, uint Flags )
FUNCTION: CUresult cuMemHostUnregister_params ( void* p )

FUNCTION-ALIAS: cuMemcpyHtoD CUresult cuMemcpyHtoD_v2 ( CUdeviceptr dstDevice, void* srcHost, size_t ByteCount )
FUNCTION-ALIAS: cuMemcpyDtoH CUresult cuMemcpyDtoH_v2 ( void* dstHost, CUdeviceptr srcDevice, size_t ByteCount )

FUNCTION-ALIAS: cuMemcpyDtoD CUresult cuMemcpyDtoD_v2 ( CUdeviceptr dstDevice, CUdeviceptr srcDevice, size_t ByteCount )

FUNCTION-ALIAS: cuMemcpyDtoA CUresult cuMemcpyDtoA_v2 ( CUarray dstArray, size_t dstIndex, CUdeviceptr srcDevice, size_t ByteCount )
FUNCTION-ALIAS: cuMemcpyAtoD CUresult cuMemcpyAtoD_v2 ( CUdeviceptr dstDevice, CUarray hSrc, size_t SrcIndex, size_t ByteCount )

FUNCTION-ALIAS: cuMemcpyHtoA CUresult cuMemcpyHtoA_v2 ( CUarray dstArray, size_t dstIndex, void* pSrc, size_t ByteCount )
FUNCTION-ALIAS: cuMemcpyAtoH CUresult cuMemcpyAtoH_v2 ( void* dstHost, CUarray srcArray, size_t srcIndex, size_t ByteCount )

FUNCTION-ALIAS: cuMemcpyAtoA CUresult cuMemcpyAtoA_v2 ( CUarray dstArray, size_t dstIndex, CUarray srcArray, size_t srcIndex, size_t ByteCount )

FUNCTION: CUresult cuMemcpy ( CUdeviceptr dst, CUdeviceptr src, size_t ByteCount )

FUNCTION-ALIAS: cuMemcpy2D CUresult cuMemcpy2D_v2 ( CUDA_MEMCPY2D* pCopy )
FUNCTION-ALIAS: cuMemcpy2DUnaligned CUresult cuMemcpy2DUnaligned_v2 ( CUDA_MEMCPY2D* pCopy )

FUNCTION-ALIAS: cuMemcpy3D CUresult cuMemcpy3D_v2 ( CUDA_MEMCPY3D* pCopy )

FUNCTION-ALIAS: cuMemcpyHtoDAsync CUresult cuMemcpyHtoDAsync_v2 ( CUdeviceptr dstDevice,
                                                void* srcHost,
                                                size_t ByteCount,
                                                CUstream hStream )
FUNCTION-ALIAS: cuMemcpyDtoHAsync CUresult cuMemcpyDtoHAsync_v2 ( void* dstHost,
                                                CUdeviceptr srcDevice,
                                                size_t ByteCount,
                                                CUstream hStream )

FUNCTION-ALIAS: cuMemcpyDtoDAsync CUresult cuMemcpyDtoDAsync_v2 ( CUdeviceptr dstDevice,
            CUdeviceptr srcDevice, size_t ByteCount, CUstream hStream )

FUNCTION-ALIAS: cuMemcpyHtoAAsync CUresult cuMemcpyHtoAAsync_v2 ( CUarray dstArray, size_t dstIndex,
            void* pSrc, size_t ByteCount, CUstream hStream )
FUNCTION-ALIAS: cuMemcpyAtoHAsync CUresult cuMemcpyAtoHAsync_v2 ( void* dstHost, CUarray srcArray, size_t srcIndex,
            size_t ByteCount, CUstream hStream )

FUNCTION-ALIAS: cuMemcpy2DAsync CUresult cuMemcpy2DAsync_v2 ( CUDA_MEMCPY2D* pCopy, CUstream hStream )
FUNCTION-ALIAS: cuMemcpy3DAsync CUresult cuMemcpy3DAsync_v2 ( CUDA_MEMCPY3D* pCopy, CUstream hStream )

FUNCTION-ALIAS: cuMemsetD8 CUresult cuMemsetD8_v2 ( CUdeviceptr dstDevice, uchar uc, size_t N )
FUNCTION-ALIAS: cuMemsetD16 CUresult cuMemsetD16_v2 ( CUdeviceptr dstDevice, ushort us, size_t N )
FUNCTION-ALIAS: cuMemsetD32 CUresult cuMemsetD32_v2 ( CUdeviceptr dstDevice, uint ui, size_t N )

FUNCTION-ALIAS: cuMemsetD2D8 CUresult cuMemsetD2D8_v2 ( CUdeviceptr dstDevice, size_t dstPitch, uchar uc, size_t Width, size_t Height )
FUNCTION-ALIAS: cuMemsetD2D16 CUresult cuMemsetD2D16_v2 ( CUdeviceptr dstDevice, size_t dstPitch, ushort us, size_t Width, size_t Height )
FUNCTION-ALIAS: cuMemsetD2D32 CUresult cuMemsetD2D32_v2 ( CUdeviceptr dstDevice, size_t dstPitch, uint ui, size_t Width, size_t Height )

FUNCTION: CUresult cuFuncSetBlockShape ( CUfunction hfunc, int x, int y, int z )
FUNCTION: CUresult cuFuncSetSharedSize ( CUfunction hfunc, uint bytes )
FUNCTION: CUresult cuFuncGetAttribute ( int* pi, CUfunction_attribute attrib, CUfunction hfunc )
FUNCTION: CUresult cuFuncSetCacheConfig ( CUfunction hfunc, CUfunc_cache config )

FUNCTION-ALIAS: cuArrayCreate CUresult cuArrayCreate_v2 ( CUarray* pHandle, CUDA_ARRAY_DESCRIPTOR* pAllocateArray )
FUNCTION-ALIAS: cuArrayGetDescriptor CUresult cuArrayGetDescriptor_v2 ( CUDA_ARRAY_DESCRIPTOR* pArrayDescriptor, CUarray hArray )
FUNCTION: CUresult cuArrayDestroy ( CUarray hArray )

FUNCTION: CUresult cuArray3DCreate ( CUarray* pHandle, CUDA_ARRAY3D_DESCRIPTOR* pAllocateArray )
FUNCTION: CUresult cuArray3DGetDescriptor ( CUDA_ARRAY3D_DESCRIPTOR* pArrayDescriptor, CUarray hArray )

FUNCTION: CUresult cuTexRefCreate ( CUtexref* pTexRef )
FUNCTION: CUresult cuTexRefDestroy ( CUtexref hTexRef )

FUNCTION: CUresult cuTexRefSetArray ( CUtexref hTexRef, CUarray hArray, uint Flags )
FUNCTION-ALIAS: cuTexRefSetAddress CUresult cuTexRefSetAddress_v2 ( size_t* ByteOffset, CUtexref hTexRef, CUdeviceptr dptr, size_t bytes )

FUNCTION-ALIAS: cuTexRefSetAddress2D CUresult cuTexRefSetAddress2D_v3 ( CUtexref hTexRef, CUDA_ARRAY_DESCRIPTOR* desc, CUdeviceptr dptr, size_t Pitch )
! FUNCTION: CUresult  cuTexRefSetAddress2D_v2 ( CUtexref hTexRef, CUDA_ARRAY_DESCRIPTOR* desc, CUdeviceptr dptr, size_t Pitch )

FUNCTION: CUresult cuTexRefSetFormat ( CUtexref hTexRef, CUarray_format fmt, int NumPackedComponents )
FUNCTION: CUresult cuTexRefSetAddressMode ( CUtexref hTexRef, int dim, CUaddress_mode am )
FUNCTION: CUresult cuTexRefSetFilterMode ( CUtexref hTexRef, CUfilter_mode fm )
FUNCTION: CUresult cuTexRefSetFlags ( CUtexref hTexRef, uint Flags )

FUNCTION-ALIAS: cuTexRefGetAddress CUresult cuTexRefGetAddress_v2 ( CUdeviceptr* pdptr, CUtexref hTexRef )
FUNCTION: CUresult cuTexRefGetArray ( CUarray* phArray, CUtexref hTexRef )
FUNCTION: CUresult cuTexRefGetAddressMode ( CUaddress_mode* pam, CUtexref hTexRef, int dim )
FUNCTION: CUresult cuTexRefGetFilterMode ( CUfilter_mode* pfm, CUtexref hTexRef )
FUNCTION: CUresult cuTexRefGetFormat ( CUarray_format* pFormat, int* pNumChannels, CUtexref hTexRef )
FUNCTION: CUresult cuTexRefGetFlags ( uint* pFlags, CUtexref hTexRef )

FUNCTION: CUresult cuParamSetSize ( CUfunction hfunc, uint numbytes )
FUNCTION: CUresult cuParamSeti    ( CUfunction hfunc, int offset, uint value )
FUNCTION: CUresult cuParamSetf    ( CUfunction hfunc, int offset, float value )
FUNCTION: CUresult cuParamSetv    ( CUfunction hfunc, int offset, void* ptr, uint numbytes )
FUNCTION: CUresult cuParamSetTexRef ( CUfunction hfunc, int texunit, CUtexref hTexRef )

FUNCTION: CUresult cuLaunch ( CUfunction f )
FUNCTION: CUresult cuLaunchGrid ( CUfunction f, int grid_width, int grid_height )
FUNCTION: CUresult cuLaunchGridAsync ( CUfunction f, int grid_width, int grid_height, CUstream hStream )

FUNCTION: CUresult cuEventCreate ( CUevent* phEvent, uint Flags )
FUNCTION: CUresult cuEventRecord ( CUevent hEvent, CUstream hStream )
FUNCTION: CUresult cuEventQuery ( CUevent hEvent )
FUNCTION: CUresult cuEventSynchronize ( CUevent hEvent )
FUNCTION-ALIAS: cuEventDestroy CUresult cuEventDestroy_v2 ( CUevent hEvent )
FUNCTION: CUresult cuEventElapsedTime ( float* pMilliseconds, CUevent hStart, CUevent hEnd )

FUNCTION: CUresult cuStreamCreate ( CUstream* phStream, uint Flags )
FUNCTION: CUresult cuStreamQuery ( CUstream hStream )
FUNCTION: CUresult cuStreamSynchronize ( CUstream hStream )
FUNCTION-ALIAS: cuStreamDestroy CUresult cuStreamDestroy_v2 ( CUstream hStream )

FUNCTION: CUresult cuGraphicsUnregisterResource ( CUgraphicsResource resource )
FUNCTION: CUresult cuGraphicsSubResourceGetMappedArray ( CUarray* pArray, CUgraphicsResource resource, uint arrayIndex, uint mipLevel )
FUNCTION-ALIAS: cuGraphicsResourceGetMappedPointer  CUresult cuGraphicsResourceGetMappedPointer_v2 ( CUdeviceptr* pDevPtr, size_t* pSize, CUgraphicsResource resource )
FUNCTION-ALIAS: cuGraphicsResourceSetMapFlags CUresult cuGraphicsResourceSetMapFlags_v2 ( CUgraphicsResource resource, uint flags )
FUNCTION: CUresult cuGraphicsMapResources ( uint count, CUgraphicsResource* resources, CUstream hStream )
FUNCTION: CUresult cuGraphicsUnmapResources ( uint count, CUgraphicsResource* resources, CUstream hStream )

FUNCTION: CUresult cuGetExportTable ( void** ppExportTable, CUuuid* pExportTableId )

FUNCTION: CUresult cuDevicePrimaryCtxGetState ( CUdevice dev, uint* flags, int* active )
FUNCTION: CUresult cuDevicePrimaryCtxRelease ( CUdevice dev )
FUNCTION: CUresult cuDevicePrimaryCtxReset ( CUdevice dev )
FUNCTION: CUresult cuDevicePrimaryCtxRetain ( CUcontext* pctx, CUdevice dev )
FUNCTION: CUresult cuDevicePrimaryCtxSetFlags ( CUdevice dev, uint flags )
