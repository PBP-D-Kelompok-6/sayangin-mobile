class DonationItem {
  final int? id;
  final String title;
  final String description;
  final int targetAmount;
  final int currentAmount;

  DonationItem({
    this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0,
  });

  factory DonationItem.fromJson(Map<String, dynamic> json) => DonationItem(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        targetAmount: json['target_amount'] ?? 0,
        currentAmount: json['current_amount'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
      };
}