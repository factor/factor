! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test opencl.ffi multiline locals kernel io.encodings.ascii
io.encodings.string sequences libc alien.c-types destructors math
specialized-arrays alien.data math.order alien ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAYS: float void* ;
IN: opencl.ffi.tests

STRING: kernel-source
__kernel void square(
    __global float* input,
    __global float* output,
    const unsigned int count)
{
    int i = get_global_id(0);
    if (i < count)
        output[i] = input[i] * input[i];
}
;

ERROR: cl-error err ;
: cl-success ( err -- )
    dup CL_SUCCESS = [ drop ] [ cl-error ] if ;

:: cl-string-array ( str -- alien )
    str ascii encode 0 suffix :> str-buffer
    str-buffer length malloc &free :> str-alien
    str-alien str-buffer dup length memcpy str-alien ;

:: opencl-square ( in -- out )
    0 f 0 uint <ref> [ clGetPlatformIDs cl-success ] keep uint deref
    dup void* <c-array> [ f clGetPlatformIDs cl-success ] keep first
    CL_DEVICE_TYPE_DEFAULT 1 f void* <ref> [ f clGetDeviceIDs cl-success ] keep void* deref :> device-id
    f 1 device-id void* <ref> f f 0 int <ref> [ clCreateContext ] keep int deref cl-success   :> context
    context device-id 0 0 int <ref> [ clCreateCommandQueue ] keep int deref cl-success    :> queue

    [
        context 1 kernel-source cl-string-array void* <ref>
        f 0 int <ref> [ clCreateProgramWithSource ] keep int deref cl-success
        [ 0 f f f f clBuildProgram cl-success ]
        [ "square" cl-string-array 0 int <ref> [ clCreateKernel ] keep int deref cl-success ]
        [ ] tri
    ] with-destructors :> ( kernel program )

    context CL_MEM_READ_ONLY in byte-length f
    0 int <ref> [ clCreateBuffer ] keep int deref cl-success :> input

    context CL_MEM_WRITE_ONLY in byte-length f
    0 int <ref> [ clCreateBuffer ] keep int deref cl-success :> output

    queue input CL_TRUE 0 in byte-length in 0 f f clEnqueueWriteBuffer cl-success

    kernel 0 cl_mem heap-size input void* <ref> clSetKernelArg cl-success
    kernel 1 cl_mem heap-size output void* <ref> clSetKernelArg cl-success
    kernel 2 uint heap-size in length uint <ref> clSetKernelArg cl-success

    queue kernel 1 f in length ulonglong <ref> f
    0 f f clEnqueueNDRangeKernel cl-success

    queue clFinish cl-success

    queue output CL_TRUE 0 in byte-length in length float <c-array>
    [ 0 f f clEnqueueReadBuffer cl-success ] keep

    input clReleaseMemObject cl-success
    output clReleaseMemObject cl-success
    program clReleaseProgram cl-success
    kernel clReleaseKernel cl-success
    queue clReleaseCommandQueue cl-success
    context clReleaseContext cl-success ;

{ float-array{ 1.0 4.0 9.0 16.0 100.0 } }
[ float-array{ 1.0 2.0 3.0 4.0 10.0 } opencl-square ] unit-test
