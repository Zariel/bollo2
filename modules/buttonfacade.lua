local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local bf = bollo:NewModule("Bollo-ButtonFacade")
local lib

function bf:PostCreateIcon(event, parent, button)
	local debuff = button.debuff

	local data = {
		["Icon"] = button.icon,
		["Border"] = button.border,
		["normalTexture"] = button.icon,
	}

	if debuff then
		self.debuffs:AddButton(button, data)
	else
		self.buffs:AddButton(button, data)
	end
end

function bf:OnInitialize()
	local defaults = {
		profile = {
		}
	}

	self.db = bollo.db:RegisterNamespace("Bollo-ButtonFacade", defaults)

	lib = LibStub("LibButtonFacade")

	self.buffs = lib:Group("Bollo", "Buffs")
	self.debuffs = lib:Group("Bollo", "Debuffs")
	bollo.RegisterCallback(bf, "PostCreateIcon")
end

function bf:OnEnable()

end

function bf:OnDisable()
end
