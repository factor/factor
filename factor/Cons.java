/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003, 2004 Slava Pestov.
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
 * Used to build up linked lists.
 */
public class Cons implements PublicCloneable, FactorExternalizable
{
	public static int COUNT;

	public Object car;
	public Object cdr;

	//{{{ Cons constructor
	public Cons(Object car, Object cdr)
	{
		this.car = car;
		this.cdr = cdr;

		COUNT++;
	} //}}}

	//{{{ car() method
	public Object car(Class clas) throws Exception
	{
		return FactorJava.convertToJavaType(car,clas);
	} //}}}

	//{{{ cdr() method
	public Object cdr(Class clas) throws Exception
	{
		return FactorJava.convertToJavaType(cdr,clas);
	} //}}}

	//{{{ next() method
	public Cons next()
	{
		return (Cons)cdr;
	} //}}}

	//{{{ get() method
	public Object get(int index)
	{
		return _get(index).car;
	} //}}}

	//{{{ _get() method
	public Cons _get(int index)
	{
		Cons iter = this;
		while(index != 0)
		{
			iter = (Cons)iter.cdr;
			index--;
		}
		return iter;
	} //}}}

	//{{{ contains() method
	public boolean contains(Object obj)
	{
		Cons iter = this;
		while(iter != null)
		{
			if(FactorLib.objectsEqual(obj,iter.car))
				return true;
			iter = iter.next();
		}
		return false;
	} //}}}

	//{{{ contains() method
	public static boolean contains(Cons list, Object obj)
	{
		if(list == null)
			return false;
		else
			return list.contains(obj);
	} //}}}

	//{{{ length() method
	public int length()
	{
		int size = 0;
		Cons iter = this;
		while(iter != null)
		{
			iter = (Cons)iter.cdr;
			size++;
		}
		return size;
	} //}}}

	//{{{ nappend() method
	public static Cons nappend(Cons l1, Cons l2)
	{
		if(l1 == null)
			return l2;
		if(l2 == null)
			return l1;
		Cons last = l1;
		while(last.cdr != null)
			last = last.next();
		last.cdr = l2;
		return l1;
	} //}}}

	//{{{ reverse() method
	public static Cons reverse(Cons list)
	{
		Cons reversed = null;
		while(list != null)
		{
			reversed = new Cons(list.car,reversed);
			list = list.next();
		}
		return reversed;
	} //}}}

	//{{{ assoc() method
	public static Object assoc(Cons assoc, Object key)
	{
		if(assoc == null)
			return null;
		else
		{
			Cons first = (Cons)assoc.car;
			if(FactorLib.equal(first.car,key))
				return first.cdr;
			else
				return assoc(assoc.next(),key);
		}
	} //}}}

	//{{{ elementsToString() method
	/**
	 * Returns a whitespace separated string of the unparseObject() of each
	 * item.
	 */
	public String elementsToString()
	{
		StringBuffer buf = new StringBuffer();
		Cons iter = this;
		while(iter != null)
		{
			buf.append(FactorReader.unparseObject(iter.car));
			if(iter.cdr instanceof Cons)
			{
				buf.append(' ');
				iter = (Cons)iter.cdr;
				continue;
			}
			else if(iter.cdr == null)
				break;
			else
			{
				buf.append(" | ");
				buf.append(FactorReader.unparseObject(iter.cdr));
				iter = null;
			}
		}

		return buf.toString();
	} //}}}

	//{{{ toString() method
	/**
	 * Returns elementsToString() enclosed with [ and ].
	 */
	public String toString()
	{
		return "[ " + elementsToString() + " ]";
	} //}}}

	//{{{ toArray() method
	/**
	 * Note that unlike Java list toArray(), the given array must already
	 * be the right size.
	 */
	public Object[] toArray(Object[] returnValue)
	{
		int i = 0;
		Cons iter = this;
		while(iter != null)
		{
			returnValue[i++] = iter.car;
			iter = iter.next();
		}
		return returnValue;
	} //}}}

	//{{{ fromArray() method
	public static Cons fromArray(Object[] array)
	{
		if(array == null || array.length == 0)
			return null;
		else
		{
			Cons first = new Cons(array[0],null);
			Cons last = first;
			for(int i = 1; i < array.length; i++)
			{
				Cons cons = new Cons(array[i],null);
				last.cdr = cons;
				last = cons;
			}
			return first;
		}
	} //}}}

	//{{{ equals() method
	public boolean equals(Object o)
	{
		if(o instanceof Cons)
		{
			Cons l = (Cons)o;
			return FactorLib.objectsEqual(car,l.car)
				&& FactorLib.objectsEqual(cdr,l.cdr);
		}
		else
			return false;
	} //}}}

	//{{{ hashCode() method
	public int hashCode()
	{
		if(car == null)
			return 0;
		else
			return car.hashCode();
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		if(cdr instanceof Cons)
			return new Cons(car,((Cons)cdr).clone());
		else
			return new Cons(car,cdr);
	} //}}}

	//{{{ deepClone() method
	public static Cons deepClone(Cons list)
	{
		if(list == null)
			return null;

		Object ccar;
		if(list.car instanceof PublicCloneable)
			ccar = ((PublicCloneable)list.car).clone();
		else
			ccar = list.car;
		if(list.cdr instanceof Cons)
		{
			return new Cons(ccar,deepClone(list.next()));
		}
		else if(list.cdr == null)
		{
			return new Cons(ccar,null);
		}
		else
		{
			Object ccdr;
			if(list.cdr instanceof PublicCloneable)
				ccdr = ((PublicCloneable)list.cdr).clone();
			else
				ccdr = list.cdr;
			return new Cons(ccar,ccdr);
		}
	} //}}}
}
