/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004 Slava Pestov.
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

package factor.parser;

import factor.*;
import factor.math.*;

public class ComplexLiteral extends FactorParsingDefinition
{
	private String end;

	//{{{ ComplexLiteral constructor
	/**
	 * A new definition.
	 */
	public ComplexLiteral(FactorWord word, String end)
	{
		super(word);
		this.end = end;
	} //}}}

	public void eval(FactorReader reader)
		throws Exception
	{
		// Read two numbers
		Number real = FactorLib.toNumber(
			reader.nextNonEOL(true,false));
		Number imaginary = FactorLib.toNumber(
			reader.nextNonEOL(true,false));

		// Read the end
		String end = (String)reader.nextNonEOL(false,false);
		if(!end.equals(this.end))
			reader.error("Expected " + this.end);

		reader.append(Complex.valueOf(real,imaginary));
	}
}
