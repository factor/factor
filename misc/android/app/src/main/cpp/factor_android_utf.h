#pragma once

#include <cstddef>
#include <cstdint>
#include <string>

inline std::u16string factor_utf8_to_utf16(const uint8_t* input, size_t length) {
  std::u16string output;
  const uint8_t* p = input;
  const uint8_t* end = input + length;
  while (p < end) {
    uint32_t c;
    if (*p < 0x80) c = *p++;
    else if ((*p & 0xe0) == 0xc0 && end - p >= 2) {
      c = (*p++ & 0x1f) << 6; c |= *p++ & 0x3f;
    } else if ((*p & 0xf0) == 0xe0 && end - p >= 3) {
      c = (*p++ & 0x0f) << 12; c |= (*p++ & 0x3f) << 6; c |= *p++ & 0x3f;
    } else if ((*p & 0xf8) == 0xf0 && end - p >= 4) {
      c = (*p++ & 7) << 18; c |= (*p++ & 0x3f) << 12;
      c |= (*p++ & 0x3f) << 6; c |= *p++ & 0x3f;
    } else {
      ++p; c = 0xfffd;
    }
    if (c > 0x10ffff || (c >= 0xd800 && c <= 0xdfff)) c = 0xfffd;
    if (c >= 0x10000) {
      c -= 0x10000;
      output.push_back(static_cast<char16_t>(0xd800 + (c >> 10)));
      output.push_back(static_cast<char16_t>(0xdc00 + (c & 0x3ff)));
    } else {
      output.push_back(static_cast<char16_t>(c));
    }
  }
  return output;
}

inline std::string factor_utf16_to_utf8(const char16_t* input, size_t length) {
  std::string output;
  for (size_t i = 0; i < length; ++i) {
    uint32_t c = input[i];
    if (c >= 0xd800 && c <= 0xdbff && i + 1 < length &&
        input[i + 1] >= 0xdc00 && input[i + 1] <= 0xdfff) {
      c = 0x10000 + ((c - 0xd800) << 10) + (input[++i] - 0xdc00);
    } else if (c >= 0xd800 && c <= 0xdfff) {
      c = 0xfffd;
    }
    if (c < 0x80) output.push_back(static_cast<char>(c));
    else if (c < 0x800) {
      output.push_back(static_cast<char>(0xc0 | (c >> 6)));
      output.push_back(static_cast<char>(0x80 | (c & 0x3f)));
    } else if (c < 0x10000) {
      output.push_back(static_cast<char>(0xe0 | (c >> 12)));
      output.push_back(static_cast<char>(0x80 | ((c >> 6) & 0x3f)));
      output.push_back(static_cast<char>(0x80 | (c & 0x3f)));
    } else {
      output.push_back(static_cast<char>(0xf0 | (c >> 18)));
      output.push_back(static_cast<char>(0x80 | ((c >> 12) & 0x3f)));
      output.push_back(static_cast<char>(0x80 | ((c >> 6) & 0x3f)));
      output.push_back(static_cast<char>(0x80 | (c & 0x3f)));
    }
  }
  return output;
}
