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

import java.lang.reflect.*;
import org.objectweb.asm.*;

/**
 * : name ... ;
 */
public class FactorCompoundDefinition extends FactorWordDefinition
{
	public FactorList definition;

	public FactorCompoundDefinition(FactorList definition)
	{
		this.definition = definition;
	}

	public void eval(FactorWord word, FactorInterpreter interp)
		throws Exception
	{
		interp.call(word,definition);
	}

	//{{{ canCompile() method
	boolean canCompile()
	{
		return true;
	} //}}}

	//{{{ compile() method
	/**
	 * Write the definition of the eval() method in the compiled word.
	 * Local 0 -- this
	 * Local 1 -- word
	 * Local 2 -- interpreter
	 */
	boolean compile(FactorWord word, FactorInterpreter interp,
		ClassWriter cw, CodeVisitor mw)
		throws Exception
	{
		if(definition == null)
		{
			mw.visitInsn(RETURN);
			// Max stack and locals
			mw.visitMaxs(1,1);
			return true;
		}

		FactorList fdef = compilePass1(interp,definition);
		if(fdef.car instanceof FactorReflectionForm
			&& fdef.cdr == null)
		{
			return ((FactorReflectionForm)fdef.car).compile(
				word,interp,cw,mw);
		}
		/* else
			System.err.println("WARNING: cannot compile reflection & more"); */

		return false;
	} //}}}

	//{{{ compilePass1() method
	/**
	 * Turn reflection calls into ReflectionForm objects.
	 */
	private FactorList compilePass1(FactorInterpreter interp, FactorList def)
	{
		if(!def.isProperList())
			return def;

		FactorList rdef = def.reverse();

		FactorDictionary dict = interp.dict;

		// A list of words and Java reflection forms
		FactorList fdef = null;
		while(rdef != null)
		{
			Object car = rdef.car;
			if(car == dict.jvarGet
				|| car == dict.jvarSet
				|| car == dict.jvarGetStatic
				|| car == dict.jvarSetStatic
				|| car == dict.jnew)
			{
				FactorList form = rdef;
				rdef = form._get(3);
				fdef = new FactorList(new FactorReflectionForm(form),
					fdef);
			}
			else if(car == dict.jinvoke
				|| car == dict.jinvokeStatic)
			{
				FactorList form = rdef;
				rdef = form._get(4);
				fdef = new FactorList(new FactorReflectionForm(form),
					fdef);
			}
			else if(car instanceof FactorList)
			{
				fdef = new FactorList(compilePass1(
					interp,((FactorList)car)),fdef);
			}
			else
				fdef = new FactorList(car,fdef);

			rdef = rdef.next();
		}

		return fdef;
	} //}}}

	//{{{ precompile() method
	void precompile(FactorWord newWord, FactorInterpreter interp)
		throws Exception
	{
		FactorDictionary dict = interp.dict;

		if(definition != null)
		{
			FactorList before = definition;
			FactorList fed = definition.reverse();
			precompile(interp,newWord,fed);
			definition = fed.reverse();
			/* if(!def.equals(before))
			{
				System.out.println("BEFORE: " + before);
				System.out.println("AFTER: " + def);
			} */
		}
	} //}}}

	//{{{ precompile() method
	/**
	 * Precompiling turns jconstructor, jfield and jmethod calls
	 * with all-literal arguments into inline
	 * Constructor/Field/Method literals. This improves performance.
	 */
	private void precompile(FactorInterpreter interp,
		FactorWord newWord, FactorList list)
		throws Exception
	{
		if(interp.compile)
			return;

		FactorDictionary dict = interp.dict;

		while(list != null)
		{
			Object o = list.car;
			if(o instanceof FactorWord)
			{
				FactorWord word = (FactorWord)o;
				if(word.def != FactorMissingDefinition.INSTANCE)
				{
					word.def.references++;
				}
				else
				{
					/*System.err.println(
						"WARNING: "
						+ newWord
						+ " references "
						+ o
						+ " before its defined");*/
				}

				if(o == dict.jconstructor)
				{
					jconstructorPrecompile(
						interp,list);
				}
				else if(o == dict.jmethod)
				{
					jmethodPrecompile(
						interp,list);
				}
				else if(o == dict.jfield)
				{
					jfieldPrecompile(
						interp,list);
				}
			}
			else if(o instanceof FactorList)
			{
				if(((FactorList)o).isProperList())
				{
					FactorList l = (FactorList)o;
					FactorList _l = l.reverse();
					precompile(interp,newWord,_l);
					list.car = _l.reverse();
				}
			}
			list = list.next();
		}
	} //}}}

	//{{{ jconstructorPrecompile() method
	private void jconstructorPrecompile(
		FactorInterpreter interp, FactorList list)
		throws Exception
	{
		FactorList cdr = list.next();
		if(cdr == null)
			return;
		if(!(cdr.car instanceof String))
			return;
		String clazz = (String)cdr.car;

		FactorList cddr = cdr.next();
		if(cddr == null)
			return;
		if(!(cddr.car instanceof FactorList))
			return;
		FactorList args = (FactorList)cddr.car;

		Constructor c = FactorJava.jconstructor(clazz,args);

		list.car = c;
		list.cdr = cddr.next();
	} //}}}

	//{{{ jfieldPrecompile() method
	private void jfieldPrecompile(
		FactorInterpreter interp, FactorList list)
		throws Exception
	{
		FactorList cdr = list.next();
		if(cdr == null)
			return;
		if(!(cdr.car instanceof String))
			return;
		String field = (String)cdr.car;

		FactorList cddr = cdr.next();
		if(cddr == null)
			return;
		if(!(cddr.car instanceof String))
			return;
		String clazz = (String)cddr.car;

		Field f = FactorJava.jfield(field,clazz);

		list.car = f;
		list.cdr = cddr.next();
	} //}}}

	//{{{ jmethodPrecompile() method
	/**
	 * Check if this jmethod has all-literal arguments, and if so,
	 * inline the result.
	 */
	private void jmethodPrecompile(
		FactorInterpreter interp, FactorList list)
		throws Exception
	{
		FactorList cdr = list.next();
		if(cdr == null)
			return;
		if(!(cdr.car instanceof String))
			return;
		String method = (String)cdr.car;

		FactorList cddr = cdr.next();
		if(cddr == null)
			return;
		if(!(cddr.car instanceof String))
			return;
		String clazz = (String)cddr.car;

		FactorList cdddr = cddr.next();
		if(cdddr == null)
			return;
		if(!(cdddr.car instanceof FactorList))
			return;
		FactorList args = (FactorList)cdddr.car;

		Method m = FactorJava.jmethod(method,clazz,args);

		list.car = m;
		list.cdr = cdddr.next();
	} //}}}

	public String toString()
	{
		return definition.elementsToString();
	}
}
