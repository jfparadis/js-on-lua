---------------------------------------------------------
-- Object Prototype Properties
---------------------------------------------------------

-- despite root itself has no proto,
-- '__Proto__' property will be useful for its descendants
RootPrototype.Props.__proto__ = __defineProperty({
    Getter = function (Obj)  return Obj.Reflect.GetPrototypeOf(Obj) end,
    Setter = function(Obj, V)  Obj.Reflect.setPrototypeOf(Obj, V) end,
    Enumerable = FALSE,
    Configurable = FALSE
})

RootPrototype.Props.constructor = __defineProperty({
    Enumerable = FALSE,
    Configurable = FALSE,
    Value = Object,
})

RootPrototype.Props.IsPrototypeOf = __defineFnProperty(
    function (X, Y) 
        target = X.Reflect.getPrototypeOf(X);
        repeat
            if (X == Y) then
                return TRUE;
            end
            target = target.Reflect.getPrototypeOf(target)
        until target == NULL
        return FALSE;
    end
)

-- returns object Value
RootPrototype.Props.ValueOf = __defineFnProperty(
    function (Obj)
        return Obj.Value.Internal
    end
)

-- string representation
RootPrototype.Props.ToString = __defineFnProperty( 
    function(Obj, radix) 
        if Obj.Value then
            return TO_STRING(Obj.Value, radix) 
        end
        return '[object '..Obj.__Proto__.Constructor.Name..']'
    end
)

-- check if given property is defined by object itself(no prototype chain)
RootPrototype.Props.HasOwnProperty = __defineFnProperty( 
    function (Obj, Key) 
        Obj.Reflect.Has(Obj, Key)
    end
)

-- check if given property is enumerable
RootPrototype.Props.PropertyIsEnumerable = __defineFnProperty(
    function (Obj, Key) 
        prop = Properties.Lookup(Obj, Key)
        if not prop then return FALSE end
        return prop.Enumerable
    end
)
 
-- string representation with locale
RootPrototype.Props.ToLocaleString= Properties.DefineFn( 
    function(Obj) 
        return Obj.ToString() 
    end
)

RootPrototype.Props.__LookupGetter__= Properties.DefineFn( 
    function (Obj, key) 
        prop = Properties.Lookup(Obj, key)
        if not prop then return UNDEFINED end
        return prop.Getter
    end
)
RootPrototype.Props.__LookupSetter__= Properties.DefineFn( 
    function (Obj, key) 
        prop = Properties.Lookup(Obj, key)
        if not prop then return UNDEFINED end
        return prop.Setter
    end
)
RootPrototype.Props.__DefineGetter__= Properties.DefineFn( 
    function(Obj, key, fn) 
        if (Obj.Reflect.HasOwnProperty(Obj, key)) then
            Obj.Props[ key ].Getter = fn
        else 
            Obj.Reflect.defineProperty(Obj, key, nil, {
                Getter= fn,
            })
        end
    end
)
RootPrototype.Props.__DefineSetter__= Properties.DefineFn( 
    function(Obj, key, fn) 
        if (Obj.Reflect.HasOwnProperty(Obj, key)) then
            Obj.Props[ key ].Setter = fn
        else
            Obj.Reflect.defineProperty(Obj, key, nil, {
                Setter= fn,
            })
        end
    end
)
