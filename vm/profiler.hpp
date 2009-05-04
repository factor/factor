namespace factor
{

extern bool profiling_p;
void init_profiler(void);
F_CODE_BLOCK *compile_profiling_stub(CELL word);
PRIMITIVE(profiling);

}
