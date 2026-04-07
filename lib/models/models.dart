class Car {
  final int? id;
  final String brand;
  final String model;
  final String plate;
  final int year;
  final int mileage;
  final String? photoPath;

  Car({
    this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.year,
    required this.mileage,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'plate': plate,
      'year': year,
      'mileage': mileage,
      'photoPath': photoPath,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      plate: map['plate'],
      year: map['year'],
      mileage: map['mileage'],
      photoPath: map['photoPath'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Car && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Fuel {
  final int? id;
  final int carId;
  final String date;
  final int mileage;
  final double liters;
  final double literPrice;
  final double totalCost;

  Fuel({
    this.id,
    required this.carId,
    required this.date,
    required this.mileage,
    required this.liters,
    required this.literPrice,
    required this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'date': date,
      'mileage': mileage,
      'liters': liters,
      'literPrice': literPrice,
      'totalCost': totalCost,
    };
  }

  factory Fuel.fromMap(Map<String, dynamic> map) {
    return Fuel(
      id: map['id'],
      carId: map['carId'],
      date: map['date'],
      mileage: map['mileage'],
      liters: map['liters'],
      literPrice: map['literPrice'],
      totalCost: map['totalCost'],
    );
  }
}

class Maintenance {
  final int? id;
  final int carId;
  final String category; // Yağ Değişimi, Fren Balata vb.
  final String date;
  final int mileage;
  final String nextDate;
  final int nextMileage;
  final String? jobsDone;
  final String? upcomingJobs;

  Maintenance({
    this.id,
    required this.carId,
    required this.category,
    required this.date,
    required this.mileage,
    required this.nextDate,
    required this.nextMileage,
    this.jobsDone,
    this.upcomingJobs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'category': category,
      'date': date,
      'mileage': mileage,
      'nextDate': nextDate,
      'nextMileage': nextMileage,
      'jobsDone': jobsDone,
      'upcomingJobs': upcomingJobs,
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'],
      carId: map['carId'],
      category: map['category'],
      date: map['date'],
      mileage: map['mileage'],
      nextDate: map['nextDate'],
      nextMileage: map['nextMileage'],
      jobsDone: map['jobsDone'],
      upcomingJobs: map['upcomingJobs'],
    );
  }
}

class Expense {
  final int? id;
  final int carId;
  final String category; // MTV, Sigorta vb.
  final double amount;
  final String dueDate;
  final int isPaid; // 0 veya 1 (SQLite bool için)

  Expense({
    this.id,
    required this.carId,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'category': category,
      'amount': amount,
      'dueDate': dueDate,
      'isPaid': isPaid,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      carId: map['carId'],
      category: map['category'],
      amount: map['amount'],
      dueDate: map['dueDate'],
      isPaid: map['isPaid'],
    );
  }
}

class Document {
  final int? id;
  final int carId;
  final String category; // Ruhsat, Sigorta vb.
  final String photoPath;

  Document({
    this.id,
    required this.carId,
    required this.category,
    required this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'category': category,
      'photoPath': photoPath,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      carId: map['carId'],
      category: map['category'],
      photoPath: map['photoPath'],
    );
  }
}

class Driver {
  final int? id;
  final String name;
  final String phone;
  final String? photoPath;

  Driver({this.id, required this.name, required this.phone, this.photoPath});

  Map<String, dynamic> toMap() => {"id": id, "name": name, "phone": phone, "photoPath": photoPath};

  factory Driver.fromMap(Map<String, dynamic> m) => Driver(id: m["id"], name: m["name"], phone: m["phone"], photoPath: m["photoPath"]);
}
