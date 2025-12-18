import pandas as pd
import plotly.graph_objects as go
import plotly.io

plotly.io.kaleido.scope.mathjax = None

before = pd.read_csv("circuit_size_before.csv")
after = pd.read_csv("circuit_size_after.csv")
merged = after.merge(before, on="scale_factor", suffixes=("_after", "_before"))
merged["diff_gates"] = merged["gates_after"] - merged["gates_before"]

LINE_WIDTH = 1  
fig = go.Figure()

df7 = merged[merged["query"] == 7]
fig.add_trace(
    go.Scatter(
        x=df7["scale_factor"],
        y=df7["diff_gates"],
        mode="lines+markers",
        line=dict(color="red", width=LINE_WIDTH, dash="dot"),
        marker=dict(symbol="diamond-tall", size=12, color="red"),
        name="Query 7 (tpch)"
    )
)

df9 = merged[merged["query"] == 9]
fig.add_trace(
    go.Scatter(
        x=df9["scale_factor"],
        y=df9["diff_gates"],
        mode="lines+markers",
        line=dict(color="red", width=LINE_WIDTH, dash="solid"),
        marker=dict(symbol="square", size=12, color="red"),
        name="Query 9 (tpch)"
    )
)
fig.update_layout(
    template="plotly_white",
    height=700,
    width=700,
    legend=dict(
        orientation="h",
        yanchor="bottom",
        y=-0.2,
        xanchor="center",
        x=0.5,
        font=dict(size=17)
    ),
    xaxis=dict(
        title="Scale factor",
        titlefont=dict(size=20),
        tickfont=dict(size=18)
    ),
    yaxis=dict(
        title="No. of gates",
        titlefont=dict(size=20),
        tickfont=dict(size=18),
        type="linear"
    )
)

plotly.io.write_image(fig, "circuit_size_difference.pdf", format="pdf")
