package com.artemis

import net.codepoke.experiments.artemis.EntityDSLManager
import components.Position

@EntityDSLManager(components = #[Position], targetEntity = TestEntity)
class TestEntityManager extends EntityManager {
	
	public new(int initialContainerSize) {
		super(initialContainerSize)
	}
	
}