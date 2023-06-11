CREATE OR REPLACE SCRIPT ML.Preprocessor_Train() AS
function nextnonwhitespaceorcomment(tokens, curpos)
	while curpos <= #tokens and
			sqlparsing.iswhitespaceorcomment(tokens[curpos]) do
		curpos = curpos + 1
	end
	
	return curpos
end
function prevnonwhitespaceorcomment(tokens, curpos)
	while curpos > 0 and
			sqlparsing.iswhitespaceorcomment(tokens[curpos]) do
		curpos = curpos - 1
	end
	
	return curpos
end
function extractcolumns(tokens, curpos, clause)
	if curpos > #tokens or not (tokens[curpos] == "(") then
		error("Invalid object syntax for '" .. clause .. "' clause.")
	end
	
	curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
	local startpos = curpos
	local endpos = 0
	
	while curpos <= #tokens do
		if not (sqlparsing.isidentifier(tokens[curpos]) or
				sqlparsing.isstringliteral(tokens[curpos])) then
			error("Invalid object syntax for '" .. clause .. "' clause.")
		end
	
		endpos = curpos
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		
		if curpos > #tokens then
			error("Invalid object syntax for '" .. clause .. "' clause.")
		elseif tokens[curpos] == ")" then
			break
		elseif not (tokens[curpos] == ",") then
			error("Invalid object syntax for '" .. clause .. "' clause.")
		end
	
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
	end
	
	curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		
	if curpos > #tokens then
		error("Invalid object syntax for '" .. clause .. "' clause.")
	end
	
	return { curpos, jointokens(tokens, startpos, endpos) }
end
function jointokens(tokens, startpos, endpos)
	local str = ''
	
	for i = startpos, endpos do
		if not sqlparsing.iswhitespaceorcomment(tokens[i]) then
			str = str .. tokens[i]
		end
	end
	
	return str
end
function process(sqltext)
	local tokens = sqlparsing.tokenize(sqltext)
	local curpos = sqlparsing.find(tokens, 1, true, false,
					sqlparsing.iswhitespaceorcomment, 'MODEL')
	
	if curpos == nil then
		return sqltext
	end
	
	local commandpos = prevnonwhitespaceorcomment(tokens, curpos[1] - 1)
	local namepos = nextnonwhitespaceorcomment(tokens, curpos[1] + 1)
	
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
		curpos = nextnonwhitespaceorcomment(tokens, namepos + 1)
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "ON") then
			error("The 'ON' clause is missing.")
		end
		
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		
		if curpos > #tokens or
				not (sqlparsing.isidentifier(tokens[curpos]) or
				sqlparsing.isstringliteral(tokens[curpos])) then
			error("Invalid object syntax for 'ON' clause.")
		end
		
		local onobj = tokens[curpos]
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
	
		if not sqlparsing.isstringliteral(onobj) then
			onobj = "'" .. onobj .. "'"
		end
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "PREDICT") then
			error("The 'PREDICT' clause is missing.")
		end
		
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		local col = extractcolumns(tokens, curpos, "PREDICT")
		curpos = col[1]
		local predobj = col[2]
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "USING") then
			error("The 'USING' clause is missing.")
		end
		
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		local col = extractcolumns(tokens, curpos, "USING")
		curpos = col[1]
		local useobj = col[2]
		
		if curpos > #tokens or
				not (sqlparsing.normalize(tokens[curpos]) == "WITH") then
			error("The 'WITH' clause is missing.")
		end
		
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		local withstartpos = curpos
		--local withendpos = 0
		local withobj = ''
		
		while curpos <= #tokens do
			if not sqlparsing.isstringliteral(tokens[curpos]) then
				error("Invalid object syntax for 'WITH' clause.")
			end
			
			withobj = withobj .. "'" .. tokens[curpos] .. "'="
			curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		
			if curpos > #tokens or not (tokens[curpos] == "=") then
				error("Invalid object syntax for 'WITH' clause.")
			end
			
			curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
			--withendpos = curpos
			
			if sqlparsing.isstringliteral(tokens[curpos]) then
				withobj = withobj .. "'" .. tokens[curpos] .. "'"
			elseif sqlparsing.isnumericliteral(tokens[curpos]) then
				withobj = withobj .. tokens[curpos]
			else
				error("Invalid object syntax for 'WITH' clause.")
			end
			
			curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
			
			if curpos > #tokens or not (tokens[curpos] == ",") then
				break
			end
		
			withobj = withobj .. ","
			curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		end
		
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		--local withobj = jointokens(tokens, withstartpos, withendpos)
		
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
