local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local bf = bollo:NewModule("Bollo-ButtonFacade")
local lib

function bf:PostCreateIcon(event, parent, button)
	local debuff = button.debuff

	local data = {
		icon = button.icon,
		border = button.border,
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

	bollo.RegisterCallback(bf, "PostCreateIcon")
end

function bf:OnEnable()
	lib = LibStub("LibButtonFacade-1.0")

	self.buffs = lib:Group("Bollo", "Buffs")
	self.debuffs = lib:Group("Bollo", "Debuffs")
end

function bf:OnDisable()
end
