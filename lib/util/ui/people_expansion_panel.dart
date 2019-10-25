import 'package:flutter/material.dart';
import 'package:free_chat/entity/contacts_entity.dart';

class PeopleExpansionPanel extends ExpansionPanel {
  final Widget header;
  final List<ContactsEntity> content;
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
              children: <Widget>[...content.map((c) => c.toListTile(context))],
            ),
          ),
          headerBuilder: (BuildContext context, bool expansioned) => header,
        );
}
