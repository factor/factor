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

import factor.listener.FactorListenerPanel;
import factor.FactorInterpreter;
import java.io.InputStreamReader;
import org.gjt.sp.jedit.gui.*;
import org.gjt.sp.jedit.*;

public class FactorPlugin extends EditPlugin
{
	private static final String DOCKABLE_NAME = "factor";

	private static FactorInterpreter interp;

	//{{{ start() method
	public void start()
	{
		String path = "/factor/jedit/factor.bsh";
		BeanShell.runScript(null,path,new InputStreamReader(
			getClass().getResourceAsStream(path)),false);
	} //}}}

	//{{{ getInterpreter() method
	/**
	 * This can be called from the SideKick thread and must be thread safe.
	 */
	public static synchronized FactorInterpreter getInterpreter()
	{
		if(interp == null)
		{
			interp = FactorListenerPanel.newInterpreter(
				new String[] { "-jedit" });
		}

		return interp;
	} //}}}
	
	//{{{ eval() method
	public static void eval(View view, String cmd)
	{
		DockableWindowManager wm = view.getDockableWindowManager();
		wm.addDockableWindow(DOCKABLE_NAME);
		FactorListenerPanel panel = (FactorListenerPanel)
			wm.getDockableWindow(DOCKABLE_NAME);
		panel.getListener().eval(cmd);
	} //}}}
}
