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

public class JVarGet extends FactorPrimitiveDefinition
{
	//{{{ JVarGet constructor
	/**
	 * A new definition.
	 */
	public JVarGet(FactorWord word)
		throws Exception
	{
		super(word);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorArray datastack = interp.datastack;
		String fieldName = FactorJava.toString(datastack.pop());
		Class clazz = FactorJava.toClass(datastack.pop());
		Field field = clazz.getField(fieldName);
		Object obj = FactorJava.convertToJavaType(datastack.pop(),
			clazz);
		datastack.push(
			FactorJava.convertFromJavaType(
			field.get(obj)));
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
		String fieldName = FactorJava.toString(compiler.popLiteral());
		if(mw == null)
			compiler.ensure(compiler.datastack,Class.class);
		Class clazz = FactorJava.toClass(compiler.popLiteral());
		Field field = clazz.getField(fieldName);

		if(mw != null)
			FlowObject.generateToConversionPre(mw,field.getType());
		if(mw == null)
			compiler.ensure(compiler.datastack,clazz);
		compiler.pop(compiler.datastack,mw,clazz);

		if(mw != null)
		{
			mw.visitFieldInsn(GETFIELD,
				clazz.getName().replace('.','/'),
				fieldName,
				FactorJava.javaClassToVMClass(field.getType()));
		}

		compiler.push(compiler.datastack,mw,field.getType());
	} //}}}
}
