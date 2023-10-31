CREATE OR REPLACE SCRIPT ML.Preprocessor_Train() AS
exa.import("ML.Preprocessor_HelperScript", "helper")
function process(sqltext)
	local tokens = sqlparsing.tokenize(sqltext)
	local curpos = sqlparsing.find(tokens, 1, true, false,
					sqlparsing.iswhitespaceorcomment, 'MODEL')
	
	if curpos == nil then
		return sqltext
	end
	
	local commandpos = helper.prevnonwhitespaceorcomment(tokens, curpos[1] - 1)
	local namepos = helper.nextnonwhitespaceorcomment(tokens, curpos[1] + 1)
	
	if commandpos == nil or namepos == nil or
			commandpos == 0 or namepos > #tokens or
			not sqlparsing.iskeyword(tokens[commandpos]) or
			not (sqlparsing.isidentifier(tokens[namepos]) or
			sqlparsing.isstringliteral(tokens[namepos])) then
		return sqltext
	end
	
	local command = sqlparsing.normalize(tokens[commandpos])
	local name = tokens[namepos]
	
	if not sqlparsing.isstringliteral(name) then
		name = "'" .. name .. "'"
	end
	
	if command == 'CREATE' then
		curpos = helper.nextnonwhitespaceorcomment(tokens, namepos + 1)
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "ON") then
			error("The 'ON' clause is missing.")
		end
		
		curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
		
		if curpos > #tokens or
				not (sqlparsing.isidentifier(tokens[curpos]) or
				sqlparsing.isstringliteral(tokens[curpos])) then
			error("Invalid object syntax for 'ON' clause.")
		end
		
		local onobj = tokens[curpos]
		curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
	
		if not sqlparsing.isstringliteral(onobj) then
			onobj = "'" .. onobj .. "'"
		end
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "PREDICT") then
			error("The 'PREDICT' clause is missing.")
		end
		
		curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
		local col = helper.extractcolumns(tokens, curpos, "PREDICT")
		curpos = col[1]
		local predobj = col[2]
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "USING") then
			error("The 'USING' clause is missing.")
		end
		
		curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
		local col = helper.extractcolumns(tokens, curpos, "USING")
		curpos = col[1]
		local useobj = col[2]
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "WITH") then
			error("The 'WITH' clause is missing.")
		end
		
		curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
		local withstartpos = curpos
		--local withendpos = 0
		local withobj = ''
		
		while curpos <= #tokens do
			if not sqlparsing.isstringliteral(tokens[curpos]) then
				error("Invalid object syntax for 'WITH' clause.")
			end
			
			withobj = withobj .. "'" .. tokens[curpos] .. "'="
			curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
		
			if curpos > #tokens or not (tokens[curpos] == "=") then
				error("Invalid object syntax for 'WITH' clause.")
			end
			
			curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
			--withendpos = curpos
			
			if sqlparsing.isstringliteral(tokens[curpos]) then
				withobj = withobj .. "'" .. tokens[curpos] .. "'"
			elseif sqlparsing.isnumericliteral(tokens[curpos]) then
				withobj = withobj .. tokens[curpos]
			else
				error("Invalid object syntax for 'WITH' clause.")
			end
			
			curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
			
			if curpos > #tokens or not (tokens[curpos] == ",") then
				break
			end
		
			withobj = withobj .. ","
			curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
		end
		
		curpos = helper.nextnonwhitespaceorcomment(tokens, curpos + 1)
		--local withobj = helper.jointokens(tokens, withstartpos, withendpos)
		
		sqltext = "EXECUTE SCRIPT ML.Model_Train(" ..
			name .. ", " .. onobj .. ", '" .. predobj ..
			"', '" .. useobj .. "', '" .. withobj .. "')"
	elseif command == 'REPLACE' then

	elseif command == 'ALTER' then

	elseif command == 'RENAME' then

	elseif command == 'DROP' then

	end
	
	return sqltext
end

-- RETRAIN / REFRESH model
