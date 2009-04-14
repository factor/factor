#if 4 > (1 + 2) 
good
#endif

#if 4 > 1 + 2
good
#endif

#if (4 > 1) - 1
bad
#endif

#if (4 > 1) - 2
good
#endif
