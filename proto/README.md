# proto

This is the main flutter application. It is responsible for image picking (via storage or from taking a photo using the camera), pose detection, finding the reference object and persistent storage of data. Manual height and weight measurements can also be entered by a user.

## Dependencies

1. `image_picker` - allows for images to be taken with the camera, or selected from storage.
2. `tflite` - allows for running Tensorflow Lite models. We use the PoseNet model to determine pose keypoints.
3. `fl_chart` - used for plotting length-for-age and height-for-age curves.
4. `sqflite` - allows for persistent storage of parent data, child data and measurements.
5. `intl` - used for DateTime parsing/formatting.
6. `opencv` - local plugin to find a reference object and compute the pixels to real world factor.

## Usage

Upon loading, the user is presented with a list of parent ID numbers. These can be searched to find an existing parent, or a new parent may be added.

Once a new parent has been added/found, a new child can be created, or an existing child can be updated.

Measurements for the child can entered directly via text or after finding/taking a photo and processing.
