package com.artemis

import components.Position
import net.codepoke.experiments.artemis.EntityDSLComponents

@EntityDSLComponents(Position)
class TestEntity extends Entity {
	
	public new(World world, int id) {
		super(world, id)
	}
	
}