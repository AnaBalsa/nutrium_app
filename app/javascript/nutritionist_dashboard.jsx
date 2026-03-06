import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";

function PendingRequestsApp({ nutritionistId }) {
  const [loading, setLoading] = useState(true);
  const [requests, setRequests] = useState([]);
  const [error, setError] = useState(null);
  const [busyId, setBusyId] = useState(null);

  async function load() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/nutritionists/${nutritionistId}/appointment_requests?status=pending`);

      if (!res.ok) throw new Error(`Failed to load (${res.status})`);
      const data = await res.json();
      setRequests(data);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { load(); }, [nutritionistId]);

  async function decide(id, decision) {
    setBusyId(id);
    setError(null);
    try {
      const res = await fetch(`/api/appointment_requests/${id}/decide`, {
        method: "PATCH",
        headers: { 
          "Content-Type": "application/json" },
        body: JSON.stringify({ decision })
      });

      if (!res.ok) {
        throw new Error("Failed to update appointment");
      }
      // reload pending requests after decision
      await load();
    } catch (e) {
      setError(e.message);
    } finally {
      setBusyId(null);
    }
  }

  return (
    <div style={{ maxWidth: 1100 }}>
      <div style={{ marginBottom: 14 }}>
        <div style={{ opacity: 0.7 }}>Accept or reject new pending requests</div>
      </div>

      {error && (
        <div style={{ padding: 10, border: "1px solid #f5c2c7", background: "#f8d7da", marginBottom: 12 }}>
          {error}
        </div>
      )}

      {loading ? (
        <div>Loading…</div>
      ) : requests.length === 0 ? (
        <div>No pending requests.</div>
      ) : (
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: 12 }}>
          {requests.map((r) => (
            <div key={r.id} style={{ border: "1px solid #eee", borderRadius: 14, padding: 14 }}>
              <div style={{ fontWeight: 800 }}>{r.guest_name}</div>
              <div style={{ opacity: 0.75, marginBottom: 10 }}>{r.service?.name || "Appointment"}</div>

              <div style={{ fontSize: 14, lineHeight: 1.4 }}>
                <div><strong>When:</strong> {new Date(r.starts_at).toLocaleString()}</div>
                <div><strong>Location: </strong> {r.service?.location_name || "Online appointment"}</div>
                <div><strong>Client email:</strong> {r.guest_email}</div>
              </div>

              <div style={{ display: "flex", gap: 8, marginTop: 12 }}>
                <button disabled={busyId === r.id} onClick={() => decide(r.id, "accepted")}>
                  Accept
                </button>
                <button disabled={busyId === r.id} onClick={() => decide(r.id, "rejected")}>
                  Reject
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

let root = null;

function mount() {
  const el = document.getElementById("nutritionist-dashboard");
  if (!el) return;

  const nutritionistId = el.dataset.nutritionistId;

  if (!root) root = createRoot(el);
  root.render(<PendingRequestsApp nutritionistId={nutritionistId} />);
}

function unmount() {
  if (root) {
    root.unmount();
    root = null;
  }
}

document.addEventListener("turbo:load", mount);
document.addEventListener("turbo:before-cache", unmount);
document.addEventListener("DOMContentLoaded", mount);
