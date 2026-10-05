-- видеоскрипт для плейлиста "AlmaTV" https://online.almatv.kz (5/10/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: almatv_pls.lua
-- расширение дополнения httptimeshift: almatv-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://almatv.kz/channels/tran-tv-hd/5812
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://almatv%.kz') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local host = 'https://almatv.platform24.tv/v2/'
	local url = m_simpleTV.Control.CurrentAddress
	inAdr = url:gsub('$OPT:.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.almatv then
		m_simpleTV.User.almatv = {}
	end
	
	local user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:157.0) Gecko/20100101 Firefox/157.0'
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
	local session = m_simpleTV.Http.New(user_agent, decode64(GetPrx()), true)
	m_simpleTV.Http.SetTimeout(session, 8000)
	
		-----
		math.randomseed( os.time() )
		math.random()
		-----
		local function num2bs(num)
			local _mod = math.fmod or math.mod
			local _floor = math.floor
			--
			local result = ""
			if(num == 0) then return "0" end
			while(num  > 0) do
				 result = _mod(num,2) .. result
				 num = _floor(num*0.5)
			end
			return result
		end
		--
		local function bs2num(num)
			local _sub = string.sub
			local index, result = 0, 0
			if(num == "0") then return 0; end
			for p=#num,1,-1 do
				local this_val = _sub( num, p,p )
				if this_val == "1" then
					result = result + ( 2^index )
				end
				index=index+1
			end
			return result
		end
		--
		local function padbits(num,bits)
			if #num == bits then return num end
			if #num > bits then print("too many bits") end
			local pad = bits - #num
			for i=1,pad do
				num = "0" .. num
			end
			return num
		end
		--
		local function getUUID()
			local _rnd = math.random
			local _fmt = string.format
			--
			_rnd()
			--
			local time_low_a = _rnd(0, 65535)
			local time_low_b = _rnd(0, 65535)
			--
			local time_mid = _rnd(0, 65535)
			--
			local time_hi = _rnd(0, 4095 )
			time_hi = padbits( num2bs(time_hi), 12 )
			local time_hi_and_version = bs2num( "0100" .. time_hi )
			--
			local clock_seq_hi_res = _rnd(0,63)
			clock_seq_hi_res = padbits( num2bs(clock_seq_hi_res), 6 )
			clock_seq_hi_res = "10" .. clock_seq_hi_res
			--
			local clock_seq_low = _rnd(0,255)
			clock_seq_low = padbits( num2bs(clock_seq_low), 8 )
			--
			local clock_seq = bs2num(clock_seq_hi_res .. clock_seq_low)
			--
			local node = {}
			for i=1,6 do
				node[i] = _rnd(0,255)
			end
			--
			local guid = ""
			guid = guid .. padbits(_fmt("%X",time_low_a), 4)
			guid = guid .. padbits(_fmt("%X",time_low_b), 4) .. "-"
			guid = guid .. padbits(_fmt("%X",time_mid), 4) .. "-"
			guid = guid .. padbits(_fmt("%X",time_hi_and_version), 4) .. "-"
			guid = guid .. padbits(_fmt("%X",clock_seq), 4) .. "-"
			--
			for i=1,6 do
				guid = guid .. padbits(_fmt("%X",node[i]), 2)
			end
			--
			return guid
		end
		--

	local function GetToken()
	
		local login = getUUID()
		local pass = string.sub(encode64(login), 0, 32)
		
		local headers = 'Content-Type: application/json\n'
		local body = '{"username":"' .. login .. '","password":"' .. pass .. '","is_guest":true,"app_version":"v30"}'
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = host .. 'users', body = body, headers = headers})
			if rc ~= 200 or not answer then return end
		
		local body1 = '{"login":"' .. login .. '","password":"' .. pass .. '","app_version":"v30"}'
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = host .. 'auth/login', body = body1, headers = headers})
		local user_token = answer:match('access_token":"([^"]+)')
				if rc ~= 200 or not user_token then return end
		
		local serial = getUUID()

		local body2 = '{"device_type":"pc","vendor":"PC","model":"Firefox 132","version":"166","os_name":"Windows","os_version":"10","application_type":"web","serial":"' .. serial .. '"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = host .. 'users/self/devices?access_token=' .. user_token, body = body2, headers = headers})
	
		local device_id = answer:match('id":"([^"]+)')
				if rc ~= 200 or not device_id then return end
		
		local body3 = '{"device_id":"' .. device_id .. '"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = host .. 'auth/device', body = body3, headers = headers})
		local device_token = answer:match('access_token":"([^"]+)')
				if rc ~= 200 or not device_token then return end
		
		m_simpleTV.Config.SetValue('almatv_token', device_token)
		
		return device_token
	end
	
	local access_token = m_simpleTV.Config.GetValue('almatv_token')
		if not access_token then access_token = GetToken() end	
	
	local num = url:match('([^/]%d+)$')
		if not num then return end
		
	local url = string.format(host .. 'channels/%s/stream?access_token=%s&force_https=true', num, access_token)
	m_simpleTV.User.almatv.url_archive = url
	m_simpleTV.User.almatv.prx = GetPrx()
	local rc, answer
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
	if rc == 401 then access_token = GetToken()
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
	end
	m_simpleTV.Http.Close(session)
		if not answer then return end
	local retAdr = answer:match('"stream_info":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('^https://', 'http://'):gsub('data.json', 'index.m3u8')
	local session = m_simpleTV.Http.New(user_agent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	m_simpleTV.Http.Close(session)
	local t = {}
		for w in string.gmatch(answer, 'EXT%-X%-STREAM%-INF(.-)\n') do
			local res = w:match('RESOLUTION=%d+x(%d+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			if bw and res then
				bw = math.ceil(tonumber(bw) / 10000) * 10
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', retAdr, bw)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('almatv_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
		index = #t
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
			t.ExtParams = {LuaOnOkFunName = 'almatvSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end
	
	m_simpleTV.Control.CurrentAddress = t[index].Address
	
	function almatvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('almatv_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
