import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import plotly.io

plotly.io.kaleido.scope.mathjax = None

data = pd.read_csv('scale_avg_semirings_tpch.csv')

data['query_label'] = data['query'].str.extract(r'(\d+)_')[0].astype(int)  # Extract numeric part
unique_queries = data['query_label'].unique()
unique_queries.sort()
n_queries = len(unique_queries)

fig = make_subplots(
    rows=3,
    cols=2,
    subplot_titles=[f"Query {q}" for q in unique_queries],
    horizontal_spacing=0.1,
    vertical_spacing=0.1
)

colors = {'formula(s)': 'darkblue', 'counting(s)': 'orange', 'why(s)': 'red'}
markers = {'formula(s)': 'circle-open-dot', 'counting(s)': 'diamond-tall', 'why(s)': 'square'}
legend_names = {'formula(s)': 'Formula', 'counting(s)': 'Counting', 'why(s)': 'Why(X)'}

for i, query in enumerate(unique_queries):
    query_data = data[data['query_label'] == query]
    row = (i // 2) + 1
    col = (i % 2) + 1

    for semiring in ['formula(s)', 'counting(s)', 'why(s)']:
        fig.add_trace(
            go.Scatter(
                x=query_data['scale_factor'],
                y=query_data[semiring],
                mode='lines+markers',
                name=legend_names[semiring],  # Use updated legend names
                opacity=0.9,
                marker=dict(
                    symbol=markers[semiring],
                    size=29 if semiring == 'formula(s)' else 33 if semiring == 'counting(s)' else 15,
                    line=dict(color=colors[semiring],width =4 if semiring == 'formula(s)' else 2 if semiring == 'counting(s)' else 1)
                    
                ),
                line=dict(color=colors[semiring], width=3),
                legendgroup='Semirings:',  # Group legends by updated names
                showlegend=i == 0  # Show legend only once
            ),
            row=row, col=col
        )

prov_data = pd.read_csv('s_tpch_prov.csv')

prov_data['query_label'] = prov_data['query'].str.extract(r'(\d+)_')[0].astype(int)

for i, query in enumerate(unique_queries):
    query_data = prov_data[prov_data['query_label'] == query]
    if query_data.empty:  # Skip if the query is not in prov_data
        continue
    row = (i // 2) + 1
    col = (i % 2) + 1

    fig.add_trace(
        go.Scatter(
            x=query_data['scale_factor'],
            y=query_data['time(s)'],
            mode='lines+markers',
            name="Provenance Circuit Computation",
            opacity=0.9,
            marker=dict(
                symbol='circle',
                size=5,
                line=dict(width=1, color='magenta')
            ),
            line=dict(color='magenta', width=1),
            legendgroup="Provenance Circuit Computation",
            showlegend=i == 0  # Show legend only once
        ),
        row=row, col=col
    )
    fig.update_xaxes(
    title_text="Scale factor",
    titlefont=dict(size=33),
    tickfont=dict(size=33),
    showline=True,
    row=row, col=col
    #tickvals=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    )   

# Update layout
fig.update_layout(
    height=2100,
    width=1600,  # Adjust width for 2 columns
    title_font_size=30,
    template="plotly_white",
    legend=dict(
        title=dict(
            text="Semiring instantiations:",  # Set legend title
            font=dict(size=30)
        ),
        orientation="v",  # Horizontal legend
        yanchor="bottom",
        y=0.1,  # Push below the chart
        xanchor="right",
        x=1,
        font=dict(
            size=35,
            color="black"
        )
    ),
    margin=dict(l=50, r=50, t=50, b=100)  # Add space for the legend
)


fig.update_yaxes(
    title_text="Execution time (s)",
    titlefont=dict(size=33),
    showline=True,
    tickfont=dict(size=33),
    type="linear"  # Set y-axis to linear scale
)
# fig.update_yaxes(
#     range=[0, 0.2],
#     row=4,
#     col=1
# )
fig.update_yaxes(
    range=[0, 250],
    tickvals=[0,50,100,150,200,250],
    row=2,
    col=1
)
# fig.update_yaxes(
#      range=[0, 3.5],
#      row=3,
#     col=1
# )
fig.update_yaxes(
    tickvals=[0,10,20,30,40,50],
    row=1,
    col=1,
)
fig.update_yaxes(
    tickvals=[0,10,20,30,40,50],
    row=2,
    col=2,
)
# fig.update_yaxes(
#     tickvals=[0,0.2,0.4,0.6,0.8],
#     row=1,
#     col=1,
# )
fig.update_annotations(font_size=24)
#fig.update_traces(line={'width': 4})

plotly.io.write_image(fig, 'semirings_tpch.pdf', format='pdf')
