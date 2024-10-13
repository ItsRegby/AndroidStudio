import 'package:flutter/material.dart';
import '../models/list_item.dart';

class EditItemDialog extends StatefulWidget {
  final ListItem item;

  const EditItemDialog({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late String _selectedType;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController1;
  late TextEditingController _textController2;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.item.runtimeType.toString();
    _textController1 = TextEditingController();
    _textController2 = TextEditingController();

    if (widget.item is HeadingItem) {
      _textController1.text = (widget.item as HeadingItem).heading;
    } else if (widget.item is MessageItem) {
      _textController1.text = (widget.item as MessageItem).sender;
      _textController2.text = (widget.item as MessageItem).body;
    } else if (widget.item is ImageItem) {
      _textController1.text = (widget.item as ImageItem).imageUrl;
      _textController2.text = (widget.item as ImageItem).description;
    } else if (widget.item is DateItem) {
      _selectedDate = (widget.item as DateItem).date;
      _textController1.text = (widget.item as DateItem).description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type: $_selectedType'),
            const SizedBox(height: 16),
            if (_selectedType == 'HeadingItem')
              TextFormField(
                controller: _textController1,
                decoration: const InputDecoration(labelText: 'Heading'),
                validator: (value) => value!.isEmpty ? 'Please enter a heading' : null,
              )
            else if (_selectedType == 'MessageItem') ...[
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
            ] else if (_selectedType == 'ImageItem') ...[
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
            ] else if (_selectedType == 'DateItem') ...[
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
              ListItem updatedItem;
              switch (_selectedType) {
                case 'HeadingItem':
                  updatedItem = HeadingItem(_textController1.text, id: widget.item.id);
                  break;
                case 'MessageItem':
                  updatedItem = MessageItem(_textController1.text, _textController2.text, id: widget.item.id);
                  break;
                case 'ImageItem':
                  updatedItem = ImageItem(_textController1.text, _textController2.text, id: widget.item.id);
                  break;
                case 'DateItem':
                  updatedItem = DateItem(_selectedDate, _textController1.text, id: widget.item.id);
                  break;
                default:
                  throw Exception('Unknown item type');
              }
              Navigator.of(context).pop(updatedItem);
            }
          },
          child: const Text('Update'),
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