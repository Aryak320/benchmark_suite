import plotly.graph_objects as go
import pandas as pd
from plotly.subplots import make_subplots
import plotly.io

plotly.io.kaleido.scope.mathjax = None
provsql = pd.read_csv('provsql_unsafe.csv')  # Replace with your ProvSQL CSV file path
maybms = pd.read_csv('maybms_unsafe.csv')  # Replace with your MayBMS CSV file path

provsql['system'] = 'ProvSQL'
maybms['system'] = 'MayBMS'
combined = pd.concat([provsql, maybms], ignore_index=True)

query_map = {
    "query11.sql": "Query 11",
    "query14.sql": "Query 14",
    "query15.sql": "Query 15",
    "query17.sql": "Query 17"
}
combined["query"] = combined["query"].map(query_map)

unique_queries = combined["query"].unique()

# Create a subplot figure (2x2 grid for 4 queries)
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=unique_queries,
    horizontal_spacing=0.15,
    vertical_spacing=0.2
)

colors = {"ProvSQL": "orange", "MayBMS": "blue"}
markers = {"ProvSQL": "circle", "MayBMS": "square"}

for i, query in enumerate(unique_queries):
    query_data = combined[combined["query"] == query]
    
    row = (i // 2) + 1
    col = (i % 2) + 1

    for system in query_data['system'].unique():
        system_data = query_data[query_data["system"] == system]

        fig.add_trace(
            go.Scatter(
                x=system_data["scale_factor"],
                y=system_data["prob_eval(s)"],
                mode="lines+markers",
                name=system if i == 0 else None,  # Add legend only for the first query
                legendgroup="ProvSQL" if system == 'ProvSQL' else 'MayBMS',
                marker=dict(symbol=markers[system]),
                line=dict(color=colors[system]),
                showlegend= i==0
            ),
            row=row,
            col=col
        )
        fig.update_xaxes(range=[0, 11],showline=True, type="linear", row=row, col=col, titlefont={'size':15},title_standoff=2,title_text="Scale factor",tickfont=dict(size=16),tickvals=[1,2,3,4,5,6,7,8,9,10])
        fig.update_yaxes(range=[0,3],autorange=False,type="log", row=row, col=col,titlefont={'size':15},title_standoff=0.005,title_text="Execution time (s)",tickfont=dict(size=16),tickvals=[0.1,1,10,100,1000] )

fig.update_layout(
    height=800,
    width=800,
    template="plotly_white",
    legend=dict(
        orientation="h",
        yanchor="bottom",
        y=-0.2,
        xanchor="center",
        x=0.5,
        font=dict(
            size=17,
            color="black"
        )
    )
)
fig.update_yaxes(range=[-2,1],autorange=False,type="log", row=1, col=1,titlefont={'size':15},title_standoff=0.005,title_text="Execution time (s)",tickfont=dict(size=16),tickvals=[0.01,0.1,1,10,100] )

plotly.io.write_image(fig, 'unsafe.pdf', format='pdf')

