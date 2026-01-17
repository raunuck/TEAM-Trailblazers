// lib/models/schedule_task.dart

enum TaskStatus { scheduled, free, cancelled }

class ScheduleTask {
  String id;
  String time;
  String endTime;
  String title;
  String location;
  TaskStatus status;
  String? description;
  String? resourceUrl;
  String? resourceType;
  bool isCompleted; // This is the new field for checkboxes

  ScheduleTask({
    required this.id,
    required this.time,
    required this.endTime,
    required this.title,
    this.location = "",
    this.status = TaskStatus.scheduled,
    this.description,
    this.resourceUrl,
    this.resourceType,
    this.isCompleted = false,
  });
}
