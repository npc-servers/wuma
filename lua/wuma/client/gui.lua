
WUMA = WUMA or {}
WUMA.GUI = {}
WUMA.GUI.Tabs = {}

local WGUI = WUMA.GUI

if not WUMA.HasCreatedFonts then
	surface.CreateFont("WUMATextSmall", {
		font = "Arial",
		size = 10,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true
	})
end
WUMA.HasCreatedFonts = true

WUMA.Subscriptions = {}
WUMA.Subscriptions.user = {}
WUMA.Subscriptions.timers = {}

function WUMA.GUI.Initialize()

	--Requests
	if GetConVar("wuma_request_on_join"):GetBool() then
		WUMA.RequestFromServer("settings")
		WUMA.RequestFromServer("restrictions")
		WUMA.RequestFromServer("limits")
		WUMA.RequestFromServer("cvarlimits")
		WUMA.RequestFromServer("users")
		WUMA.RequestFromServer("groups")
		WUMA.RequestFromServer("maps")
		WUMA.RequestFromServer("inheritance")
		WUMA.RequestFromServer("lookup", 200)
		WUMA.RequestFromServer("restrictionitems")

		WUMA.RequestFromServer("subscription", Restriction:GetID())
		WUMA.RequestFromServer("subscription", Limit:GetID())

		WUMA.Subscriptions.info = true
		WUMA.Subscriptions.restrictions = true
		WUMA.Subscriptions.limits = true
		WUMA.Subscriptions.users = true
	end

	--Create EditablePanel
	WGUI.Base = vgui.Create("EditablePanel")
	WGUI.Base:SetSize(ScrW()*0.40, ScrH()*0.44)
	WGUI.Base:SetPos(ScrW()/2-WGUI.Base:GetWide()/2, ScrH()/2-WGUI.Base:GetTall()/2)
	WGUI.Base:SetVisible(false)

	--Create propertysheet
	WGUI.PropertySheet = vgui.Create("WPropertySheet", WGUI.Base)
	WGUI.PropertySheet:SetSize(WGUI.Base:GetSize())
	WGUI.PropertySheet:SetPos(0, 0)
	WGUI.PropertySheet:SetShowExitButton(true)

	--Request panels
	WGUI.Tabs.Settings = vgui.Create("WUMA_Settings", WGUI.PropertySheet) --Settings
	WGUI.Tabs.Restrictions = vgui.Create("WUMA_Restrictions", WGUI.PropertySheet) --Restriction
	WGUI.Tabs.Limits = vgui.Create("WUMA_Limits", WGUI.PropertySheet) --Limit
	WGUI.Tabs.Users = vgui.Create("WUMA_Users", WGUI.PropertySheet) --Users

	WGUI.PropertySheet.OnTabChange = WUMA.OnTabChange

	--Adding panels to PropertySheet
	WGUI.PropertySheet:AddSheet(WGUI.Tabs.Settings.TabName, WGUI.Tabs.Settings, WGUI.Tabs.Settings.TabIcon) --Settings
	WGUI.PropertySheet:AddSheet(WGUI.Tabs.Restrictions.TabName, WGUI.Tabs.Restrictions, WGUI.Tabs.Restrictions.TabIcon) --Restriction
	WGUI.PropertySheet:AddSheet(WGUI.Tabs.Limits.TabName, WGUI.Tabs.Limits, WGUI.Tabs.Limits.TabIcon) --Limit
	WGUI.PropertySheet:AddSheet(WGUI.Tabs.Users.TabName, WGUI.Tabs.Users, WGUI.Tabs.Users.TabIcon) --Player

	--Setting datatables
	WGUI.Tabs.Restrictions:GetDataView():SetDataTable(function() return WUMA.Restrictions end)
	WGUI.Tabs.Limits:GetDataView():SetDataTable(function() return WUMA.Limits end)
	WGUI.Tabs.Users:GetDataView():SetDataTable(function() return WUMA.LookupUsers end)

	--Adding data update hooks
	hook.Add(WUMA.RESTRICTIONUPDATE, "WUMARestrictionDataUpdate", function(update) WGUI.Tabs.Restrictions:GetDataView():UpdateDataTable(update) end) --Restriction
	hook.Add(WUMA.LIMITUPDATE, "WUMALimitDataUpdate", function(update) WGUI.Tabs.Limits:GetDataView():UpdateDataTable(update) end) --Limits

	WGUI.Tabs.Users.OnExtraChange = WUMA.OnUserTabChange

	hook.Call("OnWUMAInitialized", _, WGUI.PropertySheet)

end
hook.Add("PostGamemodeLoaded", "WUMAGuiInitialize", function() timer.Simple(2, WUMA.GUI.Initialize) end)

function WUMA.GUI.Show()
	if not WUMA.GUI.Base then WUMA.GUI.Initialize() end

	if (table.Count(WUMA.GUI.Base:GetChildren()) > 0) then
		WUMA.OnTabChange(WUMA.GUI.ActiveTab or WUMA.GUI.Tabs.Settings.TabName)

		WUMA.GUI.Base:SetVisible(true)
		WUMA.GUI.Base:MakePopup()
	end
end

function WUMA.GUI.Hide()
	if not WUMA.GUI.Base then WUMA.GUI.Initialize() end

	if (table.Count(WUMA.GUI.Base:GetChildren()) > 0) then
		WUMA.GUI.Base:SetVisible(false)
	end
end

function WUMA.GUI.Toggle()
	if not WUMA.GUI.Base then WUMA.GUI.Initialize() end

	if WUMA.GUI.Base:IsVisible() then
		WUMA.GUI.Hide()
	else
		WUMA.GUI.Show()
	end
end

function WUMA.SetProgress(id, msg, timeout)
	timer.Create("WUMARequestTimerBarStuff" .. id, timeout, 1, function()
		hook.Remove(WUMA.PROGRESSUPDATE, "WUMAProgressUpdate"..id)
		hook.Call(WUMA.PROGRESSUPDATE, _, id, msg)
	end)
	hook.Add(WUMA.PROGRESSUPDATE, "WUMAProgressUpdate"..id, function(incid)
		timer.Remove("WUMARequestTimerBarStuff" .. incid)
	end)
end

function WUMA.OnTabChange(_, tabname)

	if not WUMA.Subscriptions.info then
		WUMA.RequestFromServer("settings")
		WUMA.RequestFromServer("inheritance")
		WUMA.RequestFromServer("groups")
		WUMA.RequestFromServer("users")
		WUMA.RequestFromServer("maps")

		WUMA.Subscriptions.info = true
	end

	if (tabname == WUMA.GUI.Tabs.Restrictions.TabName and not WUMA.Subscriptions.restrictions) then
		WUMA.FetchData(Restriction:GetID())
	elseif (tabname == WUMA.GUI.Tabs.Limits.TabName and not WUMA.Subscriptions.limits) then
		WUMA.FetchData(Limit:GetID())
	elseif (tabname == WUMA.GUI.Tabs.Users.TabName and not WUMA.Subscriptions.users) then
		WUMA.RequestFromServer("lookup", 50)

		WUMA.Subscriptions.users = true
	end

	WUMA.GUI.ActiveTab = tabname

end

function WUMA.OnUserTabChange(_, typ, steamid)
	if (typ ~= "default") and not WUMA.Subscriptions.user[steamid] then
		WUMA.Subscriptions.user[steamid] = {}
	end

	if (typ == "default") then
		local timeout = GetConVar("wuma_autounsubscribe_user"):GetInt()

		if timeout and (timeout >= 0) and WUMA.Subscriptions.user[steamid] then
			for k, _ in pairs(WUMA.Subscriptions.user[steamid]) do
				timer.Create(k..":::"..steamid, timeout, 1, function() WUMA.FlushUserData(steamid, k) end)
			end
		end
	else
		WUMA.FetchUserData(typ, steamid)
	end
end

function WUMA.FetchData(typ)
	if typ then
		if (typ == Restriction:GetID()) then
			WUMA.RequestFromServer("restrictions")
			WUMA.RequestFromServer("subscription", Restriction:GetID())
			WUMA.RequestFromServer("restrictionitems")

			WUMA.SetProgress(Restriction:GetID(), "Requesting data", 0.2)

			WUMA.Subscriptions.restrictions = true
		elseif (typ == Limit:GetID()) then
			WUMA.RequestFromServer("limits")
			WUMA.RequestFromServer("cvarlimits")
			WUMA.RequestFromServer("subscription", Limit:GetID())

			WUMA.SetProgress(Limit:GetID(), "Requesting data", 0.2)

			WUMA.Subscriptions.limits = true
		end
	else
		WUMA.FetchData(Restriction:GetID())
		WUMA.FetchData(Limit:GetID())
	end
end

function WUMA.FetchUserData(typ, steamid)
	if typ then
		if WUMA.Subscriptions.user[steamid] and WUMA.Subscriptions.user[steamid][typ] then return end
		if (typ == Restriction:GetID()) then
			WUMA.RequestFromServer("restrictions", steamid)
			WUMA.RequestFromServer("subscription", {steamid, false, typ})

			WUMA.SetProgress(Restriction:GetID()..":::"..steamid, "Requesting data", 0.2)

			if timer.Exists(typ..":::"..steamid) then
				timer.Remove(typ..":::"..steamid)
			end
		elseif (typ == Limit:GetID()) then
			WUMA.RequestFromServer("limits", steamid)
			WUMA.RequestFromServer("cvarlimits")
			WUMA.RequestFromServer("subscription", {steamid, false, typ})

			WUMA.SetProgress(Limit:GetID()..":::"..steamid, "Requesting data", 0.2)

			if timer.Exists(typ..":::"..steamid) then
				timer.Remove(typ..":::"..steamid)
			end
		end
		WUMA.Subscriptions.user[steamid][typ] = true
	else
		WUMA.FetchUserData(Restriction:GetID(), steamid)
		WUMA.FetchUserData(Limit:GetID(), steamid)
	end
end

function WUMA.FlushData(typ)
	if typ then
		if (typ == Restriction:GetID()) then
			WUMA.RequestFromServer("subscription", {Restriction:GetID(), true})
			WUMA.Restrictions = {}

			WUMA.Subscriptions.restrictions = false
		elseif (typ == Limit:GetID()) then
			WUMA.RequestFromServer("subscription", {Limit:GetID(), true})
			WUMA.Limits = {}
		end
	else
		WUMA.FlushData(Restriction:GetID())
		WUMA.FlushData(Limit:GetID())
	end
end

function WUMA.FlushUserData(steamid, typ)
	if typ and steamid then
		if (typ == Restriction:GetID()) then
			WUMA.RequestFromServer("subscription", {steamid, true, Restriction:GetID()})
			if WUMA.UserData[steamid] then WUMA.UserData[steamid].Restrictions = nil end

			WUMA.GUI.Tabs.Users.restrictions:GetDataView():SetDataTable(function() return {} end)
			if WUMA.GUI.Tabs.Users.restrictions:IsVisible() then WUMA.GUI.Tabs.Users.OnBackClick(WUMA.GUI.Tabs.Users.restrictions) end

			if WUMA.Subscriptions.user[steamid] then WUMA.Subscriptions.user[steamid][typ] = nil end
		elseif (typ == Limit:GetID()) then
			WUMA.RequestFromServer("subscription", {steamid, true, Limit:GetID()})
			if WUMA.UserData[steamid] then WUMA.UserData[steamid].Limits = nil end

			WUMA.GUI.Tabs.Users.limits:GetDataView():SetDataTable(function() return {} end)
			if WUMA.GUI.Tabs.Users.limits:IsVisible() then WUMA.GUI.Tabs.Users.OnBackClick(WUMA.GUI.Tabs.Users.limits) end

			if WUMA.Subscriptions.user[steamid] then WUMA.Subscriptions.user[steamid][typ] = nil end
		end

		if (WUMA.Subscriptions.user[steamid] and table.Count(WUMA.Subscriptions.user[steamid]) < 1) then WUMA.Subscriptions.user[steamid] = nil end
		if (WUMA.UserData[steamid] and table.Count(WUMA.UserData[steamid]) < 1) then WUMA.UserData[steamid] = nil end
	elseif (steamid) then
		WUMA.FlushUserData(steamid, Restriction:GetID())
		WUMA.FlushUserData(steamid, Limit:GetID())
	else
		for id, _ in pairs(WUMA.Subscriptions.user) do
			WUMA.FlushUserData(id)
		end
	end
end

WUMA.GUI.HookIDs = 1
function WUMA.GUI.AddHook(h, name, func)
	hook.Add(h, name..WUMA.GUI.HookIDs, func)
	WUMA.GUI.HookIDs = WUMA.GUI.HookIDs + 1
end
