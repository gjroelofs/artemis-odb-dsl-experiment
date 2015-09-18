package com.artemis

import components.Position
import net.codepoke.experiments.artemis.EntityDSLComponents
import components.Mana
import components.Health

@EntityDSLComponents(Position, Health, Mana)
class TestEntity extends Entity {
	
	public new(World world, int id) {
		super(world, id)
	}
	
}