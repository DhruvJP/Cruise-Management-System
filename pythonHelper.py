def general_split():
    print('\nGeneral_split')
    # Empty values become empty strings (ie '')
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
    # Spit out the output
    print(',\n'.join(content))

def split_legs():
    print('\nLeg_list')
    content = []
    recordedLegs = []
    while True:
        try:
            line = input()
        except EOFError:
            break
        legs = line.split(',')
        for leg in legs:
            info = [d.strip() for d in leg.split(':')]
            if info[0] not in recordedLegs:
                recordedLegs.append(info[0])
                info = ['\'' + i + '\'' for i in [info[0], info[1][:3], info[1][-3:], info[2][:-2]]]
                combined = ', '.join(info)
                content.append('(' + combined + ')')
    print('\n\n\n')
    # Spit out the output
    print(',\n'.join(content))

def create_container():
    content = []
    while True:
        try:
            line = input()
        except EOFError:
            break
        data = line.split('\t')
        currRoute = data[0]
        legs = data[1].split(',')
        for i in range(len(legs)):
            entry = [currRoute, legs[i].split(':')[0].strip(), str(i)]
            entry = ['\'' + e + '\'' for e in entry]
            combined = ', '.join(entry)
            content.append('(' + combined + ')')
    
    print('\n\n\n')
    # Spit out the output
    print(',\n'.join(content))

print("After selection, enter or paste your content. Ctrl+D to convert. All data fields must be filled for optimal usage")
cmd = input('Select a command:\n g - general split\n l - leg split\n c - create sequence from leg path\n')
if cmd == 'g':
    general_split()
elif cmd == 'l':
    split_legs()
elif cmd == 'c':
    create_container()