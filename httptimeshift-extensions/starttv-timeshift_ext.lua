-- расширение дополнения httptimeshift - starttv (3/2/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Addons
	function httpTimeshift_starttv(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			
			if not (eventParams.params.address:match('%.24h%.tv')
				and m_simpleTV.User
				and m_simpleTV.User.starttv
				and m_simpleTV.User.starttv.url_archive)
			then
			 return
			end

			if eventParams.queryType == 'Start' then
				if eventParams.params.offset > 0 then
					local startTime = math.floor(os.time() - (eventParams.params.offset / 1000))
					local url = m_simpleTV.User.starttv.url_archive
					url = url .. '&ts=' .. startTime
					local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
						if not session then return end
					m_simpleTV.Http.SetTimeout(session, 8000)
					local rc, answer = m_simpleTV.Http.Request(session, {url = url})
						if rc ~= 200 or not answer then return end
					local adr = answer:match('"hls":%s?"([^"]+)')
					eventParams.params.address = adr
				end
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_starttv')
