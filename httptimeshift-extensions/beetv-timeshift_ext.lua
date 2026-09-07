-- расширение дополнения httptimeshift BeeTV KZ (7/9/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
	function httpTimeshift_beetv(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not ((eventParams.params.address:match('beetv%.kz')
				or eventParams.params.address:match('ucdn%.beetv%.kz'))
				and m_simpleTV.User
				and m_simpleTV.User.beetv
				and m_simpleTV.User.beetv.prx)
			then
			 return
			end
			if eventParams.queryType == 'Start' or eventParams.queryType == 'GetRecordAddress' then
				if eventParams.params.offset > 0 then
					local user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:155.0) Gecko/20100101 Firefox/155.0'
					local len = math.floor(eventParams.params.offset/1000)
					local starttime = os.time() - len
					local id = eventParams.params.address:match('/bpk%-tv/(%d*)/tve/')
						if not id then return end
					local session = m_simpleTV.Http.New(user_agent, decode64(m_simpleTV.User.beetv.prx), true)
						if not session then return end
					m_simpleTV.Http.SetRedirectAllow(session, false)
					m_simpleTV.Http.SetTimeout(session, 12000)
					local url = string.format(decode64('aHR0cHM6Ly91Y2RuLmJlZXR2Lmt6L2Jway10di8lcy90dmUvaW5kZXgubXBk'), id) .. '?begin=' .. starttime .. '&end=' .. os.time()
					local rc, answer = m_simpleTV.Http.Request(session, {url = url})
						if rc ~= 307 then return end
					local head = m_simpleTV.Http.GetRawHeader(session)
					m_simpleTV.Http.Close(session)
					local adr = head:match('Location:%s([^\n]+)')
						if not adr or adr:match('^https://fo%d%d%-bkm.beetv.kz/bpk%-tv/') then return end
					m_simpleTV.Common.Sleep(2000)
					eventParams.params.address = adr
				end
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_beetv')
