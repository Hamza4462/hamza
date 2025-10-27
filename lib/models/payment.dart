class Payment {
  final int? id;
  final int appointmentId;
  final double amount;
  final DateTime date;
  final String paymentMethod; // 'cash', 'card', 'online'
  final String status; // 'paid', 'pending', 'failed'
  final String? transactionId;
  final String? notes;

  Payment({
    this.id,
    required this.appointmentId,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'amount': amount,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      appointmentId: map['appointment_id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      paymentMethod: map['payment_method'],
      status: map['status'],
      transactionId: map['transaction_id'],
      notes: map['notes'],
    );
  }
}