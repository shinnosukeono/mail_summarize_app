import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class TextEditingDialog extends StatefulWidget {
  const TextEditingDialog({Key? key, this.jsonSummarizedSchedule})
      : super(key: key);
  final dynamic jsonSummarizedSchedule;

  @override
  State<TextEditingDialog> createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends State<TextEditingDialog> {
  final titleController = TextEditingController();
  final focusNode = FocusNode();
  late DateTime startDateTime;
  late DateTime endDateTime;
  @override
  void dispose() {
    titleController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    titleController.text = widget.jsonSummarizedSchedule['summary'];
    focusNode.addListener(
      () {
        // フォーカスが当たったときに文字列が選択された状態にする
        if (focusNode.hasFocus) {
          titleController.selection = TextSelection(
              baseOffset: 0, extentOffset: titleController.text.length);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: <Widget>[
          TextFormField(
            autofocus: true,
            focusNode: focusNode,
            controller: titleController,
            onFieldSubmitted: (_) {
              Navigator.of(context).pop(titleController.text);
            },
            decoration: const InputDecoration(
              labelText: 'タイトル',
            ),
          ),
          DateTimeField(
            format: DateFormat("yyyy-MM-dd HH:mm"),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: widget.jsonSummarizedSchedule['dt_start'] ??
                      DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      widget.jsonSummarizedSchedule['dt_start'] ??
                          DateTime.now()),
                );
                startDateTime = DateTimeField.combine(date, time);
              } else {
                startDateTime = widget.jsonSummarizedSchedule['dt_start'];
              }
              return startDateTime;
            },
            decoration: const InputDecoration(
              labelText: '開始',
            ),
          ),
          DateTimeField(
            format: DateFormat("yyyy-MM-dd HH:mm"),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate:
                      widget.jsonSummarizedSchedule['dt_end'] ?? DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      widget.jsonSummarizedSchedule['dt_end'] ??
                          DateTime.now()),
                );
                endDateTime = DateTimeField.combine(date, time);
              } else {
                endDateTime = widget.jsonSummarizedSchedule['dt_end'];
              }
              return endDateTime;
            },
            decoration: const InputDecoration(
              labelText: '終了',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('戻る'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'summary': titleController.text,
              'dt_start': startDateTime,
              'dt_end': endDateTime
            });
          },
          child: const Text('完了'),
        )
      ],
    );
  }
}
