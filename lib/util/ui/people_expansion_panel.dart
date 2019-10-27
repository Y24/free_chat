import 'package:flutter/material.dart';
import 'package:free_chat/entity/contact_entity.dart';

class PeopleExpansionPanel extends ExpansionPanel {
  final Widget header;
  final List<ContactEntity> content;
  final bool isExpanded;
  PeopleExpansionPanel(
    BuildContext context, {
    this.content,
    this.header,
    this.isExpanded,
  }) : super(
          isExpanded: isExpanded,
          body: SingleChildScrollView(
            child: Column(
              children: content.map((c) => c.toListTile(context)).toList(),
            ),
          ),
          headerBuilder: (BuildContext context, bool expansioned) => header,
        );
}
