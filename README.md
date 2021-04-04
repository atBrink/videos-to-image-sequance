videos-to-image-sequance


Bash script that is used to convert a dataset of short video files to a image sequence with timestamps.

You will need to change the path-structure on line 39 to the one corresponding to your dataset in order for the script to pull the correct short-videos.

For Example if the dataset looks like:
Dataset:
-0000:
--Cam0:
---vid0.mp4
-0001:
--Cam0:
---vid0.mp4
.
.
.

It will combine all vid0.mp4 files and create a image set containing frames of the videos in order
Dataset:
-time.txt
-image_0:
--0000.png
--0001.png
--0002.png
.
.
.


Usage:

./videosToImageSequence.sh srcPath destPath fps imageFileExtension OPTIONAL:ffmpeg-options
