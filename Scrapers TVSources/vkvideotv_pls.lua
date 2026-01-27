-- скрапер TVS для загрузки плейлиста "VK Видео ТВ" https://vkvideo.ru/tvchannels (4/1/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: vkplaylive.lua
-- ## Переименовать каналы ##

local filter = {
	{'ПРЯМОЙ ЭФИР', 'ТБВ'},
	{'НТС-Ирбит (круглосуточная трансляция)', 'НТС-Ирбит'},
	}
	local host = 'https://vkvideo.ru/'
	local my_src_name = 'VK Видео ТВ'
	module('vkvideotv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\vkvideotv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local sum = {}
	local function LoadFromSite(next_page)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'https://vkvideo.ru/tvchannels'
		
		local body
		if next_page then
			body = 'al=1&silent_loading=1&next_from=' .. next_page
		else
			body = 'al=1&silent_loading=1'
		end
		
		headers = 'X-Requested-With: XMLHttpRequest'
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = url, body = body, headers = headers})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '{}')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.payload then return end
		local stroka = tab.payload[2][1]
		stroka = stroka:gsub('\\\\', '\\')
		stroka = stroka:gsub('\\"', '"')
		local err, str = pcall(json.decode, stroka)
			if not str or not str.videos then return end
		local t = {}
			for i = 1, #str.videos do
				local slug = str.videos[i][1] .. '_' .. str.videos[i][2]
				local title = str.videos[i][4]
				title = m_simpleTV.Common.multiByteToUTF8(title,1251)
				if slug and title then
					t[#t + 1] = {}
					title = unescape3(title)
					title = title:gsub('&#33;', '!')
					title = title:gsub('%. Прямой эфир', '')
					title = title:gsub(', прямой эфир', '')
					title = title:gsub('Прямой эфир ', '')
					title = title:gsub('Прямой эфир. ', '')
					title = title:gsub('Прямой ЭФИР ', '')
					title = title:gsub(' Прямой эфир', '')
					title = title:gsub('ПРЯМОЙ ЭФИР ТЕЛЕКАНАЛА ', '')
					title = title:gsub('Телеканал ', '')
					title = title:gsub('Прямая трансляция ', '')
					title = title:gsub('Эфир православного ', '')
					title = title:gsub(' прямая трансляция', '')
					title = title:gsub('телеканала ', '')
					title = title:gsub(' Трансляция LIVE', '')
					title = title:gsub(' (круглосуточная трансляция)', '')
					title = title:gsub('| ', ''):gsub(' |', '')
					title = title:gsub('«', ''):gsub('»', '')
					title = title:gsub('&quot;', '')
					title = title:gsub('канала ', '')
					title = title:gsub('Live: ', '')
					title = title:gsub('LIVE ', '')
					title = title:gsub(' ONLINE', '')
					t[#t].name = title
					t[#t].address = host .. 'tvchannels/' .. slug
					t[#t].logo = str.videos[i][36] or ''
					t[#t].RawM3UString = 'catchup="append" catchup-minutes="180" catchup-source="?offset_p=${offset}000"'
				end
			end
		
		if str.nextFrom ~= '' and str.videos then
			LoadFromSite(str.nextFrom)
		end
		for i=1,#t do
			sum[#sum+1] = t[i]
		end
	 return sum
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
-- debug_in_file(#t_pls .. '\n')