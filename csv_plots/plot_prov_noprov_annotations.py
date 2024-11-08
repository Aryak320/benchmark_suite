import plotly.express as px
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np  # Import numpy for logarithmic scaling

# Load the datasets
d = pd.read_csv('s_tpch_no_prov.csv')
prov = pd.read_csv('s_tpch_prov.csv')

# Merge both datasets on 'query' and 'scale_factor'
merged = pd.merge(d, prov, on=['query', 'scale_factor'], suffixes=('_noprov', '_prov'))

# Calculate overhead factor (time with provenance / time without provenance)
merged['overhead'] = merged['time(s)_prov'] / merged['time(s)_noprov']

# Concatenate original running time data with overhead data for plotting
concatenated = pd.concat([
    d.assign(dataset='noprov'),
    prov.assign(dataset='prov'),
    merged[['query', 'scale_factor', 'overhead']].rename(columns={'overhead': 'time(s)'}).assign(dataset='overhead')
], ignore_index=True)

# Get the list of unique queries to determine how many subplots are needed
unique_queries = concatenated['query'].unique()
n_queries = len(unique_queries)

# Create a subplot figure with as many subplots as unique queries, wrapped over 3 columns

fig = make_subplots(rows=(n_queries // 3) + 1, cols=3, subplot_titles=[q.split('_')[0]+".sql" for q in unique_queries], shared_yaxes=False, specs=[[{"secondary_y": True} for _ in range(3)] for _ in range((n_queries // 3) + 1)], vertical_spacing=0.05, horizontal_spacing=0.08)

# Define colors for datasets
colors = {'noprov': 'darkmagenta', 'prov': 'orange', 'overhead': 'blue'}
markers = {'noprov': 'diamond-tall', 'prov': 'circle', 'overhead': 'square-open-dot'}

# Add traces for each query and dataset to the correct subplot
for i, query in enumerate(unique_queries):
    query_data = concatenated[concatenated['query'] == query]
    row = (i // 3) + 1
    col = (i % 3) + 1
    
    for dataset in query_data['dataset'].unique():
        dataset_data = query_data[query_data['dataset'] == dataset]
        # Execution time (logarithmic y-axis)
        if dataset != 'overhead':
            fig.add_trace(
                go.Scatter(
                    x=dataset_data['scale_factor'],
                    y=dataset_data['time(s)'],
                    mode='lines+markers',
                    marker=dict(symbol=markers[dataset], size=5 if dataset == 'prov' else 8),
                    #name=f'{dataset} - {query}',
                    line=dict(dash='dot' if dataset == 'overhead' else 'solid', width = 1 if dataset == 'prov' else 1.5 ),
                    marker_color=colors[dataset],
                    legendgroup="with provenance" if dataset == 'prov' else 'without provenance',
                    name="with provenance" if dataset == 'prov' else 'without provenance',
                    showlegend= i==0
                ),
                row=row, col=col, secondary_y=False  # Logarithmic y-axis
            )
        # Overhead (linear y-axis)
        else:
            fig.add_trace(
                go.Scatter(
                    x=dataset_data['scale_factor'],
                    y=dataset_data['time(s)'],
                    mode='lines+markers',
                    marker=dict(symbol=markers[dataset], size=6),
                    #name=f'{dataset} - {query}',
                    line=dict(dash='dot'),
                    marker_color=colors[dataset],
                    legendgroup="overhead",
                    name="overhead",
                    showlegend= i==0
                ),
                row=row, col=col, secondary_y=True  # Linear y-axis
            )

# Define consistent y-axis range for execution time (log-scale) and overhead (linear scale)
y_min = concatenated[concatenated['dataset'] != 'overhead']['time(s)'].min() * 0.5  # Margin below min for log
y_max = concatenated[concatenated['dataset'] != 'overhead']['time(s)'].max() * 1.5  # Margin above max for log

overhead_y_min = 0 # Overhead linear min
overhead_y_max = 5 # Overhead linear max

# Set consistent y-axis ranges for all subplots

for i, query in enumerate(unique_queries):
    row = (i // 3) + 1
    col = (i % 3) +1
    # Update log scale for execution time
    fig.update_xaxes(range=[0, 11], type="linear", row=row, col=col, titlefont={'size':17},title_standoff=2,title_text="Scale factor",tickfont=dict(size=16),tickvals=[1,2,3,4,5,6,7,8,9,10])
    fig.update_yaxes(range=[np.log10(y_min), np.log10(y_max)], type="log", row=row, col=col, secondary_y=False, titlefont={'size':17},title_standoff=0.005,title_text="Execution time(log)",tickfont=dict(size=16),tickvals=[0.1,1,10,100] )
    # Update linear scale for overhead
    fig.update_yaxes(range=[overhead_y_min, overhead_y_max], type="linear", row=row, col=col, secondary_y=True, titlefont={'size':17},title_standoff=3,title_text="Overhead(linear)", autorange=False, tickfont=dict(size=16,color='blue')  )
# Update the layout with titles and axis labels
    fig.update_layout(
    height=600 + 400 * ((n_queries // 3)),  # Adjust height dynamically based on number of queries
    width =600+ 400 * ((n_queries // 3)),
    template="plotly_white",
       legend=dict(
        orientation="h",  # Horizontal layout
        yanchor="bottom",  # Anchor the legend to the bottom
        y=0.19,
        xanchor="center",  # Center horizontally
        x= 0.5,
        font=dict(
            family="Courier",
            size=16,
            color="black"
        )
    )
)
fig.update_yaxes(range=[0, 150], type="linear", row=3, col=3, secondary_y=True, title_text="Overhead(linear)", autorange=False, tickvals=[0,100,120] )
fig.update_annotations(font_size=16)
# Show the plot
fig.show()

