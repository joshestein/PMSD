#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

using namespace cv;

const int A4_WIDTH = 21;
const double A4_LENGTH = 29.7;

std::vector<std::vector<cv::Point>> findSquares(const std::vector<std::vector<cv::Point>> &contours);
int getLargestContourIndex(const std::vector<std::vector<cv::Point>> &contours);

// Finds cosine of angle between vectors
// from pt0->pt1 and from pt0->pt2
static double angle(Point pt1, Point pt2, Point pt0) {
  double dx1 = pt1.x - pt0.x;
  double dy1 = pt1.y - pt0.y;
  double dx2 = pt2.x - pt0.x;
  double dy2 = pt2.y - pt0.y;
  return (dx1 * dx2 + dy1 * dy2) / sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}

Mat image, imageGray, dst;

int main(int argc, char **argv) {
  std::string imageName = "hanging.jpg";
  if (argc > 1) {
    imageName = argv[1];
  }
  image = imread(samples::findFile(imageName), IMREAD_COLOR);

  if (image.empty()) {
    std::cout << "Could not read image" << std::endl;
    return 1;
  }

  cvtColor(image, imageGray, COLOR_BGR2GRAY);
  blur(imageGray, imageGray, Size(3, 3));
  threshold(imageGray, imageGray, 127, 255, THRESH_BINARY);
  // TODO: add Canny filter?

  std::vector<std::vector<cv::Point>> contours, squares;
  // TODO: try RETR_EXTERNAL to get fewer, bigger contours
  findContours(imageGray, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);
  squares = findSquares(contours);
  int largestContourIndex = getLargestContourIndex(squares);
  RotatedRect rect = minAreaRect(squares[largestContourIndex]);
  std::cout << squares[largestContourIndex].size() << std::endl;

  for (int i = 0; i < 4; i++) {
    std::cout << squares[largestContourIndex][i] << std::endl;
  }

  double y1 = fabs(squares[largestContourIndex][0].y - squares[largestContourIndex][1].y);
  double y2 = fabs(squares[largestContourIndex][2].y - squares[largestContourIndex][3].y);
  double x1 = fabs(squares[largestContourIndex][0].x - squares[largestContourIndex][3].x);
  double x2 = fabs(squares[largestContourIndex][1].x - squares[largestContourIndex][2].x);
  // Instead of taking the average could also take the midpoints of each line.
  double dy = (y1 + y2) / 2;
  double dx = (x1 + x2) / 2;

  double millimetresPerPixelX = A4_WIDTH / dx;
  double millimetresPerPixelY = A4_LENGTH / dy;
  std::cout << millimetresPerPixelX << ", " << millimetresPerPixelY << std::endl;

  // TODO: how does this fitted rect compare for accuracy compared to directly
  // using the contour?
  // Point2f vertices[4];
  // rect.points(vertices);
  // for (int i = 0; i < 4; ++i) {
  //   std::cout << squares[largestContourIndex][i] << std::endl;
  //   line(image, vertices[i], vertices[(i + 1) % 4], Scalar(0, 255, 0), 2);
  // }

  polylines(image, squares[largestContourIndex], true, Scalar(0, 255, 0), 3, LINE_AA);

  const char *sourceWindow = "Source";
  namedWindow(sourceWindow);
  imshow(sourceWindow, image);

  while (waitKey() != 27)
    ;
  destroyAllWindows();
}

std::vector<std::vector<cv::Point>> findSquares(const std::vector<std::vector<cv::Point>> &contours) {
  std::vector<std::vector<Point>> squares;
  std::vector<Point> approx;

  for (int i = 0; i < contours.size(); i++) {
    approxPolyDP(contours[i], approx, arcLength(contours[i], true) * 0.02, true);

    if (approx.size() == 4 && fabs(contourArea(approx)) > 1000 && isContourConvex(approx)) {
      double maxCosine = 0;
      for (int j = 2; j < 5; j++) {
        // find the maximum cosine of the angle between joint edges
        double cosine = fabs(angle(approx[j % 4], approx[j - 2], approx[j - 1]));
        maxCosine = MAX(maxCosine, cosine);
      }
      // if cosines of all angles are small
      // (all angles are ~90 degree) then write quandrange
      // vertices to resultant sequence
      if (maxCosine < 0.3)
        squares.push_back(approx);
    }
  }
  return squares;
}

int getLargestContourIndex(const std::vector<std::vector<cv::Point>> &contours) {
  int largestContourIndex = 0;
  int largestContourArea = 0;
  for (int i = 0; i < contours.size(); i++) {
    int currentContourArea = contourArea(contours[i]);
    if (currentContourArea > largestContourArea) {
      largestContourArea = currentContourArea;
      largestContourIndex = i;
    }
  }
  return largestContourIndex;
}
