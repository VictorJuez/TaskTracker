import React, { useEffect, useState } from "react";

interface TaskItem {
  id: number;
  title: string;
  completed: boolean;
}

const API_URL = process.env.REACT_APP_API_URL || "/api/tasks";

function App() {
  const [tasks, setTasks] = useState<TaskItem[]>([]);
  const [newTitle, setNewTitle] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchTasks = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(API_URL);
      if (!res.ok) throw new Error("Failed to fetch tasks");
      setTasks(await res.json());
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  const addTask = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: newTitle, completed: false }),
      });
      if (!res.ok) throw new Error("Failed to add task");
      setNewTitle("");
      await fetchTasks();
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const updateTask = async (task: TaskItem) => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/${task.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(task),
      });
      if (!res.ok) throw new Error("Failed to update task");
      await fetchTasks();
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const deleteTask = async (id: number) => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/${id}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Failed to delete task");
      await fetchTasks();
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{ maxWidth: 500, margin: "2rem auto", fontFamily: "sans-serif" }}
    >
      <h1>TaskTracker</h1>
      <form
        onSubmit={addTask}
        style={{ display: "flex", gap: 8, marginBottom: 16 }}
      >
        <input
          type="text"
          value={newTitle}
          onChange={(e) => setNewTitle(e.target.value)}
          placeholder="New task title"
          disabled={loading}
          style={{ flex: 1 }}
        />
        <button type="submit" disabled={loading || !newTitle.trim()}>
          Add
        </button>
      </form>
      {error && <div style={{ color: "red", marginBottom: 8 }}>{error}</div>}
      {loading && <div>Loading...</div>}
      <ul style={{ listStyle: "none", padding: 0 }}>
        {tasks.map((task) => (
          <li
            key={task.id}
            style={{
              display: "flex",
              alignItems: "center",
              gap: 8,
              marginBottom: 8,
            }}
          >
            <input
              type="checkbox"
              checked={task.completed}
              onChange={() =>
                updateTask({ ...task, completed: !task.completed })
              }
              disabled={loading}
            />
            <input
              type="text"
              value={task.title}
              onChange={(e) => updateTask({ ...task, title: e.target.value })}
              disabled={loading}
              style={{
                flex: 1,
                border: "none",
                background: "transparent",
                fontSize: 16,
              }}
            />
            <button
              onClick={() => deleteTask(task.id)}
              disabled={loading}
              style={{ color: "red" }}
            >
              Delete
            </button>
          </li>
        ))}
      </ul>
      {tasks.length === 0 && !loading && <div>No tasks yet.</div>}
    </div>
  );
}

export default App;
