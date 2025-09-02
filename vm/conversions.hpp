#pragma once

namespace factor {

// Safe conversion utilities for Factor VM's mixed signed/unsigned arithmetic
// These functions document the intentional conversions between cell (unsigned)
// and fixnum (signed) types that are fundamental to Factor's tagged pointer system

// Convert fixnum to cell when we know the value is non-negative
// Used for: array indices, memory sizes, offsets
[[nodiscard]] inline constexpr cell fixnum_to_cell(fixnum n) {
  FACTOR_ASSERT(n >= 0);
  return static_cast<cell>(n);
}

// Convert fixnum to cell without checking (for performance-critical paths)
// Used when: we know from context the value must be valid
[[nodiscard]] inline constexpr cell fixnum_to_cell_unchecked(fixnum n) {
  return static_cast<cell>(n);
}

// Convert cell to fixnum with range checking
// Used when: converting memory addresses back to Factor integers
[[nodiscard]] inline constexpr fixnum cell_to_fixnum_checked(cell c) {
  FACTOR_ASSERT(c <= static_cast<cell>(std::numeric_limits<fixnum>::max()));
  return static_cast<fixnum>(c);
}

// Convert cell to fixnum without checking (for performance-critical paths)
[[nodiscard]] inline constexpr fixnum cell_to_fixnum_unchecked(cell c) {
  return static_cast<fixnum>(c);
}

// Safe conversion for array indexing operations
[[nodiscard]] inline constexpr cell array_index(fixnum n) {
  FACTOR_ASSERT(n >= 0);
  return static_cast<cell>(n);
}

// Safe conversion for memory sizes
[[nodiscard]] inline constexpr cell memory_size(fixnum n) {
  FACTOR_ASSERT(n >= 0);
  return static_cast<cell>(n);
}

// Convert int to cell (commonly used for small constants)
[[nodiscard]] inline constexpr cell int_to_cell(int n) {
  FACTOR_ASSERT(n >= 0);
  return static_cast<cell>(n);
}

// Convert size_t to cell (for system API compatibility)
[[nodiscard]] inline constexpr cell size_t_to_cell(std::size_t n) {
  static_assert(sizeof(std::size_t) == sizeof(cell));
  return static_cast<cell>(n);
}

// Convert cell to size_t (for system API calls)
[[nodiscard]] inline constexpr std::size_t cell_to_size_t(cell c) {
  static_assert(sizeof(std::size_t) == sizeof(cell));
  return static_cast<std::size_t>(c);
}

// Safe addition that handles mixed types
[[nodiscard]] inline constexpr cell safe_add(cell a, fixnum b) {
  if (b >= 0) {
    return a + static_cast<cell>(b);
  } else {
    FACTOR_ASSERT(a >= static_cast<cell>(-b));
    return a - static_cast<cell>(-b);
  }
}

// Safe subtraction that handles mixed types
[[nodiscard]] inline constexpr cell safe_subtract(cell a, fixnum b) {
  if (b >= 0) {
    FACTOR_ASSERT(a >= static_cast<cell>(b));
    return a - static_cast<cell>(b);
  } else {
    return a + static_cast<cell>(-b);
  }
}

}  // namespace factor