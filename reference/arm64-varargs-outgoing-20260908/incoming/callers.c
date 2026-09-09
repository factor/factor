#include <stdarg.h>
#ifndef FACTOR_EXPORT
#define FACTOR_EXPORT
#endif
struct inc_pair { double x, y; };
struct inc_hfa { double x, y, z; };
struct inc_big { long long x, y, z; };
typedef float inc_vec __attribute__((vector_size(16)));
struct inc_hva { inc_vec a, b; };
FACTOR_EXPORT double incoming_mixed(double (*cb)(float, double, int, ...)) {
  return cb(1,2,3,4,5.0,(long long)6,7.0,8,9.0);
}
FACTOR_EXPORT double incoming_named_hfa(double (*cb)(struct inc_pair, int, ...), int n) {
  struct inc_pair p = {n,n+1};
  struct inc_hfa h = {n+2,n+3,n+4};
  return cb(p,n+5,h,n+6.0);
}
FACTOR_EXPORT double incoming_split(double (*cb)(int,int,int,int,int,int,int,...), int n) {
  struct inc_pair p = {n+7,n+8};
  return cb(n,n+1,n+2,n+3,n+4,n+5,n+6,p,n+9.0);
}
FACTOR_EXPORT long long incoming_big(struct inc_big (*cb)(int,...)) {
  struct inc_big b = cb(3, (long long)-101, (long long)202, (long long)-303);
  return b.x + 2*b.y + 3*b.z;
}
FACTOR_EXPORT double incoming_vector(double (*cb)(int,...), int n) {
  inc_vec a = {n,n+1,n+2,n+3};
  struct inc_hva h = {{n+4,n+5,n+6,n+7},{n+8,n+9,n+10,n+11}};
  return cb(n,a,h,n+12.0);
}
FACTOR_EXPORT double incoming_consume(int count, va_list args) {
  double sum = 0;
  for (int i=0;i<count;i++) sum += va_arg(args, double)*(i+1);
  return sum;
}
FACTOR_EXPORT double incoming_split_reader(int a,int b,int c,int d,int e,int f,int g,...) {
  va_list ap; va_start(ap,g);
  struct inc_pair p = va_arg(ap,struct inc_pair);
  double tail = va_arg(ap,double); va_end(ap);
  return a+2*b+3*c+4*d+5*e+6*f+7*g+8*p.x+9*p.y+10*tail;
}
FACTOR_EXPORT double incoming_split_control(void) {
  return incoming_split(incoming_split_reader,1);
}
FACTOR_EXPORT double incoming_spill(double (*cb)(int,int,int,int,int,int,...), int n) {
  struct inc_pair p = {n+6,n+7};
  return cb(n,n+1,n+2,n+3,n+4,n+5,p,n+8.0);
}
FACTOR_EXPORT double incoming_list(double (*cb)(int,...)) {
  return cb(10,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0);
}
FACTOR_EXPORT double incoming_named_spill(double (*cb)(float,double,int,int,int,int,int,int,int,...)) {
  return cb(1,2,3,4,5,6,7,8,9,10.0,11);
}
