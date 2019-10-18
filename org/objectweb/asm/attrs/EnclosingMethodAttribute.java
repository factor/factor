/**
 * ASM: a very small and fast Java bytecode manipulation framework
 * Copyright (c) 2000,2002,2003 INRIA, France Telecom
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Contact: Eric.Bruneton@rd.francetelecom.com
 *
 * Author: Eric Bruneton
 */

package org.objectweb.asm.attrs;

import java.util.Map;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;


/**
 * The EnclosingMethod attribute is an optional fixed-length attribute
 * in the attributes table of the ClassFile structure. A class must
 * have an EnclosingMethod attribute if and only if it is a local
 * class or an anonymous class. A class may have no more than one
 * EnclosingMethod attribute.
 * <p>
 * The EnclosingMethod attribute has the following format:
 * <pre>
 *   EnclosingMethod_attribute {
 *     u2 attribute_name;
 *     u4 attribute_length;
 *     u2 method_descriptor_index;
 *   }
 * </pre>
 * The items of the EnclosingMethod_attribute structure are as follows:
 * <dl>
 * <dt>attribute_name_index</dt>
 * <dd>The value of the attribute_name_index item must be a valid index
 * into the constant_pool table. The constant_pool entry at that index
 * must be a CONSTANT_Utf8_info structure representing the string
 * "EnclosingMethod".</dd>
 * <dt>attribute_length</dt>
 * <dd>The value of the attribute_length item is zero.</dd>
 * <dt>method_descriptor_index</dt>
 * <dd>The value of the method_descriptor_index item must be a valid
 * index into the constant_pool table. The constant_pool entry at that
 * index must be a CONSTANT_Utf8_info structure representing a valid
 * method descriptor (JLS 4.4.3). It is the responsibility of the
 * Java compiler to ensure that the method identified via the
 * method_descriptor_index is indeed the closest lexically enclosing
 * method of the class that contains this EnclosingMethod attribute.</dd>
 * </dl>
 *
 * @author Eugene Kuleshov
 */

public class EnclosingMethodAttribute extends Attribute implements Dumpable {

  public String methodDescriptor;

  public EnclosingMethodAttribute () {
    super("EnclosingMethod");
  }

  public EnclosingMethodAttribute (String methodDescriptor) {
    this();
    this.methodDescriptor = methodDescriptor;
  }

  protected Attribute read (ClassReader cr, int off,
                            int len, char[] buf, int codeOff, Label[] labels) {
    return new EnclosingMethodAttribute(cr.readUTF8(off, buf));
  }

  protected ByteVector write (ClassWriter cw, byte[] code,
                              int len, int maxStack, int maxLocals) {
    return new ByteVector().putShort(cw.newUTF8(methodDescriptor));
  }

  public void dump (StringBuffer buf, String varName, Map labelNames) {
    buf.append("EnclosingMethodAttribute ").append(varName)
      .append(" = new EnclosingMethodAttribute(\"")
      .append(methodDescriptor).append("\");\n");
  }

  public String toString () {
    return methodDescriptor;
  }
}
