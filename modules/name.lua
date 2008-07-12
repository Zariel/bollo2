local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local name = bollo:NewModule("Bollo-Name")

local subs = setmetatable({}, {__mode = "k"})

local truncate = function(self)
	local buff = self:GetBuff()
	if subs[buff] then return self[buff] end

	local s = ""
	for w in string.gmatch(buff, "%S+") do s = s .. string.sub(w, 1, 1) end

	s = string.sub(s, 1, 4)

	subs[buff] = s

	return s
end

function name:PostSetBuff(self)
	local tru = truncate(self)
	if self.name:GetText() ~= tru then
		self.name:SetText(tru)
	end
end

function name:PostCreateIcon(buff)
	local f = buff:CreateFontString(nil, "OVERLAY")
	f:SetPoint("TOP", buff, "BOTTOM", 0, -1)
	f:SetFont(name.db.font, name.db.fontSize, name.db.fontStyle)
	buff.name = f
end

function name:OnEnable()
	local defaults = {
		profile = {
			["font"] = STANDARD_TEXT_FONT,
			["fontStyle"] = "OUTLINE",
			["fontSize"] = 9,
		}
	}

	self.db = bollo.db:RegisterNamespace("Module-Name", defaults)

	if #bollo.buffs > 0 then
		for k, v in ipairs(bollo.buffs) do
			self:PostCreateIcon(v)
		end
	end

	if #bollo.debuffs > 0 then
		for k, v in ipairs(bollo.debuffs) do
			self:PostCreateIcon(v)
		end
	end

	bollo.event:RegisterEvent(name, "PostCreateIcon")
	bollo.event:RegisterEvent(name, "PostSetBuff")

end
