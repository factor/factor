/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdarg.h>
_Static_assert(sizeof(void*)==8 && sizeof(long)==8,"Build with -mabi=64");
_Static_assert(sizeof(float)==4 && sizeof(double)==8,"IEEE scalar widths");
extern double soft_unary_double(void *,double);
extern float soft_unary_float(void *,float);
union slot { uint64_t bits; long integer; double real; float single; };
struct pair { double a,b; };
struct floats {float a,b;};
extern struct floats soft_float_pair(float,float);
extern double soft_outgoing(void *, const union slot *);
extern double hard_outgoing(void *, const union slot *);
extern float soft_float_outgoing(void *, const union slot *);
extern double soft_variadic_outgoing(void *, const union slot *);
extern float soft_float_callback(float,double);
extern double soft_callback(double,float);
extern double hard_callback(double,float);
extern struct pair soft_pair(double,double);
extern struct pair hard_pair(double,double);
__attribute__((noinline)) double sum_mix(long a,double b,float c,long d,double e,float f,long g,double h,float i,double j,long k,float l){return a+b+c+d+e+f+g+h+i+j+k+l;}
__attribute__((noinline)) float sum_single_mix(long a,double b,float c,long d,double e,float f,long g,double h,float i,double j,long k,float l){return (float)(a+b+c+d+e+f+g+h+i+j+k+l);}
__attribute__((noinline)) double sum_variadic(long count,...){va_list ap;double sum=0;va_start(ap,count);for(long i=0;i<count;i++)sum+=va_arg(ap,double);va_end(ap);return sum;}
__attribute__((noinline)) double weighted_mix(long a,double b,float c,long d,double e,float f,long g,double h,float i,double j,long k,float l){return a+2*b+3*c+4*d+5*e+6*f+7*g+8*h+9*i+10*j+11*k+12*l;}
static uint64_t bits(double x){uint64_t b;memcpy(&b,&x,8);return b;}
int main(void){
 union slot input[12]={0};
 input[0].integer=11; input[1].real=3.25;input[2].single=1.5f;input[3].integer=17;
 input[4].real=-2.5;input[5].single=-1.25f;input[6].integer=19;input[7].real=7.75;
 input[8].single=.5f;input[9].real=-4.5;input[10].integer=23;input[11].single=-2.25f;
 double good=soft_outgoing((void*)sum_mix,input),bad=hard_outgoing((void*)sum_mix,input);
 printf("generated outgoing soft=%g hardbits=%016llx expected72.5\n",good,(unsigned long long)bits(bad));
 if(good!=72.5||bad==72.5)return 1;
 good=soft_callback(5.5,2.25f);bad=hard_callback(5.5,2.25f);
 printf("generated hardware callback soft=%g hardbits=%016llx expected7.75\n",good,(unsigned long long)bits(bad));
 if(good!=7.75||bad==7.75)return 2;
 struct pair p=soft_pair(3.25,-2.5),q=hard_pair(3.25,-2.5);
 printf("generated aggregate soft=%g,%g hardbits=%016llx,%016llx\n",p.a,p.b,(unsigned long long)bits(q.a),(unsigned long long)bits(q.b));
 if(p.a!=3.25||p.b!=-2.5||(q.a==3.25&&q.b==-2.5))return 3;
 struct floats sf=soft_float_pair(1.5f,-1.25f);
 if(sf.a!=1.5f||sf.b!=-1.25f)return 6;
 printf("generated floatpair=%g,%g\n",(double)sf.a,(double)sf.b);
 float single=soft_float_outgoing((void*)sum_single_mix,input);
 if(single!=72.5f||soft_float_callback(1.5f,3.25)!=4.75f||soft_float_callback(-1.25f,.5)!=-.75f)return 4;
 union slot variadic[11]={0};variadic[0].integer=10;
 for(int i=1;i<11;i++)variadic[i].real=i;
 double vsum=soft_variadic_outgoing((void*)sum_variadic,variadic);
 printf("generated float return=%g float callbacks4.75/-0.75 variadic=%g expected55\n",(double)single,vsum);
 if(vsum!=55.)return 5;
 double weighted=soft_outgoing((void*)weighted_mix,input);
 if(weighted!=450.5)return 7;
 double(*volatile ds)(double)=sin;float(*volatile fs)(float)=sinf;
 volatile double half=.5;volatile float single_half=.5f;
 double native_sine=ds(half),generated_sine=soft_unary_double((void*)ds,half);
 float native_single_sine=fs(single_half),generated_single_sine=soft_unary_float((void*)fs,single_half);
 if(bits(native_sine)!=bits(generated_sine)||native_single_sine!=generated_single_sine||native_sine<=0||native_sine>=1)return 8;
 printf("generated weighted450.5 libm exact GP-return sin=%g sinf=%g\n",generated_sine,(double)generated_single_sine);
 puts("NetBSD N64 generated GP+stack hardware FP outgoing/callback/aggregate old-negative new-positive PASS");return 0;
}
