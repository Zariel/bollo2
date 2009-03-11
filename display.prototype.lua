local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local prototype = {}

local UnitAura = UnitAura

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

	local old = self.icons
	local bg = self.icons.bg
	self.icons = { ["bg"] = bg }

	for i = 1, self.db.profile.max do
		local name = UnitAura("player", i, base)
		if name then
			-- Attempt to move icons into their correct position
			-- here to prevent moving later
			-- Find the correct icon as now i ~= id of the buff in
			-- that slot.
			local id = i
			if #old > 1 then
				for j = 1, #old do
					local icon = old[j]
					if icon:GetName() == name then
						id = j
						break
					end
				end
			end

			local icon = old[id] and table.remove(old, id) or Bollo:NewIcon()
			icon:SetBase(base)
			icon:SetID(i)
			icon:Setup(self.db.profile)

			local time = icon:GetTimeleft()
			if not time then
				local pos = 1
				if #self.icons > 0 then
					for j = 1, #self.icons do
						pos = j + 1
						if self.icons[j] and self.icons[j]:GetTimeleft() then
							pos = j
							break
						end
					end
				end
				table.insert(self.icons, pos, icon)
			else
				local pos = #self.icons + 1
				if #self.icons >= 1 then
					for j = 1, (#self.icons) do
						local next = self.icons[j]
						if next then
							local t = next:GetTimeleft()
							if t and time > t then
								pos = j
								break
							end
						else
							break
						end
					end
				end
				table.insert(self.icons, pos, icon)
			end
		else
			break
		end
	end

	local i = 1
	while old[i] do
		Bollo:DelIcon(old[i])
		i = i + 1
	end

	old = nil
	bg = nil

	local i = self.db.profile.max + 1
	while self.icons[i] do
		Bollo:DelIcon(self.icons[i])
		self.icons[i] = nil
		i = i + 1
	end

	self:UpdatePosition()
end

function prototype:UpdatePosition()
	local count = #self.icons

	if count == self.lastUpdate then return end

	Bollo.events:Fire("PrePositionIcons", self)

	local size, spacing, rowSpacing = self.db.profile.size, self.db.profile.spacing, self.db.profile.rowSpacing
	local growthX, growthY = self.db.profile.growthX == "LEFT" and -1 or 1, self.db.profile.growthY == "DOWN" and -1 or 1
	local perRow = self.db.profile.perRow

	local anchor = growthX > 0 and "LEFT" or "RIGHT"
	local relative = growthY  > 0 and "BOTTOM" or "TOP"
	local point = relative .. anchor

	local offset = 0
	local rows = 0
	for index, buff in ipairs(self.icons) do
		if offset == perRow then
			rows = rows + 1
			offset = 0
		end

		-- Already in the correct place
		if index == buff.currentPos then return end

		buff:ClearAllPoints()
		buff:SetPoint(point, self.icons.bg, point, ((buff:GetEffectiveScale() * size) + spacing) * offset * growthX, buff:GetEffectiveScale() * (size + rowSpacing) * rows * growthY)
		buff.currentPos = index
		offset = offset + 1
	end

	self.lastUpdate = count
end

function prototype:UpdateConfig()
	for i, buff in ipairs(self.icons) do
		buff:Setup(self.db.profile)
	end
	if self.config then
		self:EnableSetupConfig()
	else
		self:Update()
	end
	self:UpdatePosition()
end

function prototype:EnableSetupConfig()
	self.config = true

	for i = 1, self.db.profile.max do
		local icon = self.icons[i] or Bollo:NewIcon()
		icon.base = self.base
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
	local t = setmetatable({}, {
		__index = prototype,
		__tostring = function()
			return name
		end,
	})

	t.name = name
	t.base = base
	t.db = self.db:RegisterNamespace(name, defaults)
	t.icons = t:CreateBackground(name)
	t.modules = {}
	t.lastUpdate = 0
	Bollo:GetModule("Config"):GenerateOptions(name, t)

	for k, v in Bollo:IterateModules() do
		if v.Register then
			v:Register(t)
		end
	end

	table.insert(self.registry, t)

	return t
end
