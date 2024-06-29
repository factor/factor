! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct combinators kernel system ;
IN: cuda.ffi

<<
"cuda" {
    { [ os windows? ] [ "nvcuda.dll" stdcall ] }
    { [ os macos? ] [ "libcuda.dylib" cdecl ] }
    { [ os unix? ] [ "libcuda.so" cdecl ] }
} cond add-library
>>

LIBRARY: cuda

TYPEDEF: uint CUdeviceptr
TYPEDEF: int CUdevice
TYPEDEF: void* CUcontext
TYPEDEF: void* CUmodule
TYPEDEF: void* CUfunction
TYPEDEF: void* CUarray
TYPEDEF: void* CUtexref
TYPEDEF: void* CUevent
TYPEDEF: void* CUstream
TYPEDEF: void* CUgraphicsResource

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

ENUM: CUmemorytype
    { CU_MEMORYTYPE_HOST   0x01 }
    { CU_MEMORYTYPE_DEVICE 0x02 }
    { CU_MEMORYTYPE_ARRAY  0x03 } ;

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
    CU_JIT_FALLBACK_STRATEGY ;

ENUM: CUjit_target
    { CU_TARGET_COMPUTE_10 0 }
    CU_TARGET_COMPUTE_11
    CU_TARGET_COMPUTE_12
    CU_TARGET_COMPUTE_13
    CU_TARGET_COMPUTE_20 ;

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

    { CUDA_ERROR_INVALID_SOURCE       300 }
    { CUDA_ERROR_FILE_NOT_FOUND       301 }

    { CUDA_ERROR_INVALID_HANDLE       400 }

    { CUDA_ERROR_NOT_FOUND            500 }

    { CUDA_ERROR_NOT_READY            600 }

    { CUDA_ERROR_LAUNCH_FAILED        700 }
    { CUDA_ERROR_LAUNCH_OUT_OF_RESOURCES 701 }
    { CUDA_ERROR_LAUNCH_TIMEOUT       702 }
    { CUDA_ERROR_LAUNCH_INCOMPATIBLE_TEXTURING 703 }

    { CUDA_ERROR_POINTER_IS_64BIT     800 }
    { CUDA_ERROR_SIZE_IS_64BIT        801 }

    { CUDA_ERROR_UNKNOWN              999 } ;

CONSTANT: CU_MEMHOSTALLOC_PORTABLE        0x01
CONSTANT: CU_MEMHOSTALLOC_DEVICEMAP       0x02
CONSTANT: CU_MEMHOSTALLOC_WRITECOMBINED   0x04

STRUCT: CUDA_MEMCPY2D
    { srcXInBytes uint }
    { srcY        uint }
    { srcMemoryType CUmemorytype }
    { srcHost void* }
    { srcDevice CUdeviceptr }
    { srcArray CUarray }
    { srcPitch uint }
    { dstXInBytes uint }
    { dstY uint }
    { dstMemoryType CUmemorytype }
    { dstHost void* }
    { dstDevice CUdeviceptr }
    { dstArray CUarray }
    { dstPitch uint }
    { WidthInBytes uint }
    { Height uint } ;

STRUCT: CUDA_MEMCPY3D
    { srcXInBytes uint }
    { srcY        uint }
    { srcZ        uint }
    { srcLOD      uint }
    { srcMemoryType CUmemorytype }
    { srcHost void* }
    { srcDevice CUdeviceptr }
    { srcArray CUarray }
    { reserved0 void* }
    { srcPitch uint }
    { srcHeight uint }
    { dstXInBytes uint }
    { dstY uint }
    { dstZ uint }
    { dstLOD uint }
    { dstMemoryType CUmemorytype }
    { dstHost void* }
    { dstDevice CUdeviceptr }
    { dstArray CUarray }
    { reserved1 void* }
    { dstPitch uint }
    { dstHeight uint }
    { WidthInBytes uint }
    { Height uint }
    { Depth uint } ;

STRUCT: CUDA_ARRAY_DESCRIPTOR
    { Width uint }
    { Height uint }
    { Format CUarray_format }
    { NumChannels uint } ;

STRUCT: CUDA_ARRAY3D_DESCRIPTOR
    { Width uint }
    { Height uint }
    { Depth uint }
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
FUNCTION: CUresult cuDeviceTotalMem ( uint* bytes, CUdevice dev )
FUNCTION: CUresult cuDeviceTotalMem_v2 ( size_t* bytes, CUdevice dev )
FUNCTION: CUresult cuDeviceGetProperties ( CUdevprop* prop, CUdevice dev )
FUNCTION: CUresult cuDeviceGetAttribute ( int* pi, CUdevice_attribute attrib, CUdevice dev )

FUNCTION: CUresult cuCtxCreate ( CUcontext* pctx, uint flags, CUdevice dev )
FUNCTION: CUresult cuCtxDestroy ( CUcontext ctx )
FUNCTION: CUresult cuCtxAttach ( CUcontext* pctx, uint flags )
FUNCTION: CUresult cuCtxDetach ( CUcontext ctx )
FUNCTION: CUresult cuCtxPushCurrent ( CUcontext ctx )
FUNCTION: CUresult cuCtxPopCurrent ( CUcontext* pctx )
FUNCTION: CUresult cuCtxGetDevice ( CUdevice* device )
FUNCTION: CUresult cuCtxSynchronize ( )

FUNCTION: CUresult cuModuleLoad ( CUmodule* module, c-string fname )
FUNCTION: CUresult cuModuleLoadData ( CUmodule* module, void* image )
FUNCTION: CUresult cuModuleLoadDataEx ( CUmodule* module, void* image, uint numOptions, CUjit_option* options, void** optionValues )
FUNCTION: CUresult cuModuleLoadFatBinary ( CUmodule* module, void* fatCubin )
FUNCTION: CUresult cuModuleUnload ( CUmodule hmod )
FUNCTION: CUresult cuModuleGetFunction ( CUfunction* hfunc, CUmodule hmod, c-string name )
FUNCTION: CUresult cuModuleGetGlobal ( CUdeviceptr* dptr, uint* bytes, CUmodule hmod, char* name )
FUNCTION: CUresult cuModuleGetTexRef ( CUtexref* pTexRef, CUmodule hmod, char* name )

FUNCTION: CUresult cuMemGetInfo ( size_t* free, size_t* total )

FUNCTION: CUresult cuMemAlloc ( CUdeviceptr* dptr, uint bytesize )
FUNCTION: CUresult cuMemAllocPitch ( CUdeviceptr* dptr,
                                      uint* pPitch,
                                      uint WidthInBytes,
                                      uint Height,
                                      uint ElementSizeBytes
                                     )
FUNCTION: CUresult cuMemFree ( CUdeviceptr dptr )
FUNCTION: CUresult cuMemGetAddressRange ( CUdeviceptr* pbase, uint* psize, CUdeviceptr dptr )

FUNCTION: CUresult cuMemAllocHost ( void** pp, uint bytesize )
FUNCTION: CUresult cuMemFreeHost ( void* p )

FUNCTION: CUresult cuMemHostAlloc ( void** pp, size_t bytesize, uint Flags )

FUNCTION: CUresult cuMemHostGetDevicePointer ( CUdeviceptr* pdptr, void* p, uint Flags )
FUNCTION: CUresult cuMemHostGetFlags ( uint* pFlags, void* p )

FUNCTION: CUresult  cuMemcpyHtoD ( CUdeviceptr dstDevice, void* srcHost, uint ByteCount )
FUNCTION: CUresult  cuMemcpyDtoH ( void* dstHost, CUdeviceptr srcDevice, uint ByteCount )

FUNCTION: CUresult  cuMemcpyDtoD ( CUdeviceptr dstDevice, CUdeviceptr srcDevice, uint ByteCount )

FUNCTION: CUresult  cuMemcpyDtoA ( CUarray dstArray, uint dstIndex, CUdeviceptr srcDevice, uint ByteCount )
FUNCTION: CUresult  cuMemcpyAtoD ( CUdeviceptr dstDevice, CUarray hSrc, uint SrcIndex, uint ByteCount )

FUNCTION: CUresult  cuMemcpyHtoA ( CUarray dstArray, uint dstIndex, void* pSrc, uint ByteCount )
FUNCTION: CUresult  cuMemcpyAtoH ( void* dstHost, CUarray srcArray, uint srcIndex, uint ByteCount )

FUNCTION: CUresult  cuMemcpyAtoA ( CUarray dstArray, uint dstIndex, CUarray srcArray, uint srcIndex, uint ByteCount )

FUNCTION: CUresult  cuMemcpy2D ( CUDA_MEMCPY2D* pCopy )
FUNCTION: CUresult  cuMemcpy2DUnaligned ( CUDA_MEMCPY2D* pCopy )

FUNCTION: CUresult  cuMemcpy3D ( CUDA_MEMCPY3D* pCopy )

FUNCTION: CUresult  cuMemcpyHtoDAsync ( CUdeviceptr dstDevice,
            void* srcHost, uint ByteCount, CUstream hStream )
FUNCTION: CUresult  cuMemcpyDtoHAsync ( void* dstHost,
            CUdeviceptr srcDevice, uint ByteCount, CUstream hStream )

FUNCTION: CUresult cuMemcpyDtoDAsync ( CUdeviceptr dstDevice,
            CUdeviceptr srcDevice, uint ByteCount, CUstream hStream )

FUNCTION: CUresult  cuMemcpyHtoAAsync ( CUarray dstArray, uint dstIndex,
            void* pSrc, uint ByteCount, CUstream hStream )
FUNCTION: CUresult  cuMemcpyAtoHAsync ( void* dstHost, CUarray srcArray, uint srcIndex,
            uint ByteCount, CUstream hStream )

FUNCTION: CUresult  cuMemcpy2DAsync ( CUDA_MEMCPY2D* pCopy, CUstream hStream )
FUNCTION: CUresult  cuMemcpy3DAsync ( CUDA_MEMCPY3D* pCopy, CUstream hStream )

FUNCTION: CUresult  cuMemsetD8 ( CUdeviceptr dstDevice, uchar uc, uint N )
FUNCTION: CUresult  cuMemsetD16 ( CUdeviceptr dstDevice, ushort us, uint N )
FUNCTION: CUresult  cuMemsetD32 ( CUdeviceptr dstDevice, uint ui, uint N )

FUNCTION: CUresult  cuMemsetD2D8 ( CUdeviceptr dstDevice, uint dstPitch, uchar uc, uint Width, uint Height )
FUNCTION: CUresult  cuMemsetD2D16 ( CUdeviceptr dstDevice, uint dstPitch, ushort us, uint Width, uint Height )
FUNCTION: CUresult  cuMemsetD2D32 ( CUdeviceptr dstDevice, uint dstPitch, uint ui, uint Width, uint Height )

FUNCTION: CUresult cuFuncSetBlockShape ( CUfunction hfunc, int x, int y, int z )
FUNCTION: CUresult cuFuncSetSharedSize ( CUfunction hfunc, uint bytes )
FUNCTION: CUresult cuFuncGetAttribute ( int* pi, CUfunction_attribute attrib, CUfunction hfunc )
FUNCTION: CUresult cuFuncSetCacheConfig ( CUfunction hfunc, CUfunc_cache config )

FUNCTION: CUresult  cuArrayCreate ( CUarray* pHandle, CUDA_ARRAY_DESCRIPTOR* pAllocateArray )
FUNCTION: CUresult  cuArrayGetDescriptor ( CUDA_ARRAY_DESCRIPTOR* pArrayDescriptor, CUarray hArray )
FUNCTION: CUresult  cuArrayDestroy ( CUarray hArray )

FUNCTION: CUresult  cuArray3DCreate ( CUarray* pHandle, CUDA_ARRAY3D_DESCRIPTOR* pAllocateArray )
FUNCTION: CUresult  cuArray3DGetDescriptor ( CUDA_ARRAY3D_DESCRIPTOR* pArrayDescriptor, CUarray hArray )

FUNCTION: CUresult  cuTexRefCreate ( CUtexref* pTexRef )
FUNCTION: CUresult  cuTexRefDestroy ( CUtexref hTexRef )

FUNCTION: CUresult  cuTexRefSetArray ( CUtexref hTexRef, CUarray hArray, uint Flags )
FUNCTION: CUresult  cuTexRefSetAddress ( uint* ByteOffset, CUtexref hTexRef, CUdeviceptr dptr, uint bytes )
FUNCTION: CUresult  cuTexRefSetAddress2D ( CUtexref hTexRef, CUDA_ARRAY_DESCRIPTOR* desc, CUdeviceptr dptr, uint Pitch )
FUNCTION: CUresult  cuTexRefSetFormat ( CUtexref hTexRef, CUarray_format fmt, int NumPackedComponents )
FUNCTION: CUresult  cuTexRefSetAddressMode ( CUtexref hTexRef, int dim, CUaddress_mode am )
FUNCTION: CUresult  cuTexRefSetFilterMode ( CUtexref hTexRef, CUfilter_mode fm )
FUNCTION: CUresult  cuTexRefSetFlags ( CUtexref hTexRef, uint Flags )

FUNCTION: CUresult  cuTexRefGetAddress ( CUdeviceptr* pdptr, CUtexref hTexRef )
FUNCTION: CUresult  cuTexRefGetArray ( CUarray* phArray, CUtexref hTexRef )
FUNCTION: CUresult  cuTexRefGetAddressMode ( CUaddress_mode* pam, CUtexref hTexRef, int dim )
FUNCTION: CUresult  cuTexRefGetFilterMode ( CUfilter_mode* pfm, CUtexref hTexRef )
FUNCTION: CUresult  cuTexRefGetFormat ( CUarray_format* pFormat, int* pNumChannels, CUtexref hTexRef )
FUNCTION: CUresult  cuTexRefGetFlags ( uint* pFlags, CUtexref hTexRef )

FUNCTION: CUresult  cuParamSetSize ( CUfunction hfunc, uint numbytes )
FUNCTION: CUresult  cuParamSeti    ( CUfunction hfunc, int offset, uint value )
FUNCTION: CUresult  cuParamSetf    ( CUfunction hfunc, int offset, float value )
FUNCTION: CUresult  cuParamSetv    ( CUfunction hfunc, int offset, void* ptr, uint numbytes )
FUNCTION: CUresult  cuParamSetTexRef ( CUfunction hfunc, int texunit, CUtexref hTexRef )

FUNCTION: CUresult cuLaunch ( CUfunction f )
FUNCTION: CUresult cuLaunchGrid ( CUfunction f, int grid_width, int grid_height )
FUNCTION: CUresult cuLaunchGridAsync ( CUfunction f, int grid_width, int grid_height, CUstream hStream )

FUNCTION: CUresult cuEventCreate ( CUevent* phEvent, uint Flags )
FUNCTION: CUresult cuEventRecord ( CUevent hEvent, CUstream hStream )
FUNCTION: CUresult cuEventQuery ( CUevent hEvent )
FUNCTION: CUresult cuEventSynchronize ( CUevent hEvent )
FUNCTION: CUresult cuEventDestroy ( CUevent hEvent )
FUNCTION: CUresult cuEventElapsedTime ( float* pMilliseconds, CUevent hStart, CUevent hEnd )

FUNCTION: CUresult  cuStreamCreate ( CUstream* phStream, uint Flags )
FUNCTION: CUresult  cuStreamQuery ( CUstream hStream )
FUNCTION: CUresult  cuStreamSynchronize ( CUstream hStream )
FUNCTION: CUresult  cuStreamDestroy ( CUstream hStream )

FUNCTION: CUresult cuGraphicsUnregisterResource ( CUgraphicsResource resource )
FUNCTION: CUresult cuGraphicsSubResourceGetMappedArray ( CUarray* pArray, CUgraphicsResource resource, uint arrayIndex, uint mipLevel )
FUNCTION: CUresult cuGraphicsResourceGetMappedPointer ( CUdeviceptr* pDevPtr, uint* pSize, CUgraphicsResource resource )
FUNCTION: CUresult cuGraphicsResourceSetMapFlags ( CUgraphicsResource resource, uint flags )
FUNCTION: CUresult cuGraphicsMapResources ( uint count, CUgraphicsResource* resources, CUstream hStream )
FUNCTION: CUresult cuGraphicsUnmapResources ( uint count, CUgraphicsResource* resources, CUstream hStream )

FUNCTION: CUresult cuGetExportTable ( void** ppExportTable, CUuuid* pExportTableId )
