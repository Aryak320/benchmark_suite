import pandas as pd
import plotly.graph_objects as go
import plotly.io
plotly.io.kaleido.scope.mathjax = None
# Load the data from the CSV file
df = pd.read_csv('scale_provsql_probabilities_tpch.csv')

# Initialize a single figure
fig = go.Figure()

# Define a list of unique marker symbols for each query
markers = ['circle', 'square', 'diamond', 'cross', 'x', 'triangle-up', 'triangle-down']
unique_queries = df['query'].unique()

# Loop over each unique query and add a trace with a different marker
for i, query in enumerate(unique_queries):
    query_data = df[df['query'] == query]
    legend_name = query.replace('_probab', '') 
    # Add a trace for each query with a unique marker symbol
    fig.add_trace(
        go.Scatter(
            x=query_data['scale_factor'],
            y=query_data['prob_eval(s)'],
            mode='lines+markers',
            name=legend_name,
            marker=dict(symbol=markers[i % len(markers)],size=20)  # Cycle through markers
        )
    )
fig.update_xaxes(range=[0, 11], type="linear",titlefont={'size':30},title_standoff=10,title_text="Scale factor",tickfont=dict(size=30),tickvals=[1,2,3,4,5,6,7,8,9,10])
fig.update_yaxes(type="log",titlefont={'size':30},title_standoff=0.005,title_text="Execution time(s)",tickfont=dict(size=30),tickvals=[0.1,1,10,100] )


fig.update_layout(
    height=1000,  # Adjust height dynamically based on number of queries
    width =1300,
    #legend_title="TPC-H Queries",
    template="plotly_white",
       legend=dict(
        orientation="h",  # Horizontal layout
        yanchor="bottom",  # Anchor the legend to the bottom
        y=-0.3,
        xanchor="center",  # Center horizontally
        x= 0.48,
        font=dict(
            family="Courier",
            size=36,
            color="black"
        )
    )
)

fig.update_annotations(font_size=30)
# Show the figure
fig.update_traces(line={'width': 4})

plotly.io.write_image(fig, 'probabilities_tpch_provsql.pdf', format='pdf')
