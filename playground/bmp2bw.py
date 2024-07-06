from PIL import Image
# creating a image object
im = Image.open('playground/nanofont3x4.bmp')
width, height = im.size
print(width, height)
pixel_values = list(im.getdata())
line = ''
for p in pixel_values[32*4*3:]:
    if p == 0:
        line+='0'
    else:
        line+='1'

n = 32
c = 0
for chunk in [line[i:i+n] for i in range(0, len(line), n)]:
    print(';; ' + chunk)
    print('i32.const ' + str(int(chunk, 2)))
    print('call $unpackFontWord')
    c+=1
print(c)
