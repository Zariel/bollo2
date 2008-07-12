local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local bf = bollo:NewModule("Bollo-ButtonFacade")
local lib

function bf:PostCreateIcon(event, parent, button)
	local debuff = button.debuff

	local data = {
		["Icon"] = button.icon,
		["Border"] = button.border,
		["normalTexture"] = button.icon,
		["Count"] = button.count,
	}

	if debuff then
		self.Debuffs:AddButton(button, data)
	else
		self.Buffs:AddButton(button, data)
	end
end

function bf:OnInitialize()
	local defaults = {
		profile = {
			Debuffs = {},
			Buffs = {},
		}
	}

	self.db = bollo.db:RegisterNamespace("Bollo-ButtonFacade", defaults)

	lib = LibStub("LibButtonFacade")

	self.Buffs = lib:Group("Bollo", "Buffs")
	self.Debuffs = lib:Group("Bollo", "Debuffs")
	bollo.RegisterCallback(bf, "PostCreateIcon")
end

function bf:UpdateSkin(SkinID, Gloss, Backdrop, Group, Button, Colors)
	if Group then
		self.db.profile[Group] = {
			["Skin"] = SkinID,
			["Gloss"] = Gloss,
			["Backdrop"] = Backdrop,
			["Color"] = Colors,
		}
	end
end

function bf:OnEnable()
	lib:RegisterSkinCallback("Bollo", self.UpdateSkin, self)

	for g, table in pairs(self.db.profile) do
		local group = self[g]
		group:Skin(table.Skin, table.Gloss, table.Backdrop)
	end
end

function bf:OnDisable()
end
