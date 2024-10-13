import 'package:flutter/material.dart';
import '../models/list_item.dart';

class AddItemDialog extends StatefulWidget {
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  String _selectedType = 'Heading';
  final _formKey = GlobalKey<FormState>();
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: ['Heading', 'Message', 'Image', 'Date']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedType == 'Heading')
              TextFormField(
                controller: _textController1,
                decoration: const InputDecoration(labelText: 'Heading'),
                validator: (value) => value!.isEmpty ? 'Please enter a heading' : null,
              )
            else if (_selectedType == 'Message') ...[
              TextFormField(
                controller: _textController1,
                decoration: const InputDecoration(labelText: 'Sender'),
                validator: (value) => value!.isEmpty ? 'Please enter a sender' : null,
              ),
              TextFormField(
                controller: _textController2,
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (value) => value!.isEmpty ? 'Please enter a message' : null,
              ),
            ] else if (_selectedType == 'Image') ...[
              TextFormField(
                controller: _textController1,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) => value!.isEmpty ? 'Please enter an image URL' : null,
              ),
              TextFormField(
                controller: _textController2,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
            ] else if (_selectedType == 'Date') ...[
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(_selectedDate.toString().split(' ')[0]),
                ),
              ),
              TextFormField(
                controller: _textController1,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              ListItem newItem;
              switch (_selectedType) {
                case 'Heading':
                  newItem = HeadingItem(_textController1.text);
                  break;
                case 'Message':
                  newItem = MessageItem(_textController1.text, _textController2.text);
                  break;
                case 'Image':
                  newItem = ImageItem(_textController1.text, _textController2.text);
                  break;
                case 'Date':
                  newItem = DateItem(_selectedDate, _textController1.text);
                  break;
                default:
                  throw Exception('Unknown item type');
              }
              Navigator.of(context).pop(newItem);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }
}