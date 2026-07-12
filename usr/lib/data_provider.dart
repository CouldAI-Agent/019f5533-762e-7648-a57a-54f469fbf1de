import 'package:flutter/foundation.dart';

enum UserRole { admin, teacher }
enum ToolStatus { available, maintenance, damaged }
enum LoanStatus { active, returned }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser({required this.id, required this.name, required this.email, required this.role});
}

class Tool {
  final String id;
  final String name;
  final String description;
  final int totalQuantity;
  int availableQuantity;
  ToolStatus status;

  Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.totalQuantity,
    required this.availableQuantity,
    this.status = ToolStatus.available,
  });
}

class Loan {
  final String id;
  final String toolId;
  final String userId;
  final DateTime loanDate;
  DateTime? returnDate;
  LoanStatus status;

  Loan({
    required this.id,
    required this.toolId,
    required this.userId,
    required this.loanDate,
    this.returnDate,
    this.status = LoanStatus.active,
  });
}

class AppProvider with ChangeNotifier {
  AppUser? _currentUser;
  
  final List<AppUser> _users = [
    AppUser(id: '1', name: 'Admin Principal', email: 'admin@escuela.edu', role: UserRole.admin),
    AppUser(id: '2', name: 'Juan Profesor', email: 'juan@escuela.edu', role: UserRole.teacher),
  ];

  final List<Tool> _tools = [
    Tool(id: 't1', name: 'Proyector Epson', description: 'Proyector HDMI', totalQuantity: 3, availableQuantity: 3),
    Tool(id: 't2', name: 'Notebook HP', description: 'Notebook para presentaciones', totalQuantity: 5, availableQuantity: 5),
    Tool(id: 't3', name: 'Cables HDMI', description: 'Cable HDMI de 2 metros', totalQuantity: 10, availableQuantity: 10),
  ];

  final List<Loan> _loans = [];

  AppUser? get currentUser => _currentUser;
  List<Tool> get tools => _tools;
  List<Loan> get loans => _loans;
  
  List<Loan> get userLoans => _loans.where((l) => l.userId == _currentUser?.id).toList();

  bool login(String email) {
    try {
      _currentUser = _users.firstWhere((u) => u.email == email);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void requestLoan(String toolId) {
    if (_currentUser == null) return;
    
    final tool = _tools.firstWhere((t) => t.id == toolId);
    if (tool.availableQuantity > 0) {
      tool.availableQuantity--;
      _loans.add(Loan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toolId: toolId,
        userId: _currentUser!.id,
        loanDate: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  void returnLoan(String loanId) {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    if (loan.status == LoanStatus.active) {
      loan.status = LoanStatus.returned;
      loan.returnDate = DateTime.now();
      
      final tool = _tools.firstWhere((t) => t.id == loan.toolId);
      tool.availableQuantity++;
      notifyListeners();
    }
  }
}
