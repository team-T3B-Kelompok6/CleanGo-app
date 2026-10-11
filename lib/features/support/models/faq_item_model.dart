import 'package:flutter/material.dart';

class FaqItemModel {
  const FaqItemModel({
    required this.id,
    required this.question,
    required this.answer,
    this.highlight,
    required this.icon,
    this.isExpanded = false,
  });

  final String id;
  final String question;
  final String answer;
  final String? highlight;
  final IconData icon;
  final bool isExpanded;

  FaqItemModel copyWith({
    String? id,
    String? question,
    String? answer,
    String? highlight,
    IconData? icon,
    bool? isExpanded,
  }) {
    return FaqItemModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      highlight: highlight ?? this.highlight,
      icon: icon ?? this.icon,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
