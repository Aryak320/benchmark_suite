import sys
import os

def process_sql_file(input_file):
    # Determine the output file name
    output_file = os.path.splitext(input_file)[0] + '_probab.sql'

    with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
        query = ''
        for line in f_in:
            # Remove leading and trailing whitespace
            line = line.strip()
            
            # Skip comment lines
            if line.startswith('--'):
                continue
            
            # Add the line to the current query, followed by a space
            query += line + ' '
            
            # If the line ends with a semicolon, it's the end of the query
            if line.endswith(';'):
                # Remove the semicolon and any trailing whitespace
                query = query.rstrip(' ;')
                
                # Wrap the query
                wrapped_query = f"SELECT *, probability_evaluate(provenance()) FROM ( {query} )t;\n"
                
                # Write the wrapped query to the output file
                f_out.write(wrapped_query)
                
                # Reset the query
                query = ''

# Usage
if __name__ == "__main__":
    process_sql_file(sys.argv[1])

