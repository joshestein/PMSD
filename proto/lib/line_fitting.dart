class LineFitter {
  final List<double> x;
  final List<double> y;

  LineFitter(this.x, this.y);

  double _mean(List<double> values) {
    double sum = 0.0;
    for (int i = 0; i < values.length; i++) {
      sum += values[i];
    }
    return sum / values.length;
  }

  double _variance(List<double> values, double mean) {
    double variance = 0.0;
    for (int i = 0; i < values.length; i++) {
      variance += (values[i] - mean) * (values[i] - mean);
    }
    return variance;
  }

  double _covariance(double xMean, double yMean) {
    double covariance = 0.0;

    for (int i = 0; i < x.length; i++) {
      covariance += (x[i] - xMean) * (y[i] - yMean);
    }
    return covariance;
  }

  List<double> get coefficients {
    double xMean = _mean(x);
    double yMean = _mean(y);
    double covariance = _covariance(xMean, yMean);
    double varianceX = _variance(x, xMean);

    double b1 = covariance / varianceX;
    double b0 = _mean(y) - b1 * xMean;

    return [b0, b1];
  }
}
