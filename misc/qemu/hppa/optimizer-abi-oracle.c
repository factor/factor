extern float ff(float,float,float,float,float);
extern double dd(double,double,double);
extern double mix(int,double,int,double);
extern long long ll(int,long long,int);
extern double var(int,...);
float cf(void){return ff(1,2,3,4,5);}
double cd(void){return dd(1,2,3);}
double cm(void){return mix(1,2,3,4);}
long long cl(void){return ll(1,2,3);}
double cv(void){return var(1,2.5);}
struct small { int a,b; }; struct medium {int a,b,c;};
extern struct small ss(struct small); extern struct medium mm(struct medium);
struct small cs(void){return ss((struct small){1,2});}
struct medium ct(void){return mm((struct medium){1,2,3});}
