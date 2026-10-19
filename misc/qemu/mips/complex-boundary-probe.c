/* Copyright (C) 2026 Doug Coleman. BSD license. */
typedef float _Complex cf;
typedef double _Complex cd;
cf complex_boundary(float a,float b,float c,float d,float e,float f,float g,cf x,cd y){return x+2*y+a+b+c+d+e+f+g;}
cf complex_stack(float a,float b,float c,float d,float e,float f,float g,float h,cf x,cd y){return x+2*y+a+b+c+d+e+f+g+h;}
cf complex_callback(cf (*cb)(cf,cd)){return cb(1.0f+2.0fi,1.5+1.0i);}
cf complex_boundary_callback(cf (*cb)(float,float,float,float,float,float,float,cf,cd)){return cb(1,2,3,4,5,6,7,1.0f+2.0fi,1.5+1.0i);}
cf complex_variadic(int tag,...){__builtin_va_list ap;__builtin_va_start(ap,tag);cf x=__builtin_va_arg(ap,cf);cd y=__builtin_va_arg(ap,cd);__builtin_va_end(ap);return tag+x+2*y;}
