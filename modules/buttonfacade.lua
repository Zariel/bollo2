local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local BF = Bollo:NewModule("ButtonFacade")
local lib = LibStub("LibButtonFacade", true)

function BF:OnInitialize()
	local defaults = {
		profile = {
			["*"] = {
			}
		}
	},

	self.db = Bollo.db:RegisterNamespace("ButtonFacade", defaults)
end

function BF:OnEnable()
	local lib = lib or LibStub("LibButtonFacade")

	lib:RegisterSkinCallback("Bollo2", self.UpdateSkin, self)
	Bollo.RegisterCallback(self, "ButtonCreated")
end

function BF:ButtonCreated(event, icon)
	local data = {
		["Icon"] = icon:GetNormalTexture(),
		["Border"] = icon.Border,
		["normalTexture"] = icon:GetNormalTexture(),
		["Count"] = icon.modules.count,
	}

	local G = lib:Group("Bollo2", button.name)

	G:AddButton(button, data)

	if self.db.profile[button.name] then
		local db = self.db.profile[button.name]
		G:Skin(unpack(db))
	end
end

function BF:UpdateSkin(SkinID, Gloss, Backdrop, Group, Button, Colors)
	if Group then
		self.db.profile[Group] = self.db.profile[Group] or {}
		local db = self.db.profile[Group]
		db[1] = SkinID
		db[2] = Gloss
		db[3] = Backdrop
		db[4] = Colors
	end
end
