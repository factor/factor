/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2005 Slava Pestov.
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

package factor.jedit;

import factor.*;
import java.io.IOException;
import java.util.*;
import org.gjt.sp.jedit.io.VFSManager;
import org.gjt.sp.jedit.*;
import org.gjt.sp.util.*;

/**
 * A class used to compile all words in a file, or infer stack effects of all
 * words in a file, etc.
 */
public class InferBufferProcessor extends FactorBufferProcessor
{
	//{{{ createInferUnitTests() method
	public static void createInferUnitTests(View view,
		final Buffer buffer,
		final ExternalFactor factor)
	{
		final Buffer newBuffer = jEdit.newFile(view);
		VFSManager.runInAWTThread(new Runnable()
		{
			public void run()
			{
				newBuffer.setMode("factor");
				try
				{
					new InferBufferProcessor(buffer,factor)
						.insertResults(newBuffer,0);
				}
				catch(Exception e)
				{
					Log.log(Log.ERROR,this,e);
				}
			}
		});
	} //}}}
	
	//{{{ InferBufferProcessor constructor
	public InferBufferProcessor(Buffer buffer, ExternalFactor factor)
		throws Exception
	{
		super(buffer,factor);
	} //}}}
	
	//{{{ processWord() method
	/**
	 * @return Code to process the word.
	 */
	public String processWord(FactorWord word)
	{
		StringBuffer expression = new StringBuffer();
		expression.append(FactorPlugin.factorWord(word));
		expression.append(" unit infer>test print");
		return expression.toString();
	} //}}}
}
