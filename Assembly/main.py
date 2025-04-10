from Instruction import parse, InstType
from constant_class import ConstType, Const

raw_program = open("prog.asm", "r")
f = open("prog.coe", "w")
code = raw_program.readline()
codeline = 1
progline = 0
const_list = []
pointer_list = []
instruction_list = []

while code:
    code = code.replace("\n",'')
    if not(code.startswith(';')) and (code.strip() != ''):
        error_suffix = "\n at line : " + str(codeline) + " -- " + code
        if code.startswith('bound'):
            code_split = list(filter(None, code.split(' ')))
            if len(code_split) == 3:
                const_type = ConstType.DECIMAL
                if code_split[2].startswith('0x'):
                    const_type = ConstType.HEXADECIMAL
                if any(c.islower() for c in code_split[1]):
                    raise Exception("ERROR: constant names must be ALL caps" + error_suffix)
                try:
                    const_list.append(Const(const_type, code_split[1], code_split[2]))
                except:
                    raise Exception("ERROR: cannot determine constant value" + error_suffix)
            else:
                raise Exception("ERROR: cannot set constant properly" + error_suffix)
        elif ':' in code:
            code_split = code.strip()
            if code_split.endswith(':'):
                pointer_list.append(Const(ConstType.DECIMAL, code_split.replace(":",''), str(progline)))
        else:
            instruction_list.append(parse(code, codeline,const_list))
            progline = progline + 1

    code = raw_program.readline()
    codeline = codeline + 1

if len(instruction_list) != 0:
    for inst in instruction_list:
        if inst.inst_type == InstType.JEQ or inst.inst_type == InstType.JNEQ  or inst.inst_type == InstType.JLT or inst.inst_type == InstType.JGR or inst.inst_type == InstType.CALL:
            if len(pointer_list) != 0:
                prog_found = 0
                for prog_marker in pointer_list:
                    if inst.const_string == prog_marker.name:
                        #print("const found: " + inst.const_string + " value is: " + str(prog_marker.value))
                        if isinstance(prog_marker.value, int):
                            inst.const_value = prog_marker.value
                        else:
                            inst.const_value = int(prog_marker.value)
                        prog_found = 1
                        break
                if not prog_found:
                    raise Exception("ERROR: Unknown Jump Location - " + inst.const_string)
            else:
                raise Exception("ERROR: Unknown Jump Location - " + inst.const_string)
else:
    raise Exception("ERROR: No instructions found")

f.write("memory_initialization_radix = 16;\n")
f.write("memory_initialization_vector=")
line_count = 1
for inst in instruction_list:
    print(inst.getHex())
    if len(inst.getHex()) != 8:
        raise Exception("ERROR: instruction size must be = 32 bits" + inst.getHex())
    if line_count == len(instruction_list):
        f.write(inst.getHex())
    else:
        f.write(inst.getHex() + ",\n")
    line_count = line_count + 1
f.write(";")
f.close()

num_inst = len(instruction_list);
print("Total program size: " + str(num_inst) + "x32b or "  + str(num_inst*4) + "B")


