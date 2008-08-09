local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local prototype = {}

Bollo.registry = setmetatable({}, {
	__newindex = function(self, k, v)
		rawset(self, k, v)
		self:Update()
	end}
)


function prototype:CreateBackground(name)
	local db = self.db.profile

	local bg = CreateFrame("Frame", nil, UIParent)
	bg:SetHeight(150)
	bg:SetWidth(400)

	bg:SetBackdrop({
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 10,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})

	bg:SetBackdropColor(0, 1, 0, 0.3)

	bg:SetMovable(true)
	bg:EnableMouse(true)
	bg:SetClampedToScreen(true)

	bg:SetScript("OnMouseDown", function(self, button)
		self:ClearAllPoints()
		return self:StartMoving()
	end)

	bg:SetScript("OnMouseUp", function(self, button)
		local x, y = self:GetLeft(), self:GetTop()
		db.x, db.y = x, y

		return self:StopMovingOrSizing()
	end)

	bg:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)

	local f = bg:CreateFontString(nil, "OVERLAY")
	f:SetFont(STANDARD_TEXT_FONT, 14)
	f:SetShadowColor(0, 0, 0, 1)
	f:SetShadowOffset(1, -1)
	f:SetAllPoints(bg)
	f:SetFormattedText("%s - Anchor", name)

	bg:Hide()

	return setmetatable({
		bg = bg
	}, {
		__tostring = function()
			return name
		end
	})
end

function prototype:Update()
	if self.config then return end
	local base = self.base
	for i = 1, self.db.profile.max do
		if GetPlayerBuff(i, base) > 0 then
			local icon = self.icons[i] or Bollo:NewIcon()
			icon:SetBase(base)
			icon:SetID(i)
			icon:Setup(self.db.profile)
			self.icons[i] = icon
		elseif self.icons[i] then
			while self.icons[i] do
				Bollo:DelIcon(self.icons[i])
				self.icons[i] = nil
				i = i + 1
			end
			break
		else
			break
		end
	end

	self:UpdatePosition()
end

function prototype:UpdateDisplayPosition()
	Bollo.events:Fire("PrePositionIcons", self.icons, self)
	local size, spacing, rowSpacing = self.db.profile.size, self.db.profile.spacing, self.db.profile.rowSpacing
	local growthX, growthY = self.db.profile.growthX == "LEFT" and -1 or 1, self.db.profile.growthY == "DOWN" and -1 or 1
	local perRow = self.db.profile.perRow

	local offset = 0
	local rows = 0
	for index, buff in ipairs(self.icons) do
		if offset == perRow then
			rows = rows + 1
			offset = 0
		end

		buff:ClearAllPoints()
		buff:SetPoint("TOPRIGHT", self.icons.bg, "TOPRIGHT", ((buff:GetEffectiveScale() * size) + spacing) * offset * growthX, buff:GetEffectiveScale() * (size + rowSpacing) * rows * growthY)
		offset = offset + 1
	end
end

function prototype:UpdateConfig()
	for i, buff in ipairs(self.icons) do
		buff:Setup(self.db.profile)
	end
	if self.config then
		self:EnableSetupConfig()
	end
	self:UpdatePosition()
end

function prototype:EnableSetupConfig()
	self.config = true

	for i = 1, self.db.profile.max do
		local icon = self.icons[i] or Bollo:NewIcon()
		icon:Setup(self.db.profile)
		icon:SetID(0)
		icon:SetNormalTexture([[Interface\Icons\Spell_SHadow_DeathCoil]])
		icon:Show()
		self.icons[i] = icon
	end

	local i = self.db.profile.max + 1
	while self.icons[i] do
		Bollo:DelIcon(self.icons[i])
		self.icons[i] = nil
		i = i + 1
	end

	self:UpdatePosition()
end

function prototype:DisableSetupConfig()
	self.config = false
	self:Update()
end

function Bollo:NewDisplay(name, base, defaults)
	local t = setmetatable({},{__index = prototype})
	t.name = name
	t.base = base
	t.db = self.db:RegisterNamespace(name, defaults)
	t.icons = t:CreateBackground(name)
	table.insert(self.registry, t)
end
