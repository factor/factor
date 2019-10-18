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

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.TreeMap;
import java.util.Iterator;
import java.util.Map;

/**
 * A namespace is a list of name/value bindings. A namespace can optionally
 * have a bound object, in which case every public field of the
 * object will be accessible through the namespace. Additionally, static fields
 * from arbitrary classes can be imported into the namespace.
 */
public class FactorNamespace implements PublicCloneable, FactorObject
{
	private static FactorWord NULL = new FactorWord(null,"#<represent-f>");
	private static FactorWord CHECK_PARENT = new FactorWord(null,"#<check-parent>");

	public Object obj;
	protected Map words;
	private Class constraint;

	//{{{ createConstrainedNamespace() method
	/**
	 * Used for dictionary.
	 */
	public static FactorNamespace createConstrainedNamespace(
		Class constraint) throws Exception
	{
		FactorNamespace namespace = new FactorNamespace(null,null);
		namespace.constraint = constraint;
		return namespace;
	} //}}}

	//{{{ FactorNamespace constructor
	public FactorNamespace()
	{
		this.words = new TreeMap();
	} //}}}

	//{{{ FactorNamespace constructor
	public FactorNamespace(Object obj) throws Exception
	{
		this(null,obj);
	} //}}}

	//{{{ FactorNamespace constructor
	/**
	 * Cloning constructor.
	 */
	public FactorNamespace(Map words, Object obj)
	{
		this.words = new TreeMap();

		// used by clone()
		if(words != null)
		{
			Iterator iter = words.entrySet().iterator();
			while(iter.hasNext())
			{
				Map.Entry entry = (Map.Entry)iter.next();
				Object key = entry.getKey();
				Object value = entry.getValue();
				if(value instanceof VarBinding)
				{
					VarBinding b = (VarBinding)value;
					if(b.instance != null)
						continue;
				}

				this.words.put(key,value);
			}
		}

		this.obj = obj;
	} //}}}

	//{{{ getNamespace() method
	public FactorNamespace getNamespace()
	{
		return this;
	} //}}}

	//{{{ getThis() method
	/**
	 * Returns the object bound to this namespace, or null.
	 */
	public Object getThis()
	{
		return obj;
	} //}}}

	//{{{ importVars() method
	/**
	 * Defines a variable bound to a Java field.
	 */
	public synchronized void importVars(String clazz, Cons vars)
		throws Exception
	{
		Class clas = Class.forName(clazz);
		while(vars != null)
		{
			String field = (String)vars.car(String.class);
			vars = vars.next();
			String word = (String)vars.car(String.class);

			setVariable(word,new VarBinding(
				clas.getField(field),
				null));

			vars = vars.next();
		}
	} //}}}

	//{{{ isDefined() method
	public synchronized boolean isDefined(String name)
	{
		Object o = words.get(name);
		if(o instanceof VarBinding)
			return true;
		else if(o == NULL)
			return true;
		else if(o == CHECK_PARENT)
			return false;
		else if(o == null)
		{
			// lazily instantiate object field binding
			if(obj == null)
				return false;
			else
			{
				lazyFieldInit(name);
				return isDefined(name);
			}
		}
		else
			return true;
	} //}}}

	//{{{ getVariable() method
	public synchronized Object getVariable(String name)
	{
		Object o = words.get(name);
		if(o instanceof VarBinding)
			return ((VarBinding)o).get();
		else if(o == NULL)
			return null;
		else if(o == CHECK_PARENT)
		{
			// we know this is not a field binding
			return null;
		}
		else if(o == null)
		{
			// lazily instantiate object field binding
			if(obj == null)
				return null;
			else
			{
				lazyFieldInit(name);
				return getVariable(name);
			}
		}
		else
			return o;
	} //}}}

	//{{{ setVariable() method
	public synchronized void setVariable(String name, Object value)
	{
		if(name == null)
			throw new NullPointerException();

		Object o = words.get(name);
		if(o instanceof VarBinding && !(value instanceof VarBinding))
			((VarBinding)o).set(value);
		else if(o == null)
		{
			// lazily instantiate object field binding
			if(obj == null)
			{
				if(value == null)
					words.put(name,NULL);
				else
					words.put(name,value);
			}
			else
			{
				lazyFieldInit(name);
				setVariable(name,value);
			}
		}
		else if(value == null)
			words.put(name,NULL);
		else
		{
			if(constraint != null)
			{
				if(!constraint.isAssignableFrom(
					value.getClass()))
				{
					throw new RuntimeException(
						"Can only store "
						+ constraint
						+ " in " + this);
				}
			}
			words.put(name,value);
		}
	} //}}}

	//{{{ lazyFieldInit() method
	protected void lazyFieldInit(String name)
	{
		try
		{
			Field f = obj.getClass().getField(name);
			if(!Modifier.isStatic(f.getModifiers()))
			{
				words.put(name,new VarBinding(f,obj));
				return;
			}
		}
		catch(Exception e)
		{
		}

		// not a field, don't check again
		words.put(name,CHECK_PARENT);
	} //}}}

	//{{{ initAllFields() method
	private void initAllFields()
	{
		if(obj != null)
		{
			try
			{
				Field[] fields = obj.getClass().getFields();
				for(int i = 0; i < fields.length; i++)
				{
					Field f = fields[i];
					if(Modifier.isStatic(f.getModifiers()))
						continue;
					words.put(f.getName(),
						new VarBinding(f,obj));
				}
			}
			catch(Exception e)
			{
			}
		}
	} //}}}

	//{{{ toVarList() method
	/**
	 * Returns a list of variable names.
	 */
	public synchronized Cons toVarList()
	{
		initAllFields();

		Cons first = null;
		Cons last = null;
		Iterator iter = words.keySet().iterator();
		while(iter.hasNext())
		{
			String key = (String)iter.next();
			if(words.get(key) != CHECK_PARENT)
			{
				Cons cons = new Cons(key,null);
				if(first == null)
					first = last = cons;
				else
				{
					last.cdr = cons;
					last = cons;
				}
			}
		}

		return first;
	} //}}}

	//{{{ toValueList() method
	/**
	 * Returns a list of variable values.
	 */
	public synchronized Cons toValueList()
	{
		initAllFields();

		Cons first = null;
		Cons last = null;
		Cons vars = toVarList();
		while(vars != null)
		{
			String key = (String)vars.car;
			Cons cons = new Cons(getVariable(key),null);
			if(first == null)
				first = last = cons;
			else
			{
				last.cdr = cons;
				last = cons;
			}
			vars = vars.next();
		}

		return first;
	} //}}}

	//{{{ toVarValueList() method
	/**
	 * Returns a list of pairs of variable names, and their values.
	 */
	public synchronized Cons toVarValueList()
	{
		initAllFields();

		Cons first = null;
		Cons last = null;
		Cons vars = toVarList();
		while(vars != null)
		{
			String key = (String)vars.car;

			Object value = getVariable(key);
			Cons cons = new Cons(new Cons(key,value),null);
			if(first == null)
				first = last = cons;
			else
			{
				last.cdr = cons;
				last = cons;
			}
			vars = vars.next();
		}

		return first;
	} //}}}

	//{{{ VarBinding class
	/**
	 * This is messy.
	 */
	public static class VarBinding
	{
		private Field field;
		private Object instance;

		public VarBinding(Field field, Object instance)
			throws FactorRuntimeException
		{
			this.field = field;
			this.instance = instance;
		}

		public Object get()
		{
			try
			{
				return FactorJava.convertFromJavaType(
					field.get(instance));
			}
			catch(Exception e)
			{
				throw new RuntimeException(e);
			}
		}

		public void set(Object value)
		{
			try
			{
				field.set(instance,FactorJava.convertToJavaType(
					value,field.getType()));
			}
			catch(Exception e)
			{
				throw new RuntimeException(e);
			}
		}
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		initAllFields();

		String str = getClass().getName() + ", " + words.size()
			+ " items";

		if(obj == null)
			return str;
		else
			return str + ", bound: " + obj;
	} //}}}

	//{{{ clone() method
	public FactorNamespace clone(Object rebind)
	{
		if(rebind.getClass() != obj.getClass())
			throw new RuntimeException("Cannot rebind to different type");

		try
		{
			return new FactorNamespace(words,rebind);
		}
		catch(Exception e)
		{
			throw new InternalError();
		}
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		if(obj != null)
			throw new RuntimeException("Cannot clone namespace that's bound to an object");

		try
		{
			return new FactorNamespace(new TreeMap(words),null);
		}
		catch(Exception e)
		{
			throw new InternalError();
		}
	} //}}}
}
