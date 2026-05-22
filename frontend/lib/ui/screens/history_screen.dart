import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/history_viewmodel.dart';
import '../theme/app_theme.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().loadHistory();
    });
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final historyVM = context.read<HistoryViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Очистить историю?"),
          content: const Text(
            "Все записи истории будут удалены. Это действие нельзя отменить.",
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text("Очистить"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await historyVM.clearHistory();
    }
  }

  Future<void> _confirmDeleteItem(
    BuildContext context,
    String id,
  ) async {
    final historyVM = context.read<HistoryViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Удалить запись?"),
          content: const Text(
            "Эта запись будет удалена из истории.",
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text("Удалить"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await historyVM.deleteHistoryItem(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyVM = context.watch<HistoryViewModel>();
    final items = historyVM.items;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text("История распознаваний"),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              child: Text(
                _isEditMode ? "Готово" : "Edit",
                style: const TextStyle(
                  color: AppTheme.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: historyVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : items.isEmpty
              ? const Center(
                  child: Text(
                    "История пока пустая",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    if (_isEditMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          18,
                          24,
                          0,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _confirmClearHistory(context),
                          icon: const Icon(Icons.delete_sweep),
                          label: const Text("Очистить всю историю"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            minimumSize:
                                const Size(double.infinity, 52),
                            side: BorderSide(
                              color: Colors.red.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: _isEditMode
                                ? null
                                : () {
                                    context.push(
                                      '/details',
                                      extra: {
                                        "plantName": item.plantName,
                                        "diseaseName": item.diseaseName,
                                        "confidence": item.confidence,
                                        "imagePath": item.imagePath ?? "",
                                      },
                                    );
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen
                                        .withValues(alpha: 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: item.imagePath != null &&
                                            File(item.imagePath!).existsSync()
                                        ? Image.file(
                                            File(item.imagePath!),
                                            width: 58,
                                            height: 58,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 58,
                                            height: 58,
                                            color: AppTheme.softGreen,
                                            child: Icon(
                                              item.icon,
                                              color: AppTheme.primaryGreen,
                                            ),
                                          ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.plantName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          item.diseaseName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          "${item.date}  ${item.time}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  if (_isEditMode)
                                    IconButton(
                                      onPressed: () =>
                                          _confirmDeleteItem(
                                        context,
                                        item.id,
                                      ),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade700,
                                      ),
                                    )
                                  else
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.softGreen,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        item.confidence,
                                        style: const TextStyle(
                                          color:
                                              AppTheme.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}