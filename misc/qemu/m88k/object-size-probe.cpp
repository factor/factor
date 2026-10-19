#include "../../../vm/master.hpp"
namespace factor { void critical_error(const char* s, cell x) { fprintf(stderr,"object-size error %s %lx\n",s,x); ::abort(); } }
struct image_fixup { char* data; factor::object* translate_data(factor::object* p) {return (factor::object*)(data+(unsigned long)p-1024);} };
int main(){ FILE* f=fopen("boot.unix-m88k.32.image","rb"); if(!f)return 1; factor::image_header h; fread(&h,1,sizeof h,f); char* data=(char*)malloc(h.data_size);fread(data,1,h.data_size,f);fclose(f); unsigned long p=0,n=0;while(p<h.data_size){ auto o=(factor::object*)(data+p);auto z=o->size(image_fixup{data});if(z==0||z>h.data_size-p)return 2;p+=z;n++;}printf("native object_size count=%lu bytes=%lu\n",n,p); return n!=77490; }
