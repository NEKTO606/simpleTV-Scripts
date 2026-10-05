-- расширение дополнения httptimeshift - AlmaTV (5/10/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
	function httpTimeshift_almatv(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not ((eventParams.params.address:match('almatv%.kz')
					or eventParams.params.address:match('almatv%.platform24%.tv')
					or eventParams.params.address:match('79%.134%.37'))
				and m_simpleTV.User
				and m_simpleTV.User.almatv
				and m_simpleTV.User.almatv.url_archive)
			then
			 return
			end

			if eventParams.queryType == 'Start' or eventParams.queryType == 'GetRecordAddress' then
				if eventParams.params.offset > 0 then
					local prx = decode64(m_simpleTV.User.almatv.prx)
						if not prx then return end
					local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:157.0) Gecko/20100101 Firefox/157.0', prx, true)
						if not session then return end
					m_simpleTV.Http.SetTimeout(session, 8000)
					local offset = math.floor(os.time() - (eventParams.params.offset / 1000))
					local url = m_simpleTV.User.almatv.url_archive .. '&ts=' .. offset
					local rc, answer = m_simpleTV.Http.Request(session, {url = url})
						if rc ~= 200 then return end
					m_simpleTV.Http.Close(session)
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
	httpTimeshift.addEventExecutor('httpTimeshift_almatv')
