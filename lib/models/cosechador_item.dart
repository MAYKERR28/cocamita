import 'package:flutter/material.dart';

class CosechadorItem {  
  TextEditingController nombreCtrl;
  TextEditingController p1Ctrl;
  TextEditingController p2Ctrl;
  TextEditingController p3Ctrl;
  TextEditingController p4Ctrl;
  bool g1;
  bool g2;

  CosechadorItem({  
    required String nombre, required String p1
    })
    : nombreCtrl = TextEditingController(text: nombre),
      p1Ctrl = TextEditingController(text: p1),
      p2Ctrl = TextEditingController(),
      p3Ctrl = TextEditingController(),
      p4Ctrl = TextEditingController(),
      g1 = false,
      g2 = false;

  int get sTot {
    int val(TextEditingController c) => int.tryParse(c.text) ?? 0;
    return val(p1Ctrl) + val(p2Ctrl) + val(p3Ctrl) + val(p4Ctrl);
  }

  void dispose() {
    nombreCtrl.dispose();
    p1Ctrl.dispose();
    p2Ctrl.dispose();
    p3Ctrl.dispose();
    p4Ctrl.dispose();
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombreCtrl.text,
    'p1': p1Ctrl.text,
    'p2': p2Ctrl.text,
    'p3': p3Ctrl.text,
    'p4': p4Ctrl.text,
    'g1': g1,
    'g2': g2,
  };

  factory CosechadorItem.fromJson(Map<String, dynamic> json) {
    final item = CosechadorItem(
      nombre: json['nombre'] ?? '',
      p1: json['p1'] ?? '',
    );
    item.p2Ctrl.text = json['p2'] ?? '';
    item.p3Ctrl.text = json['p3'] ?? '';
    item.p4Ctrl.text = json['p4'] ?? '';
    item.g1 = json['g1'] ?? false;
    item.g2 = json['g2'] ?? false;
    return item;
  }
}
