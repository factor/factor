namespace factor
{

extern bool profiling_p;
void init_profiler(void);
code_block *compile_profiling_stub(cell word);
PRIMITIVE(profiling);

}
