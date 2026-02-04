-- скрапер TVS для загрузки плейлиста "Start TV" https://start.ru (3/2/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: starttv.lua
-- ## Переименовать каналы ##
local filter = {
		{'Детско-юношеский телеканал «Карусель»', 'Карусель'},
		{'Телеканал «Общественное телевидение России»', 'ОТР'},
		{'Телеканал «Матч ТВ»', 'Матч ТВ'},
		{'Телекомпания НТВ', 'НТВ'},
		{'ТВ ЦЕНТР - Москва', 'ТВЦ'},
		{'Петербург - 5 канал', '5 канал'},
	}
	local host = 'https://api.start.ru'
	local my_src_name = 'Start TV'
	module('starttv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\starttv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local function GetJson(url)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 or not answer then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
	  return tab
	end
	
	local function GetCategories()
		local tab = GetJson(decode64('aHR0cHM6Ly9hcGkuc3RhcnQucnUvbXVsdGlwbGV4L3R2P2FwaWtleT1hMjBiMTJiMjc5Zjc0NGYyYjNjN2I1YzU0MDBjNGViNSZ0ej0zJmZvcl9raWRzPWZhbHNl'))
		local t = {}
		for i = 1, #tab.selections do
			t[#t + 1] = {}
			t[#t].url = tab.selections[i].url
			t[#t].group = tab.selections[i].title
		end
	 return t
	end

	local function GetChannels(cat)
		local t = {}
		for _, v in pairs(cat) do
			local url = host .. v.url .. '?apikey=a20b12b279f744f2b3c7b5c5400c4eb5'
			local tab = GetJson(url)
			for i = 1, #tab.channels do
				t[#t + 1] = {}
				t[#t].name = tab.channels[i].title
				t[#t].group = v.group
				t[#t].address = 'https://start.ru/channel/' .. tab.channels[i].alias
				t[#t].logo = tab.channels[i].logo or ''
				if tab.channels[i].catchup_days and tab.channels[i].catchup_days > 0 then
					t[#t].RawM3UString = string.format('catchup="default" catchup-days="%s"', tab.channels[i].catchup_days or 0)
				end
			end
		end
		local hash = {}
		local res = {}
		for _,v in ipairs(t) do
		   if (not hash[v.name]) then
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
		
		local cat = GetCategories()
		local t_pls = GetChannels(cat)
		
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n', "D:\xxx.txt")