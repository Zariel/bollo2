local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local bf = bollo:NewModule("ButtonFacade", "AceConsole-3.0")
local lib
local SetVertexColor

function bf:PostCreateIcon(event, parent, button)
	local debuff = tostring(parent) == "debuff"

	button.border._SetVertexColor = button.border.SetVertexColor

	local data = {
		["Icon"] = button.icon,
		["Border"] = button.border,
		["normalTexture"] = button.icon,
		["Count"] = button.count,
	}

	if debuff then
		self.debuff:AddButton(button, data)
	else
		self.buff:AddButton(button, data)
	end
	self:PostSetBuff(nil, button)
end

function bf:PostSetBuff(event, button)
	if button.name == "debuff" then
		local index = button:GetID()
		local col = DebuffTypeColor[GetPlayerBuffDispelType(index) or "none"]
		button.border:_SetVertexColor(col.r, col.g, col.b)
	end
end

function bf:OnInitialize()
	local defaults = {
		profile = {
			debuff = {
			},
			buff = {
			},
			enabled = true,
		}
	}

	self.db = bollo.db:RegisterNamespace("Bollo-ButtonFacade", defaults)

	self.options = {
		type = "group",
		name = "Button Facade",
		args = {
			enableDesc = {
				type = "description",
				name = "Enable the Button Facade module, will only take effect after reload of UI",
				order = 1,
			},
			enabled = {
				type = "toggle",
				name = "Enable",
				order = 2,
				set = function(info, val)
					local key = info[# info]
					self.db.profile[key] = val
					if val then
						self:Enable()
					else
						self:Disable()
					end
				end,
				get = function(info)
					local key = info[# info]
					return self.db.profile[key]
				end
			},
		}
	}

	bollo:AddOptions(self)

	self:SetEnabledState(self.db.profile.enabled)
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
	lib = lib or LibStub("LibButtonFacade")
	self.buff = self.buff or lib:Group("Bollo", "buff")
	self.debuff = self.debuff or lib:Group("Bollo", "debuff")

	lib:RegisterSkinCallback("Bollo", self.UpdateSkin, self)
	bollo.RegisterCallback(bf, "PostCreateIcon")
	bollo.RegisterCallback(bf, "PostSetBuff")
	bollo.RegisterCallback(bf, "PostUpdateConfig", "UpdateSkins")
	bollo.RegisterCallback(bf, "NewIconGroup")

	self:UpdateSkins()
end

function bf:UpdateSkins(event)
	for name in pairs(bollo.icons) do
		local group = self[name]
		if group then
			local table = self.db.profile[name]
			group:Skin(table.Skin, table.Gloss, table.Backdrop)
			for k, v in ipairs(bollo.icons[name]) do
				self:PostCreateIcon(nil, nil, v)
			end
		end
	end
end

function bf:NewIconGroup(event, name, table)
end

function bf:OnDisable()
	self.Print(self, "To unskin the buffs you must reload your interface")
	bollo.UnregisterCallback(bf, "PostCreateIcon")
	bollo.UnregisterCallback(bf, "PostSetBuff")
	bollo.UnregisterCallback(bf, "PostUpdateConfig")
end
