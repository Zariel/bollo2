local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local name = bollo:NewModule("Bollo-Name")

local subs = setmetatable({}, {__mode = "k"})

local truncate = function(b)
	local buff = b:GetBuff()
	if subs[buff] then return subs[buff] end

	local s = ""
	for w in string.gmatch(buff, "%S+") do s = s .. string.sub(w, 1, 1) end

	s = string.sub(s, 1, 4)

	subs[buff] = s

	return s
end

function name:PostSetBuff(event, buff)
	local tru = truncate(buff)
	if buff.name:GetText() ~= tru then
		buff.name:SetText(tru)
	end
end

function name:PostCreateIcon(event, parent, buff)
	local f = buff:CreateFontString(nil, "OVERLAY")
	f:SetPoint("TOP", buff, "BOTTOM", 0, -1)
	f:SetFont(self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle)
	buff.name = f
end

function name:OnInitialize()
	local defaults = {
		profile = {
			["Description"] = "Shows truncated names of buffs",
			["font"] = STANDARD_TEXT_FONT,
			["fontStyle"] = "OUTLINE",
			["fontSize"] = 9,
		}
	}
	self.db = bollo.db:RegisterNamespace("Module-Name", defaults)
end

function name:OnEnable()
	for index, buff in ipairs(bollo.buffs) do
		self:PostCreateIcon(nil, bollo.buffs, buff)
	end
	for index, buff in ipairs(bollo.debuffs) do
		self:PostCreateIcon(nil, bollo.debuffs, buff)
	end

	bollo.RegisterCallback(name, "PostCreateIcon")
	bollo.RegisterCallback(name, "PostSetBuff")
end
