import { ObjectReflect } from "./object_reflect";
const FunctionReflect = struct.Reflect({
  ...ObjectReflect,
  // Calls a target function with arguments as specified by the args parameter.
  apply($, This, Arguments) {
    return Apply($.Internal, This, Arguments);
  },
  // The new operator as a function. Equivalent to calling new target(...args).
  construct($, Arguments) {
    const $new = MakeObject({}, $.Internal.Prototype);
    Apply($.Internal, $new, Arguments);
    return $new;
  }
})

const FunctionPrototype = {
  Get__Length: $ => $.Internal.Parameters.length,
  Get__Name: ($) => $.Internal.Name || 'anonymous',
  Apply: ($, This, Arguments) => Apply($.Internal, This, Arguments),
  Call: ($, This, ...Arguments) => Apply($.Internal, This, Arguments),
  Bind: ($, BoundToThis, ...Arguments) => MakeFunction({
    BoundToThis,
    Code($this, ...args) {
      Apply($.Internal, $this.BoundToThis, [ ...Arguments, ...args ])
    }
  })
};

function FunctionConstructor($, Parameters, Source){
  $.Internal = struct.Func({ 
    Params, 
    Prototype: MakeObject({ Constructor: $ }),
    ...TRANSLATE(Source)
  })
}

function MakeFunction(initials) {
  const $ = MakeObject({}, FunctionPrototype, NULL, NULL);
  $.Reflect = FunctionReflect;
  $.Internal = MakeInternalFunction({ Prototype: MakeObject({ Constructor: $ }), ...initials });
  return $;
}

