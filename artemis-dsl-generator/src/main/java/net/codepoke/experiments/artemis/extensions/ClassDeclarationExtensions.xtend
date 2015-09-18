package net.codepoke.experiments.artemis.extensions

import java.lang.reflect.Field
import java.util.List
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import java.util.ArrayList

class ClassDeclarationExtensions {
	
	/**
	 * Returns all matching fields that exist on a Class and any superclass.
	 */
	def static List<? extends FieldDeclaration> matchingFields(ClassDeclaration clzz, (FieldDeclaration)=>boolean match){
		
		val fields = new ArrayList(clzz.declaredFields.filter(match).toList);
		
		if(clzz.extendedClass != null){
			fields += matchingFields(clzz.extendedClass.type as ClassDeclaration, match) as List
		}
		
		return fields		
	}
	
}
