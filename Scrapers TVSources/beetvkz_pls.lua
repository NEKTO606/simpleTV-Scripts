-- скрапер TVS для загрузки плейлиста "BeeTV KZ" https://beetv.kz (7/9/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: beetvkz.lua
-- ## Переименовать каналы ##
local filter = {
	{'Curiosity HD', 'Curiosity Stream HD'},
	{'History 2HD', 'History2 HD'},
	}
	local my_src_name = 'BeeTV KZ'
	module('beetvkz_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_beetvkz.m3u', logo = '..\\Channel\\logo\\Icons\\beetvkz.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:155.0) Gecko/20100101 Firefox/155.0'
	local function GetPrx()
		local prx
		if m_simpleTV.Config.GetValue('beetv_prx') then
			prx = m_simpleTV.Config.GetValue('beetv_prx')
		else
			local session = m_simpleTV.Http.New(user_agent)
				if not session then return end
			m_simpleTV.Http.SetTimeout(session, 8000)
			local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG1fc2ltcGxlVFYuQ29tbW9uLkdldENNb2R1bGVFeHRlbnNpb24oKSwgTWQ1KSAuLiAnOiAnIC4uIG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG9zLmRhdGUoJyElWXwlbXwlZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
			local headers = loadstring(code)()
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvYmVldHYucGhw'), headers = headers})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 or not answer then return end
			m_simpleTV.Config.SetValue('beetv_prx', answer)
			prx = answer
		end
	 return prx
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New(user_agent, decode64(GetPrx()), true)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9hcGkuYmVldHYua3ovdjUvY2hhbm5lbHMuanNvbj9jbGllbnRfaWQ9M2UyODY4NWMtZmNlMC00OTk0LTlkM2EtMWRhZDI3NzZlMTZhJmNsaWVudF92ZXJzaW9uPTQuNC45LjM2MDE5MzYmbG9jYWxlPXJ1LUtaJnRpbWV6b25lPS0xODAwMCZwYWdlW2xpbWl0XT01MDA')})
		m_simpleTV.Http.Close(session)
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
				local image
				local name = tab.data[i].name
				local slug = tab.data[i].slug
				local id = tab.data[i].live_stream.streaming_uid
				if tab.data[i].images and tab.data[i].images[2] then
					image = tab.data[i].images[2].url_template
				end
				if image then
					image = image:gsub('{width}', '250'):gsub('{height}', '250'):gsub('{crop}', '')
				end
					if name and slug and id and not name:match('Live%s%d') then
						t[#t + 1] = {}
						t[#t].name = unescape3(name)
						t[#t].address = string.format('https://ucdn.beetv.kz/bpk-tv/%s/tve/index.mpd', id)
						t[#t].logo = image or ''
						if tab.data[i].catchup_availability.available then
							t[#t].RawM3UString = 'catchup="default" catchup-days="7"'
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
-- debug_in_file(#t_pls .. '\n')