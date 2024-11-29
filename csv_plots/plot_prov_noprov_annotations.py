import plotly.express as px
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np  
import plotly.io
plotly.io.kaleido.scope.mathjax = None
# Read CSV data
d = pd.read_csv('s_tpch_no_prov.csv')
prov = pd.read_csv('s_tpch_prov.csv')

# Merge datasets and calculate overhead
merged = pd.merge(d, prov, on=['query', 'scale_factor'], suffixes=('_noprov', '_prov'))
merged['overhead'] = merged['time(s)_prov'] / merged['time(s)_noprov']

<<<<<<< HEAD
=======

>>>>>>> 8a0f724bc322b82ea59a29a3b106d76ba8cc9d38
# Concatenate data for all datasets
concatenated = pd.concat([
    d.assign(dataset='noprov'),
    prov.assign(dataset='prov'),
    merged[['query', 'scale_factor', 'overhead']].rename(columns={'overhead': 'time(s)'}).assign(dataset='overhead')
], ignore_index=True)

# Unique queries and their count
unique_queries = concatenated['query'].unique()
n_queries = len(unique_queries)

# Define subplot layout: 5 rows, 2 columns, last cell in column 2 for legend
fig = make_subplots(
    rows=5, 
    cols=2, 
    subplot_titles=[q.split('_')[0] + ".sql" for q in unique_queries] + ["Legend"],
    shared_yaxes=False, 
    specs=[
        [{"secondary_y": True}, {"secondary_y": True}],  # Row 1
        [{"secondary_y": True}, {"secondary_y": True}],  # Row 2
        [{"secondary_y": True}, {"secondary_y": True}],  # Row 3
        [{"secondary_y": True}, {"secondary_y": True}],  # Row 4
        [{"secondary_y": True}, None]  # Row 5: Left is a subplot, right is for legend
    ],
    horizontal_spacing=0.2,
<<<<<<< HEAD
    vertical_spacing=0.05
)

# Define colors and markers for the datasets
colors = {'noprov': 'darkmagenta', 'prov': 'orange', 'overhead': 'blue'}
=======
    vertical_spacing=0.06
)

# Define colors and markers for the datasets
colors = {'noprov': 'green', 'prov': 'red', 'overhead': 'blue'}
>>>>>>> 8a0f724bc322b82ea59a29a3b106d76ba8cc9d38
markers = {'noprov': 'diamond-tall', 'prov': 'circle-dot', 'overhead': 'square-open-dot'}

# Add traces for each query and dataset
for i, query in enumerate(unique_queries):
    query_data = concatenated[concatenated['query'] == query]
    row = (i // 2) + 1
    col = (i % 2) + 1
    
    for dataset in query_data['dataset'].unique():
        dataset_data = query_data[query_data['dataset'] == dataset]
        if dataset != 'overhead':
            fig.add_trace(
                go.Scatter(
                    x=dataset_data['scale_factor'],
                    y=dataset_data['time(s)'],
                    mode='lines+markers',
                    opacity=0.9,
<<<<<<< HEAD
                    marker=dict(symbol=markers[dataset], size=15 if dataset == 'prov' else 25),
                    line=dict(dash='dot' if dataset == 'overhead' else 'solid', width=1 if dataset == 'prov' else 1.5),
                    marker_color=colors[dataset],
                    legendgroup="with provenance" if dataset == 'prov' else 'without provenance',
                    name="with provenance" if dataset == 'prov' else 'without provenance',
                    showlegend= i==0  # Show legend only in the dedicated area
=======
                    marker=dict(symbol=markers[dataset], size=11 if dataset == 'prov' else 25),
                    line=dict(dash='dot' if dataset == 'overhead' else 'solid', width=1 if dataset == 'prov' else 1.5),
                    marker_color=colors[dataset],
                    legendgroup="With provenance tracking" if dataset == 'prov' else 'Without provenance tracking',
                    name="With provenance tracking " if dataset == 'prov' else 'Without provenance tracking',
                    showlegend= i==0  
>>>>>>> 8a0f724bc322b82ea59a29a3b106d76ba8cc9d38
                ),
                row=row, col=col, secondary_y=False
            )
        else:
            fig.add_trace(
                go.Scatter(
                    x=dataset_data['scale_factor'],
                    y=dataset_data['time(s)'],
                    mode='lines+markers',
                    marker=dict(symbol=markers[dataset], size=20),
                    line=dict(dash='dot',width=5),
                    marker_color=colors[dataset],
                    marker_line_width=2,
<<<<<<< HEAD
                    legendgroup="overhead",
                    name="overhead",
=======
                    legendgroup="Overhead",
                    name="Overhead",
>>>>>>> 8a0f724bc322b82ea59a29a3b106d76ba8cc9d38
                    showlegend=i==0
                ),
                row=row, col=col, secondary_y=True
            )

# Define axis ranges and other plot properties
y_min = concatenated[concatenated['dataset'] != 'overhead']['time(s)'].min() * 0.5
y_max = concatenated[concatenated['dataset'] != 'overhead']['time(s)'].max() * 1.5
overhead_y_min = 0
overhead_y_max = 5

# Update axes for each subplot
for i, query in enumerate(unique_queries):
    row = (i // 2) + 1
    col = (i % 2) + 1
    fig.update_xaxes(
        range=[0, 11], type="linear", row=row, col=col,
        title_text="Scale factor", titlefont={'size': 26}, tickfont=dict(size=26), tickvals=list(range(1, 11))
    )
    fig.update_yaxes(
        range=[np.log10(y_min), np.log10(y_max)], type="log", row=row, col=col, secondary_y=False,
<<<<<<< HEAD
        title_text="Execution time (s)", titlefont={'size': 26}, tickfont=dict(size=26), tickvals=[0.1, 1, 10, 100]
    )
    fig.update_yaxes(
        range=[overhead_y_min, overhead_y_max], type="linear", row=row, col=col, secondary_y=True,
        title_text="Overhead", titlefont={'size': 26}, tickfont=dict(size=26, color='blue')
=======
        title_text="Execution time (log)", titlefont={'size': 26}, tickfont=dict(size=26), tickvals=[0.1, 1, 10, 100]
    )
    fig.update_yaxes(
        range=[overhead_y_min, overhead_y_max], type="linear", row=row, col=col, secondary_y=True,
        title_text="Overhead (linear)", titlefont={'size': 26}, tickfont=dict(size=26, color='blue')
>>>>>>> 8a0f724bc322b82ea59a29a3b106d76ba8cc9d38
    )

# Add a legend to the last empty space
fig.update_layout(
<<<<<<< HEAD
    height=2600, 
    width=1400, 
=======
    height=2500, 
    width=1500, 
>>>>>>> 8a0f724bc322b82ea59a29a3b106d76ba8cc9d38
    template="plotly_white",
    legend=dict(
        orientation="v",  # Vertical legend
        yanchor="middle",  # Align to the middle of the legend cell
        y=0.08,  # Center it vertically within the right column
        xanchor="center",
        x=0.77,
        font=dict(
            family="Courier",
            size=30,
            color="black"
        )
    )
)
fig.update_annotations(font_size=24)
<<<<<<< HEAD

fig.update_yaxes(range=[0, 150], type="linear", row=5, col=1, secondary_y=True,autorange=False, tickvals=[0,100,120] )

# Save the figure as a PDF
plotly.io.write_image(fig, 'overhead_tpch.pdf', format='pdf')



=======
fig.update_traces(line={'width': 4})
fig.update_yaxes(range=[0,150],type="linear",row=5, col=1, secondary_y=True,autorange=False,tickvals=[0,100,120])
# Save the figure as a PDF
plotly.io.write_image(fig, 'overhead_tpch.pdf', format='pdf')
>>>>>>> 8a0f724bc322b82ea59a29a3b106d76ba8cc9d38
