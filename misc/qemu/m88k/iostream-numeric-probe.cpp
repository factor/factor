#include <iostream>
#include <sstream>
#include <cstdio>
#include <cstring>
int main() {
 std::ostringstream out;
 out << -42 << ',' << 1234u << ',' << 0x12345678ul;
 std::printf("numeric stream got=%s expected=-42,1234,305419896\n",out.str().c_str());
 if(out.str()!="-42,1234,305419896")return 2;
 std::cout << "numeric cout=" << -42 << ',' << 1234u << ',' << 0x12345678ul << std::endl;
 std::puts("m88k iostream numeric PASS");return 0;
}
