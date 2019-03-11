// symbol primitive.
function Symbol (key) {
    return VAR(TYPE_SYMBOL, 0, STR(key))
}