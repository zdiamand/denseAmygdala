#!/bin/bash

# Directory containing MP4 files
input_directory="/media/umit/T9/UK/dAmyg/Stimuli/ForrestGumpEng/annotation_viz_n"

# Loop through each MP4 file in the directory
for input_file in "$input_directory"/*.mp3; do

    # Get the base name of the file (without extension)
    base_name=$(basename "$input_file" .mp3)
    
    input_video="$input_directory/${base_name}_emo.mp4"
    
    # Set the output file name
    output_file="$input_directory/$base_name.mov"
    
    # Convert the file
    #ffmpeg -i "$input_video" -i "$input_file" -c:v copy -map 0:v:0 -map 1:a:0 -shortest "$output_file"
    ffmpeg -i "$input_video" -i "$input_file" -q:v 0 -q:a 0 -map 0:v:0 -map 1:a:0 -shortest "$output_file"
    
    echo "Converted: $input_file -> $output_file"
done

echo "All files have been converted."

