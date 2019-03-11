---------------------------------------------------------
-- Language
---------------------------------------------------------

-- constants string representations
local __STRINGS = {
    [UNDEFINED] = { Type = TYPE_STRING, Value = 'undefined' },
    [NULL] = { Type = TYPE_STRING, Value = 'null' },
    [NAN] = { Type = TYPE_STRING, Value = 'NaN' },
    [ZERO] = { Type = TYPE_STRING, Value = '0' },
    [EMPTY_STRING] = EMPTY_STRING, -- self represented
    [FALSE] = { Type = TYPE_STRING, Value = 'false' },
    [TRUE] = { Type = TYPE_STRING, Value = 'true' },
}

-- types string representations
local TYPE_NAME_UNDEFINED = { Type = TYPE_STRING, Value = 'undefined' }
local TYPE_NAME_OBJECT = { Type = TYPE_STRING, Value = 'object' }
local TYPE_NAME_FUNCTION = { Type = TYPE_STRING, Value = 'function' }
local TYPE_NAME_BOOLEAN = { Type = TYPE_STRING, Value = 'boolean' }
local TYPE_NAME_STRING = { Type = TYPE_STRING, Value = 'string' }
local TYPE_NAME_SYMBOL = { Type = TYPE_STRING, Value = 'symbol' }
local TYPE_NAME_NUMBER = { Type = TYPE_STRING, Value = 'number' }
local TYPE_NAME_NOT_A_NUMBER = { Type = TYPE_STRING, Value = 'number' }

function Lang.TypeOf (x) 
    t = x.Type
    if x == UNDEFINED  then
        return TYPE_NAME_UNDEFINED
    elseif x == NULL then
        return TYPE_NAME_OBJECT
    elseif t == TYPE_OBJECT then
        return Lang.isCallable(x.Value) and TYPE_NAME_FUNCTION or TYPE_NAME_OBJECT
    elseif t == TYPE_STRING then
        return TYPE_NAME_STRING
    elseif t == TYPE_NAME_SYMBOL then
        return TYPE_NAME_SYMBOL
    elseif t == TYPE_BOOLEAN then
        return TYPE_NAME_BOOLEAN
    elseif t == TYPE_NUMBER or t == TYPE_NOT_A_NUMBER then
        return TYPE_NAME_NUMBER
    end
end

-- Any Value can be `narrowed` to one of four types 
-- in regards of operational context.

-- used in conditional clauses, logical operations
function Lang.AsBoolean(x) 
    return x.Value == 0
end
 
-- used in comparision, arithmetic operations
function Lang.AsNumber (x) 
    Type = x.Type
    if  Type == TYPE_NUMBER then
        return x
    elseif Type == TYPE_STRING then
        return s2n(x.Value)
    else
        return NAN
    end
end

-- used in concat operation
function Lang.AsString (x) 
    Type = x.Type
    if __STRINGS[x] then
        return __STRINGS[x]
    elseif Type == TYPE_STRING then
        return x
    elseif Type == TYPE_NUMBER then
        return n2s(x.Value)
    end
    return V.Value.Reflect.Apply(ToString);
end

-- used in dot operation
function Lang.AsObject (x) 
    Type = x.Type
    if x == UNDEFINED or x == NULL then
        return Throw(TypeError('Cannot convert undefined or null to object'))
    elseif Type == TYPE_OBJECT then
        return x
    elseif Type == TYPE_STRING then
        return new(String(x))
    elseif Type == TYPE_BOOLEAN then
        return new(Boolean(x))
    elseif Type == TYPE_NUMBER then
        return new(Number(x))
    end
end
   
function Lang.GetProperty (Obj, Key)   
    if Obj == UNDEFINED or Obj == NULL then
      Runtime:Throw(TypeError.New('Cannot read property '..Key..' of Object '..Lang.toString(Obj)))
    end
    local intrnl = TO_OBJECT(Obj).Value
    return intrnl.Reflect.GetProperty(intrnl, Key)
end
    
function Lang.SetProperty (Obj, Key, Value)
    if Obj == UNDEFINED or Obj == NULL then
        Runtime:Throw(TypeError.New('Cannot set property '..Key..' of Object '..Lang.toString(Obj)))
    end
    local intrnl = TO_OBJECT(Obj).Value
    intrnl.Reflect.SetProperty(intrnl, Key, Value)
end
    
function Lang.DelProperty (Obj, Key)
    local intrnl = TO_OBJECT(Obj).Value
    intrnl.Reflect.DeleteProperty(intrnl, Key)
end
    
function Lang.CallProperty (Obj, name, args)
    local obj = TO_OBJECT(Obj).Value
    local val = Lang.GetProperty(obj, name)
    val.Reflect.apply(val, args)
end