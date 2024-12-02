import plotly.graph_objects as go
import pandas as pd
import numpy as np
import plotly.io as pio

# Disable MathJax for exporting
pio.kaleido.scope.mathjax = None

# Load the data
data = pd.read_csv('scale_semirings.csv')

# Define colors and markers for each semiring
colors = {'formula(s)': 'darkblue', 'counting(s)': 'darkorange', 'why(s)': 'red'}
markers = {'formula(s)': 'circle-open-dot', 'counting(s)': 'diamond-tall', 'why(s)': 'square'}
legend_names = {'formula(s)': 'Formula', 'counting(s)': 'Counting', 'why(s)': 'Why(X)'}

# Create the figure
fig = go.Figure()

# Add traces for each semiring
for semiring in ['formula(s)', 'counting(s)', 'why(s)']:
    fig.add_trace(
        go.Scatter(
            x=data['scale_factor'],
            y=data[semiring],
            mode='lines+markers',
            name=legend_names[semiring],
            opacity=0.9,
            marker=dict(
                symbol=markers[semiring],
                size=25 if semiring == 'formula(s)' else 24 if semiring == 'counting(s)' else 10,
                line=dict(color=colors[semiring],width =4 if semiring == 'formula(s)' else 2 if semiring == 'counting(s)' else 1)
            ),
            line=dict(color=colors[semiring], width=3),
            legendgroup=semiring
        )
    )

# Load the second data file for provenance circuit computation
prov_data = pd.read_csv('provsql_qset_annotations_overhead.csv')

# Add trace for provenance circuit computation
fig.add_trace(
    go.Scatter(
        x=prov_data['scale_factor'],
        y=prov_data['provenance(s)'],
        mode='lines+markers',
        opacity=0.9,
        name="Provenance Circuit Computation",
        marker=dict(
            symbol='circle',
            size=16,
            line=dict(width=2, color='magenta')
        ),
        line=dict(color='magenta', width=3),
        legendgroup="Provenance Circuit Computation"  # Separate legend group
    )
)

# Update layout
fig.update_layout(
    height=700,
    width=1100,
    title_font_size=20,
    template="plotly_white",
    legend=dict(
        title=dict(
            text="Semiring instantiations:",  # Set legend title
            font=dict(size=30)
        ),
        orientation="h",  # Horizontal legend
        yanchor="bottom",
        y=-0.6,  # Push below the chart
        xanchor="center",
        x=0.5,
        font=dict(
            size=30,
            color="black"
        )
    ),
    margin=dict(l=50, r=50, t=50, b=100)  # Add space for the legend
)

# Update axes
fig.update_xaxes(
    title_text="Scale factor",
    titlefont=dict(size=27),
    tickfont=dict(size=30),
    tickvals=sorted(data['scale_factor'].unique())  # Unique scale factors as ticks
)
fig.update_yaxes(
    title_text="Execution time (s)",
    titlefont=dict(size=27),
    tickfont=dict(size=30),
    type="log",
    tickvals=[0,1,10,100,1000,10000]  # Set y-axis to linear scale
)

# Save the figure as a PDF
pio.write_image(fig, 'qset_semirings_provsql.pdf', format='pdf')
