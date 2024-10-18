#!/bin/bash

# Directory containing MP4 files
input_directory="/media/umit/T9/UK/dAmyg/Stimuli/ForrestGumpEng/Processed_Segments"

# Loop through each MP4 file in the directory
for input_file in "$input_directory"/*.mp4; do
    # Get the base name of the file (without extension)
    base_name=$(basename "$input_file" .mp4)
    
    # Set the output file name
    output_file="$input_directory/$base_name.mp3"
    
    # Extract audio
    ffmpeg -i "$input_file" -q:a 0 -map a "$output_file"
    
    echo "Extracted: $input_file -> $output_file"
done

echo "All audio files have been extracted."
