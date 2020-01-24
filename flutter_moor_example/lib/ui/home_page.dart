
import 'package:flutter/material.dart';
import 'package:flutter_moor_example/data/moor_database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'new_task_input.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tasks'),
        actions: <Widget>[
          _buildCompletedOnlySwitch(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildTaskList(context),),
          NewTaskInput(),
        ],
      ),
    );
  }

  Row _buildCompletedOnlySwitch(){
    return Row(
      children: <Widget>[
        Text('Completed only'),
        Switch(
          value: showCompleted,
          activeColor: Colors.white,
          onChanged: (newValue) {setState(() {
            showCompleted = newValue;
          });},
        )
      ],
    );
  }

  StreamBuilder<List<TaskWithTag>> _buildTaskList(BuildContext context){
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder(
      stream: dao.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<TaskWithTag>> snapshot){
        final tasks = snapshot.data ?? List();

        return ListView.builder(itemCount: tasks.length, itemBuilder: (_, index){
          final itemTask = tasks[index];
          return _buildListItem(itemTask.task, dao);
        },);
      },
    );
  }

  Widget _buildListItem(Task itemTask, TaskDao database){
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => database.deleteTask(itemTask),
        )
      ],
      child: CheckboxListTile(
        title: Text(itemTask.name),
        subtitle: Text(itemTask.dueDate.toString()),
        value: itemTask.completed,
        onChanged: (newValue){
          database.updateTask(itemTask.copyWith(completed: newValue));
        },
      ),
    );
  }
}
