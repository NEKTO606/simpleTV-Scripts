-- видеоскрипт для плейлиста "Lime HD" https://limehd.tv (12/11/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: /luaScr/user/TVSources/scrapers/lime_hd_pls.lua
-- скрипт запуска ивента: /luaScr/user/startup/lime_start.lua
-- скрипт ивента: /luaScr/user/lime/events.lua
-- видеоскрипт: /luaScr/user/video/limeHD.lua
-- расширение дополнения httptimeshift: /luaScr/user/httptimeshift/extensions/limehd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://limehd.tv/adventurehd
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://limehd%.tv/') 
		 and not (m_simpleTV.Control.CurrentAddress:match('iptv2022%.com') 
		 and m_simpleTV.Control.CurrentAddress:match('mono%.ts%.m3u8'))
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'json'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.lime then
		m_simpleTV.User.lime = {}
	end
	inAdr = inAdr:gsub('$OPT:.+', '')
	local slug = inAdr:match('([^/]+)$')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:160.0) Gecko/20100101 Firefox/160.0'
	local session = m_simpleTV.Http.New(user_agent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	
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
	m_simpleTV.User.lime.header = header

	local mono, rc, answer, retAdr
	if not (inAdr:match('iptv2022.com') and inAdr:match('mono.ts.m3u8')) then
		rc, answer = m_simpleTV.Http.Request(session, {url = string.format(decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3Y0L2NoYW5uZWwvJXM/ZXBnPTA'), slug), headers = header})
			if rc ~= 200 or not answer then return end
		answer = answer:gsub('%[%]', '""')
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
		retAdr = tab.url
		m_simpleTV.User.lime.url_archive = tab.stream.archive
			if not retAdr then return end
		m_simpleTV.Http.Close(session)
		local session = m_simpleTV.Http.New(user_agent, '', true)
			if not session then return end
		m_simpleTV.Http.SetRedirectAllow(session, false)
		m_simpleTV.Http.SetTimeout(session, 20000)
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = header})
		local head = m_simpleTV.Http.GetRawHeader(session)
		m_simpleTV.Http.Close(session)
		local inAdr = head:match('Location:%s([^\n]+)')
			if not inAdr then return end
		if inAdr:match('stitch%.teletarget%.ru') then
			m_simpleTV.Control.CurrentAddress = inAdr
		else
			m_simpleTV.Control.EventPlayingInterval = 2000
		end
		local host = inAdr:match('(https://[^/]+/)')
		local session = m_simpleTV.Http.New(user_agent)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = header})
			if rc ~= 200 or not answer then return end
		mono = retAdr:gsub('https://.-/', host)
	else
		retAdr = inAdr:gsub('tracks%-v%da%d/mono.ts.m3u8', 'index.m3u8'):gsub('https://.-/', 'https://mhd.iptv2022.com/')
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = header})
			if rc ~= 200 or not answer then return end
		mono = inAdr
	end	
	local t = {}
	for w in string.gmatch(answer, 'EXT%-X%-STREAM%-INF.-m3u8') do
		local res = w:match('RESOLUTION=%d+x(%d+)')
		local bw = w:match('BANDWIDTH=(%d+)')
		local track = w:match('(tracks.-m3u8)')
			if not track then return end
		if bw and res then
			bw = math.ceil(tonumber(bw) / 10000) * 10
			t[#t + 1] = {}
			t[#t].Id = bw
			t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
			if mono:match('index.m3u8') then
				t[#t].Address = mono:gsub('index.m3u8', track)
			elseif mono:match('tracks%-v%da%d/mono.ts.m3u8') then
				t[#t].Address = mono:gsub('tracks%-v%da%d/mono.ts.m3u8', track)
			end
		end
	end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('limehd_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 100000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = mono
	local index = #t
		for i = 1, #t do
			if t[i].Id >= lastQuality then
				index = i
			 break
			end
		end
	if index > 1 then
		if t[index].Id > lastQuality then
			index = index - 1
		end
	end
	if m_simpleTV.Control.MainMode == 0 then
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		t.ExtParams = {LuaOnOkFunName = 'limehdSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end

	mono = t[index].Address

	function limehdSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('limehd_qlty', id)
	end

	local session = m_simpleTV.Http.New(user_agent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
		if not mono then return end
	local rc, mono_body = m_simpleTV.Http.Request(session, {url = mono, headers = header})
	m_simpleTV.User.lime.mono = mono
	local ts = mono:gsub('mono.ts.m3u8', '')
	lfs.mkdir(TVSources_var.TVSdir .. 'm3u/cache/lime', true)
	local tmpName = TVSources_var.TVSdir .. 'm3u/cache/lime/lime_'
    local tmpName_m3u8 = TVSources_var.TVSdir .. 'm3u/cache/lime/lime_out.m3u8'
	m_simpleTV.User.lime.mono_ts = {}
	matches = {}
	local m3u8_head = '#EXTM3U\n' ..
				 '#EXT-X-TARGETDURATION:3\n' ..
				 '#EXT-X-VERSION:3\n' ..
				 '#EXT-X-MEDIA-SEQUENCE:0'
	
	local fhandle = io.open(tmpName_m3u8, 'w+')
	if fhandle then
		fhandle:write(m3u8_head)
		fhandle:close()
	end
	i = 0
	for w in mono_body:gmatch('%d%d%d%d/.-%.ts') do
		table.insert(matches, w)
		i = i + 1
		local fhandle = io.open(tmpName .. i .. '.ts', 'wb')
		local rc, ts_body = m_simpleTV.Http.Request(session, {url = ts .. w, headers = header})
		if fhandle then
			fhandle:setvbuf('no')
			fhandle:write(ts_body)
			fhandle:flush()
			fhandle:close()
		end
		m_simpleTV.Common.Sleep(1000)
		local fhandle = io.open(tmpName_m3u8, 'a')
		if fhandle then
			fhandle:write('\n#EXTINF:3.000,\n' .. 'lime_' .. i ..'.ts')
			fhandle:close()
		end
	end
	m_simpleTV.User.lime.count_ts = i
	m_simpleTV.User.lime.mono_ts = matches
	m_simpleTV.User.lime.count = 0
	m_simpleTV.Control.CurrentAddress = tmpName_m3u8  .. 
		'$OPT:file-caching=5000'  ..
		'$OPT:no-ts-cc-check'  ..
		'$OPT:no-ts-trust-pcr'  ..
		'$OPT:no-ts-es-id-pid'  ..
		'$OPT:ts-seek-percent'  ..
		'$OPT:cr-average=500' ..
		'$OPT:clock-jitter=0' ..
		'$OPT:clock-synchro=0' ..
		'$OPT:no-drop-late-frames' ..
		'$OPT:no-skip-frames'
		
-- debug_in_file(t[index].Address .. '\n')