from enum import Enum

class OperandType(Enum):
    NUMERICAL = 0
    REGISTER = 1
    UNDEFINED = 2

def getreg(reg_value):
    return int(reg_value[1:])

def getregbin(reg_value):
    return bin(getreg(reg_value)).replace("0b","")

def get_operand_type(eval_operand):
    try:
        if eval_operand.startswith('0x'):
            x = int(eval_operand, 16)
        elif eval_operand.startswith('0b'):
            x = int(eval_operand, 2)
        else:
            x = int(eval_operand)
        return OperandType.NUMERICAL
    except:
        if eval_operand.startswith('r'):
            register_value = eval_operand[1:]
            try:
                x = int(register_value)
                if(x >= 0) and (x <= 15):
                    return OperandType.REGISTER
            except:
                return OperandType.UNDEFINED
        return OperandType.UNDEFINED