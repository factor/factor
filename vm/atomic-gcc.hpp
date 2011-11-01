namespace factor {
	namespace atomic {
		__attribute__((always_inline))
		inline static bool cas(volatile cell *ptr, cell old_val, cell new_val)
		{
			return __sync_bool_compare_and_swap(ptr, old_val, new_val);
		}
		__attribute__((always_inline))
		inline static bool cas(volatile fixnum *ptr, fixnum old_val, fixnum new_val)
		{
			return __sync_bool_compare_and_swap(ptr, old_val, new_val);
		}

		__attribute__((always_inline))
		inline static cell add(volatile cell *ptr, cell val)
		{
			return __sync_add_and_fetch(ptr, val);
		}
		__attribute__((always_inline))
		inline static fixnum add(volatile fixnum *ptr, fixnum val)
		{
			return __sync_add_and_fetch(ptr, val);
		}

		__attribute__((always_inline))
		inline static cell subtract(volatile cell *ptr, cell val)
		{
			return __sync_sub_and_fetch(ptr, val);
		}
		__attribute__((always_inline))
		inline static fixnum subtract(volatile fixnum *ptr, fixnum val)
		{
			return __sync_sub_and_fetch(ptr, val);
		}

		__attribute__((always_inline))
		inline static void fence()
		{
			__sync_synchronize();
		}
	}
}
