# Coffeefruit_Maturity_Level
Estimation of fruit number in coffee trees by maturity level, based on color space weighting

To replicate the experiments, run the following files in Matlab:

Capture_four_cameras.m – used to obtain images of the coffee branches, with four cameras 
Detect_zero_crossing_edges.m – used to obtain the image with the edges, segmenting by the zero crossing method
distances_by_class.csv - quartile values and median obtained from the analysis of each color space component for each class. After selecting the candidate channels, they are binarized using the first (Q1) and third (Q3) quartile values from the histogram analysis to ensure proper isolation of the fruits in each class.
export_raw_quartile_statistics_per_class.m  - used to obtain Quartile and median values after analyzing each of the color space components, for each of the classes (green, olive green, cherry and raisin.

find_arcs_and_compute_angles.m – Used to find arcs e compute angles -  with this parameters, the coordinates forming the ellipse are generated in the orientation

fuit_count.m – Used to determine the number of fruits from each class, using each cluster of centroids of the ellipses projected in the previous step 

generate_color_statistics_by_class.m - Generate Q1, Median, and Q3 values for each color channel per class

generate_distances_by_class.m – Generate distances obtained for each of the channels

generate_thresholds_all_classes.m – used to define the threshold values for all classes

process_single_image_colors.m - Calculates statistical distances (Q1_fruit - Q3_background) for each color channel to identify the most discriminative channels.

project_ellipses_from_arcs.m – Used to Project ellipses from arcs obtained with previous step
proof.m – Used to test the algorithm
quartilsporclasse.csv - Quartile and median values obtained after analyzing each of the color space components, for each of the classes (green, olive green, cherry and raisin)

segment_all_classes.m – Used to segment all classes (green, olive green, cherry and raisin)
segment_image_by_class.m – Used to segment coffee images, by especif class (green, olive green, cherry and raisin)
fruit_sample_selector.m – Used to select color sample by class
thresholds_all_classes.mat – Threshold values obtained for all classes (green, olive green, cherry and raisin)
visualize_white_mask_background – Used to visualize background mask
visualize_class_histograms.m – Used to visualize histograms of each channel for the especific class and its background
