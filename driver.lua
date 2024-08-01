function Print (data)
	if (type (data) == 'table') then
		for k, v in pairs (data) do print (k, v) end
	elseif (type (data) ~= 'nil') then
		print (type (data), data)
	else
		print ('nil value')
	end
end

function OnDriverLateInit ()
	if (not (Variables and Variables.HTTP_RESPONSE_DATA)) then
		C4:AddVariable ('HTTP_RESPONSE_DATA', '', 'STRING', true, false)
		C4:SetVariable ('HTTP_RESPONSE_DATA', '')
	end

	if (not (Variables and Variables.HTTP_RESPONSE_CODE)) then
		C4:AddVariable ('HTTP_RESPONSE_CODE', 0, 'NUMBER', true, false)
		C4:SetVariable ('HTTP_RESPONSE_CODE', 0)
	end

	if (not (Variables and Variables.HTTP_ERROR)) then
		C4:AddVariable ('HTTP_ERROR', '', 'STRING', true, false)
		C4:SetVariable ('HTTP_ERROR', '')
	end

	Presets = {}

	for property, _ in pairs (Properties) do
		OnPropertyChanged (property)
	end
end

function OnPropertyChanged (strProperty)
	local value = Properties [strProperty]
	if (value == nil) then
		value = ''
	end

	local presetNum = tonumber (string.match (strProperty, ('Preset URL (%d)')))

	if (strProperty == 'Debug Mode') then
		if (value == 'On') then
			dbg = print
		else
			dbg = function () end
		end

	elseif (strProperty == 'URL Timeout') then
		C4:urlSetTimeout (tonumber (value))

	elseif (presetNum) then
		Presets [presetNum] = value
	end
end

function ExecuteCommand (strCommand, tParams)
	tParams = tParams or {}

	local output = {'--- ExecuteCommand', strCommand, '----PARAMS----'}
	for k,v in pairs (tParams) do table.insert (output, tostring (k) .. ' = ' .. tostring (v)) end
	table.insert (output, '---')
	output = table.concat (output, '\r\n')
	dbg (output)

	if (strCommand == 'LUA_ACTION') then
		if (tParams.ACTION) then
			strCommand = tParams.ACTION
			tParams.ACTION = nil
		end
	end

	local preset = tonumber (tParams.PRESET)

	local url = (preset and Presets [preset]) or tParams.URL

	local header = C4:JsonDecode(tParams.JSON_HEADER) or {}

	if (url and url ~= '') then
		if (string.find (strCommand, 'GET')) then
			C4:urlGet (url, header, false, CheckResponse)
		elseif (string.find (strCommand, 'POST')) then
			local data = tParams.DATA or ''
			C4:urlPost (url, data, header, false, CheckResponse)
		elseif (string.find (strCommand, 'PUT')) then
			local data = tParams.DATA or ''
			C4:urlPut (url, data, header, false, CheckResponse)
		elseif (string.find (strCommand, 'DELETE')) then
			C4:urlDelete (url, header, false, CheckResponse)
		end
	end
end

function CheckResponse (ticketId, strData, responseCode, tHeaders, strError)
	local output = {'---URL response---'}
	if (strError) then
		table.insert (output, strError)
	else
		table.insert (output, 'Response Code: ' .. tostring (responseCode))
		table.insert (output, 'Returned data: ' .. (strData or ''))
	end
	output = table.concat (output, '\r\n')
	dbg (output)

	if (strError) then
		C4:SetVariable ('HTTP_ERROR', strError)
		C4:SetVariable ('HTTP_RESPONSE_DATA', '')
		C4:SetVariable ('HTTP_RESPONSE_CODE', 0)
		C4:FireEvent ('Error')
	else
		C4:SetVariable ('HTTP_ERROR', '')
		C4:SetVariable ('HTTP_RESPONSE_DATA', strData)
		C4:SetVariable ('HTTP_RESPONSE_CODE', responseCode)
		C4:FireEvent ('Success')
	end
end
