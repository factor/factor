! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays
byte-arrays combinators combinators.smart destructors
io.encodings.ascii io.encodings.string kernel libc literals make
math namespaces opencl.ffi sequences specialized-arrays
variants ;
IN: opencl
SPECIALIZED-ARRAYS: void* char size_t ;

<PRIVATE

ERROR: cl-error err ;

: cl-success ( err -- )
    dup CL_SUCCESS = [ drop ] [ cl-error ] if ; inline

: cl-not-null ( err -- )
    dup f = [ cl-error ] [ drop ] if ; inline

: info-data-size ( handle name info-quot -- size_t )
    [ 0 f 0 size_t <ref> ] dip
    [ call cl-success ] keepd size_t deref ; inline

: info-data-bytes ( handle name info-quot size -- bytes )
    swap [ dup <byte-array> f ] dip [ call cl-success ] keepdd ; inline

: info ( handle name info-quot lift-quot -- value )
    [ 3dup info-data-size info-data-bytes ] dip call ; inline

: 2info-data-size ( handle1 handle2 name info-quot -- size_t )
    [ 0 f 0 size_t <ref> ] dip
    [ call cl-success ] keepd size_t deref ; inline

: 2info-data-bytes ( handle1 handle2 name info-quot size -- bytes )
    swap [ dup <byte-array> f ] dip [ call cl-success ] keepdd ; inline

: 2info ( handle1 handle2 name info_quot lift_quot -- value )
    [ 4dup 2info-data-size 2info-data-bytes ] dip call ; inline

: info-bool ( handle name quot -- ? )
    [ uint deref CL_TRUE = ] info ; inline

: info-ulong ( handle name quot -- ulong )
    [ ulonglong deref ] info ; inline

: info-int ( handle name quot -- int )
    [ int deref ] info ; inline

: info-uint ( handle name quot -- uint )
    [ uint deref ] info ; inline

: info-size_t ( handle name quot -- size_t )
    [ size_t deref ] info ; inline

: 2info-size_t ( handle1 handle2 name quot -- size_t )
    [ size_t deref ] 2info ; inline

: info-string ( handle name quot -- string )
    [ ascii decode but-last ] info ; inline

: 2info-string ( handle name quot -- string )
    [ ascii decode but-last ] 2info ; inline

: info-size_t-array ( handle name quot -- size_t-array )
    [ [ length size_t heap-size / ] keep swap size_t <c-direct-array> ] info ; inline

TUPLE: cl-handle < disposable handle ;

PRIVATE>

VARIANT: cl-device-type
    cl-device-default cl-device-cpu cl-device-gpu cl-device-accelerator ;

: size_t>cl-device-type ( size_t -- cl-device-type )
    {
        { CL_DEVICE_TYPE_DEFAULT     [ cl-device-default     ] }
        { CL_DEVICE_TYPE_CPU         [ cl-device-cpu         ] }
        { CL_DEVICE_TYPE_GPU         [ cl-device-gpu         ] }
        { CL_DEVICE_TYPE_ACCELERATOR [ cl-device-accelerator ] }
    } case ; inline

VARIANT: cl-fp-feature
    cl-denorm cl-inf-and-nan cl-round-to-nearest cl-round-to-zero cl-round-to-inf cl-fma ;

VARIANT: cl-cache-type
    cl-no-cache cl-read-only-cache cl-read-write-cache ;

VARIANT: cl-buffer-access-mode
    cl-read-access cl-write-access cl-read-write-access ;

VARIANT: cl-image-channel-order
    cl-channel-order-r cl-channel-order-a cl-channel-order-rg cl-channel-order-ra
    cl-channel-order-rga cl-channel-order-rgba cl-channel-order-bgra cl-channel-order-argb
    cl-channel-order-intensity cl-channel-order-luminance ;

VARIANT: cl-image-channel-type
    cl-channel-type-snorm-int8 cl-channel-type-snorm-int16 cl-channel-type-unorm-int8
    cl-channel-type-unorm-int16 cl-channel-type-unorm-short-565
    cl-channel-type-unorm-short-555 cl-channel-type-unorm-int-101010
    cl-channel-type-signed-int8 cl-channel-type-signed-int16 cl-channel-type-signed-int32
    cl-channel-type-unsigned-int8 cl-channel-type-unsigned-int16
    cl-channel-type-unsigned-int32 cl-channel-type-half-float cl-channel-type-float ;

VARIANT: cl-addressing-mode
    cl-repeat-addressing cl-clamp-to-edge-addressing cl-clamp-addressing cl-no-addressing ;

VARIANT: cl-filter-mode
    cl-filter-nearest cl-filter-linear ;

VARIANT: cl-command-type
    cl-ndrange-kernel-command cl-task-command cl-native-kernel-command cl-read-buffer-command
    cl-write-buffer-command cl-copy-buffer-command cl-read-image-command cl-write-image-command
    cl-copy-image-command cl-copy-buffer-to-image-command cl-copy-image-to-buffer-command
    cl-map-buffer-command cl-map-image-command cl-unmap-mem-object-command
    cl-marker-command cl-acquire-gl-objects-command cl-release-gl-objects-command ;

VARIANT: cl-execution-status
    cl-queued cl-submitted cl-running cl-complete cl-failure ;

TUPLE: cl-platform
    id profile version name vendor extensions devices ;

TUPLE: cl-device
    id type vendor-id max-compute-units max-work-item-dimensions
    max-work-item-sizes max-work-group-size preferred-vector-width-char
    preferred-vector-width-short preferred-vector-width-int
    preferred-vector-width-long preferred-vector-width-float
    preferred-vector-width-double max-clock-frequency address-bits
    max-mem-alloc-size image-support max-read-image-args max-write-image-args
    image2d-max-width image2d-max-height image3d-max-width image3d-max-height
    image3d-max-depth max-samplers max-parameter-size mem-base-addr-align
    min-data-type-align-size single-fp-config global-mem-cache-type
    global-mem-cacheline-size global-mem-cache-size global-mem-size
    max-constant-buffer-size max-constant-args local-mem? local-mem-size
    error-correction-support profiling-timer-resolution endian-little
    available compiler-available execute-kernels? execute-native-kernels?
    out-of-order-exec-available? profiling-available?
    name vendor driver-version profile version extensions ;

TUPLE: cl-context < cl-handle ;
TUPLE: cl-queue   < cl-handle ;
TUPLE: cl-buffer  < cl-handle ;
TUPLE: cl-sampler < cl-handle ;
TUPLE: cl-program < cl-handle ;
TUPLE: cl-kernel  < cl-handle ;
TUPLE: cl-event   < cl-handle ;

M: cl-context dispose* handle>> clReleaseContext      cl-success ;
M: cl-queue   dispose* handle>> clReleaseCommandQueue cl-success ;
M: cl-buffer  dispose* handle>> clReleaseMemObject    cl-success ;
M: cl-sampler dispose* handle>> clReleaseSampler      cl-success ;
M: cl-program dispose* handle>> clReleaseProgram      cl-success ;
M: cl-kernel  dispose* handle>> clReleaseKernel       cl-success ;
M: cl-event   dispose* handle>> clReleaseEvent        cl-success ;

TUPLE: cl-buffer-ptr
    { buffer cl-buffer read-only }
    { offset integer   read-only } ;
C: <cl-buffer-ptr> cl-buffer-ptr

TUPLE: cl-buffer-range
    { buffer cl-buffer read-only }
    { offset integer   read-only }
    { size   integer   read-only } ;
C: <cl-buffer-range> cl-buffer-range

SYMBOLS: cl-current-context cl-current-queue cl-current-device ;

<PRIVATE

: (current-cl-context) ( -- cl-context )
    cl-current-context get ; inline

: (current-cl-queue) ( -- cl-queue )
    cl-current-queue get ; inline

: (current-cl-device) ( -- cl-device )
    cl-current-device get ; inline

GENERIC: buffer-access-constant ( buffer-access-mode -- n )
M: cl-read-write-access buffer-access-constant drop CL_MEM_READ_WRITE ;
M: cl-read-access       buffer-access-constant drop CL_MEM_READ_ONLY ;
M: cl-write-access      buffer-access-constant drop CL_MEM_WRITE_ONLY ;

GENERIC: buffer-map-flags ( buffer-access-mode -- n )
M: cl-read-write-access buffer-map-flags drop flags{ CL_MAP_READ CL_MAP_WRITE } ;
M: cl-read-access       buffer-map-flags drop CL_MAP_READ ;
M: cl-write-access      buffer-map-flags drop CL_MAP_WRITE ;

GENERIC: addressing-mode-constant ( addressing-mode -- n )
M: cl-repeat-addressing        addressing-mode-constant drop CL_ADDRESS_REPEAT ;
M: cl-clamp-to-edge-addressing addressing-mode-constant drop CL_ADDRESS_CLAMP_TO_EDGE ;
M: cl-clamp-addressing         addressing-mode-constant drop CL_ADDRESS_CLAMP ;
M: cl-no-addressing            addressing-mode-constant drop CL_ADDRESS_NONE ;

GENERIC: filter-mode-constant ( filter-mode -- n )
M: cl-filter-nearest filter-mode-constant drop CL_FILTER_NEAREST ;
M: cl-filter-linear  filter-mode-constant drop CL_FILTER_LINEAR ;

: cl_addressing_mode>addressing-mode ( cl_addressing_mode -- addressing-mode )
    {
        { CL_ADDRESS_REPEAT        [ cl-repeat-addressing        ] }
        { CL_ADDRESS_CLAMP_TO_EDGE [ cl-clamp-to-edge-addressing ] }
        { CL_ADDRESS_CLAMP         [ cl-clamp-addressing         ] }
        { CL_ADDRESS_NONE          [ cl-no-addressing            ] }
    } case ; inline

: cl_filter_mode>filter-mode ( cl_filter_mode -- filter-mode )
    {
        { CL_FILTER_LINEAR  [ cl-filter-linear  ] }
        { CL_FILTER_NEAREST [ cl-filter-nearest ] }
    } case ; inline

: platform-info-string ( handle name -- string )
    [ clGetPlatformInfo ] info-string ;

: platform-info ( id -- profile version name vendor extensions )
    {
        [ CL_PLATFORM_PROFILE    platform-info-string ]
        [ CL_PLATFORM_VERSION    platform-info-string ]
        [ CL_PLATFORM_NAME       platform-info-string ]
        [ CL_PLATFORM_VENDOR     platform-info-string ]
        [ CL_PLATFORM_EXTENSIONS platform-info-string ]
    } cleave ;

: cl_device_fp_config>flags ( ulong -- sequence )
    {
        [ CL_FP_DENORM           bitand 0 = [ f ] [ cl-denorm           ] if ]
        [ CL_FP_INF_NAN          bitand 0 = [ f ] [ cl-inf-and-nan      ] if ]
        [ CL_FP_ROUND_TO_NEAREST bitand 0 = [ f ] [ cl-round-to-nearest ] if ]
        [ CL_FP_ROUND_TO_ZERO    bitand 0 = [ f ] [ cl-round-to-zero    ] if ]
        [ CL_FP_ROUND_TO_INF     bitand 0 = [ f ] [ cl-round-to-inf     ] if ]
        [ CL_FP_FMA              bitand 0 = [ f ] [ cl-fma              ] if ]
    } cleave>array sift ;

: cl_device_mem_cache_type>cache-type ( uint -- cache-type )
    {
        { CL_NONE             [ cl-no-cache         ] }
        { CL_READ_ONLY_CACHE  [ cl-read-only-cache  ] }
        { CL_READ_WRITE_CACHE [ cl-read-write-cache ] }
    } case ; inline

: device-info-bool ( handle name -- ? )
    [ clGetDeviceInfo ] info-bool ;

: device-info-ulong ( handle name -- ulong )
    [ clGetDeviceInfo ] info-ulong ;

: device-info-uint ( handle name -- uint )
    [ clGetDeviceInfo ] info-uint ;

: device-info-string ( handle name -- string )
    [ clGetDeviceInfo ] info-string ;

: device-info-size_t ( handle name -- size_t )
    [ clGetDeviceInfo ] info-size_t ;

: device-info-size_t-array ( handle name -- size_t-array )
    [ clGetDeviceInfo ] info-size_t-array ;

: device-info ( device-id -- device )
    dup {
        [ CL_DEVICE_TYPE                          device-info-size_t size_t>cl-device-type ]
        [ CL_DEVICE_VENDOR_ID                     device-info-uint         ]
        [ CL_DEVICE_MAX_COMPUTE_UNITS             device-info-uint         ]
        [ CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS      device-info-uint         ]
        [ CL_DEVICE_MAX_WORK_ITEM_SIZES           device-info-size_t-array ]
        [ CL_DEVICE_MAX_WORK_GROUP_SIZE           device-info-size_t       ]
        [ CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR   device-info-uint         ]
        [ CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT  device-info-uint         ]
        [ CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT    device-info-uint         ]
        [ CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG   device-info-uint         ]
        [ CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT  device-info-uint         ]
        [ CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE device-info-uint         ]
        [ CL_DEVICE_MAX_CLOCK_FREQUENCY           device-info-uint         ]
        [ CL_DEVICE_ADDRESS_BITS                  device-info-uint         ]
        [ CL_DEVICE_MAX_MEM_ALLOC_SIZE            device-info-ulong        ]
        [ CL_DEVICE_IMAGE_SUPPORT                 device-info-bool         ]
        [ CL_DEVICE_MAX_READ_IMAGE_ARGS           device-info-uint         ]
        [ CL_DEVICE_MAX_WRITE_IMAGE_ARGS          device-info-uint         ]
        [ CL_DEVICE_IMAGE2D_MAX_WIDTH             device-info-size_t       ]
        [ CL_DEVICE_IMAGE2D_MAX_HEIGHT            device-info-size_t       ]
        [ CL_DEVICE_IMAGE3D_MAX_WIDTH             device-info-size_t       ]
        [ CL_DEVICE_IMAGE3D_MAX_HEIGHT            device-info-size_t       ]
        [ CL_DEVICE_IMAGE3D_MAX_DEPTH             device-info-size_t       ]
        [ CL_DEVICE_MAX_SAMPLERS                  device-info-uint         ]
        [ CL_DEVICE_MAX_PARAMETER_SIZE            device-info-size_t       ]
        [ CL_DEVICE_MEM_BASE_ADDR_ALIGN           device-info-uint         ]
        [ CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE      device-info-uint         ]
        [ CL_DEVICE_SINGLE_FP_CONFIG              device-info-ulong cl_device_fp_config>flags           ]
        [ CL_DEVICE_GLOBAL_MEM_CACHE_TYPE         device-info-uint  cl_device_mem_cache_type>cache-type ]
        [ CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE     device-info-uint         ]
        [ CL_DEVICE_GLOBAL_MEM_CACHE_SIZE         device-info-ulong        ]
        [ CL_DEVICE_GLOBAL_MEM_SIZE               device-info-ulong        ]
        [ CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE      device-info-ulong        ]
        [ CL_DEVICE_MAX_CONSTANT_ARGS             device-info-uint         ]
        [ CL_DEVICE_LOCAL_MEM_TYPE                device-info-uint CL_LOCAL = ]
        [ CL_DEVICE_LOCAL_MEM_SIZE                device-info-ulong        ]
        [ CL_DEVICE_ERROR_CORRECTION_SUPPORT      device-info-bool         ]
        [ CL_DEVICE_PROFILING_TIMER_RESOLUTION    device-info-size_t       ]
        [ CL_DEVICE_ENDIAN_LITTLE                 device-info-bool         ]
        [ CL_DEVICE_AVAILABLE                     device-info-bool         ]
        [ CL_DEVICE_COMPILER_AVAILABLE            device-info-bool         ]
        [ CL_DEVICE_EXECUTION_CAPABILITIES        device-info-ulong CL_EXEC_KERNEL                         bitand 0 = not ]
        [ CL_DEVICE_EXECUTION_CAPABILITIES        device-info-ulong CL_EXEC_NATIVE_KERNEL                  bitand 0 = not ]
        [ CL_DEVICE_QUEUE_PROPERTIES              device-info-ulong CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE bitand 0 = not ]
        [ CL_DEVICE_QUEUE_PROPERTIES              device-info-ulong CL_QUEUE_PROFILING_ENABLE              bitand 0 = not ]
        [ CL_DEVICE_NAME                          device-info-string       ]
        [ CL_DEVICE_VENDOR                        device-info-string       ]
        [ CL_DRIVER_VERSION                       device-info-string       ]
        [ CL_DEVICE_PROFILE                       device-info-string       ]
        [ CL_DEVICE_VERSION                       device-info-string       ]
        [ CL_DEVICE_EXTENSIONS                    device-info-string       ]
    } cleave cl-device boa ;

: platform-devices ( platform-id -- devices )
    CL_DEVICE_TYPE_ALL [
        0 f 0 uint <ref> [ clGetDeviceIDs cl-success ] keep uint deref
    ] [
        rot dup void* <c-array> [ f clGetDeviceIDs cl-success ] keep
    ] 2bi ; inline

: command-queue-info-ulong ( handle name -- ulong )
    [ clGetCommandQueueInfo ] info-ulong ;

: sampler-info-bool ( handle name -- ? )
    [ clGetSamplerInfo ] info-bool ;

: sampler-info-uint ( handle name -- uint )
    [ clGetSamplerInfo ] info-uint ;

: program-build-info-string ( program-handle device-handle name -- string )
    [ clGetProgramBuildInfo ] 2info-string ;

: program-build-log ( program-handle device-handle -- string )
    CL_PROGRAM_BUILD_LOG program-build-info-string ;

: strings>char*-array ( strings -- char*-array )
    [
        ascii encode dup length dup malloc
        [ cl-not-null ] keep &free [ -rot memcpy ] keep
    ] void*-array{ } map-as ;

: (program) ( cl-context sources -- program-handle )
    [ handle>> ] dip [
        [ length ]
        [ strings>char*-array ]
        [ [ length ] size_t-array{ } map-as ] tri
        0 int <ref> [ clCreateProgramWithSource ] keep int deref cl-success
    ] with-destructors ;

:: (build-program) ( program-handle device options -- program )
    program-handle 1 device 1array [ id>> ] void*-array{ } map-as
    options ascii encode 0 suffix f f clBuildProgram
    {
        { CL_BUILD_PROGRAM_FAILURE [
            program-handle device id>> program-build-log program-handle
            clReleaseProgram cl-success cl-error f ] }
        { CL_SUCCESS [ cl-program new-disposable program-handle >>handle ] }
        [ program-handle clReleaseProgram cl-success cl-success f ]
    } case ;

: kernel-info-string ( handle name -- string )
    [ clGetKernelInfo ] info-string ;

: kernel-info-uint ( handle name -- uint )
    [ clGetKernelInfo ] info-uint ;

: kernel-work-group-info-size_t ( handle1 handle2 name -- size_t )
    [ clGetKernelWorkGroupInfo ] 2info-size_t ;

: event-info-uint ( handle name -- uint )
    [ clGetEventInfo ] info-uint ;

: event-info-int ( handle name -- int )
    [ clGetEventInfo ] info-int ;

: cl_command_type>command-type ( cl_command-type -- command-type )
    {
        { CL_COMMAND_NDRANGE_KERNEL       [ cl-ndrange-kernel-command       ] }
        { CL_COMMAND_TASK                 [ cl-task-command                 ] }
        { CL_COMMAND_NATIVE_KERNEL        [ cl-native-kernel-command        ] }
        { CL_COMMAND_READ_BUFFER          [ cl-read-buffer-command          ] }
        { CL_COMMAND_WRITE_BUFFER         [ cl-write-buffer-command         ] }
        { CL_COMMAND_COPY_BUFFER          [ cl-copy-buffer-command          ] }
        { CL_COMMAND_READ_IMAGE           [ cl-read-image-command           ] }
        { CL_COMMAND_WRITE_IMAGE          [ cl-write-image-command          ] }
        { CL_COMMAND_COPY_IMAGE           [ cl-copy-image-command           ] }
        { CL_COMMAND_COPY_BUFFER_TO_IMAGE [ cl-copy-buffer-to-image-command ] }
        { CL_COMMAND_COPY_IMAGE_TO_BUFFER [ cl-copy-image-to-buffer-command ] }
        { CL_COMMAND_MAP_BUFFER           [ cl-map-buffer-command           ] }
        { CL_COMMAND_MAP_IMAGE            [ cl-map-image-command            ] }
        { CL_COMMAND_UNMAP_MEM_OBJECT     [ cl-unmap-mem-object-command     ] }
        { CL_COMMAND_MARKER               [ cl-marker-command               ] }
        { CL_COMMAND_ACQUIRE_GL_OBJECTS   [ cl-acquire-gl-objects-command   ] }
        { CL_COMMAND_RELEASE_GL_OBJECTS   [ cl-release-gl-objects-command   ] }
    } case ;

: cl_int>execution-status ( clint -- execution-status )
    {
        { CL_QUEUED    [ cl-queued    ] }
        { CL_SUBMITTED [ cl-submitted ] }
        { CL_RUNNING   [ cl-running   ] }
        { CL_COMPLETE  [ cl-complete  ] }
        [ drop cl-failure ]
    } case ; inline

: profiling-info-ulong ( handle name -- ulong )
    [ clGetEventProfilingInfo ] info-ulong ;

: bind-kernel-arg-buffer ( kernel index buffer -- )
    [ handle>> ] [ cl_mem heap-size ] [ handle>> void* deref ] tri*
    clSetKernelArg cl-success ; inline

: bind-kernel-arg-data ( kernel index byte-array -- )
    [ handle>> ] 2dip
    [ byte-length ] keep clSetKernelArg cl-success ; inline

GENERIC: bind-kernel-arg ( kernel index data -- )
M: cl-buffer  bind-kernel-arg bind-kernel-arg-buffer ;
M: byte-array bind-kernel-arg bind-kernel-arg-data ;

PRIVATE>

: with-cl-state ( context/f device/f queue/f quot -- )
    [
        [
            [ cl-current-queue   ,, ] when*
            [ cl-current-device  ,, ] when*
            [ cl-current-context ,, ] when*
        ] 3curry H{ } make
    ] dip with-variables ; inline

: cl-platforms ( -- platforms )
    0 f 0 uint <ref> [ clGetPlatformIDs cl-success ] keep uint deref
    dup void* <c-array> [ f clGetPlatformIDs cl-success ] keep
    [
        dup
        [ platform-info ]
        [ platform-devices [ device-info ] { } map-as ] bi
        cl-platform boa
    ] { } map-as ;

: <cl-context> ( devices -- cl-context )
    [ f ] dip
    [ length ] [ [ id>> ] void*-array{ } map-as ] bi
    f f 0 int <ref> [ clCreateContext ] keep int deref cl-success
    cl-context new-disposable swap >>handle ;

: <cl-queue> ( context device out-of-order? profiling? -- command-queue )
    [ [ handle>> ] [ id>> ] bi* ] 2dip
    [ [ CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE ] [ 0 ] if ]
    [ [ CL_QUEUE_PROFILING_ENABLE ] [ 0 ] if ] bi* bitor
    0 int <ref> [ clCreateCommandQueue ] keep int deref cl-success
    cl-queue new-disposable swap >>handle ;

: cl-out-of-order-execution? ( command-queue -- ? )
    CL_QUEUE_PROPERTIES command-queue-info-ulong
    CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE bitand 0 = not ; inline

: cl-profiling? ( command-queue -- ? )
    CL_QUEUE_PROPERTIES command-queue-info-ulong
    CL_QUEUE_PROFILING_ENABLE bitand 0 = not ; inline

: <cl-buffer> ( buffer-access-mode size initial-data -- buffer )
    [ (current-cl-context) ] 3dip
    tuck [
        [ handle>> ]
        [ buffer-access-constant ]
        [ [ CL_MEM_COPY_HOST_PTR ] [ CL_MEM_ALLOC_HOST_PTR ] if ] tri* bitor
    ] 2dip
    0 int <ref> [ clCreateBuffer ] keep int deref cl-success
    cl-buffer new-disposable swap >>handle ;

: cl-read-buffer ( buffer-range -- byte-array )
    [ (current-cl-queue) handle>> ] dip
    [ buffer>> handle>> CL_TRUE ]
    [ offset>> ]
    [ size>> dup <byte-array> ] tri
    [ 0 f f clEnqueueReadBuffer cl-success ] keep ; inline

: cl-write-buffer ( buffer-range byte-array -- )
    [
        [ (current-cl-queue) handle>> ] dip
        [ buffer>> handle>> CL_TRUE ]
        [ offset>> ]
        [ size>> ] tri
    ] dip 0 f f clEnqueueWriteBuffer cl-success ; inline

: cl-queue-copy-buffer ( src-buffer-ptr dst-buffer-ptr size dependent-events -- event )
    [
        (current-cl-queue)
        [ handle>> ]
        [ [ buffer>> handle>> ] [ offset>> ] bi ]
        [ [ buffer>> handle>> ] [ offset>> ] bi ]
        tri* swapd
    ] 2dip [ length ] keep [ f ] [ [ handle>> ] void*-array{ } map-as ] if-empty
    f void* <ref> [ clEnqueueCopyBuffer cl-success ] keep void* deref cl-event
    new-disposable swap >>handle ;

: cl-queue-read-buffer ( buffer-range alien dependent-events -- event )
    [
        [ (current-cl-queue) handle>> ] dip
        [ buffer>> handle>> CL_FALSE ] [ offset>> ] [ size>> ] tri
    ] 2dip [ length ] keep [ f ] [ [ handle>> ] void*-array{ } map-as ] if-empty
    f void* <ref> [ clEnqueueReadBuffer cl-success ] keep void* deref cl-event
    new-disposable swap >>handle ;

: cl-queue-write-buffer ( buffer-range alien dependent-events -- event )
    [
        [ (current-cl-queue) handle>> ] dip
        [ buffer>> handle>> CL_FALSE ] [ offset>> ] [ size>> ] tri
    ] 2dip [ length ] keep [ f ] [ [ handle>> ] void*-array{ } map-as ] if-empty
    f void* <ref> [ clEnqueueWriteBuffer cl-success ] keep void* deref cl-event
    new-disposable swap >>handle ;

: <cl-sampler> ( normalized-coords? addressing-mode filter-mode -- sampler )
    [ (current-cl-context) ] 3dip
    [ [ CL_TRUE ] [ CL_FALSE ] if ]
    [ addressing-mode-constant ]
    [ filter-mode-constant ]
    tri* 0 int <ref> [ clCreateSampler ] keep int deref cl-success
    cl-sampler new-disposable swap >>handle ;

: cl-normalized-coords? ( sampler -- ? )
    handle>> CL_SAMPLER_NORMALIZED_COORDS sampler-info-bool ; inline

: sampler>cl-addressing-mode ( sampler -- addressing-mode )
    handle>> CL_SAMPLER_ADDRESSING_MODE sampler-info-uint cl_addressing_mode>addressing-mode ; inline

: sampler>cl-filter-mode ( sampler -- filter-mode )
    handle>> CL_SAMPLER_FILTER_MODE sampler-info-uint cl_filter_mode>filter-mode ; inline

: <cl-program> ( options strings -- program )
    [ (current-cl-device) ] 2dip
    [ (current-cl-context) ] dip
    (program) -rot (build-program) ;

: <cl-kernel> ( program kernel-name -- kernel )
    [ handle>> ] [ ascii encode 0 suffix ] bi*
    0 int <ref> [ clCreateKernel ] keep int deref cl-success
    cl-kernel new-disposable swap >>handle ; inline

: cl-kernel-name ( kernel -- string )
    handle>> CL_KERNEL_FUNCTION_NAME kernel-info-string ;

: cl-kernel-arity ( kernel -- arity )
    handle>> CL_KERNEL_NUM_ARGS kernel-info-uint ;

: cl-kernel-local-size ( kernel -- size )
    (current-cl-device) [ handle>> ] bi@ CL_KERNEL_WORK_GROUP_SIZE kernel-work-group-info-size_t ; inline

:: cl-queue-kernel ( kernel args sizes dependent-events -- event )
    args [| arg idx | kernel idx arg bind-kernel-arg ] each-index
    (current-cl-queue) handle>>
    kernel handle>>
    sizes [ length f ] [ [ ] size_t-array{ } map-as f ] bi
    dependent-events [ length ] [ [ f ] [ [ handle>> ] void*-array{ } map-as ] if-empty ] bi
    f void* <ref> [ clEnqueueNDRangeKernel cl-success ] keep void* deref
    cl-event new-disposable swap >>handle ;

: cl-event-type ( event -- command-type )
    handle>> CL_EVENT_COMMAND_TYPE event-info-uint cl_command_type>command-type ; inline

: cl-event-status ( event -- execution-status )
    handle>> CL_EVENT_COMMAND_EXECUTION_STATUS event-info-int cl_int>execution-status ; inline

: cl-profile-counters ( event -- queued submitted started finished )
    handle>> {
        [ CL_PROFILING_COMMAND_QUEUED profiling-info-ulong ]
        [ CL_PROFILING_COMMAND_SUBMIT profiling-info-ulong ]
        [ CL_PROFILING_COMMAND_START  profiling-info-ulong ]
        [ CL_PROFILING_COMMAND_END    profiling-info-ulong ]
    } cleave ; inline

: cl-barrier-events ( event/events -- )
    [ (current-cl-queue) handle>> ] dip
    dup sequence? [ 1array ] unless
    [ handle>> ] void*-array{ } map-as [ length ] keep clEnqueueWaitForEvents cl-success ; inline

: cl-marker ( -- event )
    (current-cl-queue)
    f void* <ref> [ clEnqueueMarker cl-success ] keep void* deref cl-event new-disposable
    swap >>handle ; inline

: cl-barrier ( -- )
    (current-cl-queue) clEnqueueBarrier cl-success ; inline

: cl-flush ( -- )
    (current-cl-queue) handle>> clFlush cl-success ; inline

: cl-wait ( event/events -- )
    dup sequence? [ 1array ] unless
    [ handle>> ] void*-array{ } map-as [ length ] keep clWaitForEvents cl-success ; inline

: cl-finish ( -- )
    (current-cl-queue) handle>> clFinish cl-success ; inline
