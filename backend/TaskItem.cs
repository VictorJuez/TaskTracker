namespace TaskTracker
{
    /// <summary>
    /// Represents a task item.
    /// </summary>
    public class TaskItem
    {
        /// <summary>
        /// The unique identifier for the task.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// The title or description of the task.
        /// </summary>
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// Indicates whether the task is completed.
        /// </summary>
        public bool Completed { get; set; }
    }
} 