class ExpenseModel {
  final int id;
  final double amount;
  final String? description;
  final DateTime date;
  final int? categoryId;

  ExpenseModel({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    this.categoryId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
    );
  }
}