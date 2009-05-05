namespace factor
{

void print_obj(cell obj);
void print_nested_obj(cell obj, fixnum nesting);
void dump_generations(void);
void factorbug(void);
void dump_zone(zone *z);

PRIMITIVE(die);

}
