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

import java.lang.reflect.*;

public abstract class FactorPrimitive extends FactorWordDefinition
{
	//{{{ P_callstackGet class
	static class P_callstackGet extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			interp.datastack.push(interp.callstack.clone());
		}
	} //}}}

	//{{{ P_callstackSet class
	static class P_callstackSet extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			interp.callstack = (FactorCallStack)((FactorCallStack)
				interp.datastack.pop(FactorCallStack.class))
				.clone();
		}
	} //}}}

	//{{{ P_datastackGet class
	static class P_datastackGet extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			interp.datastack.push(interp.datastack.clone());
		}
	} //}}}

	//{{{ P_datastackSet class
	static class P_datastackSet extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			interp.datastack = (FactorDataStack)((FactorDataStack)
				interp.datastack.pop(FactorDataStack.class))
				.clone();
		}
	} //}}}

	//{{{ P_clear class
	static class P_clear extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			interp.datastack.top = 0;
		}
	} //}}}

	//{{{ P_restack class
	static class P_restack extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorList list = (FactorList)datastack.pop(FactorList.class);
			interp.callstack.push(datastack);
			interp.datastack = new FactorDataStack(list);
		}
	} //}}}

	//{{{ P_unstack class
	static class P_unstack extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorList unstack = interp.datastack.toList();
			interp.datastack = (FactorDataStack)interp.callstack.pop();
			interp.datastack.push(unstack);
		}
	} //}}}

	//{{{ P_unwind class
	static class P_unwind extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			interp.callstack.top = 0;
		}
	} //}}}

	//{{{ P_jconstructor class
	static class P_jconstructor extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			datastack.push(
				FactorJava.jconstructor(
				(String)datastack.pop(String.class),
				(FactorList)datastack.pop(FactorList.class)));
		}
	} //}}}

	//{{{ P_jfield class
	static class P_jfield extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			datastack.push(
				FactorJava.jfield(
				(String)datastack.pop(String.class),
				(String)datastack.pop(String.class)));
		}
	} //}}}

	//{{{ P_jinvoke class
	static class P_jinvoke extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorJava.jinvoke(datastack,
				(Method)datastack.pop(),
				datastack.pop());
		}
	} //}}}

	//{{{ P_jinvokeStatic class
	static class P_jinvokeStatic extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorJava.jinvokeStatic(datastack,
				(Method)datastack.pop());
		}
	} //}}}

	//{{{ P_jmethod class
	static class P_jmethod extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			datastack.push(
				FactorJava.jmethod(
				(String)datastack.pop(String.class),
				(String)datastack.pop(String.class),
				(FactorList)datastack.pop(FactorList.class)));
		}
	} //}}}

	//{{{ P_jnew class
	static class P_jnew extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorJava.jnew(datastack,
				(Constructor)datastack.pop());
		}
	} //}}}

	//{{{ P_jvarGet class
	static class P_jvarGet extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			datastack.push(
				FactorJava.jvarGet(
				(Field)datastack.pop(Field.class),
				datastack.pop()));
		}
	} //}}}

	//{{{ P_jvarGetStatic class
	static class P_jvarGetStatic extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			datastack.push(
				FactorJava.jvarGetStatic(
				(Field)datastack.pop(Field.class)));
		}
	} //}}}

	//{{{ P_jvarSet class
	static class P_jvarSet extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorJava.jvarSet(
				(Field)datastack.pop(Field.class),
				datastack.pop(),
				datastack.pop());
		}
	} //}}}

	//{{{ P_jvarSetStatic class
	static class P_jvarSetStatic extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorJava.jvarSetStatic(
				(Field)datastack.pop(Field.class),
				datastack.pop());
		}
	} //}}}

	//{{{ P_get class
	static class P_get extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			datastack.push(interp.callframe.namespace.getVariable(
				(String)datastack.pop(String.class)));
		}
	} //}}}

	//{{{ P_set class
	static class P_set extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			interp.callframe.namespace.setVariable(
				(String)datastack.pop(String.class),
				datastack.pop());
		}
	} //}}}

	//{{{ P_swap_set class
	static class P_swap_set extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			interp.callframe.namespace._setVariable(datastack.pop(),
				(String)datastack.pop(String.class));
		}
	} //}}}

	//{{{ P_define class
	static class P_define extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorDictionary dict = interp.dict;
			// handle old define syntax
			Object obj = datastack.pop();
			if(obj instanceof FactorList)
				obj = new FactorCompoundDefinition((FactorList)obj);
			FactorWordDefinition def = (FactorWordDefinition)obj;

			FactorWord newWord = interp.dict.intern(
				(String)datastack.pop(String.class));

			def.precompile(newWord,interp);
			try
			{
				if(interp.compile)
					def = def.compile(newWord,interp);
			}
			catch(Throwable t)
			{
				System.err.println("WARNING: cannot compile " + newWord);
				t.printStackTrace();
			}

			if(newWord.def != FactorMissingDefinition.INSTANCE)
			{
				System.err.println("WARNING: redefining " + newWord);
				newWord.history = new FactorList(newWord.def,
					newWord.history);
			}
			newWord.def = def;
		}
	} //}}}

	//{{{ P_call class
	static class P_call extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			interp.call(word,(FactorList)interp.datastack.pop(
				FactorList.class));
		}
	} //}}}

	//{{{ P_bind class
	static class P_bind extends FactorPrimitive
	{
		public void eval(FactorWord word, FactorInterpreter interp)
			throws Exception
		{
			FactorDataStack datastack = interp.datastack;
			FactorList code = (FactorList)datastack.pop(FactorList.class);
			Object obj = datastack.pop();
			FactorNamespace ns;
			if(obj instanceof FactorNamespace)
				ns = (FactorNamespace)obj;
			else if(obj instanceof FactorObject)
			{
				ns = ((FactorObject)obj).getNamespace(interp);
				if(ns == null)
					throw new FactorRuntimeException(
						obj + " has a null"
						+ " namespace");
			}
			else
			{
				throw new FactorDomainException(obj,
					FactorObject.class);
			}
			interp.call(word,ns,code);
		}
	} //}}}
}
