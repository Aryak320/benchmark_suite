import pandas as pd
import plotly.graph_objects as go
import plotly.io
import re

plotly.io.kaleido.scope.mathjax = None

df = pd.read_csv('scale_provsql_probabilities_tpch.csv')

fig = go.Figure()

markers = ['circle-open', 'square-open', 'diamond-open', 'circle-cross-open', 'diamond-cross-open', 'triangle-up-open', 'triangle-down-open']

colors = ['magenta', 'darkorange', 'red', 'green', 'darkblue', 'teal', 'deeppink']

unique_queries = df['query'].unique()

for i, query in enumerate(unique_queries):
    query_data = df[df['query'] == query]
    
    match = re.search(r'(\d+)', query)  # This will match the digits in the query name
    if match:
        query_number = match.group(1)
        legend_name = f"Query {query_number}"  # Format the legend name
    else:
        legend_name = query  # In case the format is unexpected, fall back to the original name
    
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

fig.update_xaxes(range=[0, 11],showline=True, type="linear", titlefont={'size':30}, title_standoff=10, title_text="Scale factor", tickfont=dict(size=30), tickvals=[1,2,3,4,5,6,7,8,9,10])
fig.update_yaxes(range=[0,3],zeroline=True,autorange=False,type="log", titlefont={'size':30}, title_standoff=0.005, title_text="Execution time (s)", tickfont=dict(size=30), tickvals=[1,10,100,1000])

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


fig.update_traces(line={'width': 3})

plotly.io.write_image(fig, 'probabilities_tpch_provsql.pdf', format='pdf')
