class Sensor {
  final int id;
  final String name;
  final double value;

  Sensor({required this.id, required this.name, required this.value});

  // Перетворення в Map для збереження в базі даних
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }

  // Створення об'єкта з Map
  factory Sensor.fromMap(Map<String, dynamic> map) {
    return Sensor(
      id: map['id'],
      name: map['name'],
      value: map['value'],
    );
  }
}
