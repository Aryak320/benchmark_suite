import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import plotly.io
plotly.io.kaleido.scope.mathjax = None

# Load the data
data = pd.read_csv('scale_avg_semirings_tpch.csv')

# Extract unique queries and count
data['query_label'] = data['query'].str.extract(r'(\d+)_')[0].astype(int)  # Extract numeric part
unique_queries = data['query_label'].unique()
unique_queries.sort()
n_queries = len(unique_queries)

# Define subplot layout: 4 rows, 2 columns
fig = make_subplots(
    rows=4,
    cols=2,
    subplot_titles=[f"Query {q}" for q in unique_queries],
    horizontal_spacing=0.1,
    vertical_spacing=0.06
)

# Define colors and markers for each semiring
colors = {'formula(s)': 'darkblue', 'counting(s)': 'darkorange', 'why(s)': 'red'}
markers = {'formula(s)': 'circle-open-dot', 'counting(s)': 'diamond-open', 'why(s)': 'square-open'}
legend_names = {'formula(s)': 'Formula', 'counting(s)': 'Counting', 'why(s)': 'Why(X)'}

# Add traces for each query
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
                    size=25 if semiring == 'formula(s)' else 14 if semiring == 'counting(s)' else 17,
                    line=dict(width=2, color='DarkSlateGrey')
                ),
                line=dict(color=colors[semiring], width=2),
                legendgroup=legend_names[semiring],  # Group legends by updated names
                showlegend=i == 0  # Show legend only once
            ),
            row=row, col=col
        )

# Update layout
fig.update_layout(
    height=2500,
    width=1500,  # Adjust width for 2 columns
    title_font_size=20,
    template="plotly_white",
    legend=dict(
        title=dict(
            text="Semiring instantiations:",  # Set legend title
            font=dict(size=30)
        ),
        orientation="h",  # Horizontal legend
        yanchor="bottom",
        y=-0.06,  # Push below the chart
        xanchor="center",
        x=0.5,
        font=dict(
            size=33,
            color="black"
        )
    ),
    margin=dict(l=50, r=50, t=50, b=100)  # Add space for the legend
)

# Update axes
fig.update_xaxes(
    title_text="Scale factor",
    titlefont=dict(size=24),
    tickfont=dict(size=18),
    tickvals=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
)
fig.update_yaxes(
    title_text="Execution time (s)",
    titlefont=dict(size=24),
    tickfont=dict(size=18),
    type="linear"  # Set y-axis to linear scale
)
fig.update_yaxes(
    range=[0,0.5],
    row=4,
    col=1
)
fig.update_yaxes(
    range=[0,1],
    row=1,
    col=1
)
fig.update_yaxes(
    tickvals=[0,200,400,600,800,1000,1200,1400,1500,1600],
    row=1,
    col=2,
)
fig.update_yaxes(
    tickvals=[0,200,400,600,800,1000,1200,1400,1500,1600],
    row=3,
    col=2,
)
fig.update_annotations(font_size=24)
fig.update_traces(line={'width': 4})

# Save the figure
plotly.io.write_image(fig, 'semirings_tpch.pdf', format='pdf')
