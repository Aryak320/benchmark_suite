import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import plotly.io

# Disable MathJax rendering
plotly.io.kaleido.scope.mathjax = None

# Load the dataset
df = pd.read_csv('unsafe.csv')

# Add system columns for easier plotting
provsql = df[["scale_factor", "query", "provsql_time"]].copy()
provsql["system"] = "ProvSQL"
provsql.rename(columns={"provsql_time": "execution_time"}, inplace=True)

maybms = df[["scale_factor", "query", "maybms_time"]].copy()
maybms["system"] = "MayBMS"
maybms.rename(columns={"maybms_time": "execution_time"}, inplace=True)

# Combine both datasets into a single DataFrame
combined = pd.concat([provsql, maybms], ignore_index=True)

# Map query names for better display in the subplot titles
query_map = {
    "query10_cp.sql": "Query 13",
    "query13_cp.sql": "Query 16",
    "query14_cp.sql": "Query 10",
    "query16_cp.sql": "Query 16"
}
combined["query"] = combined["query"].map(query_map)

# Get the list of unique queries
unique_queries = combined["query"].unique()

# Create a subplot figure (2x2 grid for 4 queries)
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=unique_queries,
    horizontal_spacing=0.15,
    vertical_spacing=0.2
)

# Define colors and markers for the systems
colors = {"ProvSQL": "orange", "MayBMS": "blue"}
markers = {"ProvSQL": "circle", "MayBMS": "square"}

# Add traces for each query
for i, query in enumerate(unique_queries):
    # Filter data for the specific query
    query_data = combined[combined["query"] == query]
    
    row = (i // 2) + 1
    col = (i % 2) + 1

    for system in query_data['system'].unique():
        system_data = query_data[query_data["system"] == system]

        # Add trace for the current system and query
        fig.add_trace(
            go.Scatter(
                x=system_data["scale_factor"],
                y=system_data["execution_time"],
                mode="lines+markers",
                name=system if i == 0 else None,  # Add legend only for the first query
                legendgroup=system,
                marker=dict(symbol=markers[system]),
                line=dict(color=colors[system]),
                showlegend=i == 0
            ),
            row=row,
            col=col
        )

    # Update axes for the current subplot
    fig.update_xaxes(
        range=[0, 11],
        showline=True,
        type="linear",
        row=row,
        col=col,
        titlefont={'size': 15},
        title_standoff=2,
        title_text="Scale Factor",
        tickfont=dict(size=16),
        tickvals=list(range(1, 11))
    )
    fig.update_yaxes(
        
        
        type="log",
        row=row,
        col=col,
        titlefont={'size': 15},
        title_standoff=0.005,
        title_text="Execution Time (s)",
        tickfont=dict(size=16),
        tickvals=[0.1, 1, 10, 100, 1000]
    )

# Final layout adjustments
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
        font=dict(size=17, color="black")
    )
)

# Save the figure as a PDF
plotly.io.write_image(fig, 'unsafe.pdf', format='pdf')
