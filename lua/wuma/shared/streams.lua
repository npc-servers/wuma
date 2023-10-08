
WUMA = WUMA or {}
local WUMADebug = WUMADebug
local WUMALog = WUMALog

WUMA.Streams = {}

function WUMA.RegisterStream(tbl)
	local stream = WUMAStream:new(tbl)
	WUMA.Streams[stream:GetName()] = stream
	return stream
end

function WUMA.GetStream(name)
	return WUMA.Streams[name]
end

local Settings = WUMA.RegisterStream{name="settings", send=WUMA.SendInformation}
Settings:SetServerFunction(function(user, data)
	local metadata = {
		wuma_server_time=os.time(),
		wuma_limit_count=table.Count(WUMA.Limits),
		wuma_restriction_count=table.Count(WUMA.Restrictions)
	}
	
	return {user, Settings, table.Merge(WUMA.ConVars.Settings, metadata)}
end) 
Settings:SetClientFunction(function(data) 
	for name, value in pairs(data[1]) do
		WUMA.ServerSettings[string.sub(name, 6)] = value
	end
	hook.Call(WUMA.SETTINGSUPDATE, _, WUMA.ServerSettings)
	WUMA.ServerSettings["server_time_offset"] = WUMA.ServerSettings["server_time"] - os.time()
end)
Settings:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Inheritance = WUMA.RegisterStream{name="inheritance", send=WUMA.SendInformation}
Inheritance:SetServerFunction(function(user, data) 
	return {user, Inheritance, WUMA.GetAllInheritances()}
end) 
Inheritance:SetClientFunction(function(data) 
	WUMA.Inheritance = data[1]
	hook.Call(WUMA.INHERITANCEUPDATE, _, data[1])
end)
Inheritance:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Subscription = WUMA.RegisterStream{name="subscription", send=WUMA.SendInformation}
Subscription:SetServerFunction(function(user, data)
	if (data[2]) then
		WUMA.RemoveDataSubscription(user, data[1], data[3])
	else
		WUMA.AddDataSubscription(user, data[1], data[3])
	end
end) 
Subscription:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local CVarLimits = WUMA.RegisterStream{name="cvarlimits", send=WUMA.SendInformation}
CVarLimits:SetServerFunction(function(user, data)
	return {user, CVarLimits, WUMA.ConVars.Limits}
end) 
CVarLimits:SetClientFunction(function(data)
	WUMA.CVarLimits = data[1]
	hook.Call(WUMA.CVARLIMITSUPDATE)
end)
CVarLimits:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Groups = WUMA.RegisterStream{name="groups", send=WUMA.SendInformation}
Groups:SetServerFunction(function(user, data)
	return {user, Groups, WUMA.GetUserGroups()}
end) 
Groups:SetClientFunction(function(data)
	WUMA.ServerGroups = data[1]
	hook.Call(WUMA.USERGROUPSUPDATE)
end)
Groups:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Users = WUMA.RegisterStream{name="users", send=WUMA.SendInformation, auto_update=true}
Users:SetServerFunction(function(user, data)	
	local users = {}
	for _, ply in pairs(player.GetAll()) do
		local id = ply:SteamID()
		
		users[id] = {}
		users[id].usergroup = ply:GetUserGroup()
		users[id].nick = ply:Nick()
		users[id].steamid = id
		users[id].t = os.time()
		users[id].ent = ply
	end
	return {user, Users, users}
end) 
Users:SetClientFunction(function(data) 
	local players = {}
	for _, v in pairs(data[1]) do
		players[v.steamid] = v

		if not WUMA.LookupUsers[v.steamid] then 
			v.t=tostring(v.t)
			WUMA.LookupUsers[v.steamid] = v
		end
	end
	
	WUMA.ServerUsers = players
	
	for steamid, user in pairs(WUMA.ServerUsers) do
		if not IsValid(user.ent) then WUMA.ServerUsers[steamid] = nil end
	end
	
	hook.Call(WUMA.SERVERUSERSUPDATE)
end) 
Users:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local User = WUMA.RegisterStream{name="user", send=WUMA.SendInformation}
User:SetServerFunction(function(user, data)
	return {user, User, WUMA.GetUserData(data[1])}
end) 
User:SetClientFunction(function(data)
	if not data.steamid then return end
	WUMA.UserData[data.steamid] = data
	hook.Call(WUMA.USERDATAUPDATE, data.steamid)
end) 
User:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Lookup = WUMA.RegisterStream{name="lookup", send=WUMA.SendInformation}
Lookup:SetServerFunction(function(user, data)
	return {user, Lookup, WUMA.Lookup(data[1]) or {}}
end) 
Lookup:SetClientFunction(function(data)
	local tbl = {}
	for i=1, table.Count(data[1]) do
		WUMA.LookupUsers[data[1][i].steamid] = data[1][i]
		tbl[data[1][i].steamid] = WUMA.LookupUsers[data[1][i].steamid]
	end
	hook.Call(WUMA.LOOKUPUSERSUPDATE, _, tbl)
end) 
Lookup:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Maps = WUMA.RegisterStream{name="maps", send=WUMA.SendInformation}
Maps:SetServerFunction(function(user, data)
	local maps = {file.Find("maps/*.bsp", "GAME")}
	return {user, Maps, maps[1]}
end) 
Maps:SetClientFunction(function(data)
	WUMA.Maps = data[1]
	hook.Call(WUMA.MAPSUPDATE)
end) 
Maps:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local WhoIs = WUMA.RegisterStream{name="whois", send=WUMA.SendInformation}
WhoIs:SetServerFunction(function(user, data)
	return {user, Maps, WUMA.Lookup(data[1])}
end) 
WhoIs:SetClientFunction(function(data)
	WUMA.LookupUsers[data.steamid] = data.nick 
end) 
WhoIs:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Restrictions = WUMA.RegisterStream{name="restrictions", send=WUMA.SendCompressedData}
Restrictions:SetServerFunction(function(user, data)
	if data[1] then
		if WUMA.CheckUserFileExists(data[1], Restriction) then
			local tbl = WUMA.GetSavedRestrictions(data[1])
			return {user, tbl, Restriction:GetID()..":::"..data[1]}
		else
			return {user, {}, Restriction:GetID()..":::"..data[1]}
		end
	else
		if WUMA.RestrictionsExist() then
			local cached = WUMA.Cache(Restriction:GetID())
			if not cached then
				cached = util.Compress(util.TableToJSON(WUMA.Restrictions))
				WUMA.Cache(Restriction:GetID(), cached)
			end
			return {user, cached, Restriction:GetID(), true}
		else
			return {user, {}, Restriction:GetID()}
		end
	end
end) 
Restrictions:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local Limits = WUMA.RegisterStream{name="limits", send=WUMA.SendCompressedData}
Limits:SetServerFunction(function(user, data)
	if data[1] then
		if WUMA.CheckUserFileExists(data[1], Limit) then
			local tbl = WUMA.GetSavedLimits(data[1])
			return {user, tbl, Limit:GetID()..":::"..data[1]}
		else
			return {user, {}, Limit:GetID()..":::"..data[1]}
		end 
	else
		if WUMA.LimitsExist() then
			local cached = WUMA.Cache(Limit:GetID())
			if not cached then
				cached = util.Compress(util.TableToJSON(WUMA.Limits))
				WUMA.Cache(Limit:GetID(), cached)
			end
			return {user, cached, Limit:GetID(), true}
		else
			return {user, {}, Limit:GetID()}
		end
	end
end) 
Limits:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)

local RestrictionItems = WUMA.RegisterStream{name="restrictionitems", send=WUMA.SendInformation}
RestrictionItems:SetServerFunction(function(user, data)
	return {user, RestrictionItems, WUMA.GetAdditionalEntities()}
end) 
RestrictionItems:SetClientFunction(function(data)
	WUMA.AdditionalEntities = data[1]
end)
RestrictionItems:SetAuthenticationFunction(function(user, callback) 
	WUMA.HasAccess(user, callback)
end)