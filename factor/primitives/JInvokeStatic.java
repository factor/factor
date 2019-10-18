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

package factor.primitives;

import factor.compiler.*;
import factor.*;
import java.lang.reflect.*;
import java.util.Set;
import org.objectweb.asm.*;

public class JInvokeStatic extends FactorWordDefinition
{
	//{{{ JInvokeStatic constructor
	public JInvokeStatic(FactorWord word)
	{
		super(word);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorDataStack datastack = interp.datastack;
		Method method = FactorJava.jmethod(
			(String)datastack.pop(String.class),
			(String)datastack.pop(String.class),
			(Cons)datastack.pop(Cons.class));
		FactorJava.jinvokeStatic(datastack,method);
	} //}}}

	//{{{ getStackEffect() method
	public StackEffect getStackEffect(Set recursiveCheck,
		LocalAllocator state) throws Exception
	{
		state.ensure(state.datastack,3);
		Object clazz = state.popLiteral();
		Object name = state.popLiteral();
		Object args = state.popLiteral();

		if(clazz instanceof String &&
			name instanceof String &&
			(args == null || args instanceof Cons))
		{
			Method method = FactorJava.jmethod(
				(String)clazz,
				(String)name,
				(Cons)args);

			boolean returnValue = method.getReturnType() == Void.TYPE;
			if(returnValue)
				state.push(null);
			return new StackEffect(
				3 + method.getParameterTypes().length,
				returnValue ? 0 : 1,0,0);
		}
		else
			return null;
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 * XXX: does not use factor type system conversions.
	 */
	public int compileCallTo(
		CodeVisitor mw,
		LocalAllocator allocator,
		Set recursiveCheck)
		throws Exception
	{
		Object _method = allocator.popLiteral();
		Object _clazz = allocator.popLiteral();
		Object _args = allocator.popLiteral();
		if(_method instanceof String &&
			_clazz instanceof String &&
			(_args == null || _args instanceof Cons))
		{
			String method = (String)_method;
			String clazz = (String)_clazz;
			Class[] args = FactorJava.classNameToClassList(
				(Cons)_args);
			Class cls = FactorJava.getClass(clazz);
			Method mth = cls.getMethod(method,args);
			Class returnType = mth.getReturnType();

			clazz = clazz.replace('.','/');

			FactorJava.generateToConversionPre(mw,returnType);

			allocator.generateArgs(mw,args.length,args);

			mw.visitMethodInsn(INVOKESTATIC,
				clazz,
				method,
				FactorJava.javaSignatureToVMSignature(
				args,returnType));

			if(returnType != Void.TYPE)
			{
				FactorJava.generateToConversion(mw,returnType);
				allocator.push(mw);
			}

			return 4 + args.length;
		}
		else
			throw new FactorCompilerException("Cannot compile jinvoke with non-literal parameters");
	} //}}}
}
