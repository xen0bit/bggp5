
def getHtmlStub():
    t = ''
    with open('templates/htmlStub.html', 'r') as f:
        t = f.read()

    t = t.replace('\r', '')
    t = t.replace('\n', '')
    t = t.replace('\t', '')
    return t

with open('templates/template.wat', 'r') as wat:
    watStr = wat.read()
    with open('out/rendered.wat', 'w') as renderedWat:
        renderedWat.write(watStr.format(
            htmlStub=getHtmlStub()
        ))

