#include <assert.h>
#include <stdio.h>
#include <stdint.h>
extern unsigned m88k_fcmp32_0(float,float);
extern unsigned m88k_fcmp32_1(float,float);
extern unsigned m88k_fcmp32_2(float,float);
extern unsigned m88k_fcmp32_3(float,float);
extern unsigned m88k_fcmp32_4(float,float);
extern unsigned m88k_fcmp32_5(float,float);
extern unsigned m88k_fcmp32_6(float,float);
extern unsigned m88k_fcmp32_7(float,float);
extern unsigned m88k_fcmp32_8(float,float);
extern unsigned m88k_fcmp32_9(float,float);
extern unsigned m88k_fcmp32_10(float,float);
extern unsigned m88k_fcmp32_11(float,float);
extern unsigned m88k_fcmp32_12(float,float);
extern unsigned m88k_fcmp32_13(float,float);
extern unsigned m88k_fcmp32_14(float,float);
extern unsigned m88k_fcmp32_15(float,float);
static unsigned (*f32[16])(float,float)={m88k_fcmp32_0,m88k_fcmp32_1,m88k_fcmp32_2,m88k_fcmp32_3,m88k_fcmp32_4,m88k_fcmp32_5,m88k_fcmp32_6,m88k_fcmp32_7,m88k_fcmp32_8,m88k_fcmp32_9,m88k_fcmp32_10,m88k_fcmp32_11,m88k_fcmp32_12,m88k_fcmp32_13,m88k_fcmp32_14,m88k_fcmp32_15};
extern unsigned m88k_fcmp64_0(double,double);
extern unsigned m88k_fcmp64_1(double,double);
extern unsigned m88k_fcmp64_2(double,double);
extern unsigned m88k_fcmp64_3(double,double);
extern unsigned m88k_fcmp64_4(double,double);
extern unsigned m88k_fcmp64_5(double,double);
extern unsigned m88k_fcmp64_6(double,double);
extern unsigned m88k_fcmp64_7(double,double);
extern unsigned m88k_fcmp64_8(double,double);
extern unsigned m88k_fcmp64_9(double,double);
extern unsigned m88k_fcmp64_10(double,double);
extern unsigned m88k_fcmp64_11(double,double);
extern unsigned m88k_fcmp64_12(double,double);
extern unsigned m88k_fcmp64_13(double,double);
extern unsigned m88k_fcmp64_14(double,double);
extern unsigned m88k_fcmp64_15(double,double);
static unsigned (*f64[16])(double,double)={m88k_fcmp64_0,m88k_fcmp64_1,m88k_fcmp64_2,m88k_fcmp64_3,m88k_fcmp64_4,m88k_fcmp64_5,m88k_fcmp64_6,m88k_fcmp64_7,m88k_fcmp64_8,m88k_fcmp64_9,m88k_fcmp64_10,m88k_fcmp64_11,m88k_fcmp64_12,m88k_fcmp64_13,m88k_fcmp64_14,m88k_fcmp64_15};
static unsigned expected(unsigned p,unsigned i,unsigned j) {
 int u=i==6||j==6;
 int a=i==3?2:i,b=j==3?2:j;
 switch(p) {
 case 0:return 0; case 1:return !u&&a==b; case 2:return !u&&a>b;
 case 3:return !u&&a>=b; case 4:return !u&&a<b; case 5:return !u&&a<=b;
 case 6:return !u&&a!=b; case 7:return !u; case 8:return u;
 case 9:return u||a==b; case 10:return u||a>b; case 11:return u||a>=b;
 case 12:return u||a<b; case 13:return u||a<=b; case 14:return u||a!=b;
 default:return 1;
 }
}
int main(void) {
 union { uint32_t bits; float value; } v32[7];
 union { uint64_t bits; double value; } v64[7];
 uint32_t b32[]={0xff800000,0xc0000000,0x80000000,0,0x40400000,0x7f800000,0x7fc00000};
 uint64_t b64[]={0xfff0000000000000ULL,0xc000000000000000ULL,0x8000000000000000ULL,0,0x4008000000000000ULL,0x7ff0000000000000ULL,0x7ff8000000000000ULL};
 unsigned i,j,p;
 for(i=0;i<7;++i) {v32[i].bits=b32[i];v64[i].bits=b64[i];}
 for(p=0;p<16;++p)for(i=0;i<7;++i)for(j=0;j<7;++j) {
  unsigned e=expected(p,i,j),a=f32[p](v32[i].value,v32[j].value),b=f64[p](v64[i].value,v64[j].value);
  if(a!=e||b!=e)printf("FCMP p=%u i=%u j=%u expected=%u float=%u double=%u\n",p,i,j,e,a,b);
  assert(a==e&&b==e);
 }
 puts("m88k FCMP gate PASS: all16 predicates float/double finite infinity NaN signed zero");
 return 0;
}
