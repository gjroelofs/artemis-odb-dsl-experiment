package com.artemis

import net.codepoke.experiments.artemis.EntityDSLManager
import components.Position
import components.Health
import components.Mana

@EntityDSLManager(components = #[Position, Health, Mana], targetEntity = TestEntity)
class TestEntityManager extends EntityManager {
	
	public new(int initialContainerSize) {
		super(initialContainerSize)
	}
	
}