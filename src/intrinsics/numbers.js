
// number primitive. Does not allocate heap memory.
const NUMBER = (coef, exp = 0, neg=0) => {
  return VAR(TYPE_NUMBER, neg & 0x8000 | exp & 0x7FFF, coef)
}

const NumberPrototype = {
  ...ObjectReflect,
  ToExponential: ($, fractionalDigits) => ValueOf($),
  ToFixed: ($, fractionalDigits) => ValueOf($),
  ToPrecision: ($, fractionalDigits) => ValueOf($),
}

const NumberConstructor = ($, x) => {
  $.Value = TO_NUMBER(x)
}
