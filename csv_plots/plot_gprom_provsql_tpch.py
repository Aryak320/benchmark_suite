import plotly.graph_objects as go
import pandas as pd
import plotly.io as pio

# Disable MathJax for exporting
pio.kaleido.scope.mathjax = None

# Load the data
gprom_data = pd.read_csv('scale_gprom_tpch.csv')
no_prov_data = pd.read_csv('s_tpch_no_prov.csv')
prov_data = pd.read_csv('s_tpch_prov.csv')
semirings_data = pd.read_csv('scale_avg_semirings_tpch.csv')

# Filter data for Query 3
query = '3_tpch.sql'
gprom_query3 = gprom_data[gprom_data['query'] == query]
no_prov_query3 = no_prov_data[no_prov_data['query'] == query]
prov_query3 = prov_data[prov_data['query'] == query]
semirings_query3 = semirings_data[semirings_data['query'] == query]

# Define colors and markers
colors = {
    'GPROM': 'blue',
    'Prov': 'darkorange',
    'No Prov': 'black',
    'Why(s)': 'red'
}
markers = {
    'GPROM': 'circle-open-dot',
    'Prov': 'diamond-tall',
    'No Prov': 'circle',
    'Why(s)': 'square'
}

# Create the figure
fig = go.Figure()

# Add GPROM data
fig.add_trace(
    go.Scatter(
        x=gprom_query3['scale_factor'],
        y=gprom_query3['time(s)'],
        mode='lines+markers',
        name="GProM",
        marker=dict(
            symbol=markers['GPROM'],
            size=12,
            color=colors['GPROM']
        ),
        line=dict(color=colors['GPROM'], width=3)
    )
)

# Add Prov data
fig.add_trace(
    go.Scatter(
        x=prov_query3['scale_factor'],
        y=prov_query3['time(s)'],  # Time(s) column from s_tpch_prov.csv
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
        x=semirings_query3['scale_factor'],
        y=semirings_query3['why(s)'],
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
        x=no_prov_query3['scale_factor'],
        y=no_prov_query3['time(s)'],  # Time(s) column from s_tpch_no_prov.csv
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
    height=1100,
    width=700,
    title_font_size=12,
    template="plotly_white",
    legend=dict(
        title=dict(
            font=dict(size=30)
        ),
        orientation="h",
        yanchor="bottom",
        y=-0.2,
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
    tickvals=[1,2,3,4,5,6,7,8,9,10],
    showline=True
)
fig.update_yaxes(
    title_text="Execution Time (s)",
    titlefont=dict(size=18),
    tickfont=dict(size=22),
    type="log",
    showline=True,
    #tickvals=[0.1,1,10,100,1000] # Set y-axis to logarithmic scale

)

fig.show()
# Save the figure as a PDF
pio.write_image(fig, 'gprom_tpch.pdf', format='pdf')
