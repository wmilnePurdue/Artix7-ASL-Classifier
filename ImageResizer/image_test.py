from PIL import Image

def jpg_to_rgb_hex(image_path):
    img = Image.open(image_path).convert('RGB')
    w, h = img.size
    hex_colors = []
    for y in range(h):
        row = []
        for x in range(w):
            r, g, b = img.getpixel((x, y))
            hex_color = "#{:02x}{:02x}{:02x}".format(r, g, b)
            row.append(hex_color)
        hex_colors.append(row)
    return hex_colors

def rgb_to_jpg(hex_data, output_path):
    h = len(hex_data)
    w = len(hex_data[0])

    img = Image.new('RGB', (w, h))

    for y in range(h):
        for x in range(w):
            hex_color = hex_data[y][x]
            rgb = tuple(int(hex_color[i:i+2], 16) for i in (1, 3 ,5))
            img.putpixel((x, y), rgb)
    img.save(output_path)

def get2d_hex(i_val):
    if i_val > 255:
        return "FF"
    hh = hex(i_val).replace("0x","")
    while len(hh) < 2:
        hh = "0" + hh
    return hh

def split_hex(hex_str):
    return [hex_str[i:i+2] for i in range(0, 6, 2)]

in_path = "C:\\Users\\Michael\\Downloads\\Sample_VGA2.jpg"
out_path = "C:\\Users\\Michael\\Documents\\ECE56800\\Pictures\\Sample_process.jpg"
bin_path = "C:\\Users\\Michael\\Documents\\ECE56800\\Pictures\\Sample_bin.jpg"
rec_path = "C:\\Users\\Michael\\Documents\\ECE56800\\Pictures\\Sample_rec.jpg"
txt_path = "C:\\Users\\Michael\\Documents\\ECE56800\\Pictures\\image.hex"

image_hex = jpg_to_rgb_hex(in_path)

cropped_hex = []
ch = len(image_hex)
cw = len(image_hex[0])

first_print = True
for y in range(ch):
    nrow = []
    for x in range(cw):
        if (x >= 80) and (x < 560):
            if y < 20:
                if x < 320:
                    nrow.append("#ff0000")
                else:
                    nrow.append("#000000")
            elif y < 40:
                nrow.append("#00ff00")
            elif y < 60:
                nrow.append("#0000ff")
            elif y < 80:
                nrow.append("#000000")
            elif y < 100:
                nrow.append("#ffffff")
            else:
                nrow.append(image_hex[y][x])
            if not first_print:
                print(image_hex[y][x])
                first_print = True
    cropped_hex.append(nrow)

rgb_to_jpg(cropped_hex, out_path)

cropped_hex = []
for ny in range(ch):
    nrow = []
    for nx in range(cw):
        if (nx >= 80) and (nx < 560):
            pxl = image_hex[ny][nx].replace("#","0x")
            pxl_int = int(pxl, 16)
            pxl_del = pxl_int & int("0xF8F8F8", 16)
            pxl_res = "#" + f"{pxl_del:06X}"
            #pxl_bin = bin(int('0x' + pxl, 16)).replace('0b','')
            if first_print:
                first_print = False
                print(image_hex[ny][nx])
                print(pxl_res)
            nrow.append(pxl_res)
    cropped_hex.append(nrow)

pxl_bin = []
first_print = True
for ny in range(32):
    pxl_bin_row = []
    for nx in range(32):
        pxl_val = ""
        r_pxl = 0
        g_pxl = 0
        b_pxl = 0
        for py in range (15):
            for px in range(15):
                sx = nx*15 + px
                sy = ny*15 + py
                pxl_str = cropped_hex[sy][sx].replace("#",'')
                pxl_splt = split_hex(pxl_str)
                r_pxl = r_pxl + int( int('0x' + pxl_splt[0], 16) / 8)
                g_pxl = g_pxl + int( int('0x' + pxl_splt[1], 16) / 8)
                b_pxl = b_pxl + int( int('0x' + pxl_splt[2], 16) / 8)
                if first_print:
                    first_print = False
                    print(pxl_str)
                    print(pxl_splt)
                    print(pxl_splt[0])
                    print(pxl_splt[1])
                    print(pxl_splt[2])
                    print(r_pxl)
                    print(g_pxl)
                    print(b_pxl)
        #print("RGB["+str(ny)+"]["+str(nx)+"] = " + str(r_pxl), ", " + str(g_pxl) + ", " + str(b_pxl))
        r_pxl = get2d_hex(int(r_pxl / 15))
        g_pxl = get2d_hex(int(g_pxl / 15))
        b_pxl = get2d_hex(int(b_pxl / 15))
        pxl_bin_row.append("#" + r_pxl + g_pxl + b_pxl)
    pxl_bin.append(pxl_bin_row)

#rgb_to_jpg(cropped_hex, out_path)
rgb_to_jpg(pxl_bin, bin_path)
#for row in hex_data[:5]:
#    print(row[:10])

txt_file = open(txt_path, 'w')
for ny in range(ch):
    for nx in range(cw):
        txt_file.write(image_hex[ny][nx].replace("#","") + "\n")

txt_file.close()

txt_file = open(txt_path, 'r')
rec_img = []
for ny in range(int(ch/2)):
    rec_row = []
    for nx in range(cw):
        rec_row.append("#" + txt_file.readline())
    rec_img.append(rec_row)

rgb_to_jpg(rec_img, rec_path)