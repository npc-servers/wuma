--[[
for name, access in pairs(WUMA.AccessRegister) do
	if not access:IsStrict() then
	
		ulx[name] = access:GetFunction()
		local cmd = ulx.command(CATEGORY_NAME, "wuma "..name, ulx[name], "!"..name)
		
		for _, tbl in pairs(access:GetArguments()) do
			if istable(types[tbl.type]) then
				cmd:addParam(types[tbl.type])
			elseif types[WUMAAccess.SCOPE] then
				if tbl[2] then
					cmd:addParam{type=types[tbl[1] ],completes=tbl[3]}
				else
					cmd:addParam{type=types[tbl[1] ],completes=tbl[3],ULib.cmds.optional}
				end
			end	
		end
		
		if access:GetHelp() then cmd:help(access:GetHelp()) end
		cmd:defaultAccess(access:GetAccess())
	
	end
end



local CATEGORY_NAME = "WUMA"

local types = {}
types[WUMAAccess.PLAYER] = {type=ULib.cmds.PlayersArg}
types[WUMAAccess.STRING] = ULib.cmds.StringArg
types[WUMAAccess.USERGROUP] = {type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes}
types[WUMAAccess.NUMBER] = {type=ULib.cmds.NumArg, ULib.cmds.round}
types[WUMAAccess.SCOPE] = nil

for name, access in pairs(WUMA.AccessRegister) do
	if not access:IsStrict() then
	
		ulx[name] = access:GetFunction()
		local cmd = ulx.command(CATEGORY_NAME, "wuma "..name, ulx[name], "!"..name)
		
		for _, tbl in pairs(access:GetArguments()) do
			if istable(types[tbl.type]) then
				cmd:addParam(types[tbl.type])
			elseif types[WUMAAccess.SCOPE] then
				if tbl[2] then
					cmd:addParam{type=types[tbl[1] ],completes=tbl[3]}
				else
					cmd:addParam{type=types[tbl[1] ],completes=tbl[3],ULib.cmds.optional}
				end
			end	
		end
		
		if access:GetHelp() then cmd:help(access:GetHelp()) end
		cmd:defaultAccess(access:GetAccess())
	
	end
end


--Restrict
	function ulx.restrict(calling_ply, usergroup, type, item)
		usergroup = string.lower(usergroup)
		type = string.lower(type)
		item = string.lower(item)
		
		WUMA.AddRestriction(calling_ply,usergroup,type,item)
	end
	local restrict = ulx.command(CATEGORY_NAME, "ulx restrict", ulx.restrict, "!restrict")
	restrict:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	restrict:addParam{ type=ULib.cmds.StringArg, completes=table.GetKeys(Restriction:GetTypes()), hint="type", error="invalid type =\"%s\" specified", ULib.cmds.restrictToCompletes }
	restrict:addParam{ type=ULib.cmds.StringArg, hint="Class / Model" }
	restrict:defaultAccess(ULib.ACCESS_SUPERADMIN)
	restrict:help("Restrict something from a usergroup")

--Restrict user
	function ulx.restrictuser(calling_ply, target_ply, type, item)
		type = string.lower(type)
		item = string.lower(item)
	
		WUMA.AddUserRestriction(calling_ply,target_ply,type,item)
	end
	local restrictuser = ulx.command(CATEGORY_NAME, "ulx restrictuser", ulx.restrictuser, "!restrictuser")
	restrictuser:addParam{ type=ULib.cmds.PlayersArg }
	restrictuser:addParam{ type=ULib.cmds.StringArg, completes=table.GetKeys(Restriction:GetTypes()), hint="type", error="invalid typ =\"%s\" specified", ULib.cmds.restrictToCompletes }
	restrictuser:addParam{ type=ULib.cmds.StringArg, hint="Class / Model" }
	restrictuser:defaultAccess(ULib.ACCESS_SUPERADMIN)
	restrictuser:help("Restrict something from a player")

--Unrestrict
	function ulx.unrestrict(calling_ply, usergroup, type, item)
		usergroup = string.lower(usergroup)
		type = string.lower(type)
		item = string.lower(item)
	
		WUMA.RemoveRestriction(calling_ply,usergroup,type,item)
	end
	local unrestrict = ulx.command(CATEGORY_NAME, "ulx unrestrict", ulx.unrestrict, "!unrestrict")
	unrestrict:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	unrestrict:addParam{ type=ULib.cmds.StringArg, completes=table.GetKeys(Restriction:GetTypes()), hint="type", error="invalid typ =\"%s\" specified", ULib.cmds.restrictToCompletes }
	unrestrict:addParam{ type=ULib.cmds.StringArg, hint="Class / Model" }
	unrestrict:defaultAccess(ULib.ACCESS_SUPERADMIN)
	unrestrict:help("Unrestrict something from a usergroup")

--Unrestrict user
	function ulx.unrestrictuser(calling_ply, target_ply, type, item)
		type = string.lower(type)
		item = string.lower(item)
	
		WUMA.RemoveUserRestriction(calling_ply,target_ply,type,item)
	end
	local unrestrictuser = ulx.command(CATEGORY_NAME, "ulx unrestrictuser", ulx.unrestrictuser, "!unrestrictuser")
	unrestrictuser:addParam{ type=ULib.cmds.PlayersArg }
	unrestrictuser:addParam{ type=ULib.cmds.StringArg, completes=table.GetKeys(Restriction:GetTypes()), hint="type", error="invalid typ =\"%s\" specified", ULib.cmds.restrictToCompletes }
	unrestrictuser:addParam{ type=ULib.cmds.StringArg, hint="Class / Model" }
	unrestrictuser:defaultAccess(ULib.ACCESS_SUPERADMIN)
	unrestrictuser:help("Unrestrict something from a player")

--Set limit
	function ulx.setlimit(calling_ply, usergroup, item, limit)
		usergroup = string.lower(usergroup)
		limit = string.lower(limit)
		item = string.lower(item)
	
		WUMA.AddLimit(calling_ply,usergroup, item, limit)
	end
	local setlimit = ulx.command(CATEGORY_NAME, "ulx setlimit", ulx.setlimit, "!setlimit")
	setlimit:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	setlimit:addParam{ type=ULib.cmds.StringArg, hint="Item" }
	setlimit:addParam{ type=ULib.cmds.StringArg, hint="Limit" }
	setlimit:defaultAccess(ULib.ACCESS_SUPERADMIN)
	setlimit:help("Set somethings limit.")

--Set user limit
	function ulx.setuserlimit(calling_ply, target_plys, item, limit)
		limit = string.lower(limit)
		item = string.lower(item)
	
		WUMA.AddUserLimit(calling_ply,target_plys, item, limit)
	end
	local setuserlimit = ulx.command(CATEGORY_NAME, "ulx setuserlimit", ulx.setuserlimit, "!setuserlimit")
	setuserlimit:addParam{ type=ULib.cmds.PlayersArg }
	setuserlimit:addParam{ type=ULib.cmds.StringArg, hint="Item" }
	setuserlimit:addParam{ type=ULib.cmds.StringArg, hint="Limit" }
	setuserlimit:defaultAccess(ULib.ACCESS_SUPERADMIN)
	setuserlimit:help("Set the limit something for a player")

--Unset limit
	function ulx.unsetlimit(calling_ply, usergroup, item)
		usergroup = string.lower(usergroup)
		item = string.lower(item)
	
		WUMA.RemoveLimit(calling_ply,usergroup, item)
	end
	local unsetlimit = ulx.command(CATEGORY_NAME, "ulx unsetlimit", ulx.unsetlimit, "!unsetlimit")
	unsetlimit:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	unsetlimit:addParam{ type=ULib.cmds.StringArg, hint="Item" }
	unsetlimit:defaultAccess(ULib.ACCESS_SUPERADMIN)
	unsetlimit:help("Unset somethings limit.")

--Unset user limit
	function ulx.unsetuserlimit(calling_ply, target_ply, item)
		item = string.lower(item)
	
		WUMA.AddUserLimit(calling_ply,target_ply, item)
	end
	local unsetuserlimit = ulx.command(CATEGORY_NAME, "ulx unsetuserlimit", ulx.unsetuserlimit, "!unsetuserlimit")
	unsetuserlimit:addParam{ type=ULib.cmds.PlayersArg }
	unsetuserlimit:addParam{ type=ULib.cmds.StringArg, hint="Item" }
	unsetuserlimit:defaultAccess(ULib.ACCESS_SUPERADMIN)
	unsetuserlimit:help("Unset the limit something for a player")

--Add group loadout
	function ulx.addloadout(calling_ply, usergroup, item, primary, secondary)
		usergroup = string.lower(usergroup)
		item = string.lower(item)

		WUMA.AddLoadoutWeapon(calling_ply,usergroup, item, primary, secondary)
	end
	local addloadout = ulx.command(CATEGORY_NAME, "ulx addloadout", ulx.addloadout, "!addloadout")
	addloadout:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	addloadout:addParam{ type=ULib.cmds.StringArg, completes=WUMA.GetWeapons(), hint="weapon", error="invalid weapon \"%s\" specified", ULib.cmds.restrictToCompletes }
	addloadout:addParam{ type=ULib.cmds.NumArg, ULib.cmds.round,ULib.cmds.optional, min=0,default=200, hint="Primary ammo" }
	addloadout:addParam{ type=ULib.cmds.NumArg, ULib.cmds.round,ULib.cmds.optional, min=0,default=10, hint="Secondary ammo" }
	addloadout:defaultAccess(ULib.ACCESS_SUPERADMIN)
	addloadout:help("Add a weapon to a usergroups loadout.")

--Add user loadout
	function ulx.adduserloadout(calling_ply, target_plys, item, primary, secondary)
		item = string.lower(item)
	
		WUMA.AddUserLoadoutWeapon(calling_ply,target_plys, item, primary, secondary)
	end
	local adduserloadout = ulx.command(CATEGORY_NAME, "ulx adduserloadout", ulx.adduserloadout, "!adduserloadout")
	adduserloadout:addParam{ type=ULib.cmds.PlayersArg }
	adduserloadout:addParam{ type=ULib.cmds.StringArg, completes=WUMA.GetWeapons(), hint="weapon", error="invalid weapon \"%s\" specified", ULib.cmds.restrictToCompletes }
	adduserloadout:addParam{ type=ULib.cmds.NumArg, ULib.cmds.round,ULib.cmds.optional, min=0,default=200, hint="Primary ammo" }
	adduserloadout:addParam{ type=ULib.cmds.NumArg, ULib.cmds.round,ULib.cmds.optional, min=0,default=10, hint="Secondary ammo" }
	adduserloadout:defaultAccess(ULib.ACCESS_SUPERADMIN)
	adduserloadout:help("Add a weapon to a users loadout.")

--Delete group loadout
	function ulx.removeloadout(calling_ply, usergroup, item)
		usergroup = string.lower(usergroup)
		item = string.lower(item)
	
		WUMA.RemoveLoadoutWeapon(calling_ply,usergroup, item)
	end
	local removeloadout = ulx.command(CATEGORY_NAME, "ulx removeloadout", ulx.removeloadout, "!removeloadout")
	removeloadout:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	removeloadout:addParam{ type=ULib.cmds.StringArg, completes=WUMA.GetWeapons(), hint="weapon", error="invalid weapon \"%s\" specified", ULib.cmds.restrictToCompletes }
	removeloadout:defaultAccess(ULib.ACCESS_SUPERADMIN)
	removeloadout:help("Remove a weapon from a usergroups loadout.")

--Delete user loadout
	function ulx.removeuserloadout(calling_ply, target_plys, item)
		item = string.lower(item)
	
		WUMA.RemoveUserLoadoutWeapon(calling_ply,target_plys, item)
	end
	local removeuserloadout = ulx.command(CATEGORY_NAME, "ulx removeuserloadout", ulx.removeuserloadout, "!removeuserloadout")
	removeuserloadout:addParam{ type=ULib.cmds.PlayersArg }
	removeuserloadout:addParam{ type=ULib.cmds.StringArg, completes=WUMA.GetWeapons(), hint="weapon", error="invalid weapon \"%s\" specified", ULib.cmds.restrictToCompletes }
	removeuserloadout:defaultAccess(ULib.ACCESS_SUPERADMIN)
	removeuserloadout:help("Remove a weapon from a users loadout.")

--Clear group loadout
	function ulx.clearloadout(calling_ply, usergroup)
		usergroup = string.lower(usergroup)
	
		WUMA.ClearLoadout(calling_ply,usergroup)
	end
	local clearloadout = ulx.command(CATEGORY_NAME, "ulx clearloadout", ulx.clearloadout, "!clearloadout")
	clearloadout:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	clearloadout:defaultAccess(ULib.ACCESS_SUPERADMIN)
	clearloadout:help("Clear a usergroups loadout.")
	
--Clear user loadout
	function ulx.clearuserloadout(calling_ply, target_plys)
		WUMA.ClearUserLoadout(calling_ply,target_plys)
	end
	local clearuserloadout = ulx.command(CATEGORY_NAME, "ulx clearuserloadout", ulx.clearuserloadout, "!clearuserloadout")
	clearuserloadout:addParam{ type=ULib.cmds.PlayersArg }
	clearuserloadout:defaultAccess(ULib.ACCESS_SUPERADMIN)
	clearuserloadout:help("Clear a user loadout.")
	
--Set group primary weapon
	function ulx.setprimaryweapon(calling_ply, usergroup, item	)
		usergroup = string.lower(usergroup)
	
		WUMA.SetLoadoutPrimaryWeapon(calling_ply,usergroup,item)
	end
	local setprimaryweapon = ulx.command(CATEGORY_NAME, "ulx setprimaryweapon", ulx.setprimaryweapon, "!setprimaryweapon")
	setprimaryweapon:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	setprimaryweapon:addParam{ type=ULib.cmds.StringArg, completes=WUMA.GetWeapons(), hint="weapon", error="invalid weapon \"%s\" specified", ULib.cmds.restrictToCompletes }
	setprimaryweapon:defaultAccess(ULib.ACCESS_SUPERADMIN) 
	setprimaryweapon:help("Set a groups primary weapon.")

--Set user primary weapon
	function ulx.setuserprimaryweapon(calling_ply, users, item	)
		WUMA.SetUserLoadoutPrimaryWeapon(calling_ply,users,string.lower(item))
	end
	local setuserprimaryweapon = ulx.command(CATEGORY_NAME, "ulx setuserprimaryweapon", ulx.setuserprimaryweapon, "!setuserprimaryweapon")
	setuserprimaryweapon:addParam{ type=ULib.cmds.PlayersArg }
	setuserprimaryweapon:addParam{ type=ULib.cmds.StringArg, completes=WUMA.GetWeapons(), hint="weapon", error="invalid weapon \"%s\" specified", ULib.cmds.restrictToCompletes }
	setuserprimaryweapon:defaultAccess(ULib.ACCESS_SUPERADMIN)
	setuserprimaryweapon:help("Set a users primary weapon.")

]]--