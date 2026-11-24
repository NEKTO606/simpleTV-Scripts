-- видеоскрипт для плейлиста "Lime HD" https://limehd.tv (24/11/26)
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

	local rc, answer = m_simpleTV.Http.Request(session, {url = string.format(decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3Y0L2NoYW5uZWwvJXM/ZXBnPTA'), slug), headers = header})
		if rc ~= 200 or not answer then return end
	answer = answer:gsub('%[%]', '""')
	local err, tab = pcall(json.decode, answer)
		if not tab then return end
	local retAdr = tab.url
		if not retAdr then return end
	m_simpleTV.Http.Close(session)
	local session = m_simpleTV.Http.New(user_agent, '', true)
		if not session then return end
	m_simpleTV.Http.SetRedirectAllow(session, false)
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = header})
	local head = m_simpleTV.Http.GetRawHeader(session)
	m_simpleTV.Http.Close(session)
	local inAdr = head:match('Location:%s([^\n]+)')
		if not inAdr then return end
	if inAdr:match('stitch%.teletarget%.ru') then
		m_simpleTV.Control.CurrentAddress = inAdr
	 return
	end
	m_simpleTV.Control.EventPlayingInterval = 1000
	local host = inAdr:match('(https://[^/]+/)')
	local session = m_simpleTV.Http.New(user_agent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = header})
		if rc ~= 200 or not answer then return end
	local mono = retAdr:gsub('https://.-/', host)
	local track
	for w in answer:gmatch('tracks%-v%da%d/mono.ts.m3u8') do
		track = w
	end
	mono = 	mono:gsub('index.m3u8', track)
	local rc, mono_body = m_simpleTV.Http.Request(session, {url = mono, headers = header})
	local ts = mono:gsub('mono.ts.m3u8', '')
	if m_simpleTV.User.lime and m_simpleTV.User.lime.server then
		m_simpleTV.User.lime.server:close()
		m_simpleTV.User.lime.server = nil
	end
	local socket = require("socket")
	local server = socket.tcp()
	server:setoption("reuseaddr", true)
	assert(server:bind("127.0.0.1", 18080))
	assert(server:listen(16))
	server:settimeout(0)
	m_simpleTV.Http.Close(session)
	m_simpleTV.User.lime = {
		count_event = 0,
		url_archive = tab.stream.archive,
		mono = mono,
		header = header,
		server = server,
		client = nil,
		mono_ts = {}
	}
	
m_simpleTV.Control.CurrentAddress = 'http://127.0.0.1:18080/stream.ts$OPT:network-caching=3500'

-- debug_in_file(t[index].Address .. '\n')
