-- расширение дополнения httptimeshift limeHD (12/11/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: /luaScr/user/TVSources/scrapers/lime_hd_pls.lua
-- скрипт запуска ивента: /luaScr/user/startup/lime_start.lua
-- скрипт ивента: /luaScr/user/lime/events.lua
-- видеоскрипт: /luaScr/user/video/limeHD.lua
-- расширение дополнения httptimeshift: /luaScr/user/httptimeshift/extensions/limehd-timeshift_ext.lua
	function httpTimeshift_limehd(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not ((eventParams.params.address:match('limehd%.')
				or eventParams.params.address:match('iptv2022%.')
				or eventParams.params.address:match('lime_out%.m3u8'))
				and m_simpleTV.User
				and m_simpleTV.User.lime
				and m_simpleTV.User.lime.url_archive)
			then
			 return
			end
			if eventParams.queryType == 'Start'
				or eventParams.queryType == 'GetRecordAddress'
			then
				if eventParams.params.offset > 0 then
					local len = math.floor(eventParams.params.offset/1000)
					local starttime = os.time() - len
					eventParams.params.address = m_simpleTV.User.lime.url_archive .. 'index-' .. starttime .. '-' .. len .. '.m3u8'
				end
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_limehd')
