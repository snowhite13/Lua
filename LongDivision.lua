--[[
Author     Theo M. Quelch
Date       24/09/28
Version    1.1.0

Console application that emulates long-division procedure.
]]



local function prompt(message, read)
    io.write(message)

    return io.read(read)
end

local function getSign(number)
    if number == 0 then
        return 1
    end

    return number / math.abs(number)
end

local function isInArray(array, value)
    for index = 1, #array do
        if array[index] == value then
            return true
        end
    end
    
    return false
end

local function arrayToNumber(numbers, asFraction)
    local count = #numbers
    local number = 0
    
    for index = 1, count do
        number = number + numbers[index] * 10 ^ (count - index)
    end
    
    return number / 10 ^ (asFraction and count or 0)
end

local function getDigitCount(number)
    number = math.abs(number)

    if number < 10 then
        return 1
    end
	
	return math.floor(math.log(number, 10)) + 1
end

local function getSubdividend(dividend, divisor)
    local digitCount = getDigitCount(dividend)
  
    for exponent = digitCount, 1, -1 do
        local peek = math.floor(dividend / 10 ^ (exponent - 1))
        
        if peek >= divisor then
            return peek, digitCount - exponent + 1
        end
    end
    
    return 0
end

local function _longDivide(dividend, divisor, whole, fraction, seen)
    if dividend == 0 then
        return
    end
    
    local dividendLength = getDigitCount(dividend)
    local subdividend, subdividendLength = getSubdividend(dividend, divisor)

    local remaining = subdividend
    local count = 0
    
    while remaining >= divisor do
        remaining = remaining - divisor
        
        count = count + 1
    end
    
    if count > 0 then
        table.insert(whole, count)
        
        local remainingDividend     = dividend % 10 * (dividendLength - subdividendLength)
        local subdividendDifference = subdividend - divisor * count
        local newDividend           = subdividendDifference * (remainingDividend == 0 and 1 or 10) + remainingDividend
        
        _longDivide(
            newDividend, 
            divisor, 
            whole, fraction, seen
        )
    else
        if not isInArray(seen, dividend) then
            table.insert(seen, dividend)
        else
            return
        end
      
        while dividend < divisor do
            dividend = dividend * 10
        end

        _longDivide(
            dividend, 
            divisor, 
            fraction, fraction, seen
        )
    end
end

local function longDivide(dividend, divisor)
    if divisor == 0 then
        return nil
    end

    local whole = {}
    local fraction = {}
    local seen = {}

    _longDivide(
        math.abs(dividend), 
        math.abs(divisor), 
        whole, fraction, seen
    )

    local sign = getSign(dividend) * getSign(divisor)
    local quotient = arrayToNumber(whole, false) + arrayToNumber(fraction, true)
  
    return sign * quotient
end


local dividend = tonumber(prompt("Dividend: ", "*n"))
local divisor = tonumber(prompt("Divisor: ", "*n"))

print("\nQuotient: " .. longDivide(dividend, divisor))
