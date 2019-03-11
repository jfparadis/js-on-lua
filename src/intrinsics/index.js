/**
 * Intrinsics are built-in low-level code routines.
 * Most of them are used to construct properties of Global object
 */
const ConstructorsNames = [
 
];
export default {
  // The eval function (18.2.1)
  eval,
  // The isFinite function (18.2.2)
  isFinite,
  // The isNaN function (18.2.3)
  isNaN,
  // 	parseFloat	The parseFloat function (18.2.4)
  parseFloat,
  // 	parseInt	The parseInt function (18.2.5)
  parseInt,
  // 	decodeURI	The decodeURI function (18.2.6.2)
  decodeURI,
  // 	decodeURIComponent	The  decodeURIComponent function (18.2.6.3)
  decodeURIComponent,
  // 	encodeURI	The encodeURI function (18.2.6.4)
  encodeURI,
  // 	encodeURIComponent	The  encodeURIComponent function (18.2.6.5)
  encodeURIComponent,
  
}

function CreateGlobalObject(Realm) {

  const { Intrinsics, HostDefined } = Realm;

  function createConst(Value) {
    return {
      Value,
      Writable: FALSE,
      Configurable: FALSE,
      Enumerable: FALSE,
    }
  }

  function createFunction(Code) {
    return MakeFunction({ Code })
  }

  function createConstructor(Name) {
    return MakeFunction({
      Name,
      Prototype: MakeObject(Intrinsics[ `${Name}Prototype` ]),
      Code: Intrinsics[ `${Name}Constructor` ]
    })
  }

  const Constructors = ConstructorsNames.reduce((r, Name) => {
    r[ Name ] = createConstructor(Name);
    return r;
  }, {});

  const Eval = (source) => {

    const fn = MakeInternalFunction({});
  
    translate(fn, 'return ' + source);
  
    return Apply(fn);
  };
  const GlobalObject = {

    // Non-equal to anything including itself
    // NaN: createConst(Intrinsics.NaN),
    // // More then any other number
    // Infinity: createConst(Intrinsics.Infinity),
    // // Undefined
    // undefined: createConst(Intrinsics.UNDEFINED),
    // // Undefined
    // ['null']: createConst(Intrinsics.NULL),
    //
        // JSON: MakeObject(Intrinsics.JSON),
    // Math: MakeObject(Intrinsics.Math),
    Reflect: MakeObject(Intrinsics.Reflect),

    ...Constructors,

    ...HostDefined
  };

  Realm.GlobalObject = GlobalObject;

  return GlobalObject;

}