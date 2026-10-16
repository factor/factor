#include <assert.h>
#include <stdint.h>
#include "../openrisc.hpp"

int main() {
  uint32_t words[] = {0x19600000, 0xa96b0000};
  factor::openrisc_store_li32(words, 0x89abcdef);
  assert(words[0] == 0x196089ab);
  assert(words[1] == 0xa96bcdef);
  assert(factor::openrisc_load_li32(words) == 0x89abcdef);
  factor::openrisc_store_li32(words, 0);
  assert(words[0] == 0x19600000);
  assert(words[1] == 0xa96b0000);
}
