import plotly.graph_objects as go
import pandas as pd
import plotly.io

# Disable MathJax for saving as a PDF
plotly.io.kaleido.scope.mathjax = None

# Load the new dataset
data = pd.read_csv('provsql_qset_annotations_overhead.csv')

# Calculate overhead
data['overhead'] = data['provenance(s)'] / data['withoutprov(s)']

# Define colors and markers
colors = {'provenance(s)': 'orange', 'withoutprov(s)': 'darkmagenta'}
markers = {'provenance(s)': 'circle-dot', 'withoutprov(s)': 'diamond-tall'}

# Create the figure with secondary y-axis
fig = go.Figure()

# Add traces for provenance and without provenance
for column, color in colors.items():
    fig.add_trace(
        go.Scatter(
            x=data['scale_factor'],
            y=data[column],
            mode='lines+markers',
            name="with provenance" if column == 'provenance(s)' else "without provenance",
            marker=dict(symbol=markers[column], size=15 if column == 'provenance(s)' else 25),
            line=dict(width=1.5),
            marker_color=color,
            legendgroup="with provenance" if column == 'provenance(s)' else "without provenance"
        )
    )

# Add the overhead trace
fig.add_trace(
    go.Scatter(
        x=data['scale_factor'],
        y=data['overhead'],
        mode='lines+markers',
        name="overhead",
        marker=dict(symbol='square-open-dot', size=20, line_width=2, color='blue'),
        line=dict(dash='dot', width=5),
        yaxis="y2",  # Assign this trace to the secondary y-axis
        legendgroup="overhead"
    )
)

# Define axis ranges and labels
y_min = data[['provenance(s)', 'withoutprov(s)']].min().min() * 0.5
y_max = data[['provenance(s)', 'withoutprov(s)']].max().max() * 1.5
overhead_y_min = 0
overhead_y_max = 10

fig.update_layout(
    xaxis=dict(
        range=[0, 11],
        title_text="Scale factor",
        titlefont={'size': 26},
        tickfont=dict(size=26),
        tickvals=list(range(1, 11))
    ),
    yaxis=dict(
        #range=[y_min, y_max],
        type="log",
        title_text="Execution time (s)",
        titlefont={'size': 26},
        tickfont=dict(size=26),
        tickvals=[1, 10, 100]
    ),
    yaxis2=dict(
        range=[overhead_y_min, overhead_y_max],
        type="linear",
        title_text="Overhead",
        titlefont={'size': 26},
        tickfont=dict(size=26, color='blue'),
        overlaying="y",  # Overlay the secondary y-axis
        side="right"
    ),
    height=700,
    width=1500,
    template="plotly_white",
    title_font=dict(size=28),
    legend=dict(
        orientation="h",
        yanchor="bottom",
        y=-0.3,
        xanchor="center",
        x=0.5,
        font=dict(size=30)
    )
)

# Save the figure as a PDF
plotly.io.write_image(fig, 'qset_provsql_annotation_overhead.pdf', format='pdf')


