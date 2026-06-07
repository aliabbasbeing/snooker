import 'package:flutter/cupertino.dart';

class AddPlayerDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddPlayerDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final name = _controller.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name';
      });
      return;
    }
    
    if (name.length < 2) {
      setState(() {
        _errorMessage = 'Name must be at least 2 characters';
      });
      return;
    }
    
    widget.onAdd(name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Add Player'),
      content: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            CupertinoTextField(
              controller: _controller,
              placeholder: 'Player name',
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _handleAdd(),
              onChanged: (_) {
                if (_errorMessage.isNotEmpty) {
                  setState(() {
                    _errorMessage = '';
                  });
                }
              },
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: _handleAdd,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
