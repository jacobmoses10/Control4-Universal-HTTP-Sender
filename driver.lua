function Print (data)
	if (type (data) == 'table') then
		for k, v in pairs (data) do print (k, v) end
	elseif (type (data) ~= 'nil') then
		print (type (data), data)
	else
		print ('nil value')
	end
end

dbg = function (...) end
UrlTimeoutSeconds = 5
ActiveUrlTransfers = {}

local function RemoveActiveTransfer (transfer)
	for i = #ActiveUrlTransfers, 1, -1 do
		if (ActiveUrlTransfers [i] == transfer) then
			table.remove (ActiveUrlTransfers, i)
			return
		end
	end
end

local function RunUrlRequest (method, url, data, headers)
	headers = headers or {}

	local transfer = C4:url ()
	transfer
		:OnDone (function (completedTransfer, responses, errCode, errMsg)
			RemoveActiveTransfer (completedTransfer)

			local lastResponse = responses and responses [#responses]
			local responseCode = lastResponse and lastResponse.code or 0
			local responseBody = lastResponse and lastResponse.body or ''
			local responseHeaders = lastResponse and lastResponse.headers or {}

			local strError = nil
			if (errCode ~= 0) then
				if (errCode == -1) then
					strError = 'Transfer aborted'
				else
					strError = errMsg or ('URL transfer failed with error ' .. tostring (errCode))
				end
			end

			CheckResponse (0, responseBody, responseCode, responseHeaders, strError)
		end)
		:SetOptions ({
			timeout = UrlTimeoutSeconds,
		})

	table.insert (ActiveUrlTransfers, transfer)

	if (method == 'GET') then
		transfer:Get (url, headers)
	elseif (method == 'POST') then
		transfer:Post (url, data or '', headers)
	elseif (method == 'PUT') then
		transfer:Put (url, data or '', headers)
	elseif (method == 'DELETE') then
		transfer:Delete (url, headers)
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
			dbg = function (...) end
		end

	elseif (strProperty == 'URL Timeout') then
		UrlTimeoutSeconds = tonumber (value) or 5

	elseif (presetNum) then
		Presets [presetNum] = value
	end
end

function ExecuteCommand (strCommand, tParams)
	tParams = tParams or {}

	local output = {'--- ExecuteCommand', strCommand, '----PARAMS----'}
	for k,v in pairs (tParams) do table.insert (output, tostring (k) .. ' = ' .. tostring (v)) end
	table.insert (output, '---')
	local outputMessage = table.concat (output, '\r\n')
	dbg (outputMessage)

	if (strCommand == 'LUA_ACTION') then
		if (tParams.ACTION) then
			strCommand = tParams.ACTION
			tParams.ACTION = nil
		end
	end

	local preset = tonumber (tParams.PRESET)

	local url = (preset and Presets [preset]) or tParams.URL

	local header = {}
	if (tParams.JSON_HEADER and tParams.JSON_HEADER ~= '') then
		header = C4:JsonDecode (tParams.JSON_HEADER) or {}
	end

	if (url and url ~= '') then
		if (string.find (strCommand, 'GET')) then
			RunUrlRequest ('GET', url, nil, header)
		elseif (string.find (strCommand, 'POST')) then
			local data = tParams.DATA or ''
			RunUrlRequest ('POST', url, data, header)
		elseif (string.find (strCommand, 'PUT')) then
			local data = tParams.DATA or ''
			RunUrlRequest ('PUT', url, data, header)
		elseif (string.find (strCommand, 'DELETE')) then
			RunUrlRequest ('DELETE', url, nil, header)
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
	local outputMessage = table.concat (output, '\r\n')
	dbg (outputMessage)

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
