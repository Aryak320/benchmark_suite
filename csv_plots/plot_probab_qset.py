import plotly.graph_objects as go
import pandas as pd
import plotly.io as pio

# Disable MathJax for exporting
pio.kaleido.scope.mathjax = None

# Load the probabilities data
prob_data = pd.read_csv('scale_provsql_probabilities.csv')

# Create the figure for probabilities
fig = go.Figure()

# Add trace for probability evaluation
fig.add_trace(
    go.Scatter(
        x=prob_data['scale_factor'],
        y=prob_data['prob_eval(s)'],
        mode='lines+markers',
        name="Probability Evaluation",
        marker=dict(
            symbol='circle',
            size=12,
            line=dict(width=2, color='darkblue')
        ),
        line=dict(color='darkblue', width=3)
    )
)

# Update layout
fig.update_layout(
    height=600,
    width=500,
    title_font_size=20,
    template="plotly_white",
    legend=dict(
        title=dict(
            text="Legend",
            font=dict(size=15)
        ),
        orientation="h",  # Horizontal legend
        yanchor="bottom",
        y=-0.2,  # Push below the chart
        xanchor="center",
        x=0.5,
        font=dict(
            size=15,
            color="black"
        )
    ),
    margin=dict(l=50, r=50, t=50, b=100)
)

# Update axes
fig.update_xaxes(
    showline=True,
    title_text="Scale Factor",
    titlefont=dict(size=24),
    tickfont=dict(size=24),
    tickvals=sorted(prob_data['scale_factor'].unique())
)
fig.update_yaxes(
    range=[2,4],
    showline=True,
    title_text="Execution time (s)",
    type='log',
    titlefont=dict(size=24),
    tickfont=dict(size=24),
    tickvals=[100,1000,10000]
)

# Save the figure as a PDF
pio.write_image(fig, 'provsql_probab_qset.pdf', format='pdf')

