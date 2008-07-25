if select(2, UnitClass("player")) ~= "SHAMAN" then
	return
end

local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Totem = bollo:NewModule("Totem", "AceEvent-3.0")
local icons

function Totem:OnInitialize()
	local defaults = {
		profile = {
			totem = {
				["growthx"] = "LEFT",
				["growthy"] = "DOWN",
				["size"] = 20,
				["spacing"] = 2,
				["lock"] = false,
				["x"] = 0,
				["y"] = 0,
				["height"] = 100,
				["width"] = 350,
				["rowSpace"] = 20,= 200,
			}
		}
	}
	self.db = bollo.db:RegisterNameSpace("Totems", defaults)
end

function Totem:OnEnable()
	self:SetupIcons()

	if not bollo.icons.totem.bg then
		local bg = CreateFrame("Frame", nil, UIParent)
		bg:SetWidth(Weapon.db.profile.totem.width)
		bg:SetHeight(Weapon.db.profile.totem.height)

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
			Weapon.db.profile.totem.x, Weapon.db.profile.totem.y = x, y
			return self:StopMovingOrSizing()
		end)

		bg:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", Weapon.db.profile.totem.x, Weapon.db.profile.totem.y)

		bollo.icons.totem.bg = bg
	end

	self:RegisterEvent("PLAYER_TOTEM_UPDATE")
end

function Totem:SetupIcons()
	if bollo.icons["totem"] then
		return
	else
		bollo.icons.totem = setmetatable({}, {__tostring = function() return "totem" end})
		icons = bollo.icons.totem
	end

	local GetBuff = function(self)
		local id = self:GetID()
		return select(2, GetTotemInfo(id))
	end

	local GetTimeLeft = function(self)
		local id = self:GetID()
		local _, _, start, duration = GetTotemInfo(id)
		if start > 0 then
			local timeleft = (start + duration) - GetTime()
			return timeleft > 0 and timeleft or nil
		end
		return nil
	end

	for i = 1, 4 do
		local b = bollo:CreateIcon(bollo.icons.totem, self.db.profile.totem)
		b:SetID(i)
		b.GetBuff = GetBuff
		b.GetTimeLeft = GetTimeLeft
		b:SetScript("OnEnter", function(self)
			if self:IsVisible() then
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
				GameTooltip:SetTotem(self:GetID())
			end
		end)
	end
end

local totems = {}

local _, name, start, duration
function Totem:PLAYER_TOTEM_UDPDATE()
	for i = 1, 4 do
		_, name, startTime, duration, icon = GetTotemInfo(i)
		-- Madness
		if (not totems[i] or totems[i] ~= name) and duration > 0 then
			local buff = icons[i]
			buff.icon:SetTexture(icon)
			buff:Show()
			totems[i] = name
		elseif totems[i] and duration == 0 then
			icons[i]:Hide()
			totems[i] = nil
		end
	end

	local offset = 0
	local growthx = self.db.profile.totem["growthx"] == "LEFT" and -1 or 1
	local growthy = self.db.profile.totem["growthy"] == "DOWN" and -1 or 1
	local size = self.db.profile.totem.size
	local perCol = math.floor(icons.bg:GetWidth() / size + 0.5)
	local perRow = math.floor(icons.bg:GetHeight() / size + 0.5)
	local rowSpace = self.db.profile.totem.rowSpace
	local rows = 0
	local anchor = growthx > 0 and "LEFT" or "RIGHT"
	local relative = growthy  > 0 and "BOTTOM" or "TOP"
	local point = relative .. anchor
	for i, buff in ipairs(icons) do
		if buff:IsShown() then
			if offset == perCol then
				rows = rows + 1
				offset = 0
			end

			buff:SetPoint(point, icons.bg, point, (offset * (size + self.db.profile[name].spacing) * growthx), (rows * (size + rowSpace) * growthy))
			self.events:Fire("UpdateIconPosition", i, buff, icons)
			offset = offset + 1
		end
	end
end
