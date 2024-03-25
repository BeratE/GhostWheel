import "scripts/system/AbstractSystem"

class("UpdateSystem").extends(AbstractSystem)
tinyecs.processingSystem(UpdateSystem)
UpdateSystem.filter = tinyecs.requireAll("update")

function UpdateSystem:process(e, dt)
	e:update(dt)
end