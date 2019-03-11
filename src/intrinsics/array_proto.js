
const ArrayPrototype = {
  Length: struct.PropertyDescriptor({
    Get: ($) => $.Internal,
    Set: ($, value) => {
      $.Internal = value
    },
    Enumerable: FALSE,
    Configurable: FALSE
  }),
  ForEach($, fn) {

    const $R = $.Reflect;
    const size = $R.get($, 'Length');

    for (let index = 0; index < size; index++) {

      const item = $R.get(index);

      fn.Reflect.apply(fn, item, index, $);
    }
  },
  Reduce($, fn, initialValue) {

    const $R = $.Reflect;
    const size = $R.get($, 'Length');

    let result = initialValue;

    for (let index = 0; index < size; index++) {

      const item = $R.get($, index);

      result = fn.Reflect.apply(fn, result, item, index, $);
    }

    return result;
  },
  Map($, fn) {

    const $R = $.Reflect;
    const size = $R.get($, 'Length');
    let result = [];

    for (let index = 0; index < size; index++) {

      const item = $R.get($, index);

      result.push(fn.Reflect.apply(fn, item, index, $));
    }

    return ARRAY(...result);
  },
  Filter($, fn) {

    const $R = $.Reflect;
    const size = $R.get($, 'Length');
    let result = [];

    for (let index = 0; index < size; index++) {

      const item = $R.get($, index);

      if (fn.Reflect.apply(fn, item, index, $)) {

        result.push(item);
      }
    }

    return ARRAY(...result);
  },

  Push: ($, value) => {
    const $R = $.Reflect;
    const size = $R.get($, 'Length');
    $R.set($, size, value);
  },

  IndexOf($, X) {
    const $R = $.Reflect;
    const size = $R.get($, 'Length');
    for (let index = 0; index < size; index++) {
      const item = $R.get($, index);
      if (EQUAL(item, X)) {
        return index;
      }
    }

    return UNDEFINED;
  },
  Join($, sep = '') {
    const $R = $.Reflect;
    const size = $R.get($, 'Length');
    let result = '';
    for (let index = 0; index < size; index++) {
      const item = $R.get($, index);
      result += (index ? sep : '') + TO_STRING(item);
    }
    return result;
  },

  ToString($) {
    return CALL_METHOD($, 'Join', ', ');
  }
};
