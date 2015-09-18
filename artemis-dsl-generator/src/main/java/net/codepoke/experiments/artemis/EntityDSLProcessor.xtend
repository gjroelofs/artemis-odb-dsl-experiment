package net.codepoke.experiments.artemis

import com.artemis.Component
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import com.artemis.Entity

@Active(EntityDSLProcessor)
annotation EntityDSL {
	
	Class<? extends Component> value;
	
}

class EntityDSLProcessor extends AbstractClassProcessor {
	
	static val String ARTEMIS_PACKAGE = "com.artemis.";
	
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		
		// First register the overloading classes (XEntity, XEntityManager)
		val overloadName = annotatedClass.simpleName;
		
		(ARTEMIS_PACKAGE + overloadName + "Entity").registerClass;
		(ARTEMIS_PACKAGE + overloadName + "EntityManager").registerClass;
		
		(ARTEMIS_PACKAGE + "Entity").registerClass;
	}

	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {

		val entityDSL = factory.findAnnotation(EntityDSL.findTypeGlobally)
			
		var baseEntity = context.findClass("com.artemis.Entity")
		var entityTemplate = Entity.findTypeGlobally
		
		

	}
	
}