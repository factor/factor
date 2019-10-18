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

public class JVarSetStatic extends FactorWordDefinition
{
	//{{{ JVarSetStatic constructor
	public JVarSetStatic(FactorWord word)
	{
		super(word);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorDataStack datastack = interp.datastack;
		Field field = FactorJava.jfield(
			(String)datastack.pop(String.class),
			(String)datastack.pop(String.class));
		FactorJava.jvarSetStatic(
			field,datastack.pop());
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler state) throws FactorStackException
	{
		state.ensure(state.datastack,3);
		state.pop(null);
		state.pop(null);
		state.pop(null);
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 * XXX: does not use factor type system conversions.
	 */
	public int compileCallTo(
		CodeVisitor mw,
		FactorCompiler compiler,
		RecursiveState recursiveCheck)
		throws Exception
	{
		Object _field = compiler.popLiteral();
		Object _clazz = compiler.popLiteral();
		if(_clazz instanceof String &&
			_field instanceof String)
		{
			String field = (String)_field;
			String clazz = (String)_clazz;
			Class cls = FactorJava.getClass(clazz);
			clazz = clazz.replace('.','/');
			Field fld = cls.getField(field);

			compiler.pop(mw);
			FactorJava.generateFromConversion(mw,fld.getType());

			mw.visitFieldInsn(PUTSTATIC,
				clazz,
				field,
				FactorJava.javaClassToVMClass(fld.getType()));

			return 2;
		}
		else
			throw new FactorCompilerException("Cannot compile jvar-static@ with non-literal parameters");
	} //}}}
}
