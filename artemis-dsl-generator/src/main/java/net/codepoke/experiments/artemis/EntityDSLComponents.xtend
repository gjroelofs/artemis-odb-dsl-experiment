package net.codepoke.experiments.artemis

import com.artemis.Component
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Active(EntityDSLComponentsProcessor)
annotation EntityDSLComponents {

	Class<? extends Component>[] value;

}

/**
 * Adds in the Component DSL which either delegate to ComponentMappers (subclasses of Entity), or use naive getComponent lookup for the base Entity class.
 */
class EntityDSLComponentsProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {

		val entityComponents = factory.findAnnotation(EntityDSLComponents.findTypeGlobally)
		var extensionEntity = factory.extendedClass != Object.newTypeReference;
		
		var extension specialization = new EntityDSLDefinition();

		// Define the non-naive implementation
		for (component : entityComponents.getClassArrayValue("value")) {
			if (extensionEntity)
				factory.implementComponentDSLSpecialization(context, component.type as ClassDeclaration)
			else 
				factory.implementComponentDSLNaive(context, component.type as ClassDeclaration)
		}

	}

}