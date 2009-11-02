namespace factor
{

/* These algorithms were snarfed from various places. I did not come up with them myself */

inline cell popcount(u64 x)
{
	u64 k1 = 0x5555555555555555ll;
	u64 k2 = 0x3333333333333333ll;
	u64 k4 = 0x0f0f0f0f0f0f0f0fll;
	u64 kf = 0x0101010101010101ll;
	x =  x       - ((x >> 1)  & k1); // put count of each 2 bits into those 2 bits
	x = (x & k2) + ((x >> 2)  & k2); // put count of each 4 bits into those 4 bits
	x = (x       +  (x >> 4)) & k4 ; // put count of each 8 bits into those 8 bits
	x = (x * kf) >> 56; // returns 8 most significant bits of x + (x<<8) + (x<<16) + (x<<24) + ...

	return (cell)x;
}

inline cell log2(u64 x)
{
#ifdef FACTOR_AMD64
	cell n;
	asm ("bsr %1, %0;":"=r"(n):"r"((cell)x));
#else
	cell n = 0;
	if (x >= (u64)1 << 32) { x >>= 32; n += 32; }
	if (x >= (u64)1 << 16) { x >>= 16; n += 16; }
	if (x >= (u64)1 <<  8) { x >>=  8; n +=  8; }
	if (x >= (u64)1 <<  4) { x >>=  4; n +=  4; }
	if (x >= (u64)1 <<  2) { x >>=  2; n +=  2; }
	if (x >= (u64)1 <<  1) {           n +=  1; }
#endif
	return n;
}

inline cell log2(u16 x)
{
#if defined(FACTOR_X86) || defined(FACTOR_AMD64)
	cell n;
	asm ("bsr %1, %0;":"=r"(n):"r"((cell)x));
#else
	cell n = 0;
	if (x >= 1 << 8) { x >>=  8; n += 8; }
	if (x >= 1 << 4) { x >>=  4; n += 4; }
	if (x >= 1 << 2) { x >>=  2; n += 2; }
	if (x >= 1 << 1) {           n += 1; }
#endif
	return n;
}

inline cell rightmost_clear_bit(u64 x)
{
	return log2(~x & (x + 1));
}

inline cell rightmost_set_bit(u64 x)
{
	return log2(x & -x);
}

inline cell rightmost_set_bit(u16 x)
{
	return log2((u16)(x & -x));
}

}
