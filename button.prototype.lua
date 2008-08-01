local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local prototype = CreateFrame("Button", nil, UIParent)
Bollo.IconPrototype = prototype

function prototype:Setup(db)
	local size = db.size
	self:SetHeight(size)
	self:SetWidth(size)
	self:SetScale(db.scale)
	if self.base ~= "HARMFUL" then
		local col = db.color
		self.Border:SetVertexColor(col.r, col.g, col.b, col.a)
		self.Border:ClearAllPoints()
		self.Border:SetPoint("TOP", 0, 2)
		self.Border:SetPoint("RIGHT", 2, 0)
		self.Border:SetPoint("BOTTOM", 0, -2)
		self.Border:SetPoint("LEFT", -2, 0)
	end
end

function prototype:SetID(id)
	local base = self.base or "HELPFUL"
	self.id = GetPlayerBuff(id, base)

	local icon = GetPlayerBuffTexture(self.id)
	self:SetNormalTexture(icon)

	if self.base == "HELPFUL" then
		self.Border:SetVertexColor(0, 1, 0, 1)
	else
		local col = DebuffTypeColor[GetPlayerBuffDispelType(self.id) or "none"]
		self.Border:SetVertexColor(col.r, col.g, col.b)
	end
end

function prototype:GetTimeleft()
	if select(2, GetPlayerBuff(self.id)) > 0 then
		return nil
	else
		return math.floor(GetPlayerBuffTimeLeft(self.id) + 0.5)
	end
end

function prototype:SetBase(base)
	self.base = base
end

do
	local OnEnter = function(self)
		if self:IsShown() then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetPlayerBuff(self.id)
		end
	end

	local OnLeave = function(self)
		GameTooltip:Hide()
	end

	local OnMouseUp = function(self, button)
		if button == "RightButton" then
			CancelPlayerBuff(self.id)
		end
	end

	function prototype:Init()
		self:EnableMouse(true)
		self:SetScript("OnMouseUp", OnMouseUp)
		self:SetScript("OnEnter", OnEnter)
		self:SetScript("OnLeave", OnLeave)
	end
end


local cache = setmetatable({}, {__mode = "k"})
function Bollo:NewIcon()
	local f = next(cache)
	if f then
		cache[f] = nil
	else
		f = setmetatable(CreateFrame("Button", nil, UIParent), {__index = prototype})
		f.modules = {}

		local b = f:CreateTexture(nil, "OVERLAY")
		b:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
		b:SetPoint("TOP", 0, 2)
		b:SetPoint("RIGHT", 2, 0)
		b:SetPoint("BOTTOM", 0, -2)
		b:SetPoint("LEFT", -2, 0)
		b:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)

		f.Border = b
		f:Init()
	end

	f:Show()

	return f
end

function Bollo:DelIcon(f)
	f:Hide()

	f.id = 0
	f.base = nil

	cache[f] = true
end
