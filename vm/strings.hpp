namespace factor {

inline static cell string_capacity(const string* str) {
  return untag_fixnum(str->length);
}

inline static cell string_size(cell size) { return sizeof(string) + size; }

}
