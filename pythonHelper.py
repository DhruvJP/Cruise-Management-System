print("Enter/Paster your content. Ctrl+D to convert")
content = []
while True:
    try:
        line = input()
    except EOFError:
        break
    words = line.split()
    line = ['\'' + w + '\'' for w in words]
    line = '(' + ', '.join(line) + ')'
    content.append(line)
print('\n\n\n')
print(',\n'.join(content))