enum TasksCollectionType {
  ROUTINE_TASKS,
  TODAYS_TASKS,
}

const Map<TasksCollectionType, String> tasksCollectionTypesDBNames = {
  TasksCollectionType.ROUTINE_TASKS: "routine_tasks",
  TasksCollectionType.TODAYS_TASKS: "tasks"
};

const Map<TasksCollectionType, String> tasksCollectionTypesViewNames = {
  TasksCollectionType.ROUTINE_TASKS: "Routine Tasks",
  TasksCollectionType.TODAYS_TASKS: "Tasks"
};