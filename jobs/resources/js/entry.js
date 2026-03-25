// ---------- Helpers ----------
function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function uid() {
  return crypto?.randomUUID?.() || String(Date.now() + Math.random());
}

// Normalize URL helper
function normalizeUrl(value) {
  const v = (value || "").trim();
  if (!v) return "";
  if (/^https?:\/\//i.test(v)) return v;
  return "https://" + v;
}

// ---------- State ----------
const state = {
  notes: [] // { id, date, note }
};

// ---------- Elements ----------
const form = document.getElementById("jobForm");
const dateRejected = document.getElementById("dateRejected");
const status = document.getElementById("status");
const notesContainer = document.getElementById("notesContainer");
const addNoteBtn = document.getElementById("addNoteBtn");
const recordEl = document.getElementById("record");
const companyName = document.getElementById("companyName");
const jobTitle = document.getElementById("jobTitle");
const url = document.getElementById("url");
const dateApplied = document.getElementById("dateApplied");
const saveBtn = document.getElementById("saveBtn");
const cancelBtn = document.getElementById("cancelBtn");

// ---------- Notes UI ----------
function renderNotes() {
  notesContainer.innerHTML = "";

  if (state.notes.length === 0) {
    const empty = document.createElement("div");
    empty.className = "note-card empty";
    empty.textContent = "No notes yet. Add one to track progress.";
    notesContainer.appendChild(empty);
    return;
  }

  state.notes.forEach((n, idx) => {
    const card = document.createElement("div");
    card.className = "note-card";

    card.innerHTML = `
      <div class="note-grid three-col">
        <div class="field">
          <label>Date</label>
          <input type="date" name="notes[${idx}][date]" value="${n.date || ""}" />
        </div>

        <div class="field">
          <label>Type</label>
          <select name="notes[${idx}][type]">
            <option value="Initial" ${n.type === 'Initial' ? 'selected' : ''}>Initial</option>
            <option value="Interview" ${n.type === 'Interview' ? 'selected' : ''}>Interview</option>
            <option value="Rejection" ${n.type === 'Rejection' ? 'selected' : ''}>Rejection</option>
            <option value="Other" ${n.type === 'Other' || !n.type ? 'selected' : ''}>Other</option>
          </select>
        </div>

        <div class="field">
          <label>Note</label>
          <textarea name="notes[${idx}][note]" placeholder="e.g. Phone screen with recruiter">${n.note || ""}</textarea>
        </div>
      </div>

      <div class="note-actions">
        <button type="button" class="btn danger" data-remove-note="${n.id}">
          Remove
        </button>
      </div>
    `;

    notesContainer.appendChild(card);

    const removeBtn = card.querySelector(`[data-remove-note="${n.id}"]`);
    removeBtn.addEventListener("click", () => {
      state.notes = state.notes.filter(x => x.id !== n.id);
      renderNotes();
    });
  });
}

function syncNotesFromDOM() {
  state.notes.forEach((n, idx) => {
    const noteCard = notesContainer.children[idx];
    if (!noteCard) return;

    const dateInput = noteCard.querySelector(`input[name="notes[${idx}][date]"]`);
    const typeInput = noteCard.querySelector(`select[name="notes[${idx}][type]"]`); // <-- Added
    const noteInput = noteCard.querySelector(`textarea[name="notes[${idx}][note]"]`);
    
    if (dateInput) n.date = dateInput.value;
    if (typeInput) n.type = typeInput.value; // <-- Added
    if (noteInput) n.note = noteInput.value;
  });
}

function syncNotesFromDOM() {
  state.notes.forEach((n, idx) => {
    const noteCard = notesContainer.children[idx];
    if (!noteCard) return;

    const dateInput = noteCard.querySelector(`input[name="notes[${idx}][date]"]`);
    const noteInput = noteCard.querySelector(`textarea[name="notes[${idx}][note]"]`);
    if (dateInput) n.date = dateInput.value;
    if (noteInput) n.note = noteInput.value;
  });
}

function addNote() {
  syncNotesFromDOM();
  state.notes.unshift({
    id: uid(),
    date: todayISO(),
    type: "Other", // <-- Added default
    note: ""
  });
  renderNotes();
}

// ---------- Validation ----------
function updateSaveButtonState() {
  const enabled =
    companyName.value.trim() !== "" &&
    jobTitle.value.trim() !== "";
  saveBtn.disabled = !enabled;
}

function highlightEmptyFields() {
  companyName.style.borderColor =
    companyName.value.trim() ? "#d8d8e2" : "#b91c1c";
  jobTitle.style.borderColor =
    jobTitle.value.trim() ? "#d8d8e2" : "#b91c1c";
}

companyName.addEventListener("input", () => {
  updateSaveButtonState();
  highlightEmptyFields();
});

jobTitle.addEventListener("input", () => {
  updateSaveButtonState();
  highlightEmptyFields();
});

// ---------- Status behavior ----------
function syncRejectedField() {
  const rejected = status.value === "Rejected";
  dateRejected.disabled = !rejected;
  if (!rejected) dateRejected.value = "";
}

status.addEventListener("change", syncRejectedField);

// ---------- Cancel ----------
cancelBtn.addEventListener("click", () => {
  if (document.referrer) {
    window.location.href = document.referrer;
  } else {
    window.location.href = "./index.html";
  }
});

// ---------- Utility ----------
function getParam(name) {
  return new URLSearchParams(window.location.search).get(name) || "";
}

function setRecordValue(val) {
  recordEl.value = val || "";
}

// ---------- Populate Form (Updated for <job> XML) ----------
async function populateForm() {
  const recordId = recordEl.value || "";
  if (!recordId) return;

  const urlFetch =
    `./resources/xql/populate.xql?record=${encodeURIComponent(recordId)}`;

  try {
    const response = await fetch(urlFetch, { cache: "no-store" });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);

    const text = await response.text();
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(text, "application/xml");

    const job = xmlDoc.querySelector("job");
    if (!job) return;

    // ---- ID ----
    setRecordValue(job.getAttribute("id") || recordId);

    // ---- Simple fields ----
    companyName.value =
      job.querySelector("company")?.textContent.trim() || "";

    jobTitle.value =
      job.querySelector("title")?.textContent.trim() || "";

    url.value =
      normalizeUrl(job.querySelector("url")?.textContent || "");

    // ---- Dates ----
    const dates = job.querySelector("dates");
    if (dates) {
      dateApplied.value = dates.getAttribute("applied") || "";
      dateRejected.value = dates.getAttribute("rejected") || "";
    }

    // ---- Status ----
    const statusText =
      job.querySelector("status")?.textContent.trim() || "Submitted";

    if ([...status.options].some(o => o.value === statusText)) {
      status.value = statusText;
    } else {
      status.value = "Submitted";
    }

    syncRejectedField();

    // ---- Notes ----
    state.notes = [];
    job.querySelectorAll("notes note").forEach(n => {
      state.notes.push({
        id: uid(),
        date: n.getAttribute("date") || "",
        type: n.getAttribute("type") || "Other", // <-- Added
        note: n.textContent.trim()
      });
    });

    renderNotes();
    updateSaveButtonState();
    highlightEmptyFields();

  } catch (err) {
    console.error("Failed to populate form:", err);
  }
}

// ---------- Init ----------
window.addEventListener("DOMContentLoaded", () => {

  const recordParam = getParam("record");
  if (recordParam) {
    setRecordValue(recordParam);
  }

  addNoteBtn.addEventListener("click", addNote);

  renderNotes();
  syncRejectedField();
  updateSaveButtonState();
  highlightEmptyFields();

  populateForm();
});
