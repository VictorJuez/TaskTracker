using Microsoft.EntityFrameworkCore;

namespace TaskTracker
{
    /// <summary>
    /// Entity Framework Core database context for TaskItems.
    /// </summary>
    public class TaskContext : DbContext
    {
        public TaskContext(DbContextOptions<TaskContext> options) : base(options) { }

        /// <summary>
        /// The Tasks table.
        /// </summary>
        public DbSet<TaskItem> Tasks { get; set; } = null!;
    }
}