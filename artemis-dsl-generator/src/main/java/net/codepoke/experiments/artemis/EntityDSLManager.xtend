package net.codepoke.experiments.artemis

import com.artemis.Component
import com.artemis.Entity
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import java.util.List
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.declaration.TypeReference

@Active(EntityDSLManagerProcessor)
annotation EntityDSLManager {

	/**
	 * The Components for which we need to add ComponentMapper initialization.
	 */
	Class<? extends Component>[] components;

	/**
	 * The target Entity class we extended with the DSL.
	 * (Can't target Entity as we're overloading it.)
	 */
	Class targetEntity;

}

/**
 * 
 */
class EntityDSLManagerProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {

		val entityComponents = factory.findAnnotation(EntityDSLManager.findTypeGlobally)
		val extension specialization = new EntityDSLDefinition();

		val components = entityComponents.getClassArrayValue("components").map[type as ClassDeclaration]
		val targetEntity = entityComponents.getClassValue("targetEntity").type
		
		// Add in the ComponentMapper lookup
		factory.addMethod("initialize") [
			visibility = Visibility.PROTECTED
			body = '''
				super.initialize();
				«FOR comp : components»
					«targetEntity.qualifiedName».«comp.getMapperName» = world.getMapper(«comp.qualifiedName».class);
				«ENDFOR»
			'''
		]
		
		factory.addMethod("createEntity") [
			visibility = Visibility.PROTECTED
			
			returnType = targetEntity.newTypeReference
			addParameter("id", int.newTypeReference)
			
			body = '''
				return new «targetEntity.qualifiedName»(world, id);
			'''
		]
	}
	
}