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
import java.util.Map;
import org.objectweb.asm.*;

public class JInvoke extends FactorPrimitiveDefinition
{
	public boolean staticMethod;

	//{{{ JInvoke constructor
	/**
	 * A new definition.
	 */
	public JInvoke(FactorWord word, boolean staticMethod)
		throws Exception
	{
		super(word);
		this.staticMethod = staticMethod;
	} //}}}

	//{{{ checkStatic() method
	private void checkStatic(Method method) throws FactorRuntimeException
	{
		if(staticMethod)
		{
			if(!Modifier.isStatic(method.getModifiers()))
				throw new FactorRuntimeException(
					"Use jinvoke with static methods");
		}
		else
		{
			if(Modifier.isStatic(method.getModifiers()))
				throw new FactorRuntimeException(
					"Use jinvoke-static with static methods");
		}
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorArray datastack = interp.datastack;
		String name = FactorJava.toString(datastack.pop());
		Class clazz = FactorJava.toClass(datastack.pop());
		Cons args = (Cons)datastack.pop();
		Class[] _args = FactorJava.classNameToClassList(args);
		Method method = clazz.getMethod(name,_args);

		checkStatic(method);

		Object instance;
		if(staticMethod)
			instance = null;
		else
		{
			instance = FactorJava.convertToJavaType(
				datastack.pop(),clazz);
		}

		Object[] params = new Object[_args.length];

		try
		{
			for(int i = params.length - 1; i >= 0; i--)
			{
				params[i] = FactorJava.convertToJavaType(
					datastack.pop(),_args[i]);
			}

			if(method.getReturnType() == Void.TYPE)
				method.invoke(instance,params);
			else
			{
				datastack.push(FactorJava.convertFromJavaType(
					method.invoke(instance,params)));
			}
		}
		catch(FactorStackException e)
		{
			throw new FactorStackException(_args.length);
		}
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler compiler) throws Exception
	{
		compileImmediate(null,compiler,recursiveCheck);
	} //}}}

	//{{{ compileImmediate() method
	public void compileImmediate(
		CodeVisitor mw,
		FactorCompiler compiler,
		RecursiveState recursiveCheck)
		throws Exception
	{
		if(mw == null)
			compiler.ensure(compiler.datastack,String.class);
		String name = FactorJava.toString(compiler.popLiteral());
		if(mw == null)
			compiler.ensure(compiler.datastack,Class.class);
		Class clazz = FactorJava.toClass(compiler.popLiteral());
		if(mw == null)
			compiler.ensure(compiler.datastack,Cons.class);
		Cons args = (Cons)compiler.popLiteral();

		Class[] _args = FactorJava.classNameToClassList(args);
		Method method = clazz.getMethod(name,_args);

		checkStatic(method);

		Class returnType = method.getReturnType();

		if(mw != null)
			FlowObject.generateToConversionPre(mw,returnType);

		if(!staticMethod)
		{
			if(mw == null)
				compiler.ensure(compiler.datastack,clazz);
			compiler.pop(compiler.datastack,mw,clazz);
		}

		if(mw == null)
			compiler.ensure(compiler.datastack,_args);

		compiler.generateArgs(mw,_args.length,0,_args);

		if(mw != null)
		{
			int opcode;
			if(staticMethod)
				opcode = INVOKESTATIC;
			else if(clazz.isInterface())
				opcode = INVOKEINTERFACE;
			else
				opcode = INVOKEVIRTUAL;
			mw.visitMethodInsn(opcode,
				clazz.getName().replace('.','/'),
				name,
				FactorJava.javaSignatureToVMSignature(
				_args,returnType));
		}

		if(returnType != Void.TYPE)
			compiler.push(compiler.datastack,mw,returnType);
	} //}}}
}
