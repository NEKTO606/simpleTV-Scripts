-- скрапер TVS для загрузки плейлиста "Lime HD" https://limehd.tv (12/11/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: /luaScr/user/TVSources/scrapers/lime_hd_pls.lua
-- скрипт запуска ивента: /luaScr/user/startup/lime_start.lua
-- скрипт ивента: /luaScr/user/lime/events.lua
-- видеоскрипт: /luaScr/user/video/limeHD.lua
-- расширение дополнения httptimeshift: /luaScr/user/httptimeshift/extensions/limehd-timeshift_ext.lua
-- ## Переименовать каналы ##
local filter = {
		{'Детско-юношеский телеканал «Карусель»', 'Карусель'},
		{'Общественное телевидение Приморья (Владивосток)', 'ОТВ (Приморье)'},
		{'Петербург - 5 канал', '5 канал'},
		{'ТВ ЦЕНТР - Москва', 'ТВЦ'},
		{'Телекомпания НТВ', 'НТВ'},
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

	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:160.0) Gecko/20100101 Firefox/160.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	
	local function generate_string()
		math.randomseed(os.time())
		local part1 = math.random(100000, 999999)
		local part2_left = math.random(100000, 999999)
		local part2_right = math.random(0, 99999)
		local part2 = part2_left .. string.format("%05d", part2_right)
		local current_time = os.time()
		local part3 = math.floor(math.abs(current_time) * 1000)
		return string.format('%s.%s-%s', part1, part2, part3)
	end
	
	local function CheckToken(token)
		if token then
			token = decode64(token)
			require 'json'
			local err, data = pcall(json.decode, token)
				if not err then return 'error' end
			local header = 'x-lhd-agent: {"platform":"web","app":"limehd.tv","device_id":"' .. data[2] .. '"}\n' ..
						   'x-device-id: ' .. data[2] .. '\n' ..
						   'x-token: ' .. data[1]
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3Y0L2NoYW5uZWwva2lub2NvbWVkaWE/ZXBnPTA'),  headers = header})
				if rc ~= 200 or not answer then return end
			answer = answer:gsub('%[%]', '""')
			local err, tab = pcall(json.decode, answer)
				if not tab then return end
			if tab.url and tab.url ~= '' then
				return 200
			else
				return 'error'
			end
		end
	end
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('lime_token')
		local tok
		if saveToken and CheckToken(saveToken) == 200 then
			tok = saveToken
		else
			local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG1fc2ltcGxlVFYuQ29tbW9uLkdldENNb2R1bGVFeHRlbnNpb24oKSwgTWQ1KSAuLiAnOiAnIC4uIG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG9zLmRhdGUoJyElWXwlbXwlZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
			local headers = loadstring(code)()
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2VwZzcucnUvbGltZS5waHA'), headers = headers})
			if rc ~= 200 then return end
			if answer then
				if CheckToken(answer) == 200 then
					m_simpleTV.Config.SetValue('lime_token', answer)
					tok = answer
				else
					tok = 'error'
				end
			else
				tok = 'error'
			end
		end
	 return tok
	end

	local function GetHeader()
		local tok = GetToken()
		local header
		if tok ~= 'error' then
			local tok = decode64(tok)
			local err, data = pcall(json.decode, tok)
				if not err then return end
			header = 'x-lhd-agent: {"platform":"web","app":"limehd.tv","device_id":"' .. data[2] .. '"}\n' ..
					 'x-device-id: ' .. data[2] .. '\n' ..
					 'x-token: ' .. data[1]
		else
			header = string.format('x-lhd-agent: {"platform":"web","app":"limehd.tv","device_id":"%s"}', generate_string())
		end
	 return header
	end
	
	local header = GetHeader()
		if not header then return end
	
	local function LoadFromSite()	
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3YxL3BsYXlsaXN0'), headers = header})
			if rc ~= 200 or not answer then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
		local t = {}
			for i = 1, #tab.channels do
				if tab.channels[i].url and tab.channels[i].url ~= '' then
					t[#t + 1] = {}
					t[#t].name = tab.channels[i].name_ru
					t[#t].address = host .. tab.channels[i].address
					t[#t].logo = tab.channels[i].image
					if tab.channels[i].with_archive and tab.channels[i].url_archive ~= '' and tab.channels[i].day_archive > 0 then
						t[#t].RawM3UString = string.format('catchup="default" catchup-days="%s"', tab.channels[i].day_archive)
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
