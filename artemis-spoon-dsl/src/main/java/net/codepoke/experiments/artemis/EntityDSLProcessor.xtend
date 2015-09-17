package net.codepoke.experiments.artemis

import com.artemis.Component
import com.squareup.javapoet.JavaFile
import com.squareup.javapoet.MethodSpec
import com.squareup.javapoet.TypeSpec
import java.io.File
import java.util.List
import javax.lang.model.element.Modifier
import org.reflections.Reflections
import spoon.processing.AbstractAnnotationProcessor
import spoon.reflect.declaration.CtClass
import spoon.reflect.declaration.CtParameter
import spoon.reflect.declaration.CtTypeInformation
import spoon.reflect.reference.CtTypeReference
import spoon.reflect.visitor.Query
import spoon.reflect.visitor.filter.ReferenceTypeFilter
import spoon.support.reflect.declaration.CtClassImpl
import spoon.support.reflect.declaration.CtFieldImpl

import static spoon.reflect.declaration.ModifierKind.*
import spoon.support.reflect.code.CtStatementImpl
import spoon.support.reflect.code.CtBlockImpl

class EntityDSLProcessor extends AbstractAnnotationProcessor<EntityDSL, CtClass> {
		
	override process(EntityDSL annotation, CtClass element) {
		
		var reflections = new Reflections("");
 		val componentsDependencies = reflections.getSubTypesOf(Component)

		var components = Query.getElements(factory, [e |
			if(e instanceof CtClassImpl) e.inheritsFrom("com.artemis.Component")
		])
		var pos = factory.Type.createReference("components.Position");
			
		val idx = newIntArrayOfSize(1);
		for(component : components.map[it | it as CtClassImpl]){
			
			println(component.qualifiedName)
			
			val compFamilyID = idx.get(0);
			
			var extension typeFac = factory.Type;
						
			var field = factory.Field.create(element, #{PUBLIC, STATIC, FINAL}, int.createReference, component.simpleName.toUpperCase+"_ID")
			field.defaultExpression = factory.Core.createCodeSnippetExpression => [
				value = compFamilyID + "";
			];
			
			var List<CtParameter<?>> params = component.fields
				.filter[CtFieldImpl f | f.modifiers.contains(PUBLIC)]
				.map[ factory.Method.createParameter(null, type, component.simpleName) ].toList as List
				
			var methodBody = new CtBlockImpl();
			methodBody.addStatement(factory.Core.createCodeSnippetStatement => [
				
			])
			
			factory.Method.create(element, #{PUBLIC, STATIC}, void.createReference, "add"+component.simpleName, null, null, methodBody)
			
			idx.set(0, idx.get(0)+1);
		}
	
	}
	
	override processingDone() {
		
		var String[] s = #[""]
		
		var main = MethodSpec.methodBuilder("main")
		    .addModifiers(Modifier.PUBLIC, Modifier.STATIC)
		    .returns(void)
		    .addParameter(s.class, "args")
		    .addStatement("$T.out.println($S)", System, "Hello, JavaPoet!")
		    .build();
		
		var helloWorld = TypeSpec.classBuilder("HelloWorld")
		    .addModifiers(Modifier.PUBLIC, Modifier.FINAL)
		    .addMethod(main)
		    .build();
		
		var javaFile = JavaFile.builder("com.example.helloworld", helloWorld)
		    .build();
		
		javaFile.writeTo(new File("src/main/java"));
	}
	
	def generateComponentExtension(CtClass component, TypeSpec.Builder base){
		
//		FieldSpec.builder()
		
	}
	
	def static boolean inheritsFrom(CtTypeInformation element, String qualifiedName){
		if(element.qualifiedName.equals(qualifiedName))
			return true			
		else if(element.superclass != null)
			return inheritsFrom(element.superclass, qualifiedName)		
		
		return false
	}
	
}