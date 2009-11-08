namespace factor
{

inline cell log2(cell x)
{
	cell n;
#if defined(FACTOR_X86) || defined(FACTOR_AMD64)
	asm ("bsr %1, %0;":"=r"(n):"r"(x));
#elif defined(FACTOR_PPC)
	asm ("cntlzw %1, %0;":"=r"(n):"r"(x));
	n = (31 - n);
#else
	#error Unsupported CPU
#endif
	return n;
}

inline cell rightmost_clear_bit(cell x)
{
	return log2(~x & (x + 1));
}

inline cell rightmost_set_bit(cell x)
{
	return log2(x & -x);
}

inline cell popcount(cell x)
{
#ifdef FACTOR_64
	u64 k1 = 0x5555555555555555ll;
	u64 k2 = 0x3333333333333333ll;
	u64 k4 = 0x0f0f0f0f0f0f0f0fll;
	u64 kf = 0x0101010101010101ll;
	cell ks = 56;
#else
	u32 k1 = 0x55555555;
	u32 k2 = 0x33333333;
	u32 k4 = 0xf0f0f0f;
	u32 kf = 0x1010101;
	cell ks = 24;
#endif

	x =  x       - ((x >> 1)  & k1); // put count of each 2 bits into those 2 bits
	x = (x & k2) + ((x >> 2)  & k2); // put count of each 4 bits into those 4 bits
	x = (x       +  (x >> 4)) & k4 ; // put count of each 8 bits into those 8 bits
	x = (x * kf) >> ks; // returns 8 most significant bits of x + (x<<8) + (x<<16) + (x<<24) + ...

	return x;
}

}
