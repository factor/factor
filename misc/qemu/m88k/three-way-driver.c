#include <assert.h>
#include <stdio.h>
int three_signed(int,int),three_unsigned(unsigned,unsigned);
int main(void){unsigned v[]={0,1,0x7fffffffU,0x80000000U,0xfffffffeU,0xffffffffU};unsigned i,j; for(i=0;i<6;i++)for(j=0;j<6;j++){int a=(int)v[i],b=(int)v[j];assert(three_signed(a,b)==((a>b)-(a<b)));assert(three_unsigned(v[i],v[j])==((v[i]>v[j])-(v[i]<v[j])));}puts("m88k three-way compare PASS: signed/unsigned 36 boundary pairs");return 0;}
