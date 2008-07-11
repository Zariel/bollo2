local _G = getfenv(0)

if not _G.bollo then
	return
end

local name = bollo:NewModule("Bollo-Name")

function name:Enable()
	bollo.db.profile.modules = bollo.db.profile.modules or {}
	bollo.db.profile.modules.name = {}

	self.db = bollo.db.profile.modules.name

end
