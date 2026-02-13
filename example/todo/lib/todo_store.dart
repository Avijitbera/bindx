import 'package:bindx/bindx.dart';
import 'package:todo/todo_model.dart';

class TodoStore extends BindXStore<List<TodoModel>> {
  TodoStore() : super([]);

  Future<void> addTodo(String title, int priority) async {
    await update(
      (current) => [
        ...current,
        TodoModel(
          id: DateTime.now().toString(),
          title: title,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          priority: priority,
        ),
      ],
    );
  }

  Future<void> removeTodo(String id) async {
    await update((current) => current.where((todo) => todo.id != id).toList());
  }
}
