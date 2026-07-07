-- скрапер TVS для загрузки плейлиста "KION" https://kion.ru (7/7/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: kion.lua
-- расширение дополнения httptimeshift: kion-timeshift_ext.lua
-- ## Переименовать каналы ##
local filter = {
		{'Телекомпания НТВ', 'НТВ'},
		{'Петербург - 5 канал', '5 канал'},
		{'Петербург - 5 канал', '5 канал'},
		{'Культура', 'Россия К'},
		{'Детско-юношеский телеканал "Карусель"', 'Карусель'},
		{'Телеканал "Общественное телевидение России"', 'ОТР'},
		{'ТВ ЦЕНТР - Москва', 'ТВЦ'},
		{'РЕН', 'РЕН ТВ'},
		{'ТВ-3', 'ТВ3'},
		{'VHS – русское кино', 'VHS-русское кино'},
		{'Телеканал "АРТ"', 'АРТ'},
	}
	local host = 'https://kion.ru/'
	local my_src_name = 'KION'
	module('kion_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_kion.m3u', logo = '..\\Channel\\logo\\Icons\\kion.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local function LoadFromSite()
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:152.0) Gecko/20100101 Firefox/152.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
		local headers = 'X-App-Version: 5.17.0\nX-Device-Id: 3e6997be-0e75-445d-ac7f-73b638ec82c1\nX-Device-Model: PC_Widevine_v3'
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9tZ3cubXRzLnJ1L21ndy1ob3N0ZXNzL2FwaS9jaGFubmVscy9nZXQtYWxs'), headers = headers})
			if rc ~= 200 or not answer then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.items then return end
		local t = {}
			for i = 1, #tab.items do
				if not tab.items[i].isBlocked and not tab.items[i].isRadio and tab.items[i].live.isEnabled then
					t[#t + 1] = {}
					t[#t].name = tab.items[i].title:gsub('\\', '')
					t[#t].address = host .. tab.items[i].slug .. '/' .. tab.items[i].channelNumber
					t[#t].logo = tab.items[i].mainLogoUrl
					if tab.items[i].catchup and tab.items[i].catchup.isEnabled and tab.items[i].catchup.length then
						local days = tonumber(tab.items[i].catchup.length) / 60 / 60 / 24
						for y = 1, #tab.items[i].genres do
							if tab.items[i].genres[y].id == 'ArchiveTV' then
								t[#t].RawM3UString = string.format('catchup="default" catchup-days="%s"', days)
							end
						end
					end
				end
			end
		local hash = {}
		local res = {}
		for _,v in ipairs(t) do
		   if not hash[v.name] then
			   res[#res+1] = v
			   hash[v.name] = true
		   end
		end
	 return res
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
