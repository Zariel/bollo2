local _G = getfenv(0)

if not _G.bollo then
	return
end

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

local SetBuff = function(self)
	local tru = truncate(self)
	if self.name:GetText() ~= tru then
		self.name:SetText(tru)
	end
end

local CreateIcon = function(buff)
	local f = buff:CreateFontString(nil, "OVERLAY")
	f:SetPoint("TOP", buff, "BOTTOM", 0, -1)
	f:SetFont(name.db.font, name.db.fontSize, name.db.fontStyle)
	buff.name = f
end

function name:Enable()
	bollo.db.profile.modules = bollo.db.profile.modules or {}
	bollo.db.profile.modules.name = bollo.db.profile.modules.name or {
		["font"] = STANDARD_TEXT_FONT,
		["fontStyle"] = "OUTLINT",
		["fontSize"] = 9,
	}

	self.db = bollo.db.profile.modules.name

	for k, v in ipairs(bollo.buffs) do
		CreateIcon(v)
	end
	for k, v in ipairs(bollo.debuffs) do
		CreateIcon(v)
	end

	bollo:RegisterCallback("CreateIcon", CreateIcon)
	bollo:RegisterCallback("SetBuff", SetBuff)

end
