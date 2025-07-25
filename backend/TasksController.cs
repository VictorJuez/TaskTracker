using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace TaskTracker
{
    [ApiController]
    [Route("api/[controller]")]
    public class TasksController : ControllerBase
    {
        private readonly TaskContext _context;

        public TasksController(TaskContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Gets all tasks.
        /// </summary>
        /// <returns>List of all tasks.</returns>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TaskItem>>> GetTasks()
        {
            return await _context.Tasks.ToListAsync();
        }

        /// <summary>
        /// Gets a task by ID.
        /// </summary>
        /// <param name="id">Task ID</param>
        /// <returns>The task with the specified ID.</returns>
        [HttpGet("{id}")]
        public async Task<ActionResult<TaskItem>> GetTask(int id)
        {
            var task = await _context.Tasks.FindAsync(id);
            if (task == null)
                return NotFound();
            return task;
        }

        /// <summary>
        /// Creates a new task.
        /// </summary>
        /// <param name="taskItem">Task to create</param>
        /// <returns>The created task.</returns>
        [HttpPost]
        public async Task<ActionResult<TaskItem>> CreateTask(TaskItem taskItem)
        {
            _context.Tasks.Add(taskItem);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetTask), new { id = taskItem.Id }, taskItem);
        }

        /// <summary>
        /// Updates an existing task.
        /// </summary>
        /// <param name="id">Task ID</param>
        /// <param name="taskItem">Updated task data</param>
        /// <returns>No content if successful, 404 if not found.</returns>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTask(int id, TaskItem taskItem)
        {
            if (id != taskItem.Id)
                return BadRequest();

            var existing = await _context.Tasks.FindAsync(id);
            if (existing == null)
                return NotFound();

            existing.Title = taskItem.Title;
            existing.Completed = taskItem.Completed;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        /// <summary>
        /// Deletes a task by ID.
        /// </summary>
        /// <param name="id">Task ID</param>
        /// <returns>No content if successful, 404 if not found.</returns>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(int id)
        {
            var task = await _context.Tasks.FindAsync(id);
            if (task == null)
                return NotFound();
            _context.Tasks.Remove(task);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}