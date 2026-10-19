#include <cassert>
#include <map>
#include <vector>
#include <iostream>
int main() {
  std::vector<unsigned> v(10000);
  for (unsigned i=0;i<v.size();++i) v[i]=i*7+1;
  assert(v[9999]==69994);
  std::map<unsigned,unsigned> m;
  m[5]=v[5]; assert(m[5]==36);
  try { throw 42; } catch (int n) { assert(n==42); }
  std::cout << "m88k native C++ runtime gate PASS: vector map exception\n";
}
