abstract class ListItem {
  int? id;
  ListItem({this.id});
}

class HeadingItem extends ListItem {
  final String heading;
  HeadingItem(this.heading, {int? id}) : super(id: id);
}

class MessageItem extends ListItem {
  final String sender;
  final String body;
  MessageItem(this.sender, this.body, {int? id}) : super(id: id);
}

class ImageItem extends ListItem {
  final String imageUrl;
  final String description;
  ImageItem(this.imageUrl, this.description, {int? id}) : super(id: id);
}

class DateItem extends ListItem {
  final DateTime date;
  final String description;
  DateItem(this.date, this.description, {int? id}) : super(id: id);
}