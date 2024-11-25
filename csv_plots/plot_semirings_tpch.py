import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import plotly.io

# Load the data
data = pd.read_csv('scale_semirings_tpch.csv')

# Extract unique queries and count
unique_queries = data['query'].unique()
n_queries = len(unique_queries)

# Define subplot layout: 4 rows, 2 columns
fig = make_subplots(
    rows=4,
    cols=2,
    subplot_titles=[q for q in unique_queries],
    horizontal_spacing=0.15,
    vertical_spacing=0.1
)

# Define colors and markers for each semiring
colors = {'formula(s)': 'darkblue', 'counting(s)': 'orange', 'why(s)': 'green'}
markers = {'formula(s)': 'circle', 'counting(s)': 'diamond', 'why(s)': 'square'}

# Add traces for each query
for i, query in enumerate(unique_queries):
    query_data = data[data['query'] == query]
    row = (i // 2) + 1
    col = (i % 2) + 1

    for semiring in ['formula(s)', 'counting(s)', 'why(s)']:
        fig.add_trace(
            go.Scatter(
                x=query_data['scale_factor'],
                y=query_data[semiring],
                mode='lines+markers',
                name=semiring,
                marker=dict(symbol=markers[semiring], size=8),
                line=dict(color=colors[semiring], width=2),
                legendgroup=semiring,
                showlegend=i == 0  # Show legend only once
            ),
            row=row, col=col
        )

# Update layout
fig.update_layout(
    height=1200,  # Adjust height for 4 rows
    width=800,    # Adjust width for 2 columns
    title="Semiring Execution Times for TPCH Queries",
    title_font_size=20,
    template="plotly_white",
    legend=dict(
        orientation="h",  # Horizontal legend
        yanchor="bottom",
        y=-0.2,  # Push below the chart
        xanchor="center",
        x=0.5,
        font=dict(size=14)
    ),
    margin=dict(l=50, r=50, t=50, b=100)  # Add space for the legend
)

# Update axes
fig.update_xaxes(title_text="Scale factor", tickfont=dict(size=12))
fig.update_yaxes(
    title_text="Execution time (s)", 
    tickfont=dict(size=12),
    type="log",  # Set y-axis to logarithmic scale
    tickvals=[0.1, 1, 10, 100, 1000]  # Custom ticks for readability
)

# Save the figure
plotly.io.write_image(fig, 'semirings_tpch.pdf', format='pdf')
