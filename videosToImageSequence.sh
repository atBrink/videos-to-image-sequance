#! /bin/bash
#################################################################
### Convert dataset of short videos to a dataset of images.	#
### Requires ffmpeg, ffprobe.					#
#################################################################
# Source Directory containing the video files to be converted to a image sequence.
srcDir=$1

# Destination Directory: Where you want to save the created image sequence.
destDir=$2

# What FPS to capture the images at:
fps=$3

# What kind of file-extension you want the individual images to have. .png/.jpg etc
destExt=$4

# Custom options to pass on to ffmpeg package. See https://ffmpeg.org/documentation.html
opts=$5

# Create destination path folder structure if it does not already exist:
if [ ! -d $destDir ]; then
  mkdir -p $destDir;
  echo "Created folder: $destDir"
fi




# Create txt file with the path to all video files to be combined:
touch $destDir/videos.txt

# Extract the correct video files to be combined, Will need to change this for other datasets:
for sequenceNr in $srcDir/*; do
	filename=${sequenceNr}
	basePath=${sequenceNr%.*}
	baseName=${basePath##*/}
	
	echo "file $filename/RFC01.mp4" >> $destDir/videos.txt
done

# Combine all videos into one video file in order to make an image sequence:
ffmpeg -f concat -safe 0 -i $destDir/videos.txt -c copy $destDir/videoFull.mp4

# Use the combined video file to create the image sequence:
mkdir -p $destDir/image_0
height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 $destDir/videoFull.mp4)
ffmpeg -i "$destDir"/videoFull.mp4 -r $fps -vf scale=-1:$height -start_number 0 "$destDir"/image_0/%06d.png

# Count the number of output files:
imgnum=$(ls "$destDir"/image_0 | wc -l)

frameTime=$(echo "scale=6; 1.0/$fps" | bc)
timestamp=0.000000

for i in $(seq -f "%06g" $imgnum) do
	# Write timestamp to file
	echo $timestamp >> "$destDir"/times.txt
	# Update Timestamp for next frame:
	timestamp=$(echo "scale=6; $timestamp+$frameTime" | bc)
done

# Clean up all intermediate files:
rm "$destDir"/videos.txt
rm "$destDir"/videoFull.mp4

echo "Conversion from video files to ${destExt} complete!"
