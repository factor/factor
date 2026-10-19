#include <stdarg.h>
#include <stdio.h>
void read_variadic(double*out,...) { va_list ap;va_start(ap,out);*out=va_arg(ap,double);va_end(ap); }
extern void invoke_generated(double*,double);
int main(void) { double value=0;invoke_generated(&value,1.5);printf("Generated CR6 native va_arg=%g\n",value);return value==1.5?0:1; }
