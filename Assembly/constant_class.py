from enum import Enum

class ConstType(Enum):
    HEXADECIMAL = 0
    DECIMAL = 1

class Const:
    def __init__(self, const_type, name, value):
        self.const_type = const_type
        self.name = name
        base = 10
        if const_type == ConstType.HEXADECIMAL:
            base = 16
        self.value = int(value.replace("_",""), base)

    def get_string_value(self, base):
        if base == 2:
            return bin(self.value).replace('0b','')
        elif base == 16:
            return hex(self.value).replace('0x','')
        return str(self.value)

def is_constant(const_name, const_list):
    for constant in const_list:
        const_name_parse_dollar = const_name.replace("$","")
        if constant.name == const_name_parse_dollar:
            return True
    return False

def get_constant(const_name, const_list):
    for constant in const_list:
        const_name_parse_dollar = const_name.replace("$", "")
        if constant.name == const_name_parse_dollar:
            return constant
    return "NaN"