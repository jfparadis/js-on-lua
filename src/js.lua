-- There is simplified implementation of JS written in LUA.
-- The main purpose is to give an insight of what JS is from inside.

-----------------------------------------------------------------------------------------------------------------------------------------------
--                                                                  --| # There are following data types in JS:
local TYPE_UNDEFINED =      0x0                                     --|     undefined type of single `undefined` constant
local TYPE_BOOLEAN =        0x1                                     --|     logical type of `true` and `false` constants
local TYPE_NUMBER =         0x2                                     --|     numeric for integers and floats
local TYPE_NOT_A_NUMBER =   0x3                                     --|     non-numeric of single `NaN` constant
local TYPE_STRING =         0x4                                     --|     textual Type for strings
local TYPE_SYMBOL =         0x5                                     --|     symbolic Type
local TYPE_OBJECT =         0x6                                     --|     JS object
-----------------------------------------------------------------------------------------------------------------------------------------------
--                                                                  --| # There are several constants in JS:
local UNDEFINED =       { Type = TYPE_UNDEFINED,    Value =  0 }    --|     FULL SET
local NULL =            { Type = TYPE_OBJECT,       Value =  0 }    --|     EMPTY SET
local NAN =             { Type = TYPE_NOT_A_NUMBER, Value =  0 }    --|     SET OF ANYTHING, BUT NOT A NUMBER
local ZERO =            { Type = TYPE_NUMBER,       Value =  0 }    --|     ZERO NUMBER VALUE
local NOT_FOUND =       { Type = TYPE_NUMBER,       Value = -1 }    --|     MINUS ONE NUMBER VALUE - DENOTES IMAGINARY ONE
local EMPTY_STRING =    { Type = TYPE_STRING,       Value =  0 }    --|     EMPTY STRING VALUE
local FALSE =           { Type = TYPE_BOOLEAN,      Value =  0 }    --|     SET CONSISTS OF [ UNDEF, NULL, ZERO, EMPTY_STRING ]
local TRUE =            { Type = TYPE_BOOLEAN,      Value =  1 }    --|     SET OF ANYTHING, EXCEPT FALSE
-----------------------------------------------------------------------------------------------------------------------------------------------
--                                                                  --| ... let define macros for the rest:
macro.define('STRING(X) { Type = TYPE_STRING, Value =  X }') 
macro.define('OBJECT(X) { Type = TYPE_OBJECT, Value =  X }') 
macro.define('NUMBER(X) { Type = TYPE_NUMBER, Value =  X }') 
macro.define('SYMBOL(X) { Type = TYPE_SYMBOL, Value =  X }') 
-----------------------------------------------------------------------------------------------------------------------------------------------
--                                                                  --| # JS is implemented by:
--
local Runtime = {                                                   --| ## Runtime Engine:
    -- Main(hostDefined, source, args)                              --|     main entry point
    
    -- CreateProcedure(name, params, source, boundTarget)           --|     creates internal procedure 
    -- Apply(proc, target, args)                                    --|     applies internal procedure
    
    -- Return(result)                   
    -- Throw(Error)                 
    -- GetLastResult()                  
    -- GetLastError()                   
    -- Skip(delta)                  
    
    -- This()                   
    -- LookupVariable(name)                 
}

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 

-- access to object properties and prototype from outside
ObjectReflect = {
    -- OwnKeys(Obj)

    -- DefineProperty(Obj, Key, Value, opts)
    -- GetOwnPropertyDescriptor(Obj, Key)
    -- DeleteProperty(Obj, Key)
    -- LookupProperty(Obj, Key)
    -- HasProperty(Obj, Key)

    -- GetPropertyValue(Obj)
    -- SetPropertyValue(Obj, Key, Value)

    -- GetPrototypeOf(Obj) 
    -- SetPrototypeOf(Obj, Proto) 

    -- IsExtensible(Obj)                                            --| (whether it can have new properties added to it)
    -- PreventExtensions(Obj) 

    -- Apply(obj, args)
}

-- the default root object prototype for entire object tree.
RootPrototype = OBJECT({
    -- Has no proto itself.
    Proto = NULL,
    -- provides indirect access to object properties and prototype
    Reflect = ObjectReflect,
    -- non-extensible
    Extensible = FALSE,
    -- It provides set of common methods, available for all descendants.
    Props = {
        -- __proto__
        -- constructor
        -- hasOwnProperty()
        -- isPrototypeOf()
        -- propertyIsEnumerable()
        -- toLocaleString()
        -- toString()
        -- valueOf()
        -- __define[G/S]etter__()
        -- __lookup[G/S]etter__()
    }
})

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 

FunctionReflect = {
    unpack(ObjectReflect),                                          --| the same as ObjectReflect, but
    -- Apply
}

function FunctionReflect.Apply(obj, target, args)
    Runtime:Apply(obj.Value.Internal, target, args)
end

-- the default root object prototype for entire object tree.
FunctionPrototype = OBJECT({
    Proto = RootPrototype,                      -- Has no proto itself.
    Reflect = FunctionReflect,                  -- provides indirect access to object properties and prototype
    Extensible = FALSE ,                        -- non-extensible
    Props = {                                   -- It provides set of common methods, available for all descendants.
        -- arguments
        -- caller
        -- length
        -- name
    }
})

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Object constructor
Object = OBJECT({
    Proto = FunctionPrototype, 
    Reflect = FunctionReflect, 
    Extensible = TRUE,
    Internal = {
        -- Code
    },
    Props = {
        -- assign(X, ...D)
        -- create(Proto)
        
        -- keys(X)
        -- values(X)
        -- entries(X)
        -- fromEntries(Arr<>)                   --| transforms a list of key-value pairs into an object
            
        -- defineProperties(X)
        -- defineProperty(X)
        -- getOwnPropertyDescriptor(X)
        -- getOwnPropertyDescriptors(X)
        -- getOwnPropertyNames(X)
        -- getOwnPropertySymbols(X)

        -- [g/s]etPrototypeOf(X)
        
        -- is(A,B)                            --| determines whether two values are the same value (https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is).

        -- preventExtensions/isExtensible(X)  --| whether it can have new properties added to it
        -- freeze/isFrozen(X)                 --| A frozen object can no longer be changed; freezing an object prevents new properties from being added to it, existing properties from being removed, prevents changing the enumerability, configurability, or writability of existing properties, and prevents the values of existing properties from being changed. In addition, freezing an object also prevents its prototype from being changed
        -- seal/isSealed(X)                   --| it is not extensible and if all its properties are non-configurable and therefore not removable (but not necessarily non-writable).
    }, 
})

function Object.Value.Internal.Code(This, initialValues)
    This.Value.Internal = This
    -- hashed Key/descriptor pairs that constitute object state
    __defineProperties(This.Value, initialValues)
end

-- Function constructor
Function = OBJECT({ 
    Proto = FunctionPrototype, 
    Reflect = FunctionReflect, 
    Extensible = TRUE, 
    Internal = {
        -- Name = STRING('Function'),
        -- Code(Params, Source) 
    },
    Props = {
        -- Params,
        -- Prototype
    },
})

function Function.Value.Internal.Code(This, Params, Source) 
    This.Value.Reflect = FunctionReflect 
    This.Value.Internal = Runtime:CreateProcedure('', Params, Source)  
    This.Value.Props = { 
        Params = Params,
        Prototype = OBJECT({ 
            Proto = ObjectPrototype, 
            Reflect = ObjectReflect, 
            Extensible = TRUE,
            Props = {
                constructor = This
            },   
        }),
    }
end

-----------------------------------------------------------------------------------------------------------------------------------------------
--                                                                  --|  Language public interface
local Lang = {
    --                                                              --| ## Narrow values regarding operational context:
    -- AsBoolean (x)                                                --|     used in conditionals
    -- AsNumeric (x)                                                --|     used in comparision, arithmetic operations
    -- AsString  (x)                                                --|     used in concat operation
    -- AsObject  (x)                                                --|     used in dot operation
    --                                                              --| ## Object properties access:
    -- GetProperty(Obj, Key)                                        --|
    -- SetProperty(Obj, Key, Value)                                 --|
    -- DelProperty(Obj, Key)                                        --|
    -- CallProperty(Obj, name, args)                                --|

    -- GetVariable(Key)                                             --|
    -- SetVariable(Key, Value)                                      --|

    -- New(constructor, arguments) 
}

function Lang.New(constructor, arguments) 
    local this = OBJECT({  
        Proto = GetProperty(constructor, STRING('prototype')), 
        Reflect = ObjectReflect, 
        Internal = UNDEFINED,
        Extensible = TRUE, 
    })
    Runtime:Apply(constructor.Value.Internal, this, arguments)
    Runtime:Return(this)
end
-----------------------------------------------------------------------------------------------------------------------------------------------
-- set of global objects and constructors
local Intrinsics = {

    Object = Object,
    Function = Function,
    --.................................................................     --|    
    -- Boolean
    -- Number
    -- String
    -- Date
    -- Symbol
    --.................................................................     --|    
    -- Array
    -- Map
    -- Set
    -- WeakMap
    -- WeakSet
    --.................................................................     --|
    -- Proxy
    -- Promise
    -- RegExp
    --.................................................................     --|
    -- Error
    -- InternalError
    -- RangeError
    -- ReferenceError
    -- SyntaxError
    -- TypeError
    -- EvalError
    -- URIError
    --.................................................................     --|
    -- DataView
    -- ArrayBuffer, SharedArrayBuffer
    -- Float[32/64]Array
    -- Int[8/16/32]Array
    -- Uint[8/16/32]Array
    -- Uint8ClampedArray
    --.................................................................     --| ## Global functions:
    -- eval()
    -- 
    -- isNan()
    -- isFinite()
    -- //
    -- parseFloat()
    -- parseInt()
    -- //
    -- encode/decode()
    -- //
    -- [encode/decode]URIComponent()
    --.................................................................     --| ## Global objects:
    -- Atomics
    -- Math
    -- JSON
}