const ArrayStatic = {
  IsArray($){
    return IsProto($, ArrayConstructor)
  }
}
const ArrayReflect = struct.Reflect({
  ...ObjectReflect,
  get($, key, value) {
    const length = ObjectReflect.get($, 'Length');
    if (IS_NUMBER(key)) {
      REFLECT.get($.Internal.Items, key + 1);
    }
    REFLECT.get($, key);
  },
  set($, key, value) {
    const length = REFLECT.get($, 'Length');
    if (IS_NUMBER(key)) {
      if (key >= length) {
        REFLECT.set($, 'Length', key + 1);
      }
      REFLECT.set($.Internal.Items, value);
    }
    REFLECT.set($, key, value);
  }
})

const ArrayConstructor = ($, args) => {
  const length = args.length;
  $.Reflect = ArrayReflect;
  $.Internal = struct.Array();
  if (length === 1 && IS_NUMBER(args[ 0 ])) {
    // 'alloc' mode
    $.Internal.Length = args[ 0 ];
  } else {
    // 'make' mode
    $.Internal.Length = length;
    for (let index = 0; index < length; index++) {
      REFLECT.set($, index, args[ index ]);
    }
  }
};
