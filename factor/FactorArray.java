/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor;

/**
 * A growable array.
 * @author Slava Pestov
 */
public class FactorArray implements FactorExternalizable, PublicCloneable
{
	public Object[] stack;
	public int top;

	//{{{ FactorArray constructor
	public FactorArray()
	{
		stack = new Object[64];
	} //}}}

	//{{{ FactorArray constructor
	public FactorArray(int size)
	{
		stack = new Object[size];
	} //}}}

	//{{{ FactorArray constructor
	public FactorArray(Cons list)
	{
		this();

		if(list != null)
		{
			ensurePush(list.length());
			while(list != null)
			{
				push(list.car);
				list = list.next();
			}
		}
	} //}}}

	//{{{ FactorArray constructor
	public FactorArray(Object[] stack, int top)
	{
		this.stack = stack;
		this.top = top;
	} //}}}

	//{{{ pop() method
	public Object pop(Class clas) throws Exception
	{
		return FactorJava.convertToJavaType(pop(),clas);
	} //}}}

	//{{{ pop() method
	public Object pop() throws FactorStackException
	{
		ensurePop(1);
		Object returnValue = stack[--top];
		stack[top] = null;
		return returnValue;
	} //}}}

	//{{{ peek() method
	public Object peek() throws FactorStackException
	{
		ensurePop(1);
		return stack[top - 1];
	} //}}}

	//{{{ ensurePop() method
	public void ensurePop(int amount) throws FactorStackException
	{
		if(amount > top)
			throw new FactorStackException(amount);
	} //}}}

	//{{{ push() method
	public void push(Object o)
	{
		ensurePush(1);
		stack[top++] = o;
	} //}}}

	//{{{ pushAll() method
	public void pushAll(Object[] array)
	{
		ensurePush(array.length);
		System.arraycopy(array,0,stack,top,array.length);
		top += array.length;
	} //}}}

	//{{{ ensureCapacity() method
	private void ensureCapacity(int index)
	{
		if(index >= stack.length)
		{
			Object[] newStack = new Object[index * 2 + 1];
			System.arraycopy(stack,0,newStack,0,top);
			stack = newStack;
		}
	} //}}}

	//{{{ ensurePush() method
	public void ensurePush(int amount)
	{
		ensureCapacity(top + amount);
	} //}}}

	//{{{ get() method
	public Object get(int index)
	{
		return stack[index];
	} //}}}
	
	//{{{ set() method
	public void set(Object value, int index)
	{
		ensureCapacity(index);
		if(index >= top)
		{
			for(int i = top; i < index; i++)
				stack[i] = null;
			top = index + 1;
		}
		stack[index] = value;
	} //}}}
	
	//{{{ getCapacity() method
	public int getCapacity()
	{
		return stack.length;
	} //}}}
	
	//{{{ toString() method
	/**
	 * Returns elementsToString() enclosed with [ and ].
	 */
	public String toString()
	{
		StringBuffer buf = new StringBuffer("{ ");
		for(int i = 0; i < top; i++)
		{
			buf.append(FactorReader.unparseObject(stack[i]));
			buf.append(' ');
		}

		return buf.append("}").toString();
	} //}}}
	
	//{{{ toList() method
	public Cons toList()
	{
		Cons first = null, last = null;
		for(int i = 0; i < top; i++)
		{
			Cons cons = new Cons(stack[i],null);
			if(first == null)
				first = cons;
			else
				last.cdr = cons;
			last = cons;
		}
		return first;
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		if(stack == null)
			return new FactorArray();
		else
		{
			Object[] newArray = new Object[stack.length];
			System.arraycopy(stack,0,newArray,0,top);
			return new FactorArray(newArray,top);
		}
	} //}}}

	//{{{ hashCode() method
	public int hashCode()
	{
		int hashCode = 0;
		for(int i = 0; i < Math.min(top,4); i++)
		{
			Object obj = stack[i];
			if(obj != null)
				hashCode ^= obj.hashCode();
		}

		return hashCode;
	} //}}}

	//{{{ equals() method
	public boolean equals(Object obj)
	{
		if(obj instanceof FactorArray)
		{
			FactorArray a = (FactorArray)obj;
			if(a.top != top)
				return false;
			for(int i = 0; i < top; i++)
			{
				if(!FactorLib.equal(stack[i],a.stack[i]))
					return false;
			}
			
			return true;
		}
		else
			return false;
	} //}}}
}
