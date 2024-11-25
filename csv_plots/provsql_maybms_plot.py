import plotly.graph_objects as go
import pandas as pd
from plotly.subplots import make_subplots

# Load the datasets
provsql = pd.read_csv('provsql.csv')  # Replace with your ProvSQL CSV file path
maybms = pd.read_csv('maybms.csv')  # Replace with your MayBMS CSV file path

# Combine both datasets into a single DataFrame for easier handling
provsql['system'] = 'ProvSQL'
maybms['system'] = 'MayBMS'
combined = pd.concat([provsql, maybms], ignore_index=True)

# Map query names for better display in the subplot titles
query_map = {
    "tpch_1_m.sql": "Query 1*",
    "tpch_4_m.sql": "Query 4*",
    "tpch_12_m.sql": "Query 12*",
    "tpch_15_m.sql": "Query 15*"
}
combined["query"] = combined["query"].map(query_map)

# Get the list of unique queries
unique_queries = combined["query"].unique()

# Create a subplot figure (2x2 grid for 4 queries)
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=unique_queries
)

# Define colors and markers for the systems
colors = {"ProvSQL": "blue", "MayBMS": "orange"}
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
        fig.update_xaxes(range=[0, 11], type="linear", row=row, col=col, titlefont={'size':17},title_standoff=2,title_text="Scale factor",tickfont=dict(size=16),tickvals=[1,2,3,4,5,6,7,8,9,10])
        fig.update_yaxes(type="log", row=row, col=col,titlefont={'size':17},title_standoff=0.005,title_text="Execution time(s) log scale",tickfont=dict(size=16),tickvals=[0.1,1,10,100] )

# Update layout with log scale and titles
fig.update_layout(
    height=800,
    width=800,
    title="Execution Time Comparison: ProvSQL vs. MayBMS",
    template="plotly_white",
    legend=dict(
        orientation="h",
        yanchor="bottom",
        y=-0.2,
        xanchor="center",
        x=0.5
    )
)

# Apply log scale to y-axes


# Show the plot
fig.show()

