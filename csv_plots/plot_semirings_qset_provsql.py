import plotly.graph_objects as go
import pandas as pd
import numpy as np

# Load the data
data = pd.read_csv('scale_semirings.csv')

# Define colors and markers for each semiring
colors = {'formula(s)': 'darkblue', 'counting(s)': 'orange', 'why(s)': 'red'}
markers = {'formula(s)': 'circle-open-dot', 'counting(s)': 'diamond-open', 'why(s)': 'square-open'}
legend_names = {'formula(s)': 'Formula', 'counting(s)': 'Counting', 'why(s)': 'Why(X)'}

# Calculate y-axis tick values starting from 1
y_min = max(1, data[['formula(s)', 'counting(s)', 'why(s)']].min().min())  # Ensure minimum is at least 1
y_max = data[['formula(s)', 'counting(s)', 'why(s)']].max().max()
#tickvals = [10**i for i in range(int(np.floor(np.log10(y_min))), int(np.ceil(np.log10(y_max)) + 1))]

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
                size=25 if semiring == 'formula(s)' else 14 if semiring == 'counting(s)' else 17,
                line=dict(width=2, color='DarkSlateGrey')
            ),
            line=dict(color=colors[semiring], width=4),
            legendgroup=semiring
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
        y=-0.25,  # Push below the chart
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
    type="linear"  # Set y-axis to logarithmic scale
    #tickvals=[100,1000,10000],  # Use tick values starting from 1
    #ticktext=[f"{val:g}" for val in tickvals],  # Format tick labels
    #range=[1, np.ceil(np.log10(y_max))]  # Force y-axis to start at log10(1) = 0
)

# Save the figure as a PDF
import plotly.io as pio
pio.kaleido.scope.mathjax = None
pio.write_image(fig, 'qset_semirings_provsql.pdf', format='pdf')
