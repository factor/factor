#include "master.hpp"

namespace factor
{

/* Allocates memory */
string *factor_vm::allot_string_internal(cell capacity)
{
	string *str = allot<string>(string_size(capacity));

	str->length = tag_fixnum(capacity);
	str->hashcode = false_object;
	str->aux = false_object;

	return str;
}

/* Allocates memory */
void factor_vm::fill_string(string *str_, cell start, cell capacity, cell fill)
{
	data_root<string> str(str_,this);

	if(fill <= 0x7f)
		memset(&str->data()[start],(u8)fill,capacity - start);
	else
	{
		byte_array *aux;
		if(to_boolean(str->aux))
			aux = untag<byte_array>(str->aux);
		else
		{
			aux = allot_uninitialized_array<byte_array>(untag_fixnum(str->length) * 2);
			str->aux = tag<byte_array>(aux);
			write_barrier(&str->aux);
		}

		u8 lo_fill = (u8)((fill & 0x7f) | 0x80);
		u16 hi_fill = (u16)((fill >> 7) ^ 0x1);
		memset(&str->data()[start],lo_fill,capacity - start);
		memset_2(&aux->data<u16>()[start],hi_fill,(capacity - start) * sizeof(u16));
	}
}

/* Allocates memory */
string *factor_vm::allot_string(cell capacity, cell fill)
{
	data_root<string> str(allot_string_internal(capacity),this);
	fill_string(str.untagged(),0,capacity,fill);
	return str.untagged();
}

void factor_vm::primitive_string()
{
	cell initial = to_cell(ctx->pop());
	cell length = unbox_array_size();
	ctx->push(tag<string>(allot_string(length,initial)));
}

bool factor_vm::reallot_string_in_place_p(string *str, cell capacity)
{
	return nursery.contains_p(str)
		&& (!to_boolean(str->aux) || nursery.contains_p(untag<byte_array>(str->aux)))
		&& capacity <= string_capacity(str);
}

string* factor_vm::reallot_string(string *str_, cell capacity)
{
	data_root<string> str(str_,this);

	if(reallot_string_in_place_p(str.untagged(),capacity))
	{
		str->length = tag_fixnum(capacity);

		if(to_boolean(str->aux))
		{
			byte_array *aux = untag<byte_array>(str->aux);
			aux->capacity = tag_fixnum(capacity * 2);
		}

		return str.untagged();
	}
	else
	{
		cell to_copy = string_capacity(str.untagged());
		if(capacity < to_copy)
			to_copy = capacity;

		data_root<string> new_str(allot_string_internal(capacity),this);

		memcpy(new_str->data(),str->data(),to_copy);

		if(to_boolean(str->aux))
		{
			byte_array *new_aux = allot_uninitialized_array<byte_array>(capacity * 2);
			new_str->aux = tag<byte_array>(new_aux);
			write_barrier(&new_str->aux);

			byte_array *aux = untag<byte_array>(str->aux);
			memcpy(new_aux->data<u16>(),aux->data<u16>(),to_copy * sizeof(u16));
		}

		fill_string(new_str.untagged(),to_copy,capacity,'\0');
		return new_str.untagged();
	}
}

void factor_vm::primitive_resize_string()
{
	data_root<string> str(ctx->pop(),this);
	str.untag_check(this);
	cell capacity = unbox_array_size();
	ctx->push(tag<string>(reallot_string(str.untagged(),capacity)));
}

void factor_vm::primitive_set_string_nth_fast()
{
	string *str = untag<string>(ctx->pop());
	cell index = untag_fixnum(ctx->pop());
	cell value = untag_fixnum(ctx->pop());
	str->data()[index] = (u8)value;
}

}
