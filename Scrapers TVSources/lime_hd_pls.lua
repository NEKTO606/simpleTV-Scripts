-- скрапер TVS для загрузки плейлиста "Lime HD" https://limehd.tv (13/3/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: limeHD.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## Переименовать каналы ##
local filter = {
		{'Детско-юношеский телеканал «Карусель»', 'Карусель'},
		{'Детско-юношеский телеканал «Карусель» +2', 'Карусель +2'},
		{'Детско-юношеский телеканал «Карусель» +4', 'Карусель +4'},
		{'Детско-юношеский телеканал «Карусель» +6', 'Карусель +6'},
		{'Общественное телевидение Приморья (Владивосток)', 'ОТВ (Приморье)'},
		{'Центральное телевидение', 'ЦТВ'},
		{'Петербург - 5 канал', '5 канал'},
		{'ТВ ЦЕНТР - Москва', 'ТВЦ'},
	}
	local host = 'https://limehd.tv/'
	local my_src_name = 'Lime HD'
	module('lime_hd_pls', package.seeall)
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_lime_hd.m3u', logo = '..\\Channel\\logo\\Icons\\limehd.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local function LoadFromSite()
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvbGltZWhkLnBocA'), headers = headers})
			if rc ~= 200 or not answer then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
		local t = {}
			for i, v in pairs(tab) do
				if v[1] and v[3] then
					t[#t + 1] = {}
					local name = v[3]:gsub('Телекомпания ', '')
					name = name:gsub('Общественное телевидение России ', 'ОТР')
					t[#t].name = unescape3(name)
					t[#t].address = host .. v[1]
					if v[4] and v[4] ~= '' then
						t[#t].logo = string.format('https://assets-iptv2022.cdnvideo.ru/static/channel/%s/logo_256_%s.png', v[2], v[4])
					else 
						t[#t].logo = ''
					end
					if v[5] > 0 then
						t[#t].RawM3UString = string.format('catchup="default" catchup-days="%s"', v[5])
					end
				end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(token .. '\n', "D:\xxx.txt")
