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
      <div class="note-grid">
        <div class="field">
          <label>Date</label>
          <input type="date" name="notes[${idx}][date]" value="${n.date || ""}" />
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
    note: ""
  });
  renderNotes();
}

function updateSaveButtonState() {
  const enabled = companyName.value.trim() !== "" && jobTitle.value.trim() !== "";
  saveBtn.disabled = !enabled;
}

// Watch inputs
companyName.addEventListener("input", updateSaveButtonState);
jobTitle.addEventListener("input", updateSaveButtonState);

// Initialize state on page load
updateSaveButtonState();

function highlightEmptyFields() {
  companyName.style.borderColor = companyName.value.trim() ? "#d8d8e2" : "#b91c1c";
  jobTitle.style.borderColor = jobTitle.value.trim() ? "#d8d8e2" : "#b91c1c";
}

companyName.addEventListener("input", highlightEmptyFields);
jobTitle.addEventListener("input", highlightEmptyFields);
highlightEmptyFields();

// ---------- Status behavior ----------
function syncRejectedField() {
  const rejected = status.value === "Rejected";
  dateRejected.disabled = !rejected;
  if (!rejected) dateRejected.value = "";
}

status.addEventListener("change", syncRejectedField);

cancelBtn.addEventListener("click", () => {
  // Go back to referrer if available, otherwise fallback to index.html
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

// ---------- Populate Form ----------
async function populateForm() {
  const recordId = recordEl.value || "";
  const urlFetch = recordId
    ? `./resources/xql/populate.xql?record=${encodeURIComponent(recordId)}`
    : "./resources/xql/populate.xql";

  try {
    const response = await fetch(urlFetch, { cache: "no-store" });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);

    const text = await response.text();
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(text, "application/xml");
    const recordNode = xmlDoc.querySelector("record");

    if (!recordNode) {
      setRecordValue(recordId);
      return;
    }

    const getText = (tag) => {
      const el = recordNode.querySelector(tag);
      return el ? el.textContent.trim() : "";
    };

    if (getText("companyName")) companyName.value = getText("companyName");
    if (getText("jobTitle")) jobTitle.value = getText("jobTitle");
    if (getText("url")) url.value = normalizeUrl(getText("url"));
    if (getText("dateApplied")) dateApplied.value = getText("dateApplied");
    if (getText("dateRejected")) dateRejected.value = getText("dateRejected");

    const statusText = getText("status");
    if ([...status.options].some(o => o.value === statusText)) {
      status.value = statusText;
    } else {
      status.value = "Submitted";
    }

    syncRejectedField();
    setRecordValue(getText("id") || recordId);

    // Populate notes
    const notesNodes = recordNode.querySelectorAll("notes note");
    if (notesNodes.length) {
      state.notes = [];
      notesNodes.forEach((n) => {
        state.notes.push({
          id: uid(),
          date: n.querySelector("date")?.textContent || "",
          note: n.querySelector("noteText")?.textContent || ""
        });
      });
      renderNotes();
    }
  } catch (err) {
    console.error("Failed to populate form:", err);
    setRecordValue(recordEl.value);
  }
}

// ---------- Init ----------
window.addEventListener("DOMContentLoaded", () => {
  const recordParam = getParam("record");
  if (recordParam) setRecordValue(recordParam);

  addNoteBtn.addEventListener("click", addNote);
  renderNotes();
  syncRejectedField();

  populateForm();
});