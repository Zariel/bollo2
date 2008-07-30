local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local buff = Bollo:NewModule("Buff", "AceEvent-3.0", "AceConsole-3.0")
local units = {}

function buff:OnEnable()
	self:RegisterUnit("player")
	self:RegisterEvent("UNIT_AURA")

	local defaults = {}
	self.db = Bollo.db:RegisterNamespace("buff", defaults)

	self.icons = {}
	self:UNIT_AURA(nil, "player")

end

function buff:RegisterUnit(unit)
	units[unit] = true
end

function buff:UNIT_AURA(event, unit)
	if not units[unit] then return end

	local i = 1
	while true do
		local name = UnitBuff(unit, i)
		if not name then break end

		local icon, id = Bollo.Auras:NewIcon()
		icon:SetUnit(unit)
		icon:SetID(i)
		icon:SetBase("buff")
		icon:Update()
		icon:SetNormalTexture(icon.info.icon)
		icon:Show()

		i = i + 1

		self.icons[id] = icon
	end

	while self.icons[i] do
		local id = Bollo.Auras:DelIcon(self.icons[i])
		self.icons[id] = nil

		i = i + 1
	end
end

function buff:PositionIcons()
	local offset = 0
	for index, icon in ipairs(self.icons) do
		if icon:IsShown() then
			icon:ClearAllPoints()
			icon:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -(32 * offset + 5) - 200, -10)
			offset = offset + 1
		end
	end
end
