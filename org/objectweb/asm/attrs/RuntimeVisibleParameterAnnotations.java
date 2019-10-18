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

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;

/**
 * The RuntimeVisibleParameterAnnotations attribute is a variable length attribute
 * in the attributes table of the method_info structure. The
 * RuntimeVisibleParameterAnnotations attribute records runtime-visible Java
 * programming language annotations on the parameters of the corresponding method.
 * Each method_info structure may contain at most one
 * RuntimeVisibleParameterAnnotations attribute, which records all the
 * runtime-visible Java programming language annotations on the parameters of the
 * corresponding method. The JVM must make these annotations available so they can
 * be returned by the appropriate reflective APIs.
 * <p>
 * The RuntimeVisibleParameterAnnotations attribute has the following format:
 * <pre>
 *   RuntimeVisibleParameterAnnotations_attribute {
 *     u2 attribute_name_index;
 *     u4 attribute_length;
 *     u1 num_parameters;
 *     {
 *       u2 num_annotations;
 *       annotation annotations[num_annotations];
 *     } parameter_annotations[num_parameters];
 *   }
 * <pre>
 * The items of the RuntimeVisibleParameterAnnotations structure are as follows:
 * <dl>
 * <dt>attribute_name_index</dt>
 * <dd>The value of the attribute_name_index item must be a valid index into the
 *     constant_pool table. The constant_pool entry at that index must be a
 *     CONSTANT_Utf8_info structure representing the string
 *     "RuntimeVisibleParameterAnnotations".</dd>
 * <dt>attribute_length</dt>
 * <dd>The value of the attribute_length item indicates the length of the attribute,
 *     excluding the initial six bytes. The value of the attribute_length item is
 *     thus dependent on the number of parameters, the number of runtime-visible
 *     annotations on each parameter, and their values.</dd>
 * <dt>num_parameters</dt>
 * <dd>The value of the num_parameters item gives the number of parameters of the
 *     method represented by the method_info structure on which the annotation
 *     occurs. (This duplicates information that could be extracted from the method
 *     descriptor.)</dd>
 * <dt>parameter_annotations</dt>
 * <dd>Each value of the parameter_annotations table represents all of the
 *     runtime-visible annotations on a single parameter. The sequence of values in
 *     the table corresponds to the sequence of parameters in the method signature.
 *     Each parameter_annotations entry contains the following two items:</dd>
 *     <dl>
 *     <dt>num_annotations</dt>
 *     <dd>The value of the num_annotations item indicates the number of runtime-visible
 *         annotations on the parameter corresponding to the sequence number of this
 *         parameter_annotations element.</dd>
 *     <dt>annotations</dt>
 *     <dd>Each value of the annotations table represents a single runtime-visible
 *         {@link org.objectweb.asm.attrs.Annotation annotation} on the parameter
 *         corresponding to the sequence number of this parameter_annotations element.</dd>
 *     </dl>
 *     </dd>
 * </dl>
 *
 * @see <a href="http://www.jcp.org/en/jsr/detail?id=175">JSR 175 : A Metadata
 * Facility for the Java Programming Language</a>
 *
 * @author Eugene Kuleshov
 */

public class RuntimeVisibleParameterAnnotations
  extends Attribute implements Dumpable
{

  public List parameters = new LinkedList();

  public RuntimeVisibleParameterAnnotations () {
    super("RuntimeVisibleParameterAnnotations");
  }

  protected Attribute read (ClassReader cr, int off,
                            int len, char[] buf, int codeOff, Label[] labels) {
    RuntimeInvisibleParameterAnnotations atr =
      new RuntimeInvisibleParameterAnnotations();
    Annotation.readParameterAnnotations(atr.parameters, cr, off, buf);
    return atr;
  }

  protected ByteVector write (ClassWriter cw, byte[] code,
                              int len, int maxStack, int maxLocals) {
    return Annotation.writeParametersAnnotations(
      new ByteVector(), parameters, cw);
  }

  public void dump (StringBuffer buf, String varName, Map labelNames) {
    buf.append("RuntimeVisibleParameterAnnotations ").append(varName)
      .append(" = new RuntimeVisibleParameterAnnotations();\n");
    Annotation.dumpParameterAnnotations(buf, varName, parameters);
  }

  public String toString () {
    return Annotation.stringParameterAnnotations(parameters);
  }
}
