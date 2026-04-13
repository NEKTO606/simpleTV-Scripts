-- скрапер TVS для загрузки плейлиста "Смотрим" https://smotrim.ru (13/4/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
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
	
	local xash = {
			'7aaa81fcd9014af492554b94a6d3b51f',
			'8da903db77ac29ef545734082320264d',
			'5ba1fdd3a7d403f4f37b708cbd9821d2',
			'76133239f0cccd66e624fc40140ca9dd',
			'd942c1be90dffcc1cb5b64065494b283',
			'2293b47bb4c93e99ac08d856013a0926',
			'7c01a30c11e29d63b7082fb3332966c9',
			'7534da1a9e867105b730e27411cc372a',
			'219e4105695017f7ccb543d056ca84f9',
			'545d4edc14be0ef82b0b6c550c39f074',
			'75029612c8e3e941caf9e80d39bc5e69',
			'8cd14b07457f1331149ed2fbabd4ee14',
			'6c2b342e3d924de54f3abe6337f6b1c4',
			'4b8c3e0b1e8a6bfcaac062918747008e',
			'47f9a1d11108034c7bc91d3129f67569',
			'fa39534ff24e37386dd33336fdaaef4b',
		}
		
	local sum = {}
	local function LoadFromSite(ttt)
		local body = '{"query":"query ChannelTab($id: Int!, $page: Int = 1) {\n\ttab(id: $id) {\n\t\tid\n\t\tname\n\t\tdefaultChannel {\n\t\t\tid\n\t\t}\n\t\tchannelsPaginate(first: 20, page: $page) {\n\t\t\tdata {\n\t\t\t\timages(linkTypes: [Icon]) {\n\t\t\t\t\tlinkType\n\t\t\t\t\tpresets {\n\t\t\t\t\t\tname\n\t\t\t\t\t\tlink\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t\tid\n\t\t\t\ttitle\n\t\t\t\tslug\n\t\t\t\turl\n\t\t\t\tmostPopular {\n\t\t\t\t\tid\n\t\t\t\t\tpublicId\n\t\t\t\t\tepisode {\n\t\t\t\t\t\tbrand {\n\t\t\t\t\t\t\tid\n\t\t\t\t\t\t\ttitle\n\t\t\t\t\t\t}\n\t\t\t\t\t\timages(linkTypes: [SplashScreen]) {\n\t\t\t\t\t\t\tid\n\t\t\t\t\t\t\ttitle\n\t\t\t\t\t\t\tlinkType\n\t\t\t\t\t\t\tpresets {\n\t\t\t\t\t\t\t\tname\n\t\t\t\t\t\t\t\tlink\n\t\t\t\t\t\t\t\twidth\n\t\t\t\t\t\t\t\theight\n\t\t\t\t\t\t\t}\n\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t\tjustEnded {\n\t\t\t\t\tid\n\t\t\t\t\ttitle\n\t\t\t\t\t# TODO: Do it later\n\t\t\t\t\timages(linkTypes: [SplashScreen]) {\n\t\t\t\t\t\t... on Image {\n\t\t\t\t\t\t\tid\n\t\t\t\t\t\t\ttitle\n\t\t\t\t\t\t\tlinkType\n\t\t\t\t\t\t\tpresets {\n\t\t\t\t\t\t\t\tname\n\t\t\t\t\t\t\t\tlink\n\t\t\t\t\t\t\t\twidth\n\t\t\t\t\t\t\t\theight\n\t\t\t\t\t\t\t}\n\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t\tfullVideo {\n\t\t\t\t\t\tpublicId\n\t\t\t\t\t}\n\t\t\t\t\tbrand {\n\t\t\t\t\t\tid\n\t\t\t\t\t\ttitle\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t\taffiliation {\n\t\t\t\t\tcode\n\t\t\t\t\tenum\n\t\t\t\t\tid\n\t\t\t\t\tname\n\t\t\t\t}\n\t\t\t\tvitrinaStreams {\n\t\t\t\t\tid\n\t\t\t\t\ttvlightWeb\n\t\t\t\t\tsourceWeb\n\t\t\t\t}\n\t\t\t\tprogramListInEpg {\n\t\t\t\t\tdate\n\t\t\t\t\tlabel\n\t\t\t\t\tlist {\n\t\t\t\t\t\t... on EPGProgramDTO {\n\t\t\t\t\t\t\tprogramId\n\t\t\t\t\t\t\tageRestriction\n\t\t\t\t\t\t\tendDateTime\n\t\t\t\t\t\t\tdurationInMinutes\n\t\t\t\t\t\t\thasSubtitles\n\t\t\t\t\t\t\tisPremiere\n\t\t\t\t\t\t\tgenre\n\t\t\t\t\t\t\tprogramName\n\t\t\t\t\t\t\tstartDateTime\n\t\t\t\t\t\t\tbrand {\n\t\t\t\t\t\t\t\tid\n\t\t\t\t\t\t\t}\n\t\t\t\t\t\t\tepisode {\n\t\t\t\t\t\t\t\tid\n\t\t\t\t\t\t\t\tfullVideo {\n\t\t\t\t\t\t\t\t\tpublicId\n\t\t\t\t\t\t\t\t\tplaylistContext\n\t\t\t\t\t\t\t\t}\n\t\t\t\t\t\t\t}\n\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t\tpaginatorInfo {\n\t\t\t\thasMorePages\n\t\t\t\tcurrentPage\n\t\t\t}\n\t\t}\n\t}\n}","variables":{"id":1,"page":4},"operationName":"ChannelTab"}'
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = decode64('aHR0cHM6Ly9hcGlzLnNtb3RyaW0ucnUvZ3JhcGhxbD9wYWdlPUNoYW5uZWxUYWImYm9keT1hMzVjOGRjYzVkOGJjMmM3MjU2OTZkYzU5M2FkOTk3NSZ2YXJzPQ') .. ttt
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = url, body = body})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.data.tab.channelsPaginate.data then return end
				
		local t = {}
			for i = 1, #tab.data.tab.channelsPaginate.data do
				local id = tab.data.tab.channelsPaginate.data[i].id
				local title = tab.data.tab.channelsPaginate.data[i].title
				title = unescape3(title)
				if id and title then
					t[#t + 1] = {}
					t[#t].name = title
					if tab.data.tab.channelsPaginate.data[i].affiliation
						and tab.data.tab.channelsPaginate.data[i].affiliation.code
						and tab.data.tab.channelsPaginate.data[i].affiliation.code == 'vitrina'
						and tab.data.tab.channelsPaginate.data[i].vitrinaStreams
						and tab.data.tab.channelsPaginate.data[i].vitrinaStreams[1]
						and tab.data.tab.channelsPaginate.data[i].vitrinaStreams[1].sourceWeb
					then
						t[#t].address = tab.data.tab.channelsPaginate.data[i].vitrinaStreams[1].sourceWeb .. '$OPT:INT-SCRIPT-PARAMS=smotrim.ru'
					else
						t[#t].address = host .. '/channel/' .. id
					end
					t[#t].logo = tab.data.tab.channelsPaginate.data[i].images[1].presets[3].link or ''
					if title:match('Радио') then
						t[#t].group = 'Радио'
					end
				end
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
		for i = 1, #xash do
			t_pls = LoadFromSite(xash[i])
		end
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
