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
 * Factor is a stack-based language.
 * @author Slava Pestov
 */
public abstract class FactorArrayStack implements FactorExternalizable
{
	public Object[] stack;
	public int top;

	//{{{ FactorArrayStack constructor
	public FactorArrayStack()
	{
	} //}}}

	//{{{ FactorArrayStack constructor
	public FactorArrayStack(FactorList list)
	{
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

	//{{{ FactorArrayStack constructor
	public FactorArrayStack(Object[] stack, int top)
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
		if(shouldClear(returnValue))
			stack[top] = null;
		return returnValue;
	} //}}}

	//{{{ shouldClear() method
	/**
	 * Some data (arbitrary objects) should be removed from the stack as
	 * soon as they're popped, but some (callframes) should be left on and
	 * reused later.
	 */
	public abstract boolean shouldClear(Object o);
	//}}}

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

	//{{{ ensurePush() method
	public void ensurePush(int amount)
	{
		if(stack == null)
			stack = new Object[64];

		if(top + amount > stack.length)
		{
			Object[] newStack = new Object[stack.length * 2 + 1];
			System.arraycopy(stack,0,newStack,0,top);
			stack = newStack;
		}
	} //}}}

	//{{{ toList() method
	public FactorList toList()
	{
		FactorList first = null, last = null;
		for(int i = 0; i < top; i++)
		{
			FactorList cons = new FactorList(stack[i],null);
			if(first == null)
				first = cons;
			else
				last.cdr = cons;
			last = cons;
		}
		return first;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		StringBuffer buf = new StringBuffer();
		for(int i = 0; i < top; i++)
		{
			if(i != 0)
				buf.append('\n');
			buf.append(i).append(": ");
			if(stack[i] == this)
				buf.append("THIS STACK");
			else
				buf.append(FactorJava.factorTypeToString(stack[i]));
		}
		return buf.toString();
	} //}}}
}
