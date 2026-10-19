#include "../../sh.hpp"
extern "C" int sh_freestanding_validate(void* code) {
  constexpr bool le = __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__;
  auto* p = static_cast<unsigned char*>(code);
  if (!factor::sh_call_site_p(p + 6, le)) return 1;
  if (factor::sh_call_literal(p + 6, le) != p + 12) return 2;
  if (factor::sh_load_literal(p + 12, le) != 0x12345678) return 3;
  return 0;
}
