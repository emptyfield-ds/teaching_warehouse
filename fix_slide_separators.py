#!/usr/bin/env python3
import re
import sys

def fix_slide_separators(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    lines = content.split('\n')
    new_lines = []
    
    # Track if we're in YAML header
    yaml_count = 0
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Count YAML delimiters
        if line.strip() == '---':
            yaml_count += 1
            if yaml_count <= 2:  # Keep first two --- for YAML header
                new_lines.append(line)
            else:
                # This is a slide separator
                # Look ahead to see what follows
                next_non_empty = None
                j = i + 1
                while j < len(lines) and lines[j].strip() == '':
                    j += 1
                if j < len(lines):
                    next_non_empty = lines[j]
                
                # If next line starts with ##, it's already a heading
                if next_non_empty and next_non_empty.strip().startswith('##'):
                    # Just remove the ---
                    pass
                else:
                    # Replace --- with ##
                    new_lines.append('##')
        else:
            new_lines.append(line)
        
        i += 1
    
    # Join lines back
    return '\n'.join(new_lines)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        filename = sys.argv[1]
        fixed_content = fix_slide_separators(filename)
        with open(filename, 'w') as f:
            f.write(fixed_content)
        print(f"Fixed {filename}")
    else:
        print("Usage: fix_slide_separators.py <filename>")