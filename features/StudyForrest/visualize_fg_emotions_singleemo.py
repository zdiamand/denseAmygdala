#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

This script is similar to the visualize_fg_emotions.py.
It annotates and saves video frames containing a selected emotion (e.g., "admiration", 
see `select_emotion` variable below) from Forrest Gump segments.

"""

import os
import cv2

import numpy as np
import pandas as pd
import json
from tqdm import tqdm


# ----- Locations for the files to be loaded -----
annotations_dir = '/home/umit/Documents/Research_dAmyg/vidfeats/FG_annotations'
emotion_annots_dir = os.path.join(annotations_dir, 'emotions')

vid_segment_dir = '/media/umit/T9/UK/dAmyg/Stimuli/ForrestGumpEng/Processed_Segments'

output_dir = '/media/umit/T9/UK/dAmyg/Stimuli/ForrestGumpEng/annotation_viz_select'
# ------- o -------


# ----- Load the TSV file -----
# time (seconds) based info
file_path = os.path.join(emotion_annots_dir, 'segmentation', 'emotions_av_1s_thr50.tsv')
# scene shots based info
# file_path = os.path.join(emotion_annotatoion_dir, 'segmentation', 'emotions_av_shots_thr50.tsv')

# '\s+' matches any whitespace (spaces, tabs, etc.)
emotions_df = pd.read_csv(file_path, sep=r'\s+', engine='python', header=None)
emotions_df.columns = ['Start', 'End', 'char', 'tags', 'arousal', 'val_pos', 'val_neg']  

# Display the first few rows of the dataset
# print(emotions_df.head())

# Cleaning the columns by stripping off the prefixes and extracting the numeric values
# Remove prefixes and split the tags
emotions_df['char'] = emotions_df['char'].str.replace('char=', '')
emotions_df['tags'] = emotions_df['tags'].str.replace('tags=', '')

# Extract numeric values from arousal, val_pos, and val_neg
emotions_df['arousal'] = emotions_df['arousal'].str.replace('arousal=', '').astype(float)
emotions_df['val_pos'] = emotions_df['val_pos'].str.replace('val_pos=', '').astype(float)
emotions_df['val_neg'] = emotions_df['val_neg'].str.replace('val_neg=', '').astype(float)

# Splitting the 'tags' into separate words and expanding them into a list
tags_list = emotions_df['tags'].str.split(',')

# Adding the tags_list as a new column to the data DataFrame
emotions_df['tags_list'] = tags_list

# Display the first few rows
# print(emotions_df.head())
# ------- o -------

# Exploding the tags list into separate rows for each tag
# tags_exploded = tags_list.explode()

# Counting the frequency of each tag
# tag_frequencies = tags_exploded.value_counts()

# Displaying the tag frequencies
# print(tag_frequencies)


# ----- Load info about the movie scenes -----
scenes_df = pd.read_csv(os.path.join(emotion_annots_dir, 'movie_scenes.csv'),
                         header=None)
scenes_df.columns = ['Start', 'Location', 'day_time', 'int_ext']
# Shift the 'Start' column to create the 'End' column
scenes_df['End'] = scenes_df['Start'].shift(-1)


# ----- Load info about the scene cuts -----
cuts_df = pd.read_csv(os.path.join(annotations_dir, 'cuts', 'cuts_locs_time.csv'))
# Shift the 'time' column to create the 'End' column
cuts_df['End'] = cuts_df['time'].shift(-1)
# Rename 'time' to 'Start'
cuts_df.rename(columns={'time': 'Start'}, inplace=True)


# NOTE THAT there are also annotations regarding the SEMANTIC CONFLICT in the FG movie
# in the annotations folder.
# ------- o -------


# ----- Info about video segments used in the fMRI experiment -----
vid_segment_genname = 'fg_av_eng_seg%d.mp4'
vid_segment_genfile = os.path.join(vid_segment_dir, vid_segment_genname)
vid_segments = np.arange(8).tolist()
vid_names = [ vid_segment_genname%vii for vii in vid_segments ]

video_metadata_file = os.path.join(vid_segment_dir, 'vidsinfo.json')
with open(video_metadata_file, 'r') as json_file:
    vid_info = json.load(json_file)


# Load data from Table 4 from the annotations data description paper
table_4_data = np.array([
    [0.0, 902.0, 902.0, 891.2],
    [886.0, 1768.0, 882.0, 1759.2],
    [1752.0, 2628.0, 876.0, 2618.8],
    [2612.0, 3588.0, 976.0, 3578.5],
    [3572.0, 4496.0, 924.0, 4488.0],
    [4480.0, 5358.0, 878.0, 5349.2],
    [5342.0, 6426.0, 1084.0, 6418.2],
    [6410.0, 7086.0, 676.0, 7085.5]])

# Convert the numpy array to a pandas DataFrame
table_4_df = pd.DataFrame(table_4_data, 
                          columns=['Start', 'End', 'Duration', 'Boundary'], 
                          index=vid_names)
# ------- o -------

os.makedirs(output_dir, exist_ok=True)


#%% Load videos and visualize annotation information
from vidfeats.mediaio import Video

# Select columns to visualize on the video frames
cut_cols = ['major_location', 'setting', 'locale', 'int_or_ext', 'flow_of_time', 'time_of_day']
scene_cols = ['Location', 'int_ext', 'day_time']
emotion_cols = ['char', 'tags', 'arousal', 'val_pos', 'val_neg']


select_emotion = 'admiration'

output_fname = os.path.join(output_dir, f'fg_{select_emotion}.mp4')


# Load one of the segments to get metadata info
vid_ii_info = vid_info[vid_names[0]]
nframes = vid_ii_info['nframes']
vid_fps = vid_ii_info['fps']
frame_width, frame_height = vid_ii_info['frame_width'], vid_ii_info['frame_height']

# Define the codec and create VideoWriter object
output_vid = cv2.VideoWriter(filename=output_fname,
                              fourcc=cv2.VideoWriter_fourcc(*"mp4v"),
                              fps=float(vid_fps),
                              frameSize=(frame_width, frame_height),
                              isColor=True)


def convertsecs(t_sec):
    minutes, seconds = divmod(t_sec, 60)
    return  f'{minutes:0>2.0f}:{seconds:2.0f}'



for vii, vid_ii in enumerate(vid_names):
    
    vidfile_ii = os.path.join(vid_segment_dir, vid_ii)
    
    vr = Video(vidfile_ii)
    vr_pts = vr.pts
    
    segment_shift = table_4_df.loc[vid_ii]['Start']
    vr_pts_fullvideo = vr_pts + segment_shift
    segment_end = table_4_df.loc[vid_ii]['End']
    
    nframes = vr.frame_count

    for fii, frame_ii in enumerate(tqdm(vr, total=nframes)):
        
        frame_time = vr_pts_fullvideo[fii]
        # frame_time = fii / vid_fps + table_4_df.loc[vid_ii]['Start'] # doesn't account for the PTS
    

        emotions_info_ii = emotions_df[(emotions_df['Start'] <= frame_time) & 
                       ((emotions_df['End'] > frame_time) | (pd.isna(emotions_df['End'])))]
    
        if not emotions_info_ii.empty and frame_time <= segment_end:
            
            tags_list_this = []
            for index_ii, row_ii in emotions_info_ii.iterrows():
                tags_list_this.extend(row_ii['tags_list'])
            
            if select_emotion in tags_list_this:

                frame_bgr = cv2.cvtColor(frame_ii, cv2.COLOR_RGB2BGR)
                
                eii = 0
                for index_ii, row_ii in emotions_info_ii.iterrows():
                    emotions_info_text = ' : '.join(row_ii[emotion_cols].astype(str))
                    cv2.putText(frame_bgr, emotions_info_text, (20, (eii+1)*35), cv2.FONT_HERSHEY_SIMPLEX, 1, 
                            (0, 0, 0), 2, cv2.LINE_AA);
                    eii += 1

    
                # add other info
                cut_info_ii = cuts_df[(cuts_df['Start'] <= frame_time) & 
                               ((cuts_df['End'] > frame_time) | (pd.isna(cuts_df['End'])))]
            
                scene_info_ii = scenes_df[(scenes_df['Start'] <= frame_time) & 
                               ((scenes_df['End'] > frame_time) | (pd.isna(scenes_df['End'])))]

                frame_time_vid = vr_pts[fii]

            
                if not cut_info_ii.empty and frame_time <= segment_end:
                    # Convert selected columns to string
                    cut_info_text = ' : '.join(cut_info_ii[cut_cols].astype(str).iloc[0])
                    cv2.putText(frame_bgr, cut_info_text, (20, 670), cv2.FONT_HERSHEY_SIMPLEX, 1, 
                                (0, 0, 0), 2, cv2.LINE_AA);
                

                    vid_timeinfo = f'{vid_ii} - time: {convertsecs(frame_time_vid)}'  
                    cv2.putText(frame_bgr, vid_timeinfo, (20, 705), cv2.FONT_HERSHEY_SIMPLEX, 1, 
                                (0, 0, 0), 2, cv2.LINE_AA);

                # Write the frame with new text
                output_vid.write(frame_bgr)
        

output_vid.release()

