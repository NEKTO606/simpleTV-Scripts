-- скрапер TVS для загрузки плейлиста "Beeline TV" https://beeline.tv (25/8/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts/
-- ## необходим ##
-- видеоскрипт: beeline-tv.lua
-- расширение дополнения httptimeshift: beeline-timeshift_ext.lua
-- ## Переименовать каналы ##
local filter = {
		{'ТВ Центр - Москва', 'ТВЦ'},
		{'TMB RU (Твой Мир Восток)', 'Восток ТВ'},
		{'Travel and Adventure', 'Travel+Adventure'},
		{'Детско-юношеский телеканал "Карусель"', 'Карусель'},
		{'Телеканал "Общественное телевидение России"', 'ОТР'},
		{'Телеканал 360*', 'Телеканал 360°'},
		{'Телекомпания НТВ', 'НТВ'},
		{'Мосфильм.Золотая коллекция', 'Мосфильм. Золотая коллекция'},
		{'Татарстан-Новый век', 'ТНВ'},
		{'КИНОСЕРИЯ', 'Киносерия'},
		{'КИНОУЖАС', 'Киноужас'},
		{'Петербург - 5 канал', '5 канал'},
		{'Петербург - 5 канал HD', '5 канал HD'},
		{'Настоящее страшное ТВ', 'НСТ'},
		{'Travel+ Adventure', 'Travel+Adventure'},
		{'CuriosityStream', 'Curiosity Stream'},
	}
	local my_src_name = 'Beeline TV'
	local host = 'https://beeline.tv/'
	module('beeline-tv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_beelinetv.m3u', logo = '..\\Channel\\logo\\Icons\\beeline.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:154.0) Gecko/20100101 Firefox/154.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local sum = {}
	local function LoadFromSite(x)
		if x == nil then
			offset = 0
			x = 0
		else
			offset = 30 * x
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = string.format(decode64('aHR0cHM6Ly9hcGkuYmVlcG9wY29ybi5ydS92NS9jaGFubmVscy5qc29uP2NsaWVudF9pZD0zZTI4Njg1Yy1mY2UwLTQ5OTQtOWQzYS0xZGFkMjc3NmUxNmEmY2xpZW50X3ZlcnNpb249My45LjIuMTEyNiZsb2NhbGU9cnUtUlUmdGltZXpvbmU9MTA4MDAmcGFnZVtsaW1pdF09MzAmcGFnZVtvZmZzZXRdPSVzJmNhcmRfY29uZmlnX2NvbnRleHRbc2NyZWVuXT1kZWZhdWx0'), offset)})
			if rc ~= 200 or not answer then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.data then return end
		local t = {}
			for i = 1, #tab.data do
				t[#t + 1] = {}
				t[#t].name = tab.data[i].name:gsub('\\', '')
				t[#t].address = host .. tab.data[i].slug .. '/' .. tab.data[i].live_stream.streaming_uid
				for y = 1, #tab.data[i].images do
					if tab.data[i].images[y].type == 'logo' then
						t[#t].logo = tab.data[i].images[y].url_template:gsub('{width}x{height}{crop}', '90x90c')
					 break
					end
				end
				if tab.data[i].catchup_availability.available then
					local days = tab.data[i].catchup_availability.period.value
					t[#t].RawM3UString = string.format('catchup="append" catchup-days="%s" catchup-record-source="?starttime=${start}&stoptime=${end}"', days)
				end
			end
		x = x + 1
		local count = math.floor(tab.meta.pagination.total / 30)
		if x <= count then LoadFromSite(x) end
		for i=1,#t do
			sum[#sum+1] = t[i]
		end
		local hash = {}
		local res = {}
		for _,v in ipairs(sum) do
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
