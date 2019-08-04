enum TasksCollectionTypes {
  ROUTINE_TASKS,
  TODAYS_TASKS,
}

const Map<TasksCollectionTypes, String> tasksCollectionTypesDBNames = {
  TasksCollectionTypes.ROUTINE_TASKS: "routine_tasks",
  TasksCollectionTypes.TODAYS_TASKS: "tasks"
};

const Map<TasksCollectionTypes, String> tasksCollectionTypesViewNames = {
  TasksCollectionTypes.ROUTINE_TASKS: "Routine Tasks",
  TasksCollectionTypes.TODAYS_TASKS: "Tasks"
};