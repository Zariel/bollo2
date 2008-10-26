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
	Bollo.RegisterCallback(self, "UpdateConfig")
end

function BF:UpdateConfig(event, name)
	local icons
	if name then
		for _, mod in ipairs(Bollo.registry) do
			if mod.name == name then
				icons = mod.icons
				break
			end
		end
	else
		for i, mod in ipairs(Bollo.Registry) do
			self:UpdateConfig(mod.name)
		end
		return
	end

	if icons then
		for i, icon in ipairs(icons) do
			local data = {
				["Icon"] = icon.Icon,
				["Border"] = icon.Border or nil,
				["normalTexture"] = icon.Icon,
				["Count"] = icon.modules.count or nil,
			}

			local G = lib:Group("Bollo2", icon.base)

			if self.db.profile[icon.base] then
				local db = self.db.profile[icon.base]
				G:Skin(unpack(db))
			end
		end
	end
end

function BF:ButtonCreated(event, icon)
	self:Print(event, icon)
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
