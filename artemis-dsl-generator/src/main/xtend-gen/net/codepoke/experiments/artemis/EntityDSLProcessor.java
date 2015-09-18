package net.codepoke.experiments.artemis;

import com.google.common.base.Objects;
import com.squareup.javapoet.JavaFile;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import java.util.ArrayList;
import java.util.List;
import javax.lang.model.element.Modifier;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import spoon.processing.AbstractProcessor;
import spoon.reflect.declaration.CtClass;
import spoon.reflect.declaration.CtTypeInformation;
import spoon.reflect.reference.CtTypeReference;

@SuppressWarnings("all")
public class EntityDSLProcessor extends AbstractProcessor<CtClass> {
  private ArrayList<CtClass> components = new ArrayList<CtClass>();
  
  public void process(final CtClass element) {
    CtTypeReference _reference = element.getReference();
    boolean _inheritsFrom = EntityDSLProcessor.inheritsFrom(_reference, "com.artemis.Component");
    boolean _not = (!_inheritsFrom);
    if (_not) {
      return;
    }
    this.components.add(element);
  }
  
  public void processingDone() {
    try {
      String[] s = { "" };
      MethodSpec.Builder _methodBuilder = MethodSpec.methodBuilder("main");
      MethodSpec.Builder _addModifiers = _methodBuilder.addModifiers(Modifier.PUBLIC, Modifier.STATIC);
      MethodSpec.Builder _returns = _addModifiers.returns(void.class);
      final String[] _converted_s = (String[])s;
      Class<? extends List> _class = ((List<String>)Conversions.doWrapArray(_converted_s)).getClass();
      MethodSpec.Builder _addParameter = _returns.addParameter(_class, "args");
      MethodSpec.Builder _addStatement = _addParameter.addStatement("$T.out.println($S)", System.class, "Hello, JavaPoet!");
      MethodSpec main = _addStatement.build();
      TypeSpec.Builder _classBuilder = TypeSpec.classBuilder("HelloWorld");
      TypeSpec.Builder _addModifiers_1 = _classBuilder.addModifiers(Modifier.PUBLIC, Modifier.FINAL);
      TypeSpec.Builder _addMethod = _addModifiers_1.addMethod(main);
      TypeSpec helloWorld = _addMethod.build();
      JavaFile.Builder _builder = JavaFile.builder("com.example.helloworld", helloWorld);
      JavaFile javaFile = _builder.build();
      javaFile.writeTo(System.out);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public static boolean inheritsFrom(final CtTypeInformation element, final String qualifiedName) {
    String _qualifiedName = element.getQualifiedName();
    boolean _equals = _qualifiedName.equals(qualifiedName);
    if (_equals) {
      return true;
    } else {
      CtTypeReference<?> _superclass = element.getSuperclass();
      boolean _notEquals = (!Objects.equal(_superclass, null));
      if (_notEquals) {
        CtTypeReference<?> _superclass_1 = element.getSuperclass();
        return EntityDSLProcessor.inheritsFrom(_superclass_1, qualifiedName);
      }
    }
    return false;
  }
}
