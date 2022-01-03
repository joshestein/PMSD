class Measurement {
  final int id;
  final int childId;
  final int height;
  final String date;
  final int? weight;

  Measurement(
      {required this.id,
      required this.childId,
      required this.height,
      required this.date,
      this.weight});
}
