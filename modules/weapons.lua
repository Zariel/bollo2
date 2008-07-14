local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Weapon = bollo:NewModule("WeaponBuffs")

function Weapon:OnInitialize()
	local defaults = {
		profile = {
			weapon = {
				["growthx"] = "LEFT",
				["growthy"] = "DOWN",
				["size"] = 20,
				["spacing"] = 2,
				["lock"] = false,
				["x"] = 0,
				["y"] = 0,
				["height"] = 100,
				["width"] = 350,
				["rowSpace"] = 20,
				["enabled"] = true,
			},
		}
	}

	self.db = bollo.db:RegisterNamespace("Bollo-Weapon", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function Weapon:OnEnable()
	self.weapons = setmetatable({}, {__tostring = function() return "weapon" end})
	
	for i = 1, 2 do
		local button = 	bollo:CreateIcon(bollo.weapons)
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

	local bg = CreateFrame("Frame")
	bg:SetWidth(bollo.db.profile.debuff.width)
	bg:SetHeight(bollo.db.profile.debuff.height)
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
		bollo.db.profile.weapons.x, bollo.db.profile.weapons.y = x, y
		return self:StopMovingOrSizing()
	end)

	bg:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", bollo.db.profile.weapons.x, bollo.db.profile.weapons.y)

	self.weapons.bg = bg


	bollo.RegisterCallback(self, "OnUpdate")
end

function Weapon:OnDisable()
	bollo.RegisterCallback(self, "OnUpdate")
end

local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
function Weapon:OnUpdate()
	local offset = 0
	local growthx = self.db.profile.weapons.["growthx"] == "LEFT" and -1 or 1
	local growthy = self.db.profile.weapons.["growthy"] == "DOWN" and -1 or 1
	local size = self.db.profile.weapons.size
	local perCol = math.floor(self.weapons.bg:GetWidth() / size + 0.5)
	local perRow = math.floor(self.weapons.bg.bg:GetHeight() / size + 0.5)
	local rowSpace = self.db.profile.weapons.rowSpace
	local rows = 0
	local anchor = growthx > 0 and "LEFT" or "RIGHT"
	local relative = growthy  > 0 and "BOTTOM" or "TOP"
	local point = relative .. anchor

	if hasMainHandEnchant then
		local icon = self.weapons[1]
		local texture = GetInventoryItemTexture("player", self:GetID())
		icon.icon:SetTexture(texture)
		icon:Show()
	else
		icon:Hide()
	end

	if hasOffHandEnchant then
		local icon = self.weapons[2]
		local texture = GetInventoryItemTexture("player", self:GetID())
		icon.icon:SetTexture(texture)
		icon:Show()
	else
		icon:Hide()
	end
	for i, buff in ipairs(self.weapons) do
		if buff:IsShown() then
			buff:ClearAllPoints()

			if offset == perCol then
				rows = rows + 1
				offset = 0
			end

			buff:SetPoint(point, self.weapons.bg, point, (offset * (size + self.db.profile.weapons.spacing) * growthx), (rows * (size + rowSpace) * growthy))
			offset = offset + 1
		end
	end
end
