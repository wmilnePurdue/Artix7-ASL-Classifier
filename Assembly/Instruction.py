from enum import Enum

from constant_class import is_constant, get_constant
from operand_class import get_operand_type, OperandType, getregbin


class InstType(Enum):
    ADD = 0
    SUB = 1
    MULT = 2
    DIV = 3
    MOV = 4
    OR = 5
    AND = 6
    INV = 7
    SLL = 8
    SRR = 9
    JEQ = 10
    JNEQ = 11
    JGR = 12
    JLT = 13
    CALL = 14
    RET = 15
    SW8_0 = 16
    SW8_1 = 17
    SW8_2 = 18
    SW8_3 = 19
    SW16_0 = 20
    SW16_1 = 21
    SW32 = 22
    IMMI_L = 23
    LW8_0 = 24
    LW8_1 = 25
    LW8_2 = 26
    LW8_3 = 27
    LW16_0 = 28
    LW16_1 = 29
    LW32 = 30
    IMMI_H = 31

def append_string(targ, num):
    while len(targ) < num:
        targ = "0" + targ
    return targ

def inst_check(inst_line):
    if inst_line.startswith("add ") or inst_line.startswith("sub ") or inst_line.startswith("mul ") or inst_line.startswith("div "):
        return 1
    if inst_line.startswith("or ") or inst_line.startswith("and ") or inst_line.startswith("mov ") or inst_line.startswith("invd"):
        return 1
    if inst_line.startswith("jne ") or inst_line.startswith("je ") or inst_line.startswith("jl ") or inst_line.startswith("jg "):
        return 1
    if inst_line.startswith("call ") or inst_line.startswith("ret ") or inst_line.startswith("shl ") or inst_line.startswith("shr "):
        return 1
    if inst_line.startswith("stosb ") or inst_line.startswith("stosd ") or inst_line.startswith("stosw "):
        return 1
    if inst_line.startswith("lodsb ") or inst_line.startswith("lodsd ") or inst_line.startswith("lodsw "):
        return 1
    if inst_line.startswith("lsl ") or inst_line.startswith("lss ") or inst_line.startswith("imul ") or inst_line.startswith("idiv "):
        return 1
    return 0

class Instruction:
    def __init__(self, inst_type, src0, src1, dest, option, option2, const_string, const_value):
        self.inst_type = inst_type
        self.src0 = src0
        self.src1 = src1
        self.dest = dest
        self.option = option
        self.option2 = option2
        self.const_string = const_string
        self.const_value = const_value

    def getHex(self):
        inst = 0
        opcode = append_string(getregbin("r" + str(self.inst_type.value)), 5)
        src0 = append_string(getregbin(self.src0), 4)
        src1 = "0000"
        const = "0"
        dest = append_string(getregbin(self.dest), 4)
        if (self.inst_type == InstType.SUB) or (self.inst_type == InstType.ADD):
            if not self.option:
                src1 = append_string(getregbin(self.src1),4)
                const = append_string(const, 14)
            else:
                const = append_string(self.src1, 14)
            inst = int(opcode + src0 + src1 + dest + str(self.option) + const, 2)
        elif (self.inst_type == InstType.MULT) or (self.inst_type == InstType.DIV):
            src1 = append_string(getregbin(self.src1), 4)
            const = append_string(const, 13)
            inst = int(opcode + src0 + src1 + dest + str(self.option) + str(self.option2) + const, 2)
        elif (self.inst_type == InstType.OR) or (self.inst_type == InstType.AND):
            src1 = append_string(getregbin(self.src1), 4)
            const = append_string(const, 15)
            inst = int(opcode + src0 + src1 + dest + const, 2)
        elif (self.inst_type == InstType.MOV) or (self.inst_type == InstType.INV):
            const = append_string(const, 15)
            inst = int(opcode + src0 + src1 + dest + const, 2)
        elif (self.inst_type == InstType.SRR) or (self.inst_type == InstType.SLL):
            const = append_string(const, 13)
            if self.option:
                const = append_string(self.src1, 13)
                src1 = "0000"
            else:
                src1 = append_string(getregbin(self.src1),4)
            inst = int(opcode + src0 + src1 + dest + const, 2)
        elif (self.inst_type == InstType.JEQ) or (self.inst_type == InstType.JNEQ) or (self.inst_type == InstType.JLT) or (self.inst_type == InstType.JGR):
            if self.const_value == -1:
                raise Exception("ERROR: Jump Location, " + self.const_string + ", not found")
            else:
                src1 = append_string(getregbin(self.src1), 4)
                const = append_string(bin(int(str(self.const_value))).replace('0b',''), 19)
                inst = int(opcode + src0 + src1 + const, 2)
        elif self.inst_type == InstType.CALL:
            if self.const_value == -1:
                raise Exception("ERROR: Jump Location, " + self.const_string + ", not found")
            else:
                const = append_string(bin(int(str(self.const_value))).replace('0b', ''), 19)
                inst = int(opcode + src0 + "0000" + const, 2)
        elif self.inst_type == InstType.RET:
            const = append_string(const, 19)
            inst = int(opcode + src0 + "0000" + const, 2)
        elif (self.inst_type == InstType.SW8_0) or (self.inst_type == InstType.SW8_1) or (self.inst_type == InstType.SW8_2) or (self.inst_type == InstType.SW8_3) or (self.inst_type == InstType.SW16_0) or (self.inst_type == InstType.SW16_1) or (self.inst_type == InstType.SW32):
            const = append_string(bin(int(self.const_string)).replace('0b',''), 14)
            src1 = append_string(getregbin(self.src1), 4)
            inst = int(opcode + src0 + src1 + "0000" + str(self.option) + const, 2)
        elif (self.inst_type == InstType.LW8_0) or (self.inst_type == InstType.LW8_1) or (self.inst_type == InstType.LW8_2) or (self.inst_type == InstType.LW8_3) or (self.inst_type == InstType.LW16_0) or (self.inst_type == InstType.LW16_1) or (self.inst_type == InstType.LW32):
            const = append_string(bin(int(self.const_string)).replace('0b',''), 14)
            inst = int(opcode + "0000" + src0 + dest + str(self.option) + const, 2)
        elif (self.inst_type == InstType.IMMI_H) or (self.inst_type == InstType.IMMI_L):
            const = append_string(bin(int(self.const_string)).replace('0b', ''), 16)
            inst = int(opcode + dest + "000000" + str(self.option) + const, 2)
        else:
            raise Exception("ERROR: Unknown instruction")
        return f"{inst:08X}"


def parse(code, codeline, const_list):
    error_suffix = "\n at line : " + str(codeline) + " -- " + code
    if not inst_check(code):
        if "jmp" in code:
            code_split = list(filter(None, code.replace(',', ' ').split(' ')))
            if len(code_split) == 2:
                return Instruction(InstType.JEQ, "r0", "r0", "r0", 0, 0, code_split[1], -1)
            else:
                raise Exception("ERROR: JMP parameters should be exactly 1" + error_suffix)
        else:
            raise Exception("ERROR: Unknown Instruction" + error_suffix)
    if "add" in code or "sub" in code:
        inst_type = InstType.ADD
        if "sub" in code:
            inst_type = InstType.SUB
        code_split = list(filter(None, code.replace(',',' ').split(' ')))
        if len(code_split) == 4:
            src0 = code_split[2]
            src1 = code_split[3]
            dest = code_split[1]
            src0_type = get_operand_type(src0)
            src1_type = get_operand_type(src1)
            dest_type = get_operand_type(dest)
            if src0_type == OperandType.UNDEFINED:
                if is_constant(src0, const_list):
                    src0_type = OperandType.NUMERICAL
                    src0 = get_constant(src0, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown variable / constant" + error_suffix)
            if src1_type == OperandType.UNDEFINED:
                if is_constant(src1, const_list):
                    src1_type = OperandType.NUMERICAL
                    src1 = get_constant(src1, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown variable / constant" + error_suffix)
            option = 0
            if dest_type != OperandType.REGISTER:
                raise Exception("ERROR: destination is not a register" +error_suffix)
            elif src1_type == OperandType.NUMERICAL and src0_type == OperandType.NUMERICAL:
                raise Exception("ERROR: both sources are numerical" + error_suffix)
            elif src1_type == OperandType.NUMERICAL:
                if int(src1) > 16383:
                    raise Exception("ERROR: numerical value too large, cannot exceed 16,383" + error_suffix)
                option = 1
                src1 = bin(int(src1)).replace('0b','')
            elif src0_type == OperandType.NUMERICAL:
                temp_src = src0
                src0 = src1
                src1 = temp_src
                if int(src1) > 16383:
                    raise Exception("ERROR: numerical value too large, cannot exceed 16,383" + error_suffix)
                option = 1
                print("Source 1: " + src1)
                src1 = bin(int(src1)).replace('0b','')
            return Instruction(inst_type, src0, src1, dest, option, 0, "Nan", -1)
        else:
            raise Exception("ERROR: MUL/DIV parameters should be exactly 3" + error_suffix)
    elif ("mul" in code) or ("imul" in code) or ("div" in code) or ("idiv" in code):
        option2 = 0
        inst_type = InstType.MULT
        if "imul" in code or "idiv" in code:
            option2 = 1
        if "div" in code or "idiv" in code:
            inst_type = InstType.DIV
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        if len(code_split) == 5:
            src0 = code_split[2]
            src1 = code_split[3]
            dest = code_split[1]
            option = 0
            if inst_type == InstType.MULT:
                if code_split[4] == 'u':
                    option = 1
                elif code_split[4] != 'l':
                    raise Exception("ERROR: unknown multiplier return" + error_suffix)
            else:
                if code_split[4] == 'r':
                    option = 1
                elif code_split[4] != 'q':
                    raise Exception("ERROR: unknown divider return" + error_suffix)
            src0_type = get_operand_type(src0)
            src1_type = get_operand_type(src1)
            dest_type = get_operand_type(dest)
            if dest_type != OperandType.REGISTER:
                raise Exception("ERROR: destination is not a register" + error_suffix)
            elif src1_type == OperandType.REGISTER and src0_type == OperandType.REGISTER:
                return Instruction(inst_type, src0, src1, dest, option, option2, "NaN", -1)
            else:
                raise Exception("ERROR: multiplier and divider, can only source from registers" + error_suffix)
        else:
            raise Exception("ERROR: MUL/DIV parameters should be exactly 4" + error_suffix)
    elif ("or" in code) or ("and" in code):
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.OR
        if "and" in code:
            inst_type = InstType.AND
        if len(code_split) == 4:
            src0 = code_split[2]
            src1 = code_split[3]
            dest = code_split[1]
            src0_type = get_operand_type(src0)
            src1_type = get_operand_type(src1)
            dest_type = get_operand_type(dest)
            if dest_type != OperandType.REGISTER:
                raise Exception("ERROR: destination is not a register" + error_suffix)
            elif src1_type == OperandType.REGISTER and src0_type == OperandType.REGISTER:
                return Instruction(inst_type, src0, src1, dest, 0, 0, "NaN", -1)
            else:
                raise Exception("ERROR: MOV/OR/AND, can only source from registers" + error_suffix)
        else:
            raise Exception("ERROR: MOV/OR/AND parameters should be exactly 3" + error_suffix)
    elif ("mov" in code) or ("invd" in code):
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.MOV
        if "invd" in code:
            inst_type = InstType.INV
        if len(code_split) == 3:
            src0 = code_split[2]
            dest = code_split[1]
            src1 = "0000"
            src0_type = get_operand_type(src0)
            dest_type = get_operand_type(dest)
            if dest_type != OperandType.REGISTER:
                raise Exception("ERROR: destination is not a register" + error_suffix)
            elif src0_type == OperandType.REGISTER:
                return Instruction(inst_type, src0, src1, dest, 0, 0, "NaN", -1)
            else:
                raise Exception("ERROR: INV/MOV, can only source from registers" + error_suffix)
        else:
            raise Exception("ERROR: MOV/OR/AND parameters should be exactly 2" + error_suffix)
    elif ("shr" in code) or ("shl" in code):
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.SRR
        option = 0
        if "shl" in code:
            inst_type = InstType.SLL
        if len(code_split) == 4:
            src0 = code_split[2]
            src1 = code_split[3]
            dest = code_split[1]
            src0_type = get_operand_type(src0)
            src1_type = get_operand_type(src1)
            dest_type = get_operand_type(dest)
            if src1_type == OperandType.UNDEFINED:
                if is_constant(src1, const_list):
                    src1_type = OperandType.NUMERICAL
                    src1 = get_constant(src1, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown variable / constant" + error_suffix)
            if dest_type != OperandType.REGISTER:
                raise Exception("ERROR: destination is not a register" + error_suffix)
            elif src0_type != OperandType.REGISTER:
                raise Exception("ERROR: operand 0 must be a register" + error_suffix)
            elif src1_type == OperandType.NUMERICAL:
                if int(src1) > 31:
                    raise Exception("ERROR: numerical value too large, cannot exceed 31" + error_suffix)
                option = 1
                src1 = bin(int(src1)).replace('0b','')
            return Instruction(inst_type, src0, src1, dest, option, 0, "NaN", -1)
        else:
            raise Exception("ERROR: SRR/SLL parameters should be exactly 3" + error_suffix)
    elif ("jne" in code) or ("je" in code) or ("jl" in code) or ("jg" in code):
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.JEQ
        if "jne" in code:
            inst_type = InstType.JNEQ
        elif "jl" in code:
            inst_type = InstType.JLT
        elif "jg" in code:
            inst_type = InstType.JGR
        if len(code_split) == 4:
            src0 = code_split[1]
            src1 = code_split[2]
            src0_type = get_operand_type(src0)
            src1_type = get_operand_type(src1)
            if (src0_type == OperandType.REGISTER) and (src1_type == OperandType.REGISTER):
                return Instruction(inst_type, src0, src1, "r0",0,0,code_split[3],-1)
            else:
                raise Exception("ERROR: JUMP comparator values should be from registers" + error_suffix)
        else:
            raise Exception("ERROR: JUMP parameters should be exactly 3" + error_suffix)
    elif "call" in code:
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.CALL
        if len(code_split) == 3:
            const = code_split[2]
            const_type = get_operand_type(const)
            src0 = code_split[1]
            src0_type = get_operand_type(src0)
            if src0_type != OperandType.REGISTER:
                raise Exception("ERROR: Call can only save the program counter in a register" + error_suffix)
            if const_type == OperandType.UNDEFINED:
                return Instruction(inst_type, src0, "0000", "r0", 0, 0, const, -1)
            else:
                raise Exception("ERROR: CALL cannot use registers or numerical values for address targets" + error_suffix)
        else:
            raise Exception("ERROR: CALL parameters should be exactly 2" + error_suffix)
    elif "ret" in code:
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.RET
        if len(code_split) == 2:
            src0 = code_split[1]
            src0_type = get_operand_type(src0)
            if src0_type == OperandType.REGISTER:
                return Instruction(inst_type, src0, "0000", "r0",0,0,"0",-1)
            else:
                raise Exception("ERROR: RET parameters should be exactly 1" + error_suffix)
    elif ("stosb" in code) or ("stosd" in code):
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.SW8_0
        if len(code_split) == 5:
            src0 = code_split[1]
            src1 = code_split[2]
            src0_type = get_operand_type(src0)
            src1_type = get_operand_type(src1)
            option = 0
            const = code_split[4]
            if "stosb" in code:
                if code_split[3] == "b1":
                    inst_type = InstType.SW8_1
                elif code_split[3] == "b2":
                    inst_type = InstType.SW8_2
                elif code_split[3] == "b3":
                    inst_type = InstType.SW8_3
                elif code_split[3] != "b0":
                    raise Exception("ERROR: Unknown byte-select" + error_suffix)
            else:
                inst_type = InstType.SW16_0
                if code_split[3] == "h1":
                    inst_type = InstType.SW16_1
                elif code_split[3] != "h0":
                    raise Exception("ERROR: Unknown half-word select" + error_suffix)
            if const.startswith("+"):
                option = 1
            elif not const.startswith("-"):
                raise Exception("ERROR: Unknown address operator" + error_suffix)
            const = const[1:]
            if get_operand_type(const) != OperandType.NUMERICAL:
                if is_constant(const, const_list):
                    const = get_constant(const, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown offset value" + error_suffix)
            if int(const) > 16383:
                raise Exception("ERROR: Offset value too big, max value is 16383" + error_suffix)
            if (src0_type == OperandType.REGISTER) and (src1_type == OperandType.REGISTER):
                return Instruction(inst_type, src0, src1, "r0", option, 0, const, -1)
            else:
                raise  Exception("ERROR: both sources should be registers" + error_suffix)
        else:
            if "stosb" in code:
                raise Exception("ERROR: STOSB/SW8 parameters should be exactly 4" + error_suffix)
            raise Exception("ERROR: STOSD/SW16 parameters should be exactly 4" + error_suffix)
    elif "stosw" in code:
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        if len(code_split) == 4:
            src0 = code_split[1]
            src1 = code_split[2]
            src0_type = get_operand_type(src0)
            src1_type = get_operand_type(src1)
            option = 0
            const = code_split[3]
            if const.startswith("+"):
                option = 1
            elif not const.startswith("-"):
                raise Exception("ERROR: Unknown address operator" + error_suffix)
            if get_operand_type(const) != OperandType.NUMERICAL:
                if is_constant(const, const_list):
                    const = get_constant(const, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown offset value" + error_suffix)
            const = const[1:]
            if int(const) > 16383:
                raise Exception("ERROR: Offset value too big, max value is 16383" + error_suffix)
            if (src0_type == OperandType.REGISTER) and (src1_type == OperandType.REGISTER):
                return Instruction(InstType.SW32, src0, src1, "r0", option, 0, const, -1)
            else:
                raise  Exception("ERROR: both operands should be registers" + error_suffix)
        else:
            raise Exception("ERROR: STOSW/SW32 parameters should be exactly 3" + error_suffix)
    elif ("lodsb" in code) or ("lodsd" in code):
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.LW8_0
        if len(code_split) == 5:
            src0 = code_split[1]
            dest = code_split[2]
            src0_type = get_operand_type(src0)
            dest_type = get_operand_type(dest)
            option = 0
            const = code_split[4]
            byte_sel = code_split[3]
            if "lodsb" in code:
                if byte_sel == 'b1':
                    inst_type = InstType.LW8_1
                elif byte_sel == 'b2':
                    inst_type = InstType.LW8_2
                elif byte_sel == 'b3':
                    inst_type = InstType.LW8_3
                elif byte_sel != 'b0':
                    raise Exception("ERROR: Unknown byte-select" + error_suffix)
            else:
                inst_type = InstType.LW16_0
                if byte_sel == 'h1':
                    inst_type = InstType.LW16_1
                elif byte_sel != 'h0':
                    raise Exception("ERROR: Unknown half-word select" + error_suffix)
            if const.startswith("+"):
                option = 1
            elif not const.startswith("-"):
                raise Exception("ERROR: Unknown address operator" + error_suffix)
            const = const[1:]
            if get_operand_type(const) != OperandType.NUMERICAL:
                if is_constant(const, const_list):
                    const = get_constant(const, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown offset value" + error_suffix)
            if int(const) > 16383:
                raise Exception("ERROR: Offset value too big, max value is 16383" + error_suffix)
            if (src0_type == OperandType.REGISTER) and (dest_type == OperandType.REGISTER):
                return Instruction(inst_type, src0, "0000", dest, option, 0, const, -1)
            else:
                raise  Exception("ERROR: both operands should be registers" + error_suffix)
        else:
            if "lodsb" in code:
                raise Exception("ERROR: LODSB/LW8 parameters should be exactly 4" + error_suffix)
            raise Exception("ERROR: LODSD/LW16 parameters should be exactly 4" + error_suffix)
    elif "lodsw" in code:
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        if len(code_split) == 4:
            src0 = code_split[1]
            dest = code_split[2]
            src0_type = get_operand_type(src0)
            dest_type = get_operand_type(dest)
            option = 0
            const = code_split[3]
            if const.startswith("+"):
                option = 1
            elif not const.startswith("-"):
                raise Exception("ERROR: Unknown address operator" + error_suffix)
            const = const[1:]
            if get_operand_type(const) != OperandType.NUMERICAL:
                if is_constant(const, const_list):
                    const = get_constant(const, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown offset value" + error_suffix)
            if int(const) > 16383:
                raise Exception("ERROR: Offset value too big, max value is 16383" + error_suffix)
            if (src0_type == OperandType.REGISTER) and (dest_type == OperandType.REGISTER):
                return Instruction(InstType.LW32, src0, "0000", dest, option, 0, const, -1)
            else:
                raise  Exception("ERROR: both operands should be registers" + error_suffix)
        else:
            raise Exception("ERROR: LODSW/LW32 parameters should be exactly 3" + error_suffix)
    elif ("lsl" in code) or ("lss" in code):
        code_split = list(filter(None, code.replace(',', ' ').split(' ')))
        inst_type = InstType.IMMI_H
        if len(code_split) == 4:
            dest = code_split[1]
            const = code_split[3]
            dest_type = get_operand_type(dest)
            const_type = get_operand_type(const)
            option = 0
            if "lsl" in code:
                inst_type = InstType.IMMI_L
            if code_split[2] == 'z':
                option = 1
            elif code_split[2] != 'nz':
                raise Exception("ERROR: Unknown zero flag" + error_suffix)
            if const_type != OperandType.NUMERICAL:
                if is_constant(const, const_list):
                    const = get_constant(const, const_list).get_string_value(10)
                else:
                    raise Exception("ERROR: Unknown constant value" + error_suffix)
            if const.startswith('0x'):
                const = str(int(const, 16))
            elif const.startswith('0b'):
                const = str(int(const, 2))
            if int(const) > 65535:
                raise Exception("ERROR: Constant value too big (" + const + "), max value is 65535" + error_suffix)
            if dest_type != OperandType.REGISTER:
                raise Exception("ERROR: Destination should be a register" + error_suffix)
            else:
                return Instruction(inst_type, "r0", "0000", dest, option, 0, const, -1)
    else:
        raise Exception("ERROR: Unknown Instruction" + error_suffix)





