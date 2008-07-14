local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local GetPlayerBuff = GetPlayerBuff
local GetPlayerBuffName = GetPlayerBuffName
local GetPlayerBuffTexture = GetPlayerBuffTexture
local GetPlayerBuffApplications = GetPlayerBuffApplications
local GetPlayerBuffTimeLeft = GetPlayerBuffTimeLeft

local prototype = CreateFrame("Button")

--[[
	New(parent)
		parent (table) - parent table
		Create a new icon with border, texture
]]

local New = function(self, parent)
	if type(parent) ~= "table" then
		error("Bad argument to #1 CreateIcon expected table")
	end

	local button = CreateFrame("Button", nil, UIParent)
	button:SetHeight(20)
	button:SetWidth(20)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)

	local border = button:CreateTextire(nil, "OVERLAY")
	border:SetAllPoints(button)

	button.icon = icon
	button.border = border

	setmetatable(button, {__index = prototype})

	bollo.events:Fire("PostCreateIcon", button)

	table.insert(parent, button)
end

--[[
	SetBuff(index, filter)
		index - ID of the aura
		filter - buff temp)
		Sets the buff
]]

function prototype:SetBuff(index, filter)
	if type(index) ~= "number" then
		error("Bad argument #1 to :SetBuff expected number")
	end
	if type(filter) ~= "string" then
		error("Bad argument #2 to :SetBuff expected string")
	end

	local texture = GetPlayerBuffTexture(index)

	self:SetID(index)
	self.debuff = filter == "HARMFUL"

	self.icon:SetTexture(texture)

	if self.debuff then
		local col = DebuffTypeColor[GetPlayerBuffDispelType(index) or "none"]
		self.border:SetVertexColor(col.r, col.g, col.b)
		self.border:Show()
	else
		self.border:Hide()
	end
end

--[[
	GetBuff()
		returns
		Buffname, rank
]]

function prototype:GetBuff()
	return GetPlayerBuffName(self:GetID())
end

--[[
	GetTimeLeft()
		returns
		BufftimeLeft (seconds)
]]

function prototype:GetTimeLeft()
	local id = self:GetID()
	if select(2, GetPlayerBuff(id)) > 0 then
		return 0
	else
		return GetPlayerBuffTimeLeft(id) or 0
	end
end

bollo.CreateIcon = New
