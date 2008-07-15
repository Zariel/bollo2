local bollo = LibStub("AceAddon-3.0"):NewAddon("Bollo", "AceEvent-3.0", "AceConsole-3.0")

local ipairs = ipairs
local pairs = pairs

local GetPlayerBuffName = GetPlayerBuffName
local GetPlayerBuff = GetPlayerBuff
local DebuffTypeColor = DebuffTypeColor
local GetPlayerBuffDispelType = GetPlayerBuffDispelType
local GetPlayerBuffApplications = GetPlayerBuffApplications
local DebuffTypeColor = DebuffTypeColor

function bollo:OnInitialize()
	local defaults = {
		profile = {
			buff = {
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
			},
			debuff = {
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
			}
		},
	}
	self.db = LibStub("AceDB-3.0"):New("BolloDB", defaults, "default")
	self.events = LibStub("CallbackHandler-1.0"):New(bollo)

	local OnUpdate
	do
		local timer = 0
		OnUpdate = function(self, elapsed)
			timer = timer + elapsed
			if timer > 0.25 then
				bollo.events:Fire("OnUpdate")
				timer = 0
			end
		end
	end

	function bollo.events:OnUsed(target, event)
		if event == "OnUpdate" then
			bollo.frame:SetScript("OnUpdate", OnUpdate)
		end
	end

	function bollo.events:OnUnused(target, event)
		if event == "OnUpdate" then
			bollo.frame:SetScript("OnUpdate", nil)
		end
	end
end

function bollo:OnEnable()
	self.frame = CreateFrame("Frame")       -- Frame for modules to run OnUpdate
	self.buffs = setmetatable({}, {__tostring = function() return "buff" end})
	self.debuffs =setmetatable({}, {__tostring = function() return "debuff" end})

	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)
	_G.BuffButton_OnUpdate = nil

	local bbg = CreateFrame("Frame")
	bbg:SetWidth(bollo.db.profile.buff.width)
	bbg:SetHeight(bollo.db.profile.buff.height)
	bbg:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	bbg:SetBackdropColor(0, 1, 0, 0.3)
	bbg:Hide()

	bbg:SetMovable(true)
	bbg:EnableMouse(true)
	bbg:SetClampedToScreen(true)
	bbg:SetScript("OnMouseDown", function(self, button)
		self:ClearAllPoints()
		return self:StartMoving()
	end)
	bbg:SetScript("OnMouseUp", function(self, button)
		local x, y = self:GetLeft(), self:GetTop()
		bollo.db.profile.buff.x, bollo.db.profile.buff.y = x, y
		return self:StopMovingOrSizing()
	end)

	bbg:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", bollo.db.profile.buff.x, bollo.db.profile.buff.y)

	self.buffs.bg = bbg

	local dbg = CreateFrame("Frame")
	dbg:SetWidth(bollo.db.profile.debuff.width)
	dbg:SetHeight(bollo.db.profile.debuff.height)
	dbg:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	dbg:SetBackdropColor(1, 0, 0, 0.3)
	dbg:Hide()

	dbg:SetMovable(true)
	dbg:EnableMouse(true)
	dbg:SetClampedToScreen(true)
	dbg:SetScript("OnMouseDown", function(self, button)
		self:ClearAllPoints()
		return self:StartMoving()
	end)
	dbg:SetScript("OnMouseUp", function(self, button)
		local x, y = self:GetLeft(), self:GetTop()
		bollo.db.profile.debuff.x, bollo.db.profile.debuff.y = x, y
		return self:StopMovingOrSizing()
	end)

	dbg:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", bollo.db.profile.debuff.x, bollo.db.profile.debuff.y)

	self.debuffs.bg = dbg

	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:PLAYER_AURAS_CHANGED()
end

local SortFunc = function(a, b)
	if not a then
		a = 0
	else
		a = a:GetTimeLeft()
	end
	if not b then
		b = 0
	else
		b = b:GetTimeLeft()
	end
	return a > b
end

function bollo:GetPoint(point)
	local anchor, relative, mod
	if point == "TOP" then
		relative = "TOP"
		anchor = "BOTTOM"
		mod = 1
	elseif point == "BOTTOM" then
		relative = "BOTTOM"
		anchor = "TOP"
		mod = -1
	elseif point == "CENTER" then
		relative = "CENTER"
		anchor = "CENTER"
		mod = 1
	end
	return anchor, relative, mod
end

function bollo:SortBuffs(icons, max)
--	table.sort(icons, SortFunc)
	local name = tostring(icons)
	local offset = 0
	local growthx = self.db.profile[name]["growthx"] == "LEFT" and -1 or 1
	local growthy = self.db.profile[name]["growthy"] == "DOWN" and -1 or 1
	local size = self.db.profile[name].size
	local perCol = math.floor(icons.bg:GetWidth() / size + 0.5)
	local perRow = math.floor(icons.bg:GetHeight() / size + 0.5)
	local rowSpace = self.db.profile[name].rowSpace
	local rows = 0
	local anchor = growthx > 0 and "LEFT" or "RIGHT"
	local relative = growthy  > 0 and "BOTTOM" or "TOP"
	local point = relative .. anchor
	for i, buff in ipairs(icons) do
		if buff:IsShown() then
			buff:ClearAllPoints()

			if offset == perCol then
				rows = rows + 1
				offset = 0
			end

			buff:SetPoint(point, icons.bg, point, (offset * (size + self.db.profile[name].spacing) * growthx), (rows * (size + rowSpace) * growthy))
			offset = offset + 1
		end
	end
end

function bollo:UpdateIcons(i, parent, filter)
	local index = GetPlayerBuff(i, filter)
	local icon = parent[i]

	if index > 0 then
		icon = icon or self:CreateIcon(parent)
		icon:SetBuff(index, filter)
		return true
	elseif icon then
		icon:SetID(0)
		icon:Hide()
		return false
	end
end

-- Blatently copied from oUF
function bollo:PLAYER_AURAS_CHANGED()
	local max = 1
	for i = 1, 40 do
		if not self:UpdateIcons(i, self.buffs, "HELPFUL") then
			for a = i,  #self.buffs do
				self.buffs[a]:Hide()
			end
			break
		end
		max = max + 1
	end
	self:SortBuffs(self.buffs, max - 1)
	max = 1
	for i = 1, 40 do
		if not self:UpdateIcons(i, self.debuffs, "HARMFUL") then
			for a = i,  #self.debuffs do
				self.debuffs[a]:Hide()
			end
			break
		end
		max = max + 1
	end
	self:SortBuffs(self.debuffs, max - 1)
end

function bollo:UpdateSettings(table)
	local bf = self:GetModule("ButtonFacade", true)
	local name = tostring(table)
	table.bg:SetHeight(self.db.profile[name].height)
	table.bg:SetWidth(self.db.profile[name].width)

	for index, buff in ipairs(table) do
		local size = self.db.profile[name].size
		buff:SetHeight(size)
		buff:SetWidth(size)
		buff.border:ClearAllPoints()
		buff.border:SetAllPoints(buff)
		buff.icon:ClearAllPoints()
		buff.icon:SetAllPoints(buff)
	end

	self:SortBuffs(table)

	if bf then
		bf:OnEnable()
	end
end


