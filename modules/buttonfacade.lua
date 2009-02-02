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
	Bollo.RegisterCallback(self, "PostUpdateIcon")
end

function BF:OnEnable()
	lib = lib or LibStub("LibButtonFacade")

	lib:RegisterSkinCallback("Bollo2", self.UpdateSkin, self)
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
			self:PostUpdateIcon(event, icon)
		end
	end
end

function BF:PostUpdateIcon(event, icon)
	local data = {
		["Icon"] = icon:GetNormalTexture(),
		["Border"] = icon.Border,
		["Count"] = icon.modules.count,
	}

	local G = lib:Group("Bollo2", icon.base)
	G:AddButton(icon, data)

	if self.db.profile[icon.base] then
		local db = self.db.profile[icon.base]
		G:Skin(unpack(db))
	end
end

function BF:UpdateSkin(skinID, gloss, backdrop, group, button, colors)
	if Group then
		self.db.profile[group] = self.db.profile[group] or {}
		local db = self.db.profile[group]
		db[1] = skinID
		db[2] = gloss
		db[3] = backdrop
		db[4] = colors
		local G = lib:Group("Bollo2", group)
		G:Skin(unpack(db))
	end
end
