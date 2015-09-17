package com.artemis;

import java.util.UUID;

import com.artemis.annotations.Wire;

import components.Position;

@Wire
public final class DependencyEntity extends Entity {

	protected static ComponentMapper<Position> position;
	
	protected DependencyEntity(World world, int id) {
		super(world, id);
	}

	public DependencyEntity(World world, int id, UUID uuid) {
		super(world, id, uuid);
	}

	@Override
	public final Position position() {
		return position.get(id);
	}
			
}
