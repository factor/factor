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

package factor.jedit;

import factor.*;
import java.awt.Component;
import javax.swing.*;
import org.gjt.sp.jedit.*;

public class FactorWordRenderer extends DefaultListCellRenderer
{
	private FactorInterpreter interp;

	public FactorWordRenderer(FactorInterpreter interp)
	{
		this.interp = interp;
	}

	public Component getListCellRendererComponent(
		JList list,
		Object value,
		int index,
		boolean isSelected,
		boolean cellHasFocus)
	{
		super.getListCellRendererComponent(list,value,index,
			isSelected,cellHasFocus);

		String prop = "factor.completion.plain";
		String stackEffect = null;

		if(!(value instanceof FactorWord))
			return this;

		FactorWord word = (FactorWord)value;
		if(word.def == null)
		{
			if(word.parsing != null)
				prop = "factor.completion.parsing";
			else
				prop = "factor.completion.defer";
		}
		else if(word.def instanceof FactorShuffleDefinition)
		{
			prop = "factor.completion.shuffle";
			StringBuffer buf = new StringBuffer();
			Cons def = word.def.toList(interp);
			while(def != null)
			{
				if(buf.length() != 0)
					buf.append(' ');

				buf.append(def.car);
				def = def.next();
			}
			stackEffect = buf.toString();
		}
		else
		{
			Cons def = word.def.toList(interp);
			if(def != null && def.car instanceof FactorDocComment)
			{
				FactorDocComment comment = (FactorDocComment)
					def.car;
				if(comment.isStackComment())
				{
					prop = "factor.completion.stack";
					stackEffect = comment.toString();
				}
			}
		}

		setText(jEdit.getProperty(prop,
			new String[] {
				MiscUtilities.charsToEntities(word.name),
				stackEffect == null
				? null :
				MiscUtilities.charsToEntities(stackEffect)
			}));

		return this;
	}
}
