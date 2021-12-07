#!/usr/bin/env python3

from PIL import Image, ImageOps
import os
import tempfile
import numpy as np
import tensorflow as tf

from utils import vis_segmentation


BASE_DIR = '/home/josh/Documents/Masters/3rd_semester/PMSD'

image_path = f"{BASE_DIR}/baby_pics/hanging.jpg"
input_size = 257

# Initialize the TFLite interpreter
interpreter = tf.lite.Interpreter(
    model_path=f"{BASE_DIR}/tflite/models/lite-model_deeplabv3_1_metadata_2.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()

# Get image size - converting from BHWC to WH
input_size = input_details[0]['shape'][2], input_details[0]['shape'][1]

image = Image.open(image_path)
old_size = image.size  # old_size is in (width, height) format
desired_ratio = input_size[0] / input_size[1]
old_ratio = old_size[0] / old_size[1]

if old_ratio < desired_ratio:  # '<': cropping, '>': padding
    new_size = (old_size[0], int(old_size[0] / desired_ratio))
else:
    new_size = (int(old_size[1] * desired_ratio), old_size[1])

print(new_size, old_size)

# Cropping the original image to the desired aspect ratio
delta_w = new_size[0] - old_size[0]
delta_h = new_size[1] - old_size[1]
padding = (delta_w//2, delta_h//2, delta_w-(delta_w//2), delta_h-(delta_h//2))
cropped_image = ImageOps.expand(image, padding)

# Resize the cropped image to the desired model size
resized_image = cropped_image.convert('RGB').resize(input_size, Image.BILINEAR)

# Convert to a NumPy array, add a batch dimension, and normalize the image.
image_for_prediction = np.asarray(resized_image).astype(np.float32)
image_for_prediction = np.expand_dims(image_for_prediction, 0)
image_for_prediction = image_for_prediction / 127.5 - 1

interpreter.set_tensor(input_details[0]['index'], image_for_prediction)
interpreter.invoke()

# Retrieve the raw output map.
raw_prediction = interpreter.tensor(
    interpreter.get_output_details()[0]['index'])()

width, height = cropped_image.size
seg_map = tf.argmax(tf.image.resize(raw_prediction, (height, width)), axis=3)
seg_map = tf.squeeze(seg_map).numpy().astype(np.int8)

vis_segmentation(cropped_image, seg_map)
