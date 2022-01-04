# Project Management and Software Development for Medical Applications (PMSD)

This project is aimed at developing a low-cost solution to measuring infant height and weight. The focus is on measuring height, since this is the more challenging metric. Currently, this is a tedious process that requires an 'infantometer'. The existing analogue approach is (1) slow, (2) uncomfortable for the baby, (3) innaccurate and (4) requires multiple people.

### Approach

The approach consists of two core steps. Firstly, we perform pose detection to detect keypoints of the infant. Secondly, we use a known real-world object to determine the relative size of image pixels.

By performing a vector sum along the pose vectors and scaling by our known object size we can recover the true size of the baby.

Off-the-shelf pose networks show useful keypoints. However, we could likely improve performance and accuracy by storing manually placed keypoints and fine-tuning an existing network on image poses.

The real-world object chosen is a [Bicycle Poker playing card](https://en.wikipedia.org/wiki/Bicycle_Playing_Cards#Design). These are a standard size, widely available and cheap. Further, they can easily be placed on the baby in such a way that (at a distance) the card seems to lie on the same plane as the baby.

### Project Structure

- `baby_pics` - contains input images
- `opencv` - initial C++ prototyping code for measuring height
- `tflite` - Python code for pose detection and segmentation
- `proto` - mobile app (written in Flutter) for taking images, computing height and viewing growth charts
