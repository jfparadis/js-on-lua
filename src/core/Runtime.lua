--=====================================================--
-- Runtime Engine

function Runtime:Main(HostDefined, Source, Args) 
    -- global vars
    local Globals = {}
    for Key, Value in pairs(Intrinsics) do
        Globals[Key] = Value
    end
    for Key, Value in pairs(HostDefined) do
        Globals[Key] = Value
    end
    -- global scope
    local Scope = { 
        Vars = Globals, 
        Outer = nil 
    }
    -- global context
    local Context = { Scope, Target = Globals, Args }
    -- translate JS source
    local Code, LocalNames, ParamsNames, ExternalNames = Parser.parse(Source)
    
    self.Stack = { Context }
    local Main = Runtime:CreateProcedure('<main>', {}, Source)
    CALL(Main.Code)
    -- return result
    return R(AX)
end

--This is internal procedure, (not JS object).
function Runtime:CreateProcedure(Name, Params, Source, BoundTarget) 
    local Code, LocalNames, ParamsNames, ExternalNames = Parser.parse(Source, Params)
    local Closure = {}
    return {
        Name = Name,
        BoundTarget = BoundTarget,
        -- here and now keep current variable scope 
        -- to be used as outer for new variable scopes at APPLY()
        Closure = self.Stack.Scope,
        -- put translated locals, params, externals variable names and code
        Code = Code, 
        LocalNames = LocalNames, 
        ParamsNames = ParamsNames, 
        ExternalNames = ExternalNames,
    }
end
  
-- Apply fn with given target and arguments
function Runtime:Apply(proc, target, args) 
    -- initialize variables
    local Vars = {}
    for index, name in ipairs(proc.ParamsNames) do
        Vars[name] = index <= #args and args[index] or UNDEFINED
    end
    for _, name in ipairs(proc.LocalNames) do
        Vars[name] = UNDEFINED
    end

    -- create a new execution context for this invocation
    self.Stack =  { 
        Prev = self.Stack,
        IP = 1,
        Done = false,
        Result = UNDEFINED,
        Scope = { 
            Outer = proc.Closure, 
            Vars = Vars
       },
    }
    -- execute code
    repeat
        local code = proc.Code[self.Stack.IP]
        self.Stack.IP = self.Stack.IP + 1
        code()
    until self.Stack.Done or self.Stack.IP > #proc.Code

    self.Stack = self.Stack.Prev
end

-- to be used from JS code to stop evaluation with result
function Runtime:Return(Result) 
    self.Stack.Done = true
    self.Stack.Prev.Result = Result 
end

-- to be used from JS code to stop evaluation with error
function Runtime:Throw(Error)
    self.Stack.Done = true
    self.Stack.Prev.Error = Error
end


function Runtime:GetLastResult()
    return self.Stack.Result
end

function Runtime:GetLastError()
    return self.Stack.Error
end

function Runtime:Skip(delta)
    self.Stack.IP = self.Stack.IP + delta
end

function Runtime:This()
    return self.Stack.Target
end

-- look up variable by name
function Runtime:LookupVariable(name)
    local scope = self.Stack.Scope
    
    -- here were looking into scopes chain for a variable
    repeat
      val = scope.vars[name]
      if (val ~= nil) then
        return val
      end
      scope = scope.Outer
    until scope == nil

    Runtime:Throw(ReferenceError.New('Variable is not defined: '..name))
end

