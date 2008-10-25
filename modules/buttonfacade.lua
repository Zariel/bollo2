local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local BF = Bollo:NewModule("ButtonFacade", "AceConsole-3.0")
local lib = LibStub("LibButtonFacade", true)

function BF:OnInitialize()
	local defaults = {
		profile = {
			["*"] = {
			}
		}
	}

	self.db = Bollo.db:RegisterNamespace("ButtonFacade", defaults)
end

function BF:OnEnable()
	lib = lib or LibStub("LibButtonFacade")

	lib:RegisterSkinCallback("Bollo2", self.UpdateSkin, self)
	Bollo.RegisterCallback(self, "ButtonCreated")
end

function BF:ButtonCreated(event, icon)
	local data = {
		["Icon"] = icon.Icon,
		["Border"] = icon.Border or nil,
		["Count"] = icon.modules.count or nil,
	}

	local G = lib:Group("Bollo2", icon.base)

	G:AddButton(icon, data)

	if self.db.profile[icon.base] then
		local db = self.db.profile[icon.base]
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
