import plotly.graph_objects as go
import pandas as pd
import plotly.io as pio

# Disable MathJax for exporting
pio.kaleido.scope.mathjax = None

# Load the data
qset_data = pd.read_csv('gprom_qset.csv')

# Define colors and markers
colors = {
    'No Prov': 'black',
    'Prov': 'darkorange',
    'Why(s)': 'red',
    'GPROM Prov': 'blue'
}
markers = {
    'No Prov': 'circle',
    'Prov': 'diamond-tall',
    'Why(s)': 'square',
    'GPROM Prov': 'circle-open-dot'
}

# Create the figure
fig = go.Figure()
# Add GPROM Prov data
fig.add_trace(
    go.Scatter(
        x=qset_data['scale_factor'],
        y=qset_data['gprom_prov(s)'],
        mode='lines+markers',
        name="GProM",
        marker=dict(
            symbol=markers['GPROM Prov'],
            size=12,
            color=colors['GPROM Prov']
        ),
        line=dict(color=colors['GPROM Prov'], width=3)
    )
)
# Add Prov data
fig.add_trace(
    go.Scatter(
        x=qset_data['scale_factor'],
        y=qset_data['prov(s)'],
        mode='lines+markers',
        name="Provenance circuit computation (ProvSQL)",
        marker=dict(
            symbol=markers['Prov'],
            size=15,
            color=colors['Prov'],
            line=dict(color=colors['Prov'], width=1)
        ),
        line=dict(color=colors['Prov'], width=3)
    )
)
# Add Why(s) data
fig.add_trace(
    go.Scatter(
        x=qset_data['scale_factor'],
        y=qset_data['why(s)'],
        mode='lines+markers',
        name="Why(X) semiring (ProvSQL)",
        marker=dict(
            symbol=markers['Why(s)'],
            size=7,
            color=colors['Why(s)'],
            line=dict(color=colors['Why(s)'], width=3)
        ),
        line=dict(color=colors['Why(s)'], width=3)
    )
)


# Add No Prov data
fig.add_trace(
    go.Scatter(
        x=qset_data['scale_factor'],
        y=qset_data['noprov(s)'],
        mode='lines+markers',
        name="Without provenance tracking",
        marker=dict(
            symbol=markers['No Prov'],
            size=5,
            color=colors['No Prov'],
            line=dict(color=colors['No Prov'], width=1.2)
        ),
        line=dict(color=colors['No Prov'], width=1)
    )
)





# Update layout
fig.update_layout(
    height=600,
    width=500,
    title_font_size=12,
    template="plotly_white",
    legend=dict(
        title=dict(
            font=dict(size=30)
        ),
        orientation="h",
        yanchor="bottom",
        y=-0.48,
        xanchor="center",
        x=0.5,
        font=dict(size=17)
    ),
    margin=dict(l=50, r=50, t=50, b=100)
)

# Update axes
fig.update_xaxes(
    title_text="Scale Factor",
    titlefont=dict(size=18),
    tickfont=dict(size=22),
    tickvals=list(range(1, 11)),  # Scale factor values from 1 to 10
    showline=True
)
fig.update_yaxes(
    title_text="Execution Time (s)",
    titlefont=dict(size=18),
    tickfont=dict(size=22),
    type="log",  # Logarithmic scale
    showline=True,
    tickvals=[10,100,1000,10000]
)


# Save the figure as a PDF
pio.write_image(fig, 'gprom_qset.pdf', format='pdf')
