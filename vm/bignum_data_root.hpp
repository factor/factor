// Overloads for data_root<bignum> to avoid .untagged() calls
// This file must be included after data_roots.hpp

namespace factor {

// Overloads that accept data_root<bignum> to keep code clean
inline bignum_length_type BIGNUM_LENGTH(const data_root<bignum>& b) {
  return BIGNUM_LENGTH(b.untagged());
}

inline bool BIGNUM_NEGATIVE_P(const data_root<bignum>& b) {
  return BIGNUM_NEGATIVE_P(b.untagged());
}

inline bool BIGNUM_ZERO_P(const data_root<bignum>& b) {
  return BIGNUM_ZERO_P(b.untagged());
}

inline void BIGNUM_SET_NEGATIVE_P(data_root<bignum>& b, bool neg) {
  BIGNUM_SET_NEGATIVE_P(b.untagged(), neg);
}

inline bignum_digit_type& BIGNUM_REF(data_root<bignum>& b, bignum_length_type index) {
  return BIGNUM_REF(b.untagged(), index);
}

// Now we can overload BIGNUM_START_PTR since it's an inline function
inline bignum_digit_type* BIGNUM_START_PTR(data_root<bignum>& b) {
  return BIGNUM_START_PTR(b.untagged());
}

// Const versions
inline const bignum_digit_type& BIGNUM_REF(const data_root<bignum>& b, bignum_length_type index) {
  return BIGNUM_REF(b.untagged(), index);
}

inline const bignum_digit_type* BIGNUM_START_PTR(const data_root<bignum>& b) {
  return BIGNUM_START_PTR(const_cast<bignum*>(b.untagged()));
}

}