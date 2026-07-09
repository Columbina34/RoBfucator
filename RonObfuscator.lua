if debug and debug.getinfo then
    local info = debug.getinfo(1, "S")
    if info and not info.short_src:match("RonObfuscator_Ultra") then
        local _c = 0
        for _ = 1, 500000 do _c = _c + 1 end
    end
end
if getfenv and getfenv() ~= _G then
    while true do end
end
local startTime = os and os.time and os.time() or 0
if startTime > 0 and os.time() - startTime > 5 then
    -- Posible depuración con pausas
    while true do end
end

local _PRIME_LIST = {}
do
    local limit = 100000
    local sieve = {}
    for i = 1, limit do sieve[i] = true end
    sieve[1] = false
    for i = 2, math.sqrt(limit) do
        if sieve[i] then
            for j = i*i, limit, i do sieve[j] = false end
        end
    end
    for i = 2, limit do
        if sieve[i] then
            _PRIME_LIST[#_PRIME_LIST + 1] = i
        end
    end
end

local _FIBONACCI = {}
do
    local a, b = 0, 1
    for i = 1, 10000 do
        a, b = b, a + b
        _FIBONACCI[i] = b % 1000003
    end
end

local _RANDOM_TABLE_A = {}
local _RANDOM_TABLE_B = {}
local function _LCG(state)
    return function()
        state = (state * 1103515245 + 12345) % 2147483648
        return state
    end
end
local _rng1 = _LCG(123456789)
local _rng2 = _LCG(987654321)
for i = 1, 5000 do
    _RANDOM_TABLE_A[i] = _rng1() % 1000000
    _RANDOM_TABLE_B[i] = _rng2() % 1000000
end

local _M1, _M2, _M3 = {}, {}, {}
do
    for i = 1, 200 do
        _M1[i] = {}; _M2[i] = {}; _M3[i] = {}
        for j = 1, 200 do
            _M1[i][j] = (_PRIME_LIST[(i*j + 1) % #_PRIME_LIST + 1] * _FIBONACCI[(i+j) % 10000 + 1]) % 10000
            _M2[i][j] = (_RANDOM_TABLE_A[(i*j) % 5000 + 1] + _RANDOM_TABLE_B[(i+j) % 5000 + 1]) % 10000
            _M3[i][j] = 0  -- se llenará en multiplicación
        end
    end
end
local function _HEAVY_MATRIX_MULT()
    for i = 1, 200 do
        for j = 1, 200 do
            local sum = 0
            for k = 1, 200 do
                sum = sum + _M1[i][k] * _M2[k][j]
            end
            _M3[i][j] = sum
        end
    end
    local total = 0
    for i = 1, 200 do
        for j = 1, 200 do
            total = total + _M3[i][j]
        end
    end
    return total
end
local _mat_result = _HEAVY_MATRIX_MULT()
local _B64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local function _base64encode(data)
    local out = {}
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i+2)
        local n = (a or 0) * 65536 + (b or 0) * 256 + (c or 0)
        local d1 = math.floor(n / 262144) % 64 + 1
        local d2 = math.floor(n / 4096) % 64 + 1
        local d3 = math.floor(n / 64) % 64 + 1
        local d4 = n % 64 + 1
        out[#out+1] = _B64_ALPHABET:sub(d1, d1) .. _B64_ALPHABET:sub(d2, d2)
        if not b then
            out[#out+1] = "=="
            break
        else
            out[#out+1] = _B64_ALPHABET:sub(d3, d3)
            if not c then
                out[#out+1] = "="
                break
            else
                out[#out+1] = _B64_ALPHABET:sub(d4, d4)
            end
        end
    end
    return table.concat(out)
end
local function _base64decode(b64)
    local rev = {}
    for i = 1, #_B64_ALPHABET do rev[_B64_ALPHABET:sub(i, i)] = i-1 end
    b64 = b64:gsub("=+$", "")
    local data = {}
    for i = 1, #b64, 4 do
        local d1 = rev[b64:sub(i, i)] or 0
        local d2 = rev[b64:sub(i+1, i+1)] or 0
        local d3 = rev[b64:sub(i+2, i+2)] or 0
        local d4 = rev[b64:sub(i+3, i+3)] or 0
        local n = d1 * 262144 + d2 * 4096 + d3 * 64 + d4
        local c1 = math.floor(n / 65536) % 256
        local c2 = math.floor(n / 256) % 256
        local c3 = n % 256
        data[#data+1] = string.char(c1)
        if b64:sub(i+2, i+2) ~= "=" then data[#data+1] = string.char(c2) end
        if b64:sub(i+3, i+3) ~= "=" then data[#data+1] = string.char(c3) end
    end
    return table.concat(data)
end

local function _rot13(s)
    local r = {}
    for i = 1, #s do
        local b = s:byte(i)
        if b >= 65 and b <= 90 then
            r[i] = string.char(((b - 65 + 13) % 26) + 65)
        elseif b >= 97 and b <= 122 then
            r[i] = string.char(((b - 97 + 13) % 26) + 97)
        else
            r[i] = s:sub(i, i)
        end
    end
    return table.concat(r)
end
local function _rot5(s)
    local r = {}
    for i = 1, #s do
        local b = s:byte(i)
        if b >= 48 and b <= 57 then
            r[i] = string.char(((b - 48 + 5) % 10) + 48)
        else
            r[i] = s:sub(i, i)
        end
    end
    return table.concat(r)
end
local function _rot47(s)
    local r = {}
    for i = 1, #s do
        local b = s:byte(i)
        if b >= 33 and b <= 126 then
            r[i] = string.char(33 + ((b - 33 + 47) % 94))
        else
            r[i] = s:sub(i, i)
        end
    end
    return table.concat(r)
end
local function _xor(str, key)
    local klen = #key
    local res = {}
    for i = 1, #str do
        res[i] = string.char(str:byte(i) ~ key:byte((i-1) % klen + 1))
    end
    return table.concat(res)
end

local _SUBSTITUTE_ALPHABET = {}
do
    local chars = {}
    for i = 33, 126 do chars[#chars+1] = string.char(i) end
    -- Fisher-Yates shuffle usando LCG con seed basado en primos
    local seed = _PRIME_LIST[100] + _PRIME_LIST[5000]
    local rng = _LCG(seed)
    for i = #chars, 2, -1 do
        local j = (rng() % i) + 1
        chars[i], chars[j] = chars[j], chars[i]
    end
    local original = {}
    for i = 33, 126 do original[#original+1] = string.char(i) end
    for i = 1, #original do
        _SUBSTITUTE_ALPHABET[original[i]] = chars[i]
    end
end
local function _custom_substitute(s, reverse)
    local res = {}
    local map = _SUBSTITUTE_ALPHABET
    if reverse then
        local rev_map = {}
        for k, v in pairs(map) do rev_map[v] = k end
        map = rev_map
    end
    for i = 1, #s do
        local c = s:sub(i, i)
        local b = s:byte(i)
        if b >= 33 and b <= 126 then
            res[i] = map[c] or c
        else
            res[i] = c
        end
    end
    return table.concat(res)
end

local function _derive_key(length, seed_offs)
    local k = {}
    for i = 1, length do
        local idx = (i * 19 + seed_offs) % #_PRIME_LIST + 1
        local code = (_PRIME_LIST[idx] % 94) + 33
        k[i] = string.char(code)
    end
    return table.concat(k)
end
local _KEY1 = _derive_key(128, 0)
local _KEY2 = _derive_key(64, 200)
local _KEY3 = _derive_key(32, 400)

local function _encrypt_string(s)
    s = _rot13(s)
    s = _rot5(s)
    s = _rot47(s)
    s = _custom_substitute(s, false)
    s = _xor(s, _KEY1)
    s = _xor(s, _KEY2)
    s = _xor(s, _KEY3)
    s = _rot13(s)
    return _base64encode(s)
end

local function _decrypt_string(s)
    s = _base64decode(s)
    s = _rot13(s)
    s = _xor(s, _KEY3)
    s = _xor(s, _KEY2)
    s = _xor(s, _KEY1)
    s = _custom_substitute(s, true)
    s = _rot47(s)
    s = _rot5(s)
    s = _rot13(s)
    return s
end

assert(_decrypt_string(_encrypt_string("RonObfuscator_Ultra_Test_123!@#")) == "RonObfuscator_Ultra_Test_123!@#", "Cipher failure")

local _VM_OP = {
    NOP   = 0,
    PUSH  = 1,
    POP   = 2,
    ADD   = 3,
    SUB   = 4,
    MUL   = 5,
    DIV   = 6,
    XOR   = 7,
    LOADK = 8,
    CALL  = 9,
    RET   = 10,
    JMP   = 11,
    JZ    = 12,
    NEWT  = 13,
    SETT  = 14,
    GETT  = 15,
    STOREG= 16,
    LOADG = 17,
    HALT  = 18
}
local function _vm_exec(bytecode, constants, global)
    local stack = {}
    local pc = 1
    local regs = {}
    local function push(v) stack[#stack+1] = v end
    local function pop() local v = stack[#stack]; stack[#stack] = nil; return v end
    while true do
        local op = bytecode[pc]
        if op == _VM_OP.HALT then break
        elseif op == _VM_OP.NOP then pc = pc + 1
        elseif op == _VM_OP.PUSH then push(bytecode[pc+1]); pc = pc + 2
        elseif op == _VM_OP.POP then pop(); pc = pc + 1
        elseif op == _VM_OP.ADD then local b=pop(); local a=pop(); push(a+b); pc=pc+1
        elseif op == _VM_OP.SUB then local b=pop(); local a=pop(); push(a-b); pc=pc+1
        elseif op == _VM_OP.MUL then local b=pop(); local a=pop(); push(a*b); pc=pc+1
        elseif op == _VM_OP.DIV then local b=pop(); local a=pop(); push(a/b); pc=pc+1
        elseif op == _VM_OP.XOR then local b=pop(); local a=pop(); push(a~b); pc=pc+1
        elseif op == _VM_OP.LOADK then local idx=bytecode[pc+1]; push(constants[idx]); pc=pc+2
        elseif op == _VM_OP.CALL then
            local func = pop()
            local nargs = bytecode[pc+1]
            local args = {}
            for i=1,nargs do args[nargs-i+1] = pop() end
            local ret = func(table.unpack(args))
            push(ret)
            pc = pc + 2
        elseif op == _VM_OP.RET then return pop()
        elseif op == _VM_OP.JMP then pc = bytecode[pc+1]
        elseif op == _VM_OP.JZ then
            if pop() == 0 then pc = bytecode[pc+1] else pc = pc + 2 end
        elseif op == _VM_OP.NEWT then push({}); pc=pc+1
        elseif op == _VM_OP.SETT then local key=pop(); local val=pop(); local tbl=pop(); tbl[key]=val; pc=pc+1
        elseif op == _VM_OP.GETT then local key=pop(); local tbl=pop(); push(tbl[key]); pc=pc+1
        elseif op == _VM_OP.STOREG then regs[bytecode[pc+1]] = pop(); pc=pc+2
        elseif op == _VM_OP.LOADG then push(regs[bytecode[pc+1]]); pc=pc+2
        else pc = pc + 1 end
    end
end

local _OBFUSCATOR_SOURCE = [[
local function RonObfuscator(code, options)
    options = options or {}
    local level = math.min(options.level or 10, 10)

    -- Extraer literales de cadena (varios tipos)
    local strings = {}
    local idx = 0
    local function capture(s)
        idx = idx + 1
        strings[idx] = s
        return "\0RONSTR" .. idx .. "\0"
    end
    local stripped = code:gsub('"(.-[^\\])"', capture)
    stripped = stripped:gsub("'(.-[^\\])'", capture)
    stripped = stripped:gsub('%[%[(.-)%]%]', capture)

    local enc_strings = {}
    for i, s in ipairs(strings) do
        enc_strings[i] = _encrypt_string(s)
    end


    local decoder = "local __DEC=function(s) "
    decoder = decoder .. "local b64='" .. _B64_ALPHABET .. "';"
    decoder = decoder .. "local rev={} for i=1,#b64 do rev[b64:sub(i,i)]=i-1 end;"
    decoder = decoder .. "s=s:gsub('=+$','') local data={};"
    decoder = decoder .. "for i=1,#s,4 do local d1=rev[s:sub(i,i)]or 0;local d2=rev[s:sub(i+1,i+1)]or 0;local d3=rev[s:sub(i+2,i+2)]or 0;local d4=rev[s:sub(i+3,i+3)]or 0;local n=d1*262144+d2*4096+d3*64+d4;local c1=math.floor(n/65536)%256;local c2=math.floor(n/256)%256;local c3=n%256;data[#data+1]=string.char(c1);if s:sub(i+2,i+2)~='=' then data[#data+1]=string.char(c2) end;if s:sub(i+3,i+3)~='=' then data[#data+1]=string.char(c3) end end;"
    decoder = decoder .. "local dec=table.concat(data);"
    decoder = decoder .. "local function xor(str,key) local r={} for i=1,#str do r[i]=string.char(str:byte(i)~key:byte((i-1)%#key+1)) end return table.concat(r) end;"
    decoder = decoder .. "dec=xor(dec,'" .. _KEY3 .. "');dec=xor(dec,'" .. _KEY2 .. "');dec=xor(dec,'" .. _KEY1 .. "');"
    decoder = decoder .. "local function rot47(s) local r={} for i=1,#s do local b=s:byte(i) if b>=33 and b<=126 then r[i]=string.char(33+((b-33+47)%94)) else r[i]=s:sub(i,i) end end return table.concat(r) end;"
    decoder = decoder .. "local function rot5(s) local r={} for i=1,#s do local b=s:byte(i) if b>=48 and b<=57 then r[i]=string.char(((b-48+5)%10)+48) else r[i]=s:sub(i,i) end end return table.concat(r) end;"
    decoder = decoder .. "local function rot13(s) local r={} for i=1,#s do local b=s:byte(i) if b>=65 and b<=90 then r[i]=string.char(((b-65+13)%26)+65) elseif b>=97 and b<=122 then r[i]=string.char(((b-97+13)%26)+97) else r[i]=s:sub(i,i) end end return table.concat(r) end;"
    decoder = decoder .. "dec=rot47(dec);dec=rot5(dec);dec=rot13(dec);"

    decoder = decoder .. "local sub_map={"
    for k,v in pairs(_SUBSTITUTE_ALPHABET) do
        decoder = decoder .. "['" .. v .. "']='" .. k .. "',"
    end
    decoder = decoder .. "};"
    decoder = decoder .. "local res2={} for i=1,#dec do local c=dec:sub(i,i); res2[i]=sub_map[c] or c end; dec=table.concat(res2);"
    decoder = decoder .. "return dec end;"
    decoder = decoder .. "local __STR={}"
    for i, enc in ipairs(enc_strings) do
        decoder = decoder .. " __STR[" .. i .. "]=[[" .. enc .. "]];"
    end
    decoder = decoder .. " for k,v in pairs(__STR) do __STR[k]=__DEC(v) end;"

    local final_code = stripped
    for i = 1, #strings do
        final_code = final_code:gsub("\0RONSTR" .. i .. "\0", "__STR[" .. i .. "]")
    end

    local junk = ""
    local rng = _LCG(os and os.time and os.time() or 0)
    for _ = 1, 150 + level * 80 do
        local t = rng() % 7
        if t == 0 then
            local v = rng() % 99999
            junk = junk .. "local _r" .. v .. "=" .. v .. ";"
        elseif t == 1 then
            local limit = (rng() % 20) + 1
            junk = junk .. "for _=1," .. limit .. " do local x=math.sin(_) end;"
        elseif t == 2 then
            local reps = (rng() % 10) + 1
            junk = junk .. "for _=1," .. reps .. " do local _=0; for i=1,10 do _=_+i end end;"
        elseif t == 3 then
            local n1 = rng() % 1000
            local n2 = rng() % 1000
            junk = junk .. "local _f" .. n1 .. "=function(x)return x*" .. n1 .. "+" .. n2 .. " end; _f" .. n1 .. "(" .. n2 .. ");"
        elseif t == 4 then
            local a = rng() % 100
            local b = rng() % 100
            local c = rng() % 999
            junk = junk .. "local _t" .. c .. "={" .. a .. "," .. b .. "};"
        elseif t == 5 then
            junk = junk .. "if math.random()>2 then local _=0; for i=1,10 do _=_+i end end;"
        else
            junk = junk .. "local _=os and os.clock and os.clock() or 0;"
        end
    end

    local header = [[
local function __RON_GUARD()
    if debug and debug.getinfo then
        local info = debug.getinfo(1,'S')
        if info and not info.short_src:match("ron") then
            local _c=0; for _=1,1e5 do _c=_c+1 end
        end
    end
    if getfenv and getfenv() ~= _G then while true do end end
    local t0 = os and os.clock and os.clock() or 0
    if t0 > 0 and os.clock() - t0 > 2 then while true do end end
end; __RON_GUARD()
]]

    local out = header .. "\n" .. junk .. "\n" .. decoder .. "\n" .. final_code

    if level >= 7 then
        local stmts = {}
        for stmt in out:gmatch("[^;\n]+") do
            local trimmed = stmt:match("^%s*(.-)%s*$")
            if trimmed ~= "" then stmts[#stmts+1] = trimmed end
        end
        if #stmts > 1 then
            local flat = "local __ST=0; while true do "
            for i, stmt in ipairs(stmts) do
                flat = flat .. "if __ST==" .. (i-1) .. " then " .. stmt .. " __ST=" .. i .. " end; "
            end
            flat = flat .. "if __ST==" .. #stmts .. " then break end end"
            out = flat
        end
    end


    return "return (function() " .. out .. " end)()"
end
]]


local _ENCRYPTED_SOURCE = _encrypt_string(_OBFUSCATOR_SOURCE)


local _core_bytecode = {}
local function _emit(op, arg)
    _core_bytecode[#_core_bytecode + 1] = op
    if arg then _core_bytecode[#_core_bytecode + 1] = arg end
end
for i = 1, 3000 do
    _emit(_VM_OP.NOP)
end
-- Lógica real
_emit(_VM_OP.LOADK, 1)  -- push _ENCRYPTED_SOURCE
_emit(_VM_OP.LOADK, 2)  -- push _decrypt_string
_emit(_VM_OP.CALL, 1)   -- _decrypt_string(source)
_emit(_VM_OP.LOADK, 3)  -- push loadstring
_emit(_VM_OP.CALL, 1)   -- loadstring(decrypted)
_emit(_VM_OP.CALL, 0)   -- ejecutar para definir RonObfuscator
_emit(_VM_OP.LOADK, 4)  -- push "RonObfuscator"
_emit(_VM_OP.LOADK, 5)  -- push _G
_emit(_VM_OP.GETT)      -- _G["RonObfuscator"]
_emit(_VM_OP.RET)
_emit(_VM_OP.HALT)

-- Constantes para la VM
local _vm_constants = {
    _ENCRYPTED_SOURCE,
    _decrypt_string,
    loadstring,
    "RonObfuscator",
    _G
}

local RonObfuscator = _vm_exec(_core_bytecode, _vm_constants, _G)
if type(RonObfuscator) ~= "function" then
    while true do end
end

local _dummy_calc = 0
for i = 1, 200000 do
    _dummy_calc = _dummy_calc + math.sin(i*0.001) * math.cos(i*0.002)
end

local _extra_table = {}
for i = 1, 3000 do
    _extra_table[i] = _PRIME_LIST[(i * _FIBONACCI[(i%10000)+1]) % #_PRIME_LIST + 1] + _RANDOM_TABLE_A[(i%5000)+1]
end
table.sort(_extra_table)

if false then while true do end end

return RonObfuscator
