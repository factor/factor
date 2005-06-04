/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004, 2005 Slava Pestov.
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

import java.awt.event.*;
import java.awt.Dimension;
import javax.swing.*;
import org.gjt.sp.jedit.browser.*;
import org.gjt.sp.jedit.gui.RolloverButton;
import org.gjt.sp.jedit.*;

public class FactorOptionPane extends AbstractOptionPane
{
	//{{{ FactorOptionPane constructor
	public FactorOptionPane()
	{
		super("factor");
	} //}}}	
	
	//{{{ _init() method
	protected void _init()
	{
		ButtonGroup grp = new ButtonGroup();
		RadioAction h = new RadioAction();

		addComponent(jEdit.getProperty("options.factor.port"),
			port = new JTextField(jEdit.getProperty("factor.external.port")));
		
		addComponent(programType = new JRadioButton(jEdit.getProperty(
			"options.factor.type.program")));
		programType.addActionListener(h);
		grp.add(programType);
		
		addComponent(jEdit.getProperty("options.factor.program"),
			createProgramField(jEdit.getProperty("factor.external.program")));
		addComponent(jEdit.getProperty("options.factor.image"),
			createImageField(jEdit.getProperty("factor.external.image")));
		addComponent(jEdit.getProperty("options.factor.args"),
			createArgsField(jEdit.getProperty("factor.external.args")));
		
		addComponent(remoteType = new JRadioButton(jEdit.getProperty(
			"options.factor.type.remote")));
		remoteType.addActionListener(h);
		grp.add(remoteType);
		
		addComponent(jEdit.getProperty("options.factor.host"),
			host = new JTextField(jEdit.getProperty("factor.external.host")));
		
		String type = jEdit.getProperty("factor.external.type");
		if("program".equals(type))
			programType.setSelected(true);
		else
			remoteType.setSelected(true);
		
		updateEnabled();
	} //}}}
	
	//{{{ _save() method
	protected void _save()
	{
		if(programType.isSelected())
			jEdit.setProperty("factor.external.type","program");
		else
			jEdit.setProperty("factor.external.type","remote");
		jEdit.setProperty("factor.external.program",program.getText());
		jEdit.setProperty("factor.external.image",image.getText());
		jEdit.setProperty("factor.external.args",args.getText());
		jEdit.setProperty("factor.external.host",host.getText());
		jEdit.setProperty("factor.external.port",port.getText());
	} //}}}
	
	//{{{ Private members
	private JTextField port;
	private JRadioButton programType;
	private JTextField program;
	private JTextField image;
	private JTextField args;
	private JRadioButton remoteType;
	private JTextField host;

	//{{{ createProgramField() metnod
	private JComponent createProgramField(String text)
	{
		program = new JTextField(text);
		return createFieldAndButton(program);
	} //}}}
	
	//{{{ createImageField() metnod
	private JComponent createImageField(String text)
	{
		image = new JTextField(text);
		return createFieldAndButton(image);
	} //}}}
	
	//{{{ createArgsField() metnod
	private JComponent createArgsField(String text)
	{
		args = new JTextField(text);
		return args;
	} //}}}
	
	//{{{ createFieldAndButton() metnod
	private JComponent createFieldAndButton(JTextField field)
	{
		Box h = new Box(BoxLayout.X_AXIS);
		Box v = new Box(BoxLayout.Y_AXIS);
		v.add(Box.createGlue());
		v.add(field);
		Dimension size = field.getPreferredSize();
		size.width = Integer.MAX_VALUE;
		field.setMaximumSize(size);
		v.add(Box.createGlue());
		h.add(v);
		h.add(Box.createHorizontalStrut(12));

		JButton button = new RolloverButton(
			GUIUtilities.loadIcon("Open.png"));
		button.setToolTipText(jEdit.getProperty("options.factor.choose"));
		button.addActionListener(new ChooseFileAction(field));

		h.add(button);
		return h;
	} //}}}

	//{{{ updateEnabled() method
	private void updateEnabled()
	{
		boolean b = programType.isSelected();
		program.setEnabled(b);
		image.setEnabled(b);
		args.setEnabled(b);
		host.setEnabled(!b);
	} //}}}

	//}}}
	
	//{{{ ChooseFileAction class
	class ChooseFileAction implements ActionListener
	{
		private JTextField field;
		
		ChooseFileAction(JTextField field)
		{
			this.field = field;
		}
		
		public void actionPerformed(ActionEvent evt)
		{
			String[] paths = GUIUtilities.showVFSFileDialog(
				GUIUtilities.getView(FactorOptionPane.this),
				field.getText(),
				VFSBrowser.OPEN_DIALOG,
				false);
			if(paths == null)
				return;
			field.setText(paths[0]);
		}
	} //}}}
	
	//{{{ RadioAction class
	class RadioAction implements ActionListener
	{
		public void actionPerformed(ActionEvent evt)
		{
			updateEnabled();
		}
	} //}}}
}
