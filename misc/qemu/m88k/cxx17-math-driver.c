#include <assert.h>
#include <math.h>
#include <stdio.h>
extern int m88k_abs(int),m88k_fpclass(double);
extern double m88k_ceil(double);
extern float m88k_ceilf(float);
int main(void) {
 int ints[]={0,1,-1,42,-42,0x3fffffff,-0x3fffffff};unsigned i;
 double values[]={0.0,-0.0,1.2,-1.2,42.5,-42.5,INFINITY,-INFINITY,NAN};
 for(i=0;i<sizeof(ints)/sizeof(*ints);i++) assert(m88k_abs(ints[i])==(ints[i]<0?-ints[i]:ints[i]));
 for(i=0;i<sizeof(values)/sizeof(*values);i++) {
  double x=values[i];int expected=isfinite(x)+2*!!isnan(x)+4*!!isinf(x);
  assert(m88k_fpclass(x)==expected);
  if(!isnan(x)) { assert(m88k_ceil(x)==ceil(x)); assert(m88k_ceilf((float)x)==ceilf((float)x)); }
 }
 puts("m88k math lowering gate PASS: abs fpclass double/single ceil boundaries");return 0;
}
