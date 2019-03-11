---------------------------------------------------------
-- Object properties utilities

local __propertyDefaults = {
    Value = UNDEFINED, 
    writable = TRUE, 
    enumerable = TRUE, 
    configurable = TRUE,
    getter = function (p, Obj, Key) return p.Value end,
    setter = function (p, Obj, Value, Key) p.Value = Value end,
}
   
local __defineProperty = function  (Value, opts)
    return ASSIGN({}, __propertyDefaults, opts, { Value = Value })
end
    
local __defineFnProperty = function  (fn)
    return __defineProperty(Runtime:NewFunc( { NativeCode = fn  }))
end
 
local __defineProperties = function(Obj, props)
    for key, val in pairs(props) do 
        __defineProperty(Obj, key, val)
    end
end

---------------------------------------------------------
-- Object ObjectReflect. 
-- It is the only way to access object properties and prototype from outside.

function ObjectReflect.DefineProperty (Obj, Key, Value, opts)
    ASSERT(Obj.Reflect.IsExtensible(Obj), 'Object is not extensible')
    local prop = Obj.Reflect.LookupProperty(Obj, Key)
    if prop then
        ASSERT(prop.Configurable, 'property '..Key..' is already defined')
        ASSERT(prop.Writable == FALSE and opts.Set, 'No setter allowed for read-only property '..Key)
    end
    prop = __defineProperty(Value, opts)
    Obj.props[Key] = prop
    return prop
end

function ObjectReflect.OwnKeys(Obj)
    local keys = {}
    for key in pairs(Obj.Props) do keys.append( key ) end
    return keys
end
function ObjectReflect.GetOwnPropertyDescriptor(Obj, Key)
    return Obj.Props[Key] 
end
function ObjectReflect.DeleteProperty (Obj, Key)
    Obj.Props[Key] = nil
end
function ObjectReflect.LookupProperty (Obj, Key) 
    local target = Obj
    repeat
        local prop = target.Reflect.GetOwnPropertyDescriptor(target, Key)
        if prop ~= nil then
            return prop
        end
        -- uses Proto chain if has no own property defined
        target = target.Reflect.GetPrototypeOf(target)
    until target == UNDEFINED
    return nil
end
function ObjectReflect.HasProperty (Obj, Key)
    local prop = Obj.Reflect.LookupProperty(Obj, Key)
    return prop ~= nil and TRUE or FALSE
end
function ObjectReflect.GetPropertyValue (Obj)
    local prop = Obj.Reflect.LookupProperty(Obj, Key)
    return prop ~= nil and prop.getter(prop, Obj, Key) or UNDEFINED
end
function ObjectReflect.SetPropertyValue (Obj, Key, Value)
    local prop = Obj.Reflect.LookupProperty(Obj, Key)
    if prop then
        ASSERT(prop.Writable, 'property '..Key..' is read only')
        prop.Setter(prop, Obj, Value, Key)
    else 
        Obj.Reflect.DefineProperty(Obj, Key, Value)
    end
end

function ObjectReflect.GetPrototypeOf (Obj) return Obj.Proto end
function ObjectReflect.SetPrototypeOf (Obj, Proto) Obj.Proto = Proto end

function ObjectReflect.IsExtensible (Obj) return Obj.Extensible end
function ObjectReflect.PreventExtensions (Obj) Obj.Extensible = FALSE end

function ObjectReflect.Apply (obj, args)
    Runtime:Throw(TO_STRING(obj)..' is not a function')
end