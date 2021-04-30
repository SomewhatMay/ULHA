--=============================================================================--
--[[
    File Name:              UHash.lua
    Package Name:           Uhash
    Global Table Name:      Uhash

    Project:    Simple Hashing algorithm for Lua
    Mantainers: SomewhatMay

    Github Link: https://www.github.com/


    Required Libraries:
        + BigNumModule.lua

    --=====--

    License:

    Copyright 2021 SomewhatMay.

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall
    be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    --=====--

]]--
--=============================================================================--


--// Importing Required Libraries \\--

package.path = "/usr/local/share/lua/5.2/?.lua;/usr/local/share/lua/5.2/?/init.lua;/usr/local/lib/lua/5.2/?.lua;/usr/local/lib/lua/5.2/?/init.lua;./?.lua;/usr/local/Documents/LuaProjects/?.lua"
require("BigNumModule")

--// Hash Settings \\--

Uhash = {}
Uhash.hashSettings = {
    Data = "Hello, World!";
    HashLength = 64;
    LengthIgnore = 8;
    PrimeTableLength = 64;
    UJumbleLength = 31;
    MainPrimeNumber = 31;
}

--============================================================================--
--======= Do not edit past this line unless you know what you're doing =======--
--============================================================================--


-- // Writing variables \\--

local convStr = Uhash.hashSettings.Data or "Hello, World!"
local ujumbleLength = Uhash.hashSettings.UJumbleLength or 31
local g = Uhash.hashSettings.MainPrimeNumber or 31
local primeTLength = Uhash.hashSettings.PrimeTableLength or 64
local padLength = Uhash.hashSettings.HashLength or 64
local lengthIgnore = Uhash.hashSettings.LengthIgnore or 8

--// Reserving Memory For Frequent Functions \\--

local floor = math.floor
local ceil = math.ceil
local sub = string.sub
local byte = string.byte
local find = string.find
local insert = table.insert
local remove = table.remove

--// Main Functions \\--

local function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B), (IN%B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end

local function pad(str, desLen, lenLen)
    str = tostring(str)
    desLen = math.ceil((#str+1)/desLen)*desLen

    local realSll = ""
    local finish = ""
    local strLen = #str

    for i=1, desLen - #str - lenLen do
        str = str.."0"
    end

    for i=1, lenLen - #tostring(strLen) do
        realSll = realSll.."0"
    end

    realSll = realSll..tostring(strLen)

    finish = str..realSll

    return finish
end

local function getDec(num)
    num = tostring(num)
    local str, fin = string.find(num, "%.")
    num = string.sub(num, str+1, #num)

    return num
end

local function shift(str)
    return string.sub(str, #str, #str)..string.sub(str, 1, #str-1)
end

local function addCUBRand(num1, num2, num3)
    num1, num2, num3 = num1 + 1 or 1, num2 + 1 or 1, num3 + 1 or 1
    local num = num1 * num2 * num3
    local num2 = (num1 * num3 - 1) * num2
    num = num%primeTLength
    local p = Uhash.First512Primes[tostring(num)]

    if not p then error("No prime value on index: "..num) end

    num2 = num2 * (tonumber(getDec(p^(1/3))))
    num2 = num2%10

    return num
end

local function ujumble(str)
    local finish = string.sub(str, 1, 1)

    for i=2, #str-1, 1 do
        local p, c, n = tonumber(string.sub(str, i-1, i-1)), tonumber(string.sub(str, i, i)), tonumber(string.sub(str, i+1, i+1))
        local add = addCUBRand(g * i + c, p, n)
        finish = finish..add
    end

    finish = finish..string.sub(str, #str, #str)

    return finish
end

local function reversePad(str, desLen)
    if #str == desLen then return str end

    local sets = {}
    local finish

    for i=1, #str, desLen do
        local cb = string.sub(str, i, i+desLen-1)
        if #cb == desLen then else
            cb = pad(cb, desLen, 1)
        end
        table.insert(sets, cb)
    end

    local cur = sets[1]
    local _index = 1

    while cur do
        if not finish then
            finish = cur
        else
            local _finish = ""

            for i=1, desLen, 1 do
                local c1 = string.sub(finish, i, i)
                local c2 = string.sub(cur, i, i)

                local r = addCUBRand(_index * i + c1, _index * i + c2, 1)

                _finish = _finish..r
            end

            --print("", "", _index..": ".._finish)

            finish = _finish
        end

        table.remove(sets, 1)

        cur = sets[1]
        _index = _index + 1
    end

    return finish
end

--========================--
--// MAIN HASH FUNCTION \\--
--========================--

function Uhash:hash(str, salt)
    convStr = Uhash.hashSettings.Data or "Hello, World!"
    ujumbleLength = Uhash.hashSettings.UJumbleLength or 31
    g = Uhash.hashSettings.MainPrimeNumber or 31
    primeTLength = Uhash.hashSettings.PrimeTableLength or 64
    padLength = Uhash.hashSettings.HashLength or 64
    lengthIgnore = Uhash.hashSettings.LengthIgnore or 8

    str = str or Uhash.hashSettings.Data
    salt = salt or ""
    str = str..salt

    local _hash = BigNum.new(1)
    str = pad(str, padLength, lengthIgnore)

    for i=1, #str, 1 do
        _hash = g * _hash + math.floor(string.byte(string.sub(str, i, i)) ^ 3 + .5)
    end

    _hash = pad(_hash, padLength, lengthIgnore)
    local _hash2 = _hash
    --print("0: ".._hash2)

    for i=1, ujumbleLength, 1 do
        _hash2 = ujumble(_hash2)
        _hash2 = shift(_hash2)
        _hash2 = reversePad(_hash2, padLength)
        --print("", i..": ".._hash2)
    end

    _hash2 = reversePad(_hash2, padLength)

    return _hash2
end

Uhash.First512Primes = {
    ["0"] = 2,
    ["1"] = 3,
    ["2"] = 5,
    ["3"] = 7,
    ["4"] = 11,
    ["5"] = 13,
    ["6"] = 17,
    ["7"] = 19,
    ["8"] = 23,
    ["9"] = 29,
    ["10"] = 31,
    ["11"] = 37,
    ["12"] = 41,
    ["13"] = 43,
    ["14"] = 47,
    ["15"] = 53,
    ["16"] = 59,
    ["17"] = 61,
    ["18"] = 67,
    ["19"] = 71,
    ["20"] = 73,
    ["21"] = 79,
    ["22"] = 83,
    ["23"] = 89,
    ["24"] = 97,
    ["25"] = 101,
    ["26"] = 103,
    ["27"] = 107,
    ["28"] = 109,
    ["29"] = 113,
    ["30"] = 127,
    ["31"] = 131,
    ["32"] = 137,
    ["33"] = 139,
    ["34"] = 149,
    ["35"] = 151,
    ["36"] = 157,
    ["37"] = 163,
    ["38"] = 167,
    ["39"] = 173,
    ["40"] = 179,
    ["41"] = 181,
    ["42"] = 191,
    ["43"] = 193,
    ["44"] = 197,
    ["45"] = 199,
    ["46"] = 211,
    ["47"] = 223,
    ["48"] = 227,
    ["49"] = 229,
    ["50"] = 233,
    ["51"] = 239,
    ["52"] = 241,
    ["53"] = 251,
    ["54"] = 257,
    ["55"] = 263,
    ["56"] = 269,
    ["57"] = 271,
    ["58"] = 277,
    ["59"] = 281,
    ["60"] = 283,
    ["61"] = 293,
    ["62"] = 307,
    ["63"] = 311,
    ["64"] = 313,
    ["65"] = 317,
    ["66"] = 331,
    ["67"] = 337,
    ["68"] = 347,
    ["69"] = 349,
    ["70"] = 353,
    ["71"] = 359,
    ["72"] = 367,
    ["73"] = 373,
    ["74"] = 379,
    ["75"] = 383,
    ["76"] = 389,
    ["77"] = 397,
    ["78"] = 401,
    ["79"] = 409,
    ["80"] = 419,
    ["81"] = 421,
    ["82"] = 431,
    ["83"] = 433,
    ["84"] = 439,
    ["85"] = 443,
    ["86"] = 449,
    ["87"] = 457,
    ["88"] = 461,
    ["89"] = 463,
    ["90"] = 467,
    ["91"] = 479,
    ["92"] = 487,
    ["93"] = 491,
    ["94"] = 499,
    ["95"] = 503,
    ["96"] = 509,
    ["97"] = 521,
    ["98"] = 523,
    ["99"] = 541,
    ["100"] = 547,
    ["101"] = 557,
    ["102"] = 563,
    ["103"] = 569,
    ["104"] = 571,
    ["105"] = 577,
    ["106"] = 587,
    ["107"] = 593,
    ["108"] = 599,
    ["109"] = 601,
    ["110"] = 607,
    ["111"] = 613,
    ["112"] = 617,
    ["113"] = 619,
    ["114"] = 631,
    ["115"] = 641,
    ["116"] = 643,
    ["117"] = 647,
    ["118"] = 653,
    ["119"] = 659,
    ["120"] = 661,
    ["121"] = 673,
    ["122"] = 677,
    ["123"] = 683,
    ["124"] = 691,
    ["125"] = 701,
    ["126"] = 709,
    ["127"] = 719,
    ["128"] = 727,
    ["129"] = 733,
    ["130"] = 739,
    ["131"] = 743,
    ["132"] = 751,
    ["133"] = 757,
    ["134"] = 761,
    ["135"] = 769,
    ["136"] = 773,
    ["137"] = 787,
    ["138"] = 797,
    ["139"] = 809,
    ["140"] = 811,
    ["141"] = 821,
    ["142"] = 823,
    ["143"] = 827,
    ["144"] = 829,
    ["145"] = 839,
    ["146"] = 853,
    ["147"] = 857,
    ["148"] = 859,
    ["149"] = 863,
    ["150"] = 877,
    ["151"] = 881,
    ["152"] = 883,
    ["153"] = 887,
    ["154"] = 907,
    ["155"] = 911,
    ["156"] = 919,
    ["157"] = 929,
    ["158"] = 937,
    ["159"] = 941,
    ["160"] = 947,
    ["161"] = 953,
    ["162"] = 967,
    ["163"] = 971,
    ["164"] = 977,
    ["165"] = 983,
    ["166"] = 991,
    ["167"] = 997,
    ["168"] = 1009,
    ["169"] = 1013,
    ["170"] = 1019,
    ["171"] = 1021,
    ["172"] = 1031,
    ["173"] = 1033,
    ["174"] = 1039,
    ["175"] = 1049,
    ["176"] = 1051,
    ["177"] = 1061,
    ["178"] = 1063,
    ["179"] = 1069,
    ["180"] = 1087,
    ["181"] = 1091,
    ["182"] = 1093,
    ["183"] = 1097,
    ["184"] = 1103,
    ["185"] = 1109,
    ["186"] = 1117,
    ["187"] = 1123,
    ["188"] = 1129,
    ["189"] = 1151,
    ["190"] = 1153,
    ["191"] = 1163,
    ["192"] = 1171,
    ["193"] = 1181,
    ["194"] = 1187,
    ["195"] = 1193,
    ["196"] = 1201,
    ["197"] = 1213,
    ["198"] = 1217,
    ["199"] = 1223,
    ["200"] = 1229,
    ["201"] = 1231,
    ["202"] = 1237,
    ["203"] = 1249,
    ["204"] = 1259,
    ["205"] = 1277,
    ["206"] = 1279,
    ["207"] = 1283,
    ["208"] = 1289,
    ["209"] = 1291,
    ["210"] = 1297,
    ["211"] = 1301,
    ["212"] = 1303,
    ["213"] = 1307,
    ["214"] = 1319,
    ["215"] = 1321,
    ["216"] = 1327,
    ["217"] = 1361,
    ["218"] = 1367,
    ["219"] = 1373,
    ["220"] = 1381,
    ["221"] = 1399,
    ["222"] = 1409,
    ["223"] = 1423,
    ["224"] = 1427,
    ["225"] = 1429,
    ["226"] = 1433,
    ["227"] = 1439,
    ["228"] = 1447,
    ["229"] = 1451,
    ["230"] = 1453,
    ["231"] = 1459,
    ["232"] = 1471,
    ["233"] = 1481,
    ["234"] = 1483,
    ["235"] = 1487,
    ["236"] = 1489,
    ["237"] = 1493,
    ["238"] = 1499,
    ["239"] = 1511,
    ["240"] = 1523,
    ["241"] = 1531,
    ["242"] = 1543,
    ["243"] = 1549,
    ["244"] = 1553,
    ["245"] = 1559,
    ["246"] = 1567,
    ["247"] = 1571,
    ["248"] = 1579,
    ["249"] = 1583,
    ["250"] = 1597,
    ["251"] = 1601,
    ["252"] = 1607,
    ["253"] = 1609,
    ["254"] = 1613,
    ["255"] = 1619,
    ["256"] = 1621,
    ["257"] = 1627,
    ["258"] = 1637,
    ["259"] = 1657,
    ["260"] = 1663,
    ["261"] = 1667,
    ["262"] = 1669,
    ["263"] = 1693,
    ["264"] = 1697,
    ["265"] = 1699,
    ["266"] = 1709,
    ["267"] = 1721,
    ["268"] = 1723,
    ["269"] = 1733,
    ["270"] = 1741,
    ["271"] = 1747,
    ["272"] = 1753,
    ["273"] = 1759,
    ["274"] = 1777,
    ["275"] = 1783,
    ["276"] = 1787,
    ["277"] = 1789,
    ["278"] = 1801,
    ["279"] = 1811,
    ["280"] = 1823,
    ["281"] = 1831,
    ["282"] = 1847,
    ["283"] = 1861,
    ["284"] = 1867,
    ["285"] = 1871,
    ["286"] = 1873,
    ["287"] = 1877,
    ["288"] = 1879,
    ["289"] = 1889,
    ["290"] = 1901,
    ["291"] = 1907,
    ["292"] = 1913,
    ["293"] = 1931,
    ["294"] = 1933,
    ["295"] = 1949,
    ["296"] = 1951,
    ["297"] = 1973,
    ["298"] = 1979,
    ["299"] = 1987,
    ["300"] = 1993,
    ["301"] = 1997,
    ["302"] = 1999,
    ["303"] = 2003,
    ["304"] = 2011,
    ["305"] = 2017,
    ["306"] = 2027,
    ["307"] = 2029,
    ["308"] = 2039,
    ["309"] = 2053,
    ["310"] = 2063,
    ["311"] = 2069,
    ["312"] = 2081,
    ["313"] = 2083,
    ["314"] = 2087,
    ["315"] = 2089,
    ["316"] = 2099,
    ["317"] = 2111,
    ["318"] = 2113,
    ["319"] = 2129,
    ["320"] = 2131,
    ["321"] = 2137,
    ["322"] = 2141,
    ["323"] = 2143,
    ["324"] = 2153,
    ["325"] = 2161,
    ["326"] = 2179,
    ["327"] = 2203,
    ["328"] = 2207,
    ["329"] = 2213,
    ["330"] = 2221,
    ["331"] = 2237,
    ["332"] = 2239,
    ["333"] = 2243,
    ["334"] = 2251,
    ["335"] = 2267,
    ["336"] = 2269,
    ["337"] = 2273,
    ["338"] = 2281,
    ["339"] = 2287,
    ["340"] = 2293,
    ["341"] = 2297,
    ["342"] = 2309,
    ["343"] = 2311,
    ["344"] = 2333,
    ["345"] = 2339,
    ["346"] = 2341,
    ["347"] = 2347,
    ["348"] = 2351,
    ["349"] = 2357,
    ["350"] = 2371,
    ["351"] = 2377,
    ["352"] = 2381,
    ["353"] = 2383,
    ["354"] = 2389,
    ["355"] = 2393,
    ["356"] = 2399,
    ["357"] = 2411,
    ["358"] = 2417,
    ["359"] = 2423,
    ["360"] = 2437,
    ["361"] = 2441,
    ["362"] = 2447,
    ["363"] = 2459,
    ["364"] = 2467,
    ["365"] = 2473,
    ["366"] = 2477,
    ["367"] = 2503,
    ["368"] = 2521,
    ["369"] = 2531,
    ["370"] = 2539,
    ["371"] = 2543,
    ["372"] = 2549,
    ["373"] = 2551,
    ["374"] = 2557,
    ["375"] = 2579,
    ["376"] = 2591,
    ["377"] = 2593,
    ["378"] = 2609,
    ["379"] = 2617,
    ["380"] = 2621,
    ["381"] = 2633,
    ["382"] = 2647,
    ["383"] = 2657,
    ["384"] = 2659,
    ["385"] = 2663,
    ["386"] = 2671,
    ["387"] = 2677,
    ["388"] = 2683,
    ["389"] = 2687,
    ["390"] = 2689,
    ["391"] = 2693,
    ["392"] = 2699,
    ["393"] = 2707,
    ["394"] = 2711,
    ["395"] = 2713,
    ["396"] = 2719,
    ["397"] = 2729,
    ["398"] = 2731,
    ["399"] = 2741,
    ["400"] = 2749,
    ["401"] = 2753,
    ["402"] = 2767,
    ["403"] = 2777,
    ["404"] = 2789,
    ["405"] = 2791,
    ["406"] = 2797,
    ["407"] = 2801,
    ["408"] = 2803,
    ["409"] = 2819,
    ["410"] = 2833,
    ["411"] = 2837,
    ["412"] = 2843,
    ["413"] = 2851,
    ["414"] = 2857,
    ["415"] = 2861,
    ["416"] = 2879,
    ["417"] = 2887,
    ["418"] = 2897,
    ["419"] = 2903,
    ["420"] = 2909,
    ["421"] = 2917,
    ["422"] = 2927,
    ["423"] = 2939,
    ["424"] = 2953,
    ["425"] = 2957,
    ["426"] = 2963,
    ["427"] = 2969,
    ["428"] = 2971,
    ["429"] = 2999,
    ["430"] = 3001,
    ["431"] = 3011,
    ["432"] = 3019,
    ["433"] = 3023,
    ["434"] = 3037,
    ["435"] = 3041,
    ["436"] = 3049,
    ["437"] = 3061,
    ["438"] = 3067,
    ["439"] = 3079,
    ["440"] = 3083,
    ["441"] = 3089,
    ["442"] = 3109,
    ["443"] = 3119,
    ["444"] = 3121,
    ["445"] = 3137,
    ["446"] = 3163,
    ["447"] = 3167,
    ["448"] = 3169,
    ["449"] = 3181,
    ["450"] = 3187,
    ["451"] = 3191,
    ["452"] = 3203,
    ["453"] = 3209,
    ["454"] = 3217,
    ["455"] = 3221,
    ["456"] = 3229,
    ["457"] = 3251,
    ["458"] = 3253,
    ["459"] = 3257,
    ["460"] = 3259,
    ["461"] = 3271,
    ["462"] = 3299,
    ["463"] = 3301,
    ["464"] = 3307,
    ["465"] = 3313,
    ["466"] = 3319,
    ["467"] = 3323,
    ["468"] = 3329,
    ["469"] = 3331,
    ["470"] = 3343,
    ["471"] = 3347,
    ["472"] = 3359,
    ["473"] = 3361,
    ["474"] = 3371,
    ["475"] = 3373,
    ["476"] = 3389,
    ["477"] = 3391,
    ["478"] = 3407,
    ["479"] = 3413,
    ["480"] = 3433,
    ["481"] = 3449,
    ["482"] = 3457,
    ["483"] = 3461,
    ["484"] = 3463,
    ["485"] = 3467,
    ["486"] = 3469,
    ["487"] = 3491,
    ["488"] = 3499,
    ["489"] = 3511,
    ["490"] = 3517,
    ["491"] = 3527,
    ["492"] = 3529,
    ["493"] = 3533,
    ["494"] = 3539,
    ["495"] = 3541,
    ["496"] = 3547,
    ["497"] = 3557,
    ["498"] = 3559,
    ["499"] = 3571,
    ["500"] = 3581,
    ["501"] = 3583,
    ["502"] = 3593,
    ["503"] = 3607,
    ["504"] = 3613,
    ["505"] = 3617,
    ["506"] = 3623,
    ["507"] = 3631,
    ["508"] = 3637,
    ["509"] = 3643,
    ["510"] = 3659,
    ["511"] = 3671,
    ["512"] = 3673
}



--// Debugging | Tests \\--

--local _hash = Uhash:hash("Hello, World!")
--print(_hash)
--io.read()

return Uhash
