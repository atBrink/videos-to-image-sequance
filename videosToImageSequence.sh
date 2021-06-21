#! /bin/bash
#################################################################
### Convert dataset of short videos to a dataset of images.	#
### Requires ffmpeg, ffprobe.					#
#################################################################
# Source Directory containing the video files to be converted to a image sequence.
srcDir=$1

# Destination Directory: Where you want to save the created image sequence.
destDir=$2

# Stereo or Mono vision
cameraSetup=$3

# What FPS to capture the images at:
fps=$4

# What kind of file-extension you want the individual images to have. .png/.jpg etc
destExt=$5

# Create destination path folder structure if it does not already exist:
if [ ! -d $destDir ]; then
  mkdir -p $destDir;
  echo "Created folder: $destDir"
fi


if [ $cameraSetup == 'Mono' ]; then
	iter=1;
else
	iter=2;
fi

i=1
until [ $i -gt $iter ]; do
	# Create txt file with the path to all video files to be combined:
	touch $destDir/videos$i.txt
	
	# Extract the correct video files to be combined, Will need to change this for other datasets:
	for sequenceNr in $srcDir/*; do
		filename=${sequenceNr}
		echo "file $filename/RFC0$i.mp4" >> $destDir/"videos$i.txt"
	done

	# Combine all videos into one video file in order to make an image sequence:
	ffmpeg -f concat -safe 0 -i $destDir/videos$i.txt -c copy $destDir/videoFull$i.mp4

	# Use the combined video file to create the image sequence:
	mkdir -p $destDir/image_$(( i - 1 ))
	height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 $destDir/videoFull$i.mp4)
	ffmpeg -i $destDir/videoFull$i.mp4 -r $fps -vf scale=-1:$height -start_number 0 $destDir/image_$(( i - 1 ))/%06d.png

	$(( i++ ))
done

# Count the number of output files:
imgnum=$(ls "$destDir"/image_0 | wc -l)
echo "$imgnum"
frameTime=$(echo "scale=6; 1.0/$fps" | bc)
timestamp=0.000000

for i in $(seq -f "%06g" $imgnum); do
	# Write timestamp to file
	echo $timestamp >> "$destDir"/times.txt
	# Update Timestamp for next frame:
	timestamp=$(echo "scale=6; $timestamp+$frameTime" | bc)
done

# Clean up all intermediate files:
rm "$destDir"/videos1.txt
rm "$destDir"/videoFull1.mp4
rm "$destDir"/videos2.txt
rm "$destDir"/videoFull2.mp4
echo "Conversion from video files to ${destExt} complete!"
