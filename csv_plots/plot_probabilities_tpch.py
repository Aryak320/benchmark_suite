import pandas as pd
import plotly.graph_objects as go
import plotly.io
import re

plotly.io.kaleido.scope.mathjax = None

# Load the data from the CSV file
df = pd.read_csv('scale_provsql_probabilities_tpch.csv')

# Initialize a single figure
fig = go.Figure()

# Define a list of unique marker symbols for each query
markers = ['circle-open', 'square-open', 'diamond-open', 'circle-cross-open', 'diamond-cross-open', 'triangle-up-open', 'triangle-down-open']

# Define a list of custom colors
colors = ['magenta', 'darkorange', 'red', 'green', 'darkblue', 'teal', 'deeppink']

# Extract unique queries
unique_queries = df['query'].unique()

# Loop over each unique query and add a trace with a different marker and color
for i, query in enumerate(unique_queries):
    query_data = df[df['query'] == query]
    
    # Extract the numeric part from the query (e.g., from '3.sql' to 'Query 3')
    match = re.search(r'(\d+)', query)  # This will match the digits in the query name
    if match:
        query_number = match.group(1)
        legend_name = f"Query {query_number}"  # Format the legend name
    else:
        legend_name = query  # In case the format is unexpected, fall back to the original name
    
    # Add a trace for each query with a unique marker symbol and custom color
    fig.add_trace(
        go.Scatter(
            x=query_data['scale_factor'],
            y=query_data['prob_eval(s)'],
            mode='lines+markers',
            name=legend_name,
            marker=dict(symbol=markers[i % len(markers)], size=20,line=dict(width=3), color=colors[i % len(colors)]),  # Use custom colors
            line=dict(color=colors[i % len(colors)], width=4)  # Apply custom line color
        )
    )

# Update axis and layout properties
fig.update_xaxes(range=[0, 11],showline=True, type="linear", titlefont={'size':30}, title_standoff=10, title_text="Scale factor", tickfont=dict(size=30), tickvals=[1,2,3,4,5,6,7,8,9,10])
fig.update_yaxes(range=[-2,2],zeroline=True,autorange=False,type="log", titlefont={'size':30}, title_standoff=0.005, title_text="Execution time (s)", tickfont=dict(size=30), tickvals=[0.01,0.1,1,10,100])

fig.update_layout(
    height=950,  # Adjust height dynamically based on the number of queries
    width=800,
    template="plotly_white",
    legend=dict(
        orientation="h",  # Horizontal layout
        yanchor="bottom",  # Anchor the legend to the bottom
        y=-0.26,
        xanchor="center", # Center horizontally
        x=0.40,
        font=dict(
            size=29,
            color="black"
        )
    )
)

fig.update_annotations(font_size=30)

# Show the figure
fig.update_traces(line={'width': 3})

# Save the figure as a PDF
plotly.io.write_image(fig, 'probabilities_tpch_provsql.pdf', format='pdf')
