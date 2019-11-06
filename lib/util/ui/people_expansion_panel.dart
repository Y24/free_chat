import 'package:flutter/material.dart';

class PeopleExpansionPanel extends ExpansionPanel {
  final Widget header;
  final List content;
  final bool isExpanded;
  PeopleExpansionPanel(
    BuildContext context, {
    this.content,
    this.header,
    this.isExpanded,
  }) : super(
          isExpanded: isExpanded,
          body: SingleChildScrollView(
            child: column(content, context),
          ),
          headerBuilder: (BuildContext context, bool expansioned) => header,
        );

  static Widget column(List content, BuildContext context) {
    final data = content.map<Widget>((c) => c.toListTile(context)).toList();
    if (data.isEmpty)
      return SizedBox(
        height: 40,
      );
    return Column(
      children: data,
    );
  }
}
