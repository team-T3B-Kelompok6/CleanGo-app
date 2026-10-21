import 'package:flutter/material.dart';

class FaqItemModel {
  const FaqItemModel({
    required this.id,
    required this.question,
    required this.answer,
    this.category = '',
    this.viewCount = 0,
    this.highlight,
    required this.icon,
    this.isExpanded = false,
  });

  final String id;
  final String question;
  final String answer;

  /// Category name managed in the admin dashboard (empty for legacy entries).
  final String category;

  /// How many times the question has been opened (drives "popular").
  final int viewCount;
  final String? highlight;
  final IconData icon;
  final bool isExpanded;

  FaqItemModel copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? viewCount,
    String? highlight,
    IconData? icon,
    bool? isExpanded,
  }) {
    return FaqItemModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      viewCount: viewCount ?? this.viewCount,
      highlight: highlight ?? this.highlight,
      icon: icon ?? this.icon,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
