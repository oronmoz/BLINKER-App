import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class DropdownCustom extends StatefulWidget {
  final String? title;
  final List<String> items;

  DropdownCustom({required this.title, required this.items});

  @override
  _DropdownCustomState createState() => _DropdownCustomState();
}

class _DropdownCustomState extends State<DropdownCustom> {
  final SingleValueDropDownController _controller = SingleValueDropDownController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Please pick a ${widget.title}:'),
        SizedBox(height: 20),
        DropDownTextField(
          controller: _controller,
          clearOption: true,
          textFieldDecoration: InputDecoration(
            hintText: 'Select ${widget.title}',
            border: OutlineInputBorder(),
          ),
          dropDownItemCount: widget.items.length,
          dropDownList: widget.items.map((item) => DropDownValueModel(name: item, value: item)).toList(),
          onChanged: (val) {
            setState(() {
              try{
                _controller.dropDownValue = val;
              }
              catch (e){
                _controller.dropDownValue = null;
              }
            });
          },
        ),
      ],
    );
  }
}
