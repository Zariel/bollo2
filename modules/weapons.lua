local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Weapon = bollo:NewModule("WeaponBuffs")

function Weapon:OnInitialize()
	local defaults = {
		profile = {
			["growthx"] = "LEFT",
			["growthy"] = "DOWN",
			["size"] = 30,
			["spacing"] = 2,
			["lock"] = false,
			["x"] = 0,
			["y"] = 0,
			["height"] = 100,
			["width"] = 350,
			["rowSpace"] = 20,
			["enabled"] = true,
		}
	}

	local conf = bollo.options.args.general.args
	conf.weapon = {
		order = 3,
		type = "group",
		set = function(info, val)
			local key = info[# info]
			self.db.profile[key] = val
			self:OnUpdate()
		end,
		get = function(info)
			local key = info[# info]
			return self.db.profile[key]
		end,
		name = "Weapon Buff Settings",
		args = {
			enabled = {
				name = "Enable",
				order = 0,
				type = "toggle",
				get = function(info)
					return self:IsEnabled()
				end,
				set = function(info, key)
					if key then
						self:Enable()
					else
						self:Disable()
					end
					self.db.profile.enabled = key
				end,
			},
			desc = {
				order = 1,
				type = "description",
				name = "Settings for weaponbuff display",
			},
			sizeDesc = {
				order = 2,
				name = "Set the size of the weaponbuffs (height and width)",
				type = "description",
			},
			size = {
				order = 3,
				name = "Size",
				type = "range",
				min = 10,
				max = 100,
				step = 1,
			},
			spacingDesc = {
				order = 4,
				name = "Set the horizontal spacing between buffs",
				type = "description",
			},
			spacing = {
				order = 5,
				name = "Spacing",
				type = "range",
				min = -20,
				max = 20,
				step = 1,
			},
			rowSpacingDesc = {
				order = 5,
				name = "Set the vertical spacing between rows",
				type = "description",
			},
			rowSpace = {
				order = 6,
				name = "Row Spacing",
				type = "range",
				min = 0,
				max = 50,
				step = 1,
			},
			heightDesc = {
				order = 7,
				name = "Set the height of the weaponbuff display",
				type = "description",
			},
			height = {
				order = 8,
				name = "Max Height",
				type = "range",
				min = 25,
				max = 600,
				step = 25,
			},
			widthDesc = {
				order = 9,
				name = "Set the width the weaponbuff display",
				type = "description",
			},
			width = {
				order = 10,
				name = "Max Width",
				type = "range",
				min = 25,
				max = 600,
				step = 25,
			},
			growthxDesc = {
				order = 11,
				name = "Set the Growth-X",
				type = "description",
			},
			growthx = {
				order = 12,
				name = "Growth X",
				type = "select",
				values = {
					["LEFT"] = "LEFT",
					["RIGHT"] = "RIGHT",
				},
			},
			growthyDesc = {
				order = 13,
				name = "Set the Growth-X",
				type = "description",
			},
			growthy = {
				order = 14,
				name = "Growth X",
				type = "select",
				values = {
					["UP"] = "UP",
					["DOWN"] = "DOWN",
				},
			},
			lockDesc = {
				order = 15,
				name = "Lock or unlock the display",
				type = "description",
			},
			lock = {
				order = 16,
				name = "lock",
				type = "toggle",
				set = function(info, key)
					if key then
						self.weapon.bg:Hide()
					else
						self.weapon.bg:Show()
					end
					self.db.profile.lock = key
				end,
				get = function(info)
					return not self.weapon.bg:IsShown()
				end,
			},
		}
	}

	self.db = bollo.db:RegisterNamespace("Bollo-Weapon", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function Weapon:OnEnable()
	self.weapon = self.weapon or setmetatable({}, {__tostring = function() return "weapon" end})

	if not self.weapon[1] then
		for i = 1, 2 do
			local button = 	bollo:CreateIcon(Weapon.weapon, Weapon.db.profile)
			button:SetID(15 + i)
			button:SetScript("OnEnter", function(self)
				if self:IsVisible() then
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
					GameTooltip:SetInventoryItem("player", self:GetID())
				end
			end)
			button:SetScript("OnMouseUp", function(self, button)
				if button == "RightButton" then
					CancelItemTempEnchantment(self:GetID() - 15)
				end
			end)
		end
	end


	if not self.weapon.bg then
		local bg = CreateFrame("Frame")
		bg:SetWidth(Weapon.db.profile.width)
		bg:SetHeight(Weapon.db.profile.height)
		bg:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = 1, right = 1, top = 1, bottom = 1},
		})
		bg:SetBackdropColor(0, 0, 1, 0.3)
		bg:Hide()

		bg:SetMovable(true)
		bg:EnableMouse(true)
		bg:SetClampedToScreen(true)
		bg:SetScript("OnMouseDown", function(self, button)
			self:ClearAllPoints()
			return self:StartMoving()
		end)

		bg:SetScript("OnMouseUp", function(self, button)
			local x, y = self:GetLeft(), self:GetTop()
			bollo.db.profile.x, bollo.db.profile.y = x, y
			return self:StopMovingOrSizing()
		end)

		bg:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", Weapon.db.profile.x, Weapon.db.profile.y)

		self.weapon.bg = bg
	end

	bollo.RegisterCallback(self, "OnUpdate")
end

function Weapon:OnDisable()
	bollo.UnregisterCallback(self, "OnUpdate")
end

local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges
function Weapon:OnUpdate()
	hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
	local offset = 0
	local growthx = self.db.profile["growthx"] == "LEFT" and -1 or 1
	local growthy = self.db.profile["growthy"] == "DOWN" and -1 or 1
	local size = self.db.profile.size
	local perCol = math.floor(self.weapon.bg:GetWidth() / size + 0.5)
	local perRow = math.floor(self.weapon.bg:GetHeight() / size + 0.5)
	local rowSpace = self.db.profile.rowSpace
	local spacing = self.db.profile.spacing
	local rows = 0
	local anchor = growthx > 0 and "LEFT" or "RIGHT"
	local relative = growthy  > 0 and "BOTTOM" or "TOP"
	local point = relative .. anchor

	local icon = self.weapon[1]
	if hasMainHandEnchant then
		local texture = GetInventoryItemTexture("player", icon:GetID())
		icon.icon:SetTexture(texture)
		icon:Show()
	else
		icon:Hide()
	end

	icon = self.weapon[2]
	if hasOffHandEnchant then
		local texture = GetInventoryItemTexture("player", icon:GetID())
		icon.icon:SetTexture(texture)
		icon:Show()
	else
		icon:Hide()
	end

	for i, buff in ipairs(self.weapon) do
		if buff:IsShown() then
			buff:ClearAllPoints()

			if offset == perCol then
				rows = rows + 1
				offset = 0
			end

			buff:SetPoint(point, self.weapon.bg, point, (offset * (size + spacing) * growthx), (rows * (size + rowSpace) * growthy))
			offset = offset + 1
		end
	end
end
