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

public class JNew extends FactorWordDefinition
{
	//{{{ JNew constructor
	public JNew(FactorWord word)
	{
		super(word);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorDataStack datastack = interp.datastack;
		String name = (String)datastack.pop(String.class);
		Cons args = (Cons)datastack.pop(Cons.class);
		Constructor constructor = FactorJava.jconstructor(
			name,args);
		FactorJava.jnew(datastack,constructor);
	} //}}}

	//{{{ getStackEffect() method
	/**
	 * XXX: does not use factor type system conversions.
	 */
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler state) throws Exception
	{
		state.ensure(state.datastack,2);

		Object clazz = state.popLiteral();
		Object args = state.popLiteral();
		if(clazz instanceof String &&
			(args == null || args instanceof Cons))
		{
			Constructor constructor
				= FactorJava.jconstructor(
				(String)clazz,
				(Cons)args);

			int params = constructor.getParameterTypes().length;
			state.consume(state.datastack,params);
			state.push(null);
		}
		else
			throw new FactorCompilerException("Cannot deduce stack effect of " + word + " with non-literal arguments");;
	} //}}}

	//{{{ compileImmediate() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 * XXX: does not use factor type system conversions.
	 */
	public int compileImmediate(
		CodeVisitor mw,
		FactorCompiler compiler,
		RecursiveState recursiveCheck)
		throws Exception
	{
		Object _clazz = compiler.popLiteral();
		Object _args = compiler.popLiteral();
		if(_clazz instanceof String &&
			(_args == null || _args instanceof Cons))
		{
			String clazz = ((String)_clazz)
				.replace('.','/');
			Class[] args = FactorJava.classNameToClassList(
				(Cons)_args);

			mw.visitTypeInsn(NEW,clazz);
			mw.visitInsn(DUP);

			compiler.generateArgs(mw,args.length,args);

			mw.visitMethodInsn(INVOKESPECIAL,
				clazz,
				"<init>",
				FactorJava.javaSignatureToVMSignature(
				args,void.class));

			compiler.push(mw);

			return 3 + args.length;
		}
		else
			throw new FactorCompilerException("Cannot compile jnew with non-literal parameters");
	} //}}}
}
