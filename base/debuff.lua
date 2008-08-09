local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Debuff = Bollo:NewModule("Debuff", "AceEvent-3.0")

function Debuff:OnInitialize()
	local defaults = {
		profile = {
			max = 40,
			perRow = 20,
			size = 32,
			spacing = 20,
			growthX = "LEFT",
			growthY = "DOWN",
			rowSpacing = 25,
			scale = 1,
			x = 0,
			y = 0,
			color = {
				r = 0,
				g = 1,
				b = 1,
				a = 0
			},
		},
	}

	self.db = Bollo.db:RegisterNamespace("Debuff", defaults)
end

function Debuff:OnEnable()
	self:RegisterEvent("PLAYER_AURAS_CHANGED", "Update")
	self.icons = self.icons or Bollo:CreateBackground("debuff", self.db.profile)

	for name, module in Bollo:IterateModules() do
		if module.Register then
			module:Register(Debuff)
		end
	end
	local config = Bollo:GetModule("Config")
	config.options.args.icons.args.debuff = config:GenerateOptions("Debuff", Debuff)
end

function Debuff:Update()
	for i = 1, self.db.profile.max do
		if GetPlayerBuff(i, "HARMFUL") > 0 then
			local icon = self.icons[i] or Bollo:NewIcon()
			icon:SetBase("HARMFUL")
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

function Debuff:UpdatePosition()
	Bollo.events:Fire("PrePositionIcons", self.icons, Debuff)
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

function Debuff:UpdateConfig()
	for i, buff in ipairs(self.icons) do
		buff:Setup(self.db.profile)
	end
	if self.config then
		self:EnableSetupConfig()
	end
	self:UpdatePosition()
end

function Debuff:EnableSetupConfig()
	self.config = true
	self:UnregisterEvent("PLAYER_AURAS_CHANGED")

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

function Debuff:DisableSetupConfig()
	self.config = false
	self:Update()
	self:RegisterEvent("PLAYER_AURAS_CHANGED", "Update")
end