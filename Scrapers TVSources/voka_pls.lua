-- скрапер TVS для загрузки плейлиста "Voka" https://voka.tv (4/5/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: voka.lua
-- ## Переименовать каналы ##
local filter = {
	--{'Мир-ТВ', 'МИР'},
	}
	local host = 'https://voka.tv/'
	local my_src_name = 'Voka'
	module('voka_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_voka.m3u', logo = '..\\Channel\\logo\\Icons\\voka.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
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
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdm9rYS5waHA'), headers = headers})
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
					if v[1] and v[2] and v[3] then
						local name = v[2]
						t[#t + 1] = {}
						t[#t].name = name:gsub('%s%(тест%)', '')
						t[#t].address = host .. v[1]
						t[#t].logo = string.format('https://resizer.voka.tv/rosing-voka-production/%s_90x90c.jpg', v[3])
						if tonumber(v[4]) > 0 then
							t[#t].RawM3UString = string.format('catchup="default" catchup-days="%s"', v[4])
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
