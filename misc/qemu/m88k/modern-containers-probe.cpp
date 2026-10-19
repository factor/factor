#include <vector>
#include <unordered_map>
#include <string>
#include <cstdio>
int main() {
 std::vector<unsigned long> v;
 for(unsigned long i=0;i<4096;i++) v.push_back(0x10000000+i*16);
 for(unsigned long i=0;i<v.size();i++) if(v[i]!=0x10000000+i*16) {printf("vector error %lu %lx\n",i,v[i]);return 1;}
 std::unordered_map<std::string,unsigned long> m;
 for(unsigned long i=0;i<1024;i++) m[std::to_string(i)]=i;
 for(unsigned long i=0;i<1024;i++) if(m[std::to_string(i)]!=i) return 2;
 puts("modern vector4096 unordered-map1024 PASS");
}
