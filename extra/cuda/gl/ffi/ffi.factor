! (c)2010 Joe Groff bsd license
USING: alien.c-types alien.syntax cuda.ffi opengl.gl ;
IN: cuda.gl.ffi

LIBRARY: cuda

FUNCTION: CUresult cuGLCtxCreate ( CUcontext* pCtx, uint Flags, CUdevice device ) ;
FUNCTION: CUresult cuGraphicsGLRegisterBuffer ( CUgraphicsResource* pCudaResource, GLuint buffer, uint Flags ) ;
FUNCTION: CUresult cuGraphicsGLRegisterImage ( CUgraphicsResource* pCudaResource, GLuint image, GLenum target, uint Flags ) ;

