import 'package:flutter/material.dart';
import '../services/journal_service.dart';
import '../models/journal_model.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _selectedMood;
  bool _isSaving = false;

  late Future<List<JournalEntry>> _journalsFuture;

  final List<String> moods = ['😊 Happy', '😐 Neutral', '😔 Sad', '😠 Angry'];

  @override
  void initState() {
    super.initState();
    _journalsFuture = JournalService.fetchJournals();
  }

  // 🔄 SAFE REFRESH (NO setState LOOP)
  void _refreshJournals() {
    setState(() {
      _journalsFuture = JournalService.fetchJournals();
    });
  }

  // 💾 SAVE JOURNAL
  Future<void> _saveJournal() async {
    if (_controller.text.trim().isEmpty || _isSaving) return;

    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    await JournalService.addJournalEntry(
      content: _controller.text.trim(),
      mood: _selectedMood,
    );

    _controller.clear();
    _selectedMood = null;

    if (mounted) {
      _refreshJournals();
      setState(() => _isSaving = false);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Journal saved 🌱")),
    );
  }

  // ✏️ EDIT JOURNAL
  Future<void> _editJournal(JournalEntry journal) async {
    final editController = TextEditingController(text: journal.content);
    String? editMood = journal.mood;

    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Journal ✏️",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: editController, maxLines: 4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: moods.map((m) {
                  return ChoiceChip(
                    label: Text(m),
                    selected: editMood == m,
                    onSelected: (_) => editMood = m,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await JournalService.updateJournalEntry(
                    id: journal.id,
                    content: editController.text.trim(),
                    mood: editMood,
                  );
                  Navigator.pop(context, true);
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        );
      },
    );

    if (updated == true && mounted) {
      _refreshJournals();
    }
  }

  // 🗑 DELETE JOURNAL
  Future<void> _deleteJournal(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Journal?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await JournalService.deleteJournalEntry(id);
      if (mounted) _refreshJournals();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Journal 📓")),
      body: Column(
        children: [
          // ✍️ INPUT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Write your thoughts…",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: moods.map((m) {
                        return ChoiceChip(
                          label: Text(m),
                          selected: _selectedMood == m,
                          onSelected: (_) {
                            setState(() {
                              _selectedMood =
                                  _selectedMood == m ? null : m;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveJournal,
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : const Text("Save Journal"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 📚 LIST
          Expanded(
            child: FutureBuilder<List<JournalEntry>>(
              future: _journalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                      child: Text("No journal entries yet 🌿"));
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, i) {
                    final j = data[i];
                    return Card(
                      child: ListTile(
                        title: Text(j.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          "${j.mood ?? ''} • ${j.createdAt.toLocal()}",
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _editJournal(j);
                            if (v == 'delete')
                              _deleteJournal(j.id);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'edit',
                                child: Text("Edit")),
                            PopupMenuItem(
                                value: 'delete',
                                child: Text("Delete")),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
