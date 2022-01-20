#include "opencv_native.hpp"

#include <math.h>

#include <opencv2/opencv.hpp>

using namespace cv;

// TODO: make configurable reference sizes
const double CARD_WIDTH = 6.4;
const double CARD_LENGTH = 8.9;

static double angle(Point pt1, Point pt2, Point pt0) {
  double dx1 = pt1.x - pt0.x;
  double dy1 = pt1.y - pt0.y;
  double dx2 = pt2.x - pt0.x;
  double dy2 = pt2.y - pt0.y;
  return (dx1 * dx2 + dy1 * dy2) /
         sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}

extern "C" __attribute__((visibility("default"))) __attribute__((used)) double
get_pixels_per_mm(char *inputImagePath) {
  Mat image = imread(inputImagePath, IMREAD_COLOR);
  Mat processedImage = preProcessImage(image);

  std::vector<std::vector<Point>> contours, squares;
  findContours(processedImage, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);
  squares = findSquares(contours);
  int largestContourIndex = getLargestContourIndex(squares);
  RotatedRect rect = minAreaRect(squares[largestContourIndex]);
  std::pair<double, double> mmPerPixel = getMillimetresPerPixel(rect);

  return (mmPerPixel.first + mmPerPixel.second) / 2;
}

Mat preProcessImage(Mat &image) {
  Mat processedImage;
  cvtColor(image, processedImage, COLOR_BGR2GRAY);
  blur(processedImage, processedImage, Size(3, 3));
  threshold(processedImage, processedImage, 127, 255, THRESH_BINARY);
  return processedImage;
}

std::vector<std::vector<Point>> findSquares(
    const std::vector<std::vector<Point>> &contours) {
  std::vector<std::vector<Point>> squares;
  std::vector<Point> approx;

  for (int i = 0; i < contours.size(); i++) {
    approxPolyDP(contours[i], approx, arcLength(contours[i], true) * 0.02,
                 true);

    if (approx.size() == 4 && fabs(contourArea(approx)) > 1000 &&
        isContourConvex(approx)) {
      double maxCosine = 0;
      for (int j = 2; j < 5; j++) {
        // find the maximum cosine of the angle between joint edges
        double cosine =
            fabs(angle(approx[j % 4], approx[j - 2], approx[j - 1]));
        maxCosine = MAX(maxCosine, cosine);
      }
      // if cosines of all angles are small
      // (all angles are ~90 degree) then write quandrange
      // vertices to resultant sequence
      if (maxCosine < 0.3) squares.push_back(approx);
    }
  }
  return squares;
}

int getLargestContourIndex(const std::vector<std::vector<Point>> &contours) {
  int largestContourIndex = 0;
  int largestContourArea = 0;
  for (int i = 0; i < contours.size(); i++) {
    int currentContourArea = contourArea(contours[i]);
    if (currentContourArea > largestContourArea &&
        currentContourArea < 1000000) {
      largestContourArea = currentContourArea;
      largestContourIndex = i;
    }
  }
  return largestContourIndex;
}

std::pair<double, double> getMillimetresPerPixel(const RotatedRect &rect) {
  Point2f vertices[4];
  rect.points(vertices);

  Point2d width1 = Point2d((vertices[0].x + vertices[3].x) / 2,
                           (vertices[0].y + vertices[3].y) / 2);
  Point2d width2 = Point2d((vertices[1].x + vertices[2].x) / 2,
                           (vertices[1].y + vertices[2].y) / 2);
  Point2d height1 = Point2d((vertices[2].x + vertices[3].x) / 2,
                            (vertices[2].y + vertices[3].y) / 2);
  Point2d height2 = Point2d((vertices[1].x + vertices[0].x) / 2,
                            (vertices[1].y + vertices[0].y) / 2);

  double width =
      sqrt(pow(width1.x - width2.x, 2) + pow(width1.y - width2.y, 2));
  double height =
      sqrt(pow(height1.x - height2.x, 2) + pow(height1.y - height2.y, 2));

  double millimetresPerPixelHeight =
      CARD_LENGTH / (height > width ? height : width);
  double millimetresPerPixelWidth =
      CARD_WIDTH / (height > width ? width : height);
  return std::make_pair(millimetresPerPixelWidth, millimetresPerPixelHeight);
}
