import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String name;
  final String amount;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  const MyListTile(
      {super.key,
      required this.name,
      required this.amount,
      this.onEditPressed,
      this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            //settings option
            SlidableAction(
              onPressed: onEditPressed,
              icon: Icons.settings,
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6.0),
                bottomLeft: Radius.circular(6.0),
              ),
            ),
            //delete option
            SlidableAction(
              onPressed: onDeletePressed,
              icon: Icons.delete,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6.0),
                bottomRight: Radius.circular(6.0),
              ),
              backgroundColor: Colors.grey,
              foregroundColor: const Color.fromARGB(255, 208, 55, 44),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            title: Text(name),
            trailing: Text(amount),
          ),
        ),
      ),
    );
  }
}
