namespace factor
{

void print_obj(cell obj);
void print_nested_obj(cell obj, fixnum nesting);
void dump_generations();
void factorbug();
void dump_zone(zone *z);

PRIMITIVE(die);

}
