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
import factor.db.*;
import factor.*;
import java.util.Set;
import org.objectweb.asm.*;

public class InterpreterGet extends FactorPrimitiveDefinition
{
	//{{{ InterpreterGet constructor
	/**
	 * A new definition.
	 */
	public InterpreterGet(FactorWord word, Workspace workspace)
		throws Exception
	{
		super(word,workspace);
	} //}}}

	//{{{ InterpreterGet constructor
	/**
	 * A blank definition, about to be unpickled.
	 */
	public InterpreterGet(Workspace workspace, long id)
		throws Exception
	{
		super(workspace,id);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		interp.datastack.push(interp);
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
		if(mw != null)
			mw.visitVarInsn(ALOAD,0);
		compiler.push(compiler.datastack,mw,FactorInterpreter.class);
	} //}}}
}
