import pandas as pd
import plotly.graph_objects as go
import plotly.io

plotly.io.kaleido.scope.mathjax = None

mmap = pd.read_csv("mmap_provsql.csv")
indb = pd.read_csv("in_database_provsql.csv")
shm = pd.read_csv("shared_memory_provsql.csv")
mmap["prov_type"] = "provsql_mmap"
indb["prov_type"] = "provsql_indb"
shm["prov_type"] = "provsql_shm"

data = pd.concat([mmap, indb, shm], ignore_index=True)

colors = {
    "provsql_mmap": "orangered",
    "provsql_indb": "blue",
    "provsql_shm": "forestgreen"
}
markers = {
    "provsql_mmap": "square",
    "provsql_indb": "circle",
    "provsql_shm": "diamond"
}
dashes = {
    "7_tpch.sql": "solid",
    "9_tpch.sql": "dash"
}

query_labels = {
    "7_tpch.sql": "Query 7 (tpch)",
    "9_tpch.sql": "Query 9 (tpch)"
}

fig = go.Figure()

for prov_type in data["prov_type"].unique():
    for query in ["7_tpch.sql", "9_tpch.sql"]:
        df = data[(data["prov_type"] == prov_type) & (data["query"] == query)]
        fig.add_trace(
            go.Scatter(
                x=df["scale_factor"],
                y=df["time(s)"],
                mode="lines+markers",
                marker=dict(symbol=markers[prov_type], size=14),
                line=dict(width=2, dash=dashes[query]),
                marker_color=colors[prov_type],
                name=prov_type,         
                legendgroup=prov_type,
                showlegend=(query == "7_tpch.sql")  # only once per prov type
            )
        )

for query, dash in dashes.items():
    fig.add_trace(
        go.Scatter(
            x=[None], y=[None],  
            mode="lines",
            line=dict(color="black", width=2, dash=dash),
            name=query_labels[query],   
            legendgroup="queries",
            showlegend=True
        )
    )

fig.update_xaxes(
    title_text="Scale factor", 
    type="linear", 
    tickfont=dict(size=18), 
    titlefont=dict(size=20)
)
fig.update_yaxes(
    title_text="Execution time (s)",
    type="log", 
    tickfont=dict(size=18), 
    titlefont=dict(size=20),
    tickvals=[0.1, 1, 10, 100, 1000]
)

fig.update_layout(
    height=700,
    width=700,
    template="plotly_white",
    legend=dict(
        orientation="h",
        yanchor="bottom",
        y=-0.4,
        xanchor="center",
        x=0.5,
        font=dict(size=18)
    )
)

plotly.io.write_image(fig, "provsql_versions.pdf", format="pdf")


