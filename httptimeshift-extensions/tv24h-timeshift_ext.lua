-- расширение дополнения httptimeshift - tv24h (1/6/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
	function httpTimeshift_tv24h(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not ((eventParams.params.address:match('24h%.tv')
							or eventParams.params.address:match('tv24h/%d')
							or eventParams.params.address:match('195%.191%.208'))
				and m_simpleTV.User
				and m_simpleTV.User.tv24h
				and m_simpleTV.User.tv24h.url_archive)
			then
			 return
			end
			if eventParams.queryType == 'Start' or eventParams.queryType == 'GetRecordAddress' then
				if eventParams.params.offset > 0 then
					local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0')
						if not session then return end
					m_simpleTV.Http.SetTimeout(session, 5000)
					local offset = math.floor(os.time() - (eventParams.params.offset / 1000))
					local url = m_simpleTV.User.tv24h.url_archive .. '&ts=' .. offset
					local rc, answer = m_simpleTV.Http.Request(session, {url = url})
						if rc ~= 200 then return end
					local retAdr = answer:match('"stream_info":"([^"]+)')
						if not retAdr then return end
					retAdr = retAdr:gsub('data.json', 'index.m3u8')
						if not retAdr then return end
					local qv = eventParams.params.address:match('$OPT:.+') or ''
					eventParams.params.address = retAdr .. qv
				end
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_tv24h')
