import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_database_sql/constants.dart';
import 'package:flutter_database_sql/models/label.dart';
import 'package:flutter_database_sql/models/note.dart';
import 'package:flutter_database_sql/providers/label_provider.dart';
import 'package:flutter_database_sql/providers/notes_provider.dart';
import 'package:flutter_database_sql/widgets/note_insert_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NoteWidget extends StatefulWidget {
  final Note note;
  final Key key;
  NoteWidget(this.note, this.key) : super(key: key);
  @override
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  bool open = false;
  Label label;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setLabel();
  }

  void setLabel() {
    label = widget.note.labelId != 'default'
        ? Provider.of<Labels>(context, listen: false)
            .findLabelById(widget.note.labelId)
        : Label('default', 'default', 0x000000);
  }

  @override
  Widget build(BuildContext context) {
    setLabel();
    return GestureDetector(
      onTap: () {
        setState(() {
          open = !open;
        });
      },
      onDoubleTap: () async {
        showDialog<bool>(
            barrierColor: Colors.white70,
            context: context,
            builder: (ctx) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32))),
                  children: [
                    AddNote(
                      note: widget.note,
                    )
                  ],
                ),
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Dismissible(
          key: ValueKey(widget.note.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) async {
            await Provider.of<Notes>(context, listen: false)
                .deleteNote(widget.note.id);
          },
          background: Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'REMOVE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0))),
            elevation: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.label,
                            size: 15,
                            color: Color(
                                    label == null ? 0x000000 : label.colorValue)
                                .withOpacity(1)),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            widget.note.title ?? '',
                            style: kNoteTitleTextStyle,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                            DateFormat('dd.MM.yyyy')
                                .format(DateTime.parse(widget.note.date))
                                .toString(),
                            style: kNoteDateTextStyle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 8.0),
                    child: Text(
                      widget.note.content ?? '',
                      softWrap: true,
                      overflow:
                          open ? TextOverflow.clip : TextOverflow.ellipsis,
                      style: kNoteContentTextStyle,
                    ),
                  ),
                  if (open) SizedBox(height: 8.0),
                  if (open) Divider(height: 1),
                  if (open)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Double tap to edit.',
                            style: kNoteDateTextStyle.copyWith(
                                color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
