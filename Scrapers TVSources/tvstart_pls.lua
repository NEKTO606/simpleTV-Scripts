-- скрапер TVS для загрузки плейлиста "ТВ Старт" https://tvstart.ru (1/11/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## Переименовать каналы ##
local filter = {
	}
	local my_src_name = 'ТВ Старт'
	module('tvstart_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\tvstart.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
	local channels = {
					{'YXBpX2ZyZWVfZmQxNGVkMzQxNjRhNTJkMTA5MGU0Y2I5ZGI5MzY4M2YvNF83OTI3NjUxNy9kMzNiYmYzZTZhYzdjNDE1MjRlYWU1ZDFjM2Q5MjU4ZC80ODczMTY3OTAy', 'Старт'},
					{'YXBpX2ZyZWVfN2E5NjliMGI0NTM0NWZlZTA1MGMwN2U3YWIxNGY1MmUvMzNfODU0Nzk5ODIvZTJjMDM4YWU3OTE2ZDc1MDI5YjJkZDhhZWFhYzZlOTAvNDg3MzE2NzkwMg==', 'Триумф'},
					{'ZnJlZV82MjFkMTY5ZTVjNjMxYzYzODEzNmRmM2NiMTM2YzVjOS8zM182ODg4MTY3Ni9iMzJlYWFlNWZiZjFkMmI4MjExNTQzNTY2YTFkOWE3OC80OTE0MzkyNzY5', 'Баскет'},
					{'ZnJlZV84NDc5OWViM2VlNTliZjhmMmQwNWI4Mzg0NjhiZTc3ZS8zM185NDI3ODA5Ni81YWU2ZDM0NDE3NTcyODE4YzkzYjFiM2EwOGVhZjUzMC80ODgzMTI4ODI4', 'Футбол'},
					{'ZnJlZV82ZjliODgyYTc1ZDhlNGEwYjMxM2JmYzY3Y2FkYmMxYy8zM183MjEzNjI0MS8wOTY1MGQ4MGRjMWU4NTA4ZDQxNzliOTdmNzU2M2I2Ny80ODc3MDcxMjc1', 'ТВ Спорт'},
					{'ZnJlZV84NGMyMWJiMGFmNWQ5N2IxNTIzOTUwZGJlYzJkMmMzYy8zM183Mzc2MTIyOS9jODIyZGUzODUzM2RmMjU1ZGY4NDBhMTA5YTEyZDBjNC80ODc3MDcxMjcy', 'Мяч'},
					{'ZnJlZV8zOTJlZDJiYWMzMzMyZjM0NzA1NWIzYTk3ZTA4N2MwYy8zM182OTM1Mjg3OC9iYzVkNjBkYTk5ZTE4MDllMTRlZjNmY2Y0Zjk5YmYxYi80ODc3MDcxMjY1', 'Хоккей ТВ'},
					{'ZnJlZV9kNmJhM2RiZDM5YTkyODJiN2M2YmMzMTI0ZTVmY2Q3ZC8zM183NTc2MTA0OS9lMmZiMDNiMGQzYzdiY2ZhYjUyNzQyNTY1ZmE5MzI0ZC80ODgzMTEwNjc2', 'Trace Sport Stars'},
					{'ZnJlZV84ZjczZmE2ZmE5YWUzMmFmZTQ0N2NiMzZiNzg5YWRjYy8zM184OTk1OTE1MC82ODM4NGZiMDQ0YzNmZWMwNmI0ZDkzYzM1YjE1YTNjOS80ODc3MDY2MzU4', 'МИР'},
					{'ZnJlZV9hZTIxZGNlMmQ0MDg2YWEyYmEzMDFkMWUxYjM3ZWVhOC8zM184NDk5MTc1Ny85ODVmODQyMjI5OTc3MDk4OWRjZjFjMDNjODFlMGMyYi80ODgzNzEwNDA5', 'Оружие'},
					{'ZnJlZV83MDNiM2ZhNzAyMmE4OTBmNTYwNGYyMjM4YzVlNWE3YS8zM183MzU0NzAwOC9lNzBmNmRiODQyOTJmZWI1OWNiYmUxZjg2MWMxOGNmOC80ODk5OTU3OTI4', 'Русская история'},
					{'ZnJlZV8wNWUwODVhZmMyOTVmNGE0OTVkODA5OTczNDU4M2JiYi8zM183MzU1ODY2Ny83ZWYyZjcwNjVmNmFiZjU2OTJmNDFiYzMxZjBkMGIxNy80OTAxNjc0MTIw', 'The Explorers'},
					{'ZnJlZV8yMmZmNWQ0ZjI2MDQzOGQwNTQxYjg1ZDE1YjMxZmM2Ni8zM182NjkwOTgyMS9lN2YwMjk3Mzg0Y2U1ZWEyMzQwNzcyZjcyODU1MTVhNi80ODgxNjI0ODc5', 'Мир вокруг'},
					{'ZnJlZV9iNTRiZTc5NmUwODg0NmE0ZWFmOGUyOWIxNWQ2Y2ZiYS8zM184MzE0MzQ5MC81ZjE5MjY1NmQ5MTI2OGNlNDA1YTU3OWNlMTFmOWUxOS80ODgzMTA5ODU4', 'TERRA'},
					{'ZnJlZV8xNGE1MjVmNWI5MGYxZDAwZmRkZThhMmMwMDE1OWQ4Yi8zM184MTIwNTU5OS85ODk4NmRkNmQ2Y2Q4ODliN2E5NTcxZjA2NGVlZmRhZi80ODgzMTExODA3', 'Мы'},
					{'ZnJlZV9lNDIyMTI5NDQzNDk5MGJjNGE5ZDNlNDgyMzc1MTBiMi8zM183NTk4NjU2My83MmEyNzY5OGM3NDU5YWY5MWNiOGE0MjQ3YzYxMDFmMi80ODc2OTgxNzA2', 'RT Документальный'},
					{'ZnJlZV9mOWM2YTFhMWU5OWI1MDlmNDBkZmZhMTY4YzIwMjNkNS8zM183MTQ3NzA0NS81YWQ5ZDBjZGZmYWQ3ODUzYWVmMjcyY2NhYjJjMDFhZC80ODgxNjI4NzIz', 'Тонус'},
					{'ZnJlZV82NzA5ODkxYzBjMWI1MzY4MTQ1YjhiNzRmYTU4ZGI3Zi8zM185MTIxOTczMS9jZDgzMmUwYTQ0OTM2OWE2Zjg5ZTQzOWJjZTA4MDI5Yi80ODc2OTgxNjIx', 'МИР24'},
					{'ZnJlZV81MGI1MzNmOGEwNzVkMWYzMDA4NWZmMzc4MzZiZDk3NS8zM185NzI0MDIwMi8xODBhZDg1ODkwYzU1MjU3NjVlYWRjYzBmYTcxMDc2YS80ODgzMTEyNzYy', 'Феникс+Кино'},
					{'ZnJlZV84MDNjZmZlY2I4ZWRlN2Q1NGFiYThmNzgyNzk4OTJhYy8zM184MjQ4NTEyNS8xYWI5ZTNhN2YxYzM5MDIxMmM2ZmFkN2NiZDUyMTVkNi80ODgzMTExNDk2', 'Кинеко'},
					{'ZnJlZV83ODYwODcwNDM5M2Y5MzI3OTAyZTU2YWE3Zjg1ZWU5Ny8zM182NjQwNjY2MS82NGQ3NGQ2Yjc1Mzc1M2IyYjA2OWU1YmNlYzVjZGRjYi80ODgzMTExOTc4', 'САПФИР'},
					{'ZnJlZV80ODZkNjRkYjIwYjExNWM3YjkyZjcwYTgwMDE0ODNhMS8zM184MTQxNjY1NS9jMTA1YjFmYzIyNTMxNzdhNTQ3OTYyMTMxNjVkMzdjOC80ODgzMDE2Nzcw', '.Red'},
					{'ZnJlZV84MzI4Y2E4YzVkODJiNzkzNDRlMWE1MTBmNzkxOWM1NS8zM184OTQ2MzE5Ni84OGNkY2E0ZmIyNDc4ODQ5MmM3NTg4ODc4ZTIyYzE0YS80ODgzMDA5ODk5', '.Black'},
					{'ZnJlZV8yNjE2MTQxMDczY2M1NzJhYjVkODdlNDk5MTdjNTY2ZS8zM185MjkzMzcyMC9kZTY0ZGNhOGMyNGVhZDJiOGJkM2Q5ZDAzZDkwMzU5OC80ODgzMDE3NDAw', '.SciFi'},
					{'ZnJlZV81YmIxNThlMDI4YzUyYWYyNjA0NGZkMTY0NWIxNWExNi8zM184MjY5NDAzNy84MmZlYzk3MDcxODY0NzRlNjk4OGExYmFjMWZlODJjNC80ODgxMjk4MTQy', 'Star Family'},
					{'ZnJlZV8yZDAxNDVmNWNmNzYwZmNkYzE4NGFjMDM3ODk5ODBkMC8zM184NTI3Nzc1OC9mNzhkNzZkMDExNGRkMDE1YzFmNjBkNDg3YTZhYTZiZS80ODgzNDYxODA1', 'Star Cinema'},
					{'ZnJlZV9kYTgyOGYxNDQ4OTc5MDIyMmRkOTQzMDA0MzM4MTYxNS8zM183MjA2NzI5OS8xZmZhOTc4ZjE5NzlmNTgwNmNlODI2NmMyNDQxMGRmMS80ODgzMDk2NzI3', 'Bolt'},
					{'ZnJlZV8xNjQyNjFkYWNhMTQzMWEyZmI5ODhiOWFlNzliMzU4NS8zM182NzU4ODEzMy8zNmNjOGFjZGU2ZjMyMGYwYmE2NzA1Nzg5M2ZhYjIwNi80ODgzMTEwOTEz', 'Диалоги о рыбалке'},
					{'ZnJlZV9hYTg5ZDg0ZjdmNTUyNmU2NzVkYWMxNTU1NTA0YWQ2NC8zM183OTI5OTg4NC9mMzkxNWE4MGM0MGMyYzJmNjRmYmZlYTk5ZDZlMTZiZS80ODgzMTI4MDk4', 'Анекдот ТВ'},
					{'ZnJlZV9iODk4MGZlNzUwMjU3OGM2NThhNTkzZmJjMTk3MWQ1MS8zM184Njk0MTA2Ny9mMGRlNjI2NWVkYWFjYTgzMWMwZTFkOTJlOTQ1MTVkNC80ODgzMTEwMTE3', 'Аппетитный'},
					{'ZnJlZV8xOGE5NzgwNzc1NTBiN2Q4YTcwNjc4MTU0MGFlNDdlOC8zM183OTY3MjIwMC81MmY4MzMyYmY1ZTNiZjBmOWI1ZjE0ZjMzYmNkMTdkYy80ODc3MDY2NDcy', 'World Fashion РФ'},
					--{'ZnJlZV8xNmQ3MTczNmFmZTA2N2UxNGIxYWMwMzhjMzY1ZjFhNC8zM185MDIwOTczOC9jNDQwNzc4OGY4YjM2ODMxNjkwNDVhOWQ5MjhlM2MxMS80ODc2OTgxODk0', 'Sochi Live'},
					{'ZnJlZV9kYTQyOTNkMTE5MzUwOTQ3NzUxOTk3ZTVkM2YxZGIyNy8zM185ODY0MTk0Ni83ZGZiYTMzMGVmNzk3NTQ5ODk3MTJmNzE1YjU4YWNmNy80ODgzMTEyNTI0', 'СТС kids'},
					{'ZnJlZV83OWM2NDkxODg0YTcxYTA4ZDBiODY2ZDIyMzk5YzgyMS8zM183MzMwMjY2OS9mMTJkMDljOThlNDFiMzhhZWM1M2M4N2ExNjYwZjA5NC80ODgzMDk3MzU0', 'Ducktv'},
					{'ZnJlZV9jN2ZmMDA4MTUxOGU2ZTcxNTg2ZjVkOTY2YzFhYmY5ZC8zM183MjM3Mzk4OS9mZjgxNjQ1NzgxZGE2NzlkMjhiNjViYzg1MDZhMzkzNS80ODgzMzYzMjEx', 'Русский Корабль'},
					--{'ZnJlZV84MGY5Y2EwYTg1MmUzMzM0YzA0MzdmNDM2OTFiNjhiYS8zM184NDAwNzYzOS81NjYxZWIyNmVhOWE0NmZmZTRhYmM0MTJmM2U4Yzk4Yi80ODc3MDY2NTYw', 'Сочи24'},
					{'ZnJlZV9jMzQxMmIxNGJjYjg4NDQ1YzljMWE3OGJmNjZkMmI5OC8zM185MjgyMTE4Ny9jZWI0MGM5ZTBhNmQwYjNiYmM4NmQwZjI1ZWQ3YTE4Zi80ODc3MDY2NDc3', 'ТНВ'},
					{'ZnJlZV82NmRiMjdiZGIxNjlkMDkxZGQ5ZDM0N2I1NmZhMjBiMS8zM185OTI2MDkwNi8xYWRiNmFmNDU5ZTI4ZGNmYzYyNTRlYThiMDZhOGI5Mi80ODc2OTgxODYx', 'RT английский'},
					{'ZnJlZV9hZmJhNGFlNWM2ZDc4NzM0MjYxMWNiZWEzYjk5NjkzMS8zM182OTI4NzY3Ni82NmJjMWE4ZGViOTdkZDU5YmUyYTk0MTQ3Y2Y2ZTkxNC80ODc2OTgxNzk5', 'RT Арабский'},
					{'ZnJlZV9hNjU0NzYwZGMxM2ViZjQ5ZjU2ZDEyOTIyNjUxYWExMy8zM184NjI0Mzk0Ny9iNDllNjVhOTE4ODEzOGYzODNlOWJhZTIzOWU0NzZiNi80ODc2OTgxODMw', 'RT Испанский'},
					{'ZnJlZV8xNWMwY2I2MDllZjAyNjkyMGU3OThhNTQ2ZmFjYTI1ZC8zM182NjQ1MTkyMS8xZGY5ZDU4NThkYzNkMDQ5MzgzYjc0YjE4MWVlMWZiMC80ODc2OTgxNzY0', 'RT Немецкий'},
					{'ZnJlZV9jMGI3MWZmMGY5YTFjZjRjYjVlYzE4OWJkNjJlMTI5Yi8zM184MTc1MzY5OC9kZDY5Zjk3YjMxNDhjNDkyM2JjZDI5YjQ5Y2E3Y2E3OS80ODc2OTgxNzM2', 'RT Французский'},
				}
		local t = {}
			for i, v in pairs(channels) do
				if v[1] and v[2] then
					t[#t + 1] = {}
					t[#t].name = unescape3(v[2])
					t[#t].address = 'https://tvstart.ru/' .. v[1]
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
-- debug_in_file(token .. '\n', "D:\xxx.txt")
