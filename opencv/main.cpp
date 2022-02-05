#include <math.h>

#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

using namespace cv;

const std::string BASE_DIR =
    "/home/josh/Documents/Masters/3rd_semester/PMSD/baby_pics/";
const double CARD_WIDTH = 6.4;
const double CARD_LENGTH = 8.9;

std::vector<std::vector<cv::Point>> findSquares(
    const std::vector<std::vector<cv::Point>> &contours);
int getLargestContourIndex(const std::vector<std::vector<cv::Point>> &contours);
std::pair<double, double> getMillimetresPerPixel(
    const std::vector<Point> &square);
std::pair<double, double> getMillimetresPerPixel(const Point2f vertices[]);
void drawKeypoints();

// Finds cosine of angle between vectors
// from pt0->pt1 and from pt0->pt2
static double angle(Point pt1, Point pt2, Point pt0) {
  double dx1 = pt1.x - pt0.x;
  double dy1 = pt1.y - pt0.y;
  double dx2 = pt2.x - pt0.x;
  double dy2 = pt2.y - pt0.y;
  return (dx1 * dx2 + dy1 * dy2) /
         sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}

Mat image, imageGray, dst;

int main(int argc, char **argv) {
  std::string imageName = BASE_DIR + "card_far.jpg";
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
  if (squares.size() == 0) {
    std::cout << "Could not find any squares" << std::endl;
    return 1;
  }
  int largestContourIndex = getLargestContourIndex(squares);
  RotatedRect rect = minAreaRect(squares[largestContourIndex]);

  // TODO: how does this fitted rect compare for accuracy compared to directly
  // using the contour?
  Point2f vertices[4];
  rect.points(vertices);
  for (int i = 0; i < 4; ++i) {
    line(image, vertices[i], vertices[(i + 1) % 4], Scalar(0, 255, 0), 2);
  }

  std::pair<double, double> mmPerPixel = getMillimetresPerPixel(vertices);
  std::cout << "mmPerPixel vertices: " << mmPerPixel.first << " "
            << mmPerPixel.second << std::endl;
  std::cout << "average: " << (mmPerPixel.first + mmPerPixel.second) / 2
            << std::endl;
  double xDist = fabs(keyPoints[2][0] - keyPoints[15][0]);
  double yDist = fabs(keyPoints[2][1] - keyPoints[15][1]);
  std::cout << "xDist: " << xDist << ", yDist " << yDist << std::endl;
  std::cout << sqrt(pow(xDist * mmPerPixel.first, 2) +
                    pow(yDist * mmPerPixel.second, 2))
            << std::endl;

  // polylines(image, squares[largestContourIndex], true, Scalar(0, 255, 0), 3,
  // LINE_AA);
  line(image, Point(keyPoints[2][0], keyPoints[2][1]),
       Point(keyPoints[15][0], keyPoints[15][1]), Scalar(0, 0, 255), 5,
       LINE_AA);

  const char *sourceWindow = "Source";
  namedWindow(sourceWindow);
  imshow(sourceWindow, image);

  while (waitKey() != 27)
    ;
  destroyAllWindows();
}

std::vector<std::vector<cv::Point>> findSquares(
    const std::vector<std::vector<cv::Point>> &contours) {
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

int getLargestContourIndex(
    const std::vector<std::vector<cv::Point>> &contours) {
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

std::pair<double, double> getMillimetresPerPixel(
    const std::vector<Point> &square) {
  double y1 = fabs(square[0].y - square[1].y);
  double y2 = fabs(square[2].y - square[3].y);
  double x1 = fabs(square[0].x - square[3].x);
  double x2 = fabs(square[1].x - square[2].x);

  // Instead of taking the average could also take the midpoints of each line.
  double dy = (y1 + y2) / 2;
  double dx = (x1 + x2) / 2;

  return std::make_pair(dx, dy);
}

std::pair<double, double> getMillimetresPerPixel(const Point2f vertices[]) {
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

  line(image, width1, width2, Scalar(0, 0, 255), 5, LINE_AA);
  line(image, height1, height2, Scalar(0, 255, 255), 5, LINE_AA);

  double millimetresPerPixelHeight =
      CARD_LENGTH / (height > width ? height : width);
  double millimetresPerPixelWidth =
      CARD_WIDTH / (height > width ? width : height);
  std::cout << "Width:" << width << ", Height: " << height << std::endl;

  std::cout << millimetresPerPixelWidth << ", " << millimetresPerPixelHeight
            << std::endl;
  return std::make_pair(millimetresPerPixelWidth, millimetresPerPixelHeight);
}

void drawKeypoints() {
  for (int i = 0; i < sizeof keyPoints / sizeof keyPoints[0]; i++) {
    circle(image, Point(keyPoints[i][0], keyPoints[i][1]), 5, Scalar(0, 0, 255),
           -1);
  }
}