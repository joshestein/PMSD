#include <opencv2/opencv.hpp>

using namespace cv;

extern "C" __attribute__((visibility("default"))) __attribute__((used)) double
get_pixels_per_mm(char *inputImagePath) {
  Mat input = imread(inputImagePath);
  return 3.56;
}