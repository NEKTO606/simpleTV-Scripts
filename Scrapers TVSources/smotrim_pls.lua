-- скрапер TVS для загрузки плейлиста "Смотрим" https://smotrim.ru (8/5/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: smotrim.ru.lua, mediavitrina.lua
-- ## Переименовать каналы ##
local filter = {
	--{'Евроспорт 2', 'Eurosport 2'},
	}
	local host = 'https://smotrim.ru'
	local my_src_name = 'Смотрим'
	module('smotrim_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_smotrim.m3u', logo = '..\\Channel\\logo\\Icons\\smotrim.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:150.0) Gecko/20100101 Firefox/150.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG1fc2ltcGxlVFYuQ29tbW9uLkdldENNb2R1bGVFeHRlbnNpb24oKSwgTWQ1KSAuLiAnOiAnIC4uIG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG9zLmRhdGUoJyElWXwlbXwlZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
		local headers = loadstring(code)()
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvc21vdHJpbS5waHA'), headers = headers})
			if rc ~= 200 or not answer then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab 
				or not tab.data 
				or not tab.data.tabs
				or not tab.data.tabs[1]
				or not tab.data.tabs[1].channels
			then return end		
		local t = {}
			for i = 1, #tab.data.tabs[1].channels do
				local id = tab.data.tabs[1].channels[i].id
				local title = tab.data.tabs[1].channels[i].title
				title = unescape3(title)
				if id and title then
					t[#t + 1] = {}
					t[#t].name = title
					if tab.data.tabs[1].channels[i].vitrinaStreams
						and tab.data.tabs[1].channels[i].vitrinaStreams[1]
						and tab.data.tabs[1].channels[i].vitrinaStreams[1].sourceWeb
					then
						t[#t].address = tab.data.tabs[1].channels[i].vitrinaStreams[1].sourceWeb .. '$OPT:INT-SCRIPT-PARAMS=smotrim.ru'
					else
						t[#t].address = host .. '/channel/' .. id
					end
					for x = 1, #tab.data.tabs[1].channels[i].images[1].presets do
						if tab.data.tabs[1].channels[i].images[1].presets[x].name == 'Small' then
							t[#t].logo = tab.data.tabs[1].channels[i].images[1].presets[x].link
						end
					end
					if title:match('Радио') then
						t[#t].group = 'Радио'
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
		t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
