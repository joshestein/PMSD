#include <opencv2/opencv.hpp>

using namespace cv;

extern "C" double get_pixels_per_mm(char *inputImagePath);
Mat preProcessImage(Mat &image);
std::vector<std::vector<Point>> findSquares(
    const std::vector<std::vector<Point>> &contours);
int getLargestContourIndex(const std::vector<std::vector<Point>> &contours);
std::pair<double, double> getMillimetresPerPixel(const RotatedRect &rect);