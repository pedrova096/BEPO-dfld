local Colors = require("lib.colors")
local StatusUpgradeType = require("lib.rewards.status.upgrade_type")

local AMMO_COLORS = {
	vmath.vector4(unpack(Colors["#88c3f8"])),
	vmath.vector4(unpack(Colors["#4b5bab"])),
	vmath.vector4(unpack(Colors["#4da6ff"])),
}
local VELOCITY_COLORS = {
	vmath.vector4(unpack(Colors["#b4e98c"])),
	vmath.vector4(unpack(Colors["#3d6e70"])),
	vmath.vector4(unpack(Colors["#8fde5d"])),
}
local LIFE_COLORS = {
	vmath.vector4(unpack(Colors["#f18e80"])),
	vmath.vector4(unpack(Colors["#8c3f5d"])),
	vmath.vector4(unpack(Colors["#eb564b"])),
}
local DAMAGE_COLORS = {
	vmath.vector4(unpack(Colors["#f6c38d"])),
	vmath.vector4(unpack(Colors["#8c3f5d"])),
	vmath.vector4(unpack(Colors["#f2a65e"])),
}
local CRITIC_COLORS = {
	vmath.vector4(unpack(Colors["#d385a5"])),
	vmath.vector4(unpack(Colors["#5a265e"])),
	vmath.vector4(unpack(Colors["#bd4882"])),
}

return {
	[StatusUpgradeType.Ammo] = AMMO_COLORS,
	[StatusUpgradeType.Velocity] = VELOCITY_COLORS,
	[StatusUpgradeType.Life] = LIFE_COLORS,
	[StatusUpgradeType.Damage] = DAMAGE_COLORS,
	[StatusUpgradeType.CriticalChance] = CRITIC_COLORS,
}
