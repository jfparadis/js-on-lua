
---------------------------------------------------------
-- Intrinsics
---------------------------------------------------------

Intrinsics.Object = Object
    
function Intrinsics.Object.Create(prototype) 
    if Lang.TypeOf(prototype) ~= 'object' or prototype == NULL then 
        Runtime.throw(TypeError.New('Object prototype may only be an Object or null: '..type))
    end
    return Object.New({}, prototype)
end

function Intrinsics.Object.Assign(Obj, Sources...)
    assert(Obj, 'Unable to assign to '..Obj)
    for _, src in ipairs(Sources) do
        for Key, val in pairs(src) do
            Obj[Key] = val
        end
    end
    return Obj
end

function Intrinsics.Object.Keys(Obj)
    local hash ={}
    local target = Obj.ObjectReflect.getPrototypeOf(Obj);
    repeat
        for Key, prop in pairs(target.Props) do if prop.Enumerable then
            hash[Key] = 1
            end
        end
        target = This.ObjectReflect.getPrototypeOf(This)
    until target == NULL
    local keys = {}
    for Key in pairs(hash) do 
        keys[#keys+1] = Key
    end
    return keys
end

function Intrinsics.Object.OwnKeys(Obj) 
    local keys = {}
    for Key, prop in pairs(Obj.ObjectReflect.OwnKeys(Obj)) do 
        if prop.Enumerable then
            keys[#keys+1] = Key
        end
    end
    return keys
end
