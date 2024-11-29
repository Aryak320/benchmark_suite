import plotly.graph_objects as go
import pandas as pd

# Load the data
data = pd.read_csv('scale_semirings.csv')
print(data['formula(s)'])
# Define colors and markers for each semiring
colors = {'formula(s)': 'darkblue', 'counting(s)': 'orange', 'why(s)': 'red'}
markers = {'formula(s)': 'circle-open-dot', 'counting(s)': 'diamond-open', 'why(s)': 'square-open'}

# Create the figure
fig = go.Figure()

# Add traces for each semiring
for semiring in ['formula(s)', 'counting(s)', 'why(s)']:
    fig.add_trace(
        go.Scatter(
            x=data['scale_factor'],
            y=data[semiring],
            mode='lines+markers',
            name=semiring,
            opacity=0.9,
            marker=dict(
                symbol=markers[semiring],
                size=22 if semiring == 'formula(s)' else 17,
                line=dict(width=2, color='DarkSlateGrey')
            ),
            line=dict(color=colors[semiring], width=2),
            legendgroup=semiring
        )
    )

# Update layout
fig.update_layout(
    height=800,
    width=1200,
    title_text="Semiring Execution Times",
    title_font_size=20,
    template="plotly_white",
    legend=dict(
        orientation="h",  # Horizontal legend
        yanchor="bottom",
        y=-0.15,  # Push below the chart
        xanchor="center",
        x=0.5,
        font=dict(
            family="Courier",
            size=18,
            color="black"
        )
    ),
    margin=dict(l=50, r=50, t=50, b=100)  # Add space for the legend
)

# Update axes
fig.update_xaxes(
    title_text="Scale factor",
    tickfont=dict(size=12),
    tickvals=sorted(data['scale_factor'].unique())  # Unique scale factors as ticks
)
fig.update_yaxes(
    title_text="Execution time(s)",
    tickfont=dict(size=12),
    type="linear"  # Keep y-axis linear as in the original
)

# Save the figure as a PDF
import plotly.io as pio
pio.write_image(fig, 'single_plot_semirings_tpch.pdf', format='pdf')

# Show the plot
fig.show()
