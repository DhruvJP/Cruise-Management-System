print("Enter/Paster your content. Ctrl+D to convert. All data fields must be filled for optimal usage")
# This will not work for content with empty values (datpoints may appear out of order)
content = []
while True:
    try:
        line = input()
    except EOFError:
        break
    # Split by word
    words = line.split('\t')
    # Add apostrophes to each word to turn into string
    line = ['\'' + w + '\'' for w in words]
    # Make each line a single entry by adding parentheses and the comma delimiter
    line = '(' + ', '.join(line) + ')'
    content.append(line)
print('\n\n\n')
# Spit out the output that can be used for strings
print(',\n'.join(content))