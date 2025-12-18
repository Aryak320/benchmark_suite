import plotly.graph_objects as go
import pandas as pd
import plotly.io

plotly.io.kaleido.scope.mathjax = None

data = pd.read_csv('provsql_qset_annotations_overhead.csv')

data['overhead'] = data['provenance(s)'] / data['withoutprov(s)']

colors = {'provenance(s)': 'orange', 'withoutprov(s)': 'darkmagenta'}
markers = {'provenance(s)': 'circle-dot', 'withoutprov(s)': 'diamond-tall'}

fig = go.Figure()

for column, color in colors.items():
    fig.add_trace(
        go.Scatter(
            x=data['scale_factor'],
            y=data[column],
            mode='lines+markers',
            name="with provenance" if column == 'provenance(s)' else "without provenance",
            marker=dict(symbol=markers[column], size=15 if column == 'provenance(s)' else 25),
            line=dict(width=3),
            marker_color=color,
            legendgroup="with provenance" if column == 'provenance(s)' else "without provenance"
        )
    )

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

y_min = data[['provenance(s)', 'withoutprov(s)']].min().min() * 0.5
y_max = data[['provenance(s)', 'withoutprov(s)']].max().max() * 2.5
overhead_y_min = 0
overhead_y_max = 10

fig.update_layout(
    xaxis=dict(
        range=[0, 11],
        title_text="Scale factor",
        titlefont={'size': 30},
        tickfont=dict(size=30),
        tickvals=list(range(1, 11))
    ),
    yaxis=dict(
        range=[1,3],
        type="log",
        title_text="Execution time (s)",
        titlefont={'size': 30},
        tickfont=dict(size=30),
        #autorange=False,
        tickvals=[0.01,0.1,1,10,100,1000]
    ),
    yaxis2=dict(
        range=[0, 5],
        type="linear",
        title_text="Overhead",
        titlefont=dict(size=30,color='blue'),
        tickfont=dict(size=30, color='blue'),
        tickvals=[0,1,2,3,4],
        overlaying="y",  # Overlay the secondary y-axis
        side="right"
    ),
    height=700,
    width=1200,
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

plotly.io.write_image(fig, 'overhead_qset.pdf', format='pdf')


