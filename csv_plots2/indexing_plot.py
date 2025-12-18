import plotly.graph_objects as go
import pandas as pd
import plotly.io
plotly.io.kaleido.scope.mathjax = None

df = pd.read_csv('indexing.csv')

categories = [
    "Without<br>provenance", "ProvSQL<br>(Circuit)", "ProvSQL<br>(Why(X))", "GProM", "GProM<br>(HAS PROVENANCE())", "GProM*"
]
full_labels = [
    "Baseline (No provenance)",
    "Circuit computation (ProvSQL)",
    "Why-semiring (ProvSQL)",
    "GProM",
    "GProM (HAS PROVENANCE())",
    "GProM *"
]

indexed = [df['noprov_i'][0], df['prov_i'][0], df['why_i'][0], df['gprom_i'][0], df['gprom_has_i'][0],df['gprom_rw_i'][0]]
non_indexed = [df['noprov'][0], df['prov'][0], df['why'][0], df['gprom'][0], df['gprom_has'][0],df['gprom_rw'][0]]

indexed_display = [800 if v >= 3000 else v for v in indexed]
non_indexed_display = [800 if v >= 3000 else v for v in non_indexed]

visible_max = max(v for v in indexed + non_indexed if v < 3000)
y_max = visible_max * 1.3

fig = go.Figure()

fig.add_trace(go.Bar(
    name='Indexed',
    x=categories,
    y=indexed_display,
    marker_color='blue',
    width=0.3,
    text=[f"{v:.2f}s" if v < 3000 else ">3000s" for v in indexed],
    hovertext=full_labels,
    hoverinfo="text+y"
))

fig.add_trace(go.Bar(
    name='Non-Indexed',
    x=categories,
    y=non_indexed_display,
    marker_color='red',
    width=0.3,
    text=[f"{v:.2f}s" if v < 3000 else ">3000s" for v in non_indexed],
    hovertext=full_labels,
    hoverinfo="text+y"
))

fig.update_layout(
    barmode='group',
    yaxis_title='Execution Time (s)',
    template='plotly_white',
    height=500,
    width=700,
    yaxis=dict(range=[0, 810], tickfont=dict(size=13),tickvals=[0,100,200,300,400,500,600,700]),
    xaxis=dict(
        tickfont=dict(size=14.8,color="black")
        
    ),
    legend=dict(
        font=dict(size=13, family="Arial", color="black"),
        y=1,
        x=0.02
    ),
    margin=dict(t=20, b=40,l=20,r=20)
)

plotly.io.write_image(fig, 'indexing.pdf', format='pdf')
