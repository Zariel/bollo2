local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local w = Bollo:NewModule("Weapons")
local defaults = {
	profile = {
		max = 2,
		perRow = 2,
		size = 32,
		spacing = 20,
		rowSpacing = 25,
		growthX = "LEFT",
		growthY = "DOWN",
		scale = 1,
		x = 0,
		y = 0,
		color = {
			r = 1,
			g = 0,
			b = 1,
			a = 0
		}
	}
}

function w:OnEnable()
	local weapon = Bollo:NewDisplay("Weapon", "TEMP", defaults)
	Bollo.RegisterCallback(weapon, "OnUpdate", "Update")

	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges

	local NewIcon
	do
		local GetTimeleft = function(self)
			local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()

			local id = self:GetID()
			if id == 16 then
				return hasMainHandEnchant and mainHandExpiration / 1000 or 0
			else
				return hasOffHandEnchant and offHandExpiration / 1000 or 0
			end
		end

		local OnEnter = function(self)
			if self:IsVisible() then
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
				GameTooltip:SetInventoryItem("player", self.id)
			end
		end

		local OnMouseUp = function(self, button)
			if button == "RightButton" then
				CancelItemTempEnchantment(self.id - 15)
			end
		end

		NewIcon = function()
			local icon = Bollo:NewIcon()
			icon:EnableMouse(true)
			icon:SetScript("OnEnter", OnEnter)
			icon:SetScript("OnMouseUp", OnMouseUp)
			icon.GetTimeleft = GetTimeleft

			return icon
		end
	end

	function weapon:Update()
		if self.config then return end

		hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()

		for i = 1, 2 do
			local index = i + 15
			if i == 1 and hasMainHandEnchant or hasOffHandEnchant then
				local icon = self.icons[i] or NewIcon()
				icon.id = index
				icon:SetNormalTexture(GetInventoryItemTexture("player", icon.id))
				icon.base = "TEMP"
				icon:Setup(self.db.profile)
				icon:Show()
				self.icons[i] = icon
			elseif self.icons[i] and self.icons[i]:IsShown() then
				Bollo:DelIcon(self.icons[i])
				self.icons[i] = nil
			end
		end

		self:UpdatePosition()
	end

end
