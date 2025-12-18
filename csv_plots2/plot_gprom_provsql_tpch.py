import plotly.graph_objects as go
import pandas as pd
from plotly.subplots import make_subplots
import plotly.io as pio

pio.kaleido.scope.mathjax = None

gprom_data = pd.read_csv('scale_gprom_tpch.csv')
query3_data = pd.read_csv('provsqlq3.csv')
query4_data = pd.read_csv('provsqlq4.csv')

gprom_q3 = gprom_data[gprom_data['query'] == '3_tpch.sql']
gprom_q4 = gprom_data[gprom_data['query'] == '4_tpch.sql']

colors = {
    'GPROM': 'blue',
    'Prov': 'darkorange',
    'No Prov': 'black',
    'Why(s)': 'red'
}
markers = {
    'GPROM': 'circle-open-dot',
    'Prov': 'diamond-tall-open',
    'No Prov': 'circle',
    'Why(s)': 'square'
}

fig = make_subplots(rows=1, cols=2, subplot_titles=("Query 3", "Query 4"))

def add_traces(fig, col, gprom_df, prov_df):
    fig.add_trace(go.Scatter(
        x=gprom_df['scale_factor'],
        y=gprom_df['time(s)'],
        mode='lines+markers',
        name='GProM',
        marker=dict(symbol=markers['GPROM'], size=12, color=colors['GPROM']),
        line=dict(color=colors['GPROM'], width=3),
        legendgroup='GProM',
        showlegend=(col==1)
    ), row=1, col=col)

    fig.add_trace(go.Scatter(
        x=prov_df['scale_factor'],
        y=prov_df['prov(s)'],
        mode='lines+markers',
        name='Provenance circuit computation (ProvSQL)',
        marker=dict(symbol=markers['Prov'], size=15, color=colors['Prov']),
        line=dict(color=colors['Prov'], width=3),
        legendgroup='Prov',
        showlegend=(col==1)
    ), row=1, col=col)

    fig.add_trace(go.Scatter(
        x=prov_df['scale_factor'],
        y=prov_df['why(s)'],
        mode='lines+markers',
        name='Why(X) semiring (ProvSQL)',
        marker=dict(symbol=markers['Why(s)'], size=7, color=colors['Why(s)']),
        line=dict(color=colors['Why(s)'], width=1),
        legendgroup='Why(s)',
        showlegend=(col==1)
    ), row=1, col=col)

    fig.add_trace(go.Scatter(
        x=prov_df['scale_factor'],
        y=prov_df['noprov(s)'],
        mode='lines+markers',
        name='Without provenance tracking',
        marker=dict(symbol=markers['No Prov'], size=5, color=colors['No Prov']),
        line=dict(color=colors['No Prov'], width=1),
        legendgroup='No Prov',
        showlegend=(col==1)
    ), row=1, col=col)

add_traces(fig, 1, gprom_q3, query3_data)
add_traces(fig, 2, gprom_q4, query4_data)

fig.update_layout(
    height=725,
    width=900,
    template='plotly_white',
    title_font_size=20,
    margin=dict(l=50, r=25, t=50, b=50),
    legend=dict(
        orientation='h',
        yanchor='bottom',
        y=-0.3,
        xanchor='center',
        x=0.5,
        font=dict(size=21,color="black")
    )
)

for i in range(1, 3):
    fig.update_xaxes(title_text='Scale Factor', tickfont=dict(size=19),titlefont=dict(size=19),title_standoff=0.5 , row=1, col=i,showline=True,tickvals=[1,2,3,4,5,6,7,8,9,10])
    fig.update_yaxes(
        title_text='Execution Time (s)',
        type='log',
        tickvals=[0.1, 1, 10],
        range=[-2, 2],
        titlefont=dict(size=19),
        tickfont=dict(size=19),
        row=1,
        col=i,
        title_standoff=0.5
    )

pio.write_image(fig, 'gprom_tpch.pdf', format='pdf')


