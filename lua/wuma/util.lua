
WUMA = WUMA or {}
local WUMADebug = WUMADebug
local WUMALog = WUMALog

WUMA.WUMALookupTable = "WUMALookup"
WUMA.Settings = WUMA.Settings or {}
WUMA.SettingsHooks = WUMA.SettingsHooks or {}

local uniqueIDs = 0
function WUMA.GenerateUniqueID()
	local id = uniqueIDs+1
	uniqueIDs = uniqueIDs + 1
	return id
end

function WUMA.AddLookup(user)
	WUMASQL("REPLACE INTO %s (steamid, nick, usergroup, t) values ('%s', '%s', '%s', %s);", WUMA.SQL.WUMALookupTable, user:SteamID(), user:Nick(), user:GetUserGroup(), tostring(os.time()))
end

function WUMA.RemoveLookup(user)
	WUMASQL("DELETE FROM %s WHERE steamid=%s;", WUMA.SQL.WUMALookupTable, user:SteamID())
end

function WUMA.Lookup(user)
	if isstring(user) then
		if WUMA.IsSteamID(user) then
			return WUMASQL("SELECT * FROM %s WHERE steamid LIKE '%s%s LIMIT 50;", WUMA.WUMALookupTable, user, "%'")
		else
			return WUMASQL("SELECT * FROM %s WHERE nick LIKE %s%s%s LIMIT 50;", WUMA.WUMALookupTable, "'%", user, "%'")
		end
	elseif (isnumber(user)) then
		return WUMASQL("SELECT * FROM %s ORDER BY t ASC LIMIT %s", WUMA.WUMALookupTable, tostring(user))
	end
end

function WUMA.GetSteamIDbyNick(id)
	return WUMA.Lookup(user)
end

local stcache = {}
function WUMA.STCache(id, data)
	if data then
		stcache[id] = {data=data, t=os.time()}
	else
		local entry = stcache[id]
		if entry then
			if (entry.t + 2 > os.time()) then
				stcache[id].t = os.time()
				return stcache[id].data
			else
				stcache[id] = nil
			end
		end
	end
end

local cacheCounter = 0
local cacheSize = 20
local head
local tail
function WUMA.Cache(id, data)
	if (data) then
		if not head then
			head = {id = id, data = data, next = nil}
			tail = head
			cacheCounter = cacheCounter + 1
		else
			local link = {id = id, data = data, next = head}
			head = link
			cacheCounter = cacheCounter + 1
		end

		if (cacheCounter >= cacheSize) then
			local counter = 0
			local l = head
			while l do
				if (counter > cacheSize - 2) then
					l.next = nil
					l = nil
					cacheCounter = counter
				else
					l = l.next
					counter = counter + 1
				end
			end
		end
	else
		local link = head --Set link to head (first element)
		local previous --Declare pervious
		while (link ~= nil) do
			if (link.id == id) then --Check if link is what we are looking for
				if (previous) then --If previous is not nil then link is not head
					previous.next = link.next --Set the previous element to the the current links next element
					link.next = head --Set current links next to current head
					head = link --Set head to current link
				end
				return link.data --Return the data
			end

			previous = link --Set previous to current link
			link = link.next --Set current link to next link
		end
	end
end

function WUMA.InvalidateCache(id)
	if not head then return end
	local link = head
	local previous
	while (link ~= nil) do
		if (link.id == id) then
			if (previous) then
				previous.next = link.next
			else
				head = head.next
			end
			cacheCounter = cacheCounter - 1
			break
		else
			previous = link
			link = link.next
		end
	end
end

function WUMA.TransferRestrictions( oldgroup, newgroup )
	for _, res in pairs( WUMA.GetSavedRestrictions() ) do
		local usergroup = res:GetUserGroup()
		if usergroup == oldgroup then
			WUMA.AddRestriction( _, newgroup, res:GetType(), res:GetString(), res:GetAllow(), res:GetScope() )
			res:Shred()
		end
	end

	for _, limit in pairs( WUMA.GetSavedLimits() ) do
		local usergroup = limit:GetUserGroup()
		if usergroup == oldgroup then
			WUMA.AddLimit( _, newgroup, limit:GetString(), limit:Get(), limit:IsExclusive(), limit:GetScope() )
			limit:Shred()
		end
	end

	for enum, tbl in pairs( WUMA.GetSavedInheritance() ) do
		for parent, child in pairs( tbl ) do
			if parent == oldgroup then
				WUMA.SetUsergroupInheritance( enum, newgroup, child )
				WUMA.UnsetUsergroupInheritance( enum, oldgroup )
			end
		end
	end
end

hook.Add( ULib.HOOK_GROUP_RENAMED, "WUMA_AutoTransferRanks", function( oldgroup, newgroup )
	WUMA.Log.ServerLog( "Transferring limits, restrictions and inheritance from " .. oldgroup .. " to " .. newgroup .. "." )
	WUMA.TransferRestrictions( oldgroup, newgroup )
end )
