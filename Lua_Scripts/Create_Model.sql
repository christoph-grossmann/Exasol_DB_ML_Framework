CREATE OR REPLACE SCRIPT ML.Model_Train(name, source, labels, features, settings) AS
function occcntinstr(string, char)
	local count = 0
	for i in string:gmatch(char) do
    	count = count + 1
    end
    return count
end

local params = '{'
local modelparams = '{'
local algid = null
local algname = null
local algtype = null
local algmeth = null
local algout = null
local alglang = null
local algmod = null
local algsub = null
local algfunc = null
local algens = null
local algincr = null

local featurecnt = occcntinstr(features, ',') + 1
local labelcnt = occcntinstr(labels, ',') + 1
local res = query([[SELECT * FROM ML.Model WHERE Name = :n]], { n = name })

if #res > 0 then
	error("Model with the name '" .. name .. "' already exists.")
end

local tokens = sqlparsing.tokenize(settings)
local pos = 1

-- conf = { } <-- mit allen Parametern initialisieren
-- conf[ukey] = value
-- conf["ID"], nil wenn nicht existent

while pos < #tokens do
	local rkey = tokens[pos]
	local rvalue = tokens[pos + 2]
	local key = rkey:sub(2, #rkey - 1)
	local ukey = string.upper(key)
	local value = ''
	
	if sqlparsing.isstringliteral(rvalue) then
		value = rvalue:sub(2, #rvalue - 1)
	else
		value = rvalue
	end
	
	if		ukey == 'ID'			then algid = value
	elseif	ukey == 'NAME'			then algname = value
	elseif	ukey == 'TYPE'			then algtype = value
	elseif	ukey == 'METHOD'		then algmeth = value
	elseif	ukey == 'OUTPUT'		then algout = value
	elseif	ukey == 'LANGUAGE'		then alglang = value
	elseif	ukey == 'MODULE'		then algmod = value
	elseif	ukey == 'SUBMODULE'		then algsub = value
	elseif	ukey == 'FUNCTION'		then algfunc = value
	elseif	ukey == 'ENSEMBLE'		then
		algens = value
		params = params .. '"Ensemble":"' .. value .. '",'
	elseif	ukey == 'INCREMENTAL'	then
		algincr = value
		params = params .. '"Incremental":"' .. value .. '",'
	else
		if sqlparsing.isstringliteral(rvalue) then
			modelparams = modelparams .. '"' .. key .. '":"' .. value .. '",'
		else
			modelparams = modelparams .. '"' .. key .. '":' .. value .. ','
		end
	end

	pos = pos + 4
end

if #modelparams > 1 then
	modelparams = modelparams:sub(1, #modelparams - 1)
end

modelparams = modelparams .. '}'
params = params .. '"model_params":' .. modelparams .. '}'

res = query([[SELECT		Id,
			CONCAT('ML.', "Module", '_', Submodule, '_', "Function", '_train') AS SP
FROM		ML.Algorithm
WHERE		(:i IS null OR Id = :i)
	AND		(:n IS null OR UPPER(Name) = UPPER(:n))
	AND		(:t IS null OR UPPER("Type") = UPPER(:t))
	AND		(:m IS null OR UPPER("Method") = UPPER(:m))
	AND		(:o IS null OR UPPER("Output") = UPPER(:o))
	AND		(:l IS null OR UPPER("Language") = UPPER(:l))
	AND		(:d IS null OR UPPER("Module") = UPPER(:d))
	AND		(:s IS null OR UPPER(Submodule) = UPPER(:s))
	AND		(:f IS null OR UPPER("Function") = UPPER(:f))
	AND		(:e IS null OR IsEnsemble = :e)
	AND		(:c IS null OR IncrementalLearn = :c)
ORDER BY	Priority ASC, Id ASC
LIMIT		1]], { i = algid, n = algname, t = algtype, m = algmeth, o = algout,
	l = alglang, d = algmod, s = algsub, f = algfunc, e = algens, c = algincr }) -- hier conf übergeben
	
if #res == 0 then
	error('An algorithm matching the specified settings does not exist.')
end

--query([[select ::stp (:n, :p, ::f, ::l) from ::s]],
--	{ stp = res[1].SP, n = name, p = params, f = features, l = labels, s = source })

query([[select ::stp (:n, :p, ]] .. features .. [[, ::l) from ::s]],
	{ stp = res[1].SP, n = name, p = params, l = labels, s = source })

query([[INSERT INTO ML.Model
(Name, AlgorithmId, "Source", Features, FeatureCount, Labels, LabelCount, Settings, Parameters)
VALUES (:n, :a, :s, :f, :fc, :l, :lc, :e, :p)]],
	{ n = name, a = res[1].ID, s = source, f = features, fc = featurecnt,
	l = labels, lc = labelcnt, e = settings, p = params })
