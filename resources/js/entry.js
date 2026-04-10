// ======================================================
// Helpers
// ======================================================

function getParam(name) {
  return new URLSearchParams(window.location.search).get(name) || "";
}

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function uid() {
  return crypto?.randomUUID?.() || String(Date.now() + Math.random());
}

function normalizeUrl(value) {
  const v = (value || "").trim();
  if (!v) return "";
  if (/^https?:\/\//i.test(v)) return v;
  return "https://" + v;
}

// ======================================================
// Global State
// ======================================================

const state = {
  notes: [],
  contacts: [] // { id, name, role, mail, phone }
};

// ======================================================
// Contacts UI
// ======================================================

function renderContacts() {
  const container = document.getElementById("contactsContainer");
  if (!container) return;

  container.innerHTML = "";

  if (state.contacts.length === 0) {
    const empty = document.createElement("div");
    empty.className = "card empty";
    empty.textContent = "No contacts yet. Add one to track network leads.";
    container.appendChild(empty);
    return;
  }

  state.contacts.forEach((c, idx) => {
    const card = document.createElement("div");
    card.className = "card contact-card";

    card.innerHTML = `
      <div class="contact-row top">
        <div class="field name">
          <label>Name</label>
          <input type="text" name="contacts[${idx}][name]" value="${c.name || ""}" placeholder="Full Name" />
        </div>

        <div class="field role">
          <label>Role</label>
          <select name="contacts[${idx}][role]">
            <option value="Recruiter" ${c.role === "Recruiter" ? "selected" : ""}>Recruiter</option>
            <option value="Hiring Manager" ${c.role === "Hiring Manager" ? "selected" : ""}>Hiring Manager</option>
            <option value="Referral" ${c.role === "Referral" ? "selected" : ""}>Referral</option>
            <option value="HR" ${c.role === "HR" ? "selected" : ""}>HR/Internal</option>
            <option value="Other" ${c.role === "Other" || !c.role ? "selected" : ""}>Other</option>
          </select>
        </div>
      </div>

      <div class="contact-row bottom">
        <div class="field">
          <label>Email</label>
          <input type="email" name="contacts[${idx}][mail]" value="${c.mail || ""}" placeholder="email@company.com" />
        </div>

        <div class="field">
          <label>Phone</label>
          <input type="tel" name="contacts[${idx}][phone]" value="${c.phone || ""}" placeholder="555-555-5555" />
        </div>
      </div>

      <div class="card-actions">
        <button type="button" class="btn danger" data-remove-contact="${c.id}">
          Remove
        </button>
      </div>
    `;

    container.appendChild(card);

    card.querySelector(`[data-remove-contact="${c.id}"]`)
      .addEventListener("click", () => {
        state.contacts = state.contacts.filter(x => x.id !== c.id);
        renderContacts();
      });
  });
}

function syncContactsFromDOM() {
  const container = document.getElementById("contactsContainer");
  if (!container) return;

  state.contacts.forEach((c, idx) => {
    const card = container.children[idx];
    if (!card) return;

    c.name = card.querySelector(`input[name="contacts[${idx}][name]"]`)?.value || "";
    c.role = card.querySelector(`select[name="contacts[${idx}][role]"]`)?.value || c.role;
    c.mail = card.querySelector(`input[name="contacts[${idx}][mail]"]`)?.value || "";
    c.phone = card.querySelector(`input[name="contacts[${idx}][phone]"]`)?.value || "";
  });
}

function addContact() {
  syncContactsFromDOM();
  state.contacts.unshift({
    id: uid(),
    name: "",
    role: "Recruiter",
    mail: "",
    phone: ""
  });
  renderContacts();
}

// ======================================================
// Notes UI (UPDATED)
// ======================================================

function renderNotes() {
  const container = document.getElementById("notesContainer");
  if (!container) return;

  container.innerHTML = "";

  if (state.notes.length === 0) {
    const empty = document.createElement("div");
    empty.className = "card empty";
    empty.textContent = "No notes yet. Add one to track progress.";
    container.appendChild(empty);
    return;
  }

  state.notes.forEach((n, idx) => {
    const card = document.createElement("div");
    card.className = "card note-card";

    card.innerHTML = `
      <div class="note-row top">
        <div class="field">
          <label>Date</label>
          <input type="date" name="notes[${idx}][date]" value="${n.date || ""}" />
        </div>

        <div class="field">
          <label>Type</label>
          <select name="notes[${idx}][type]">
            <option value="Initial" ${n.type === "Initial" ? "selected" : ""}>Initial</option>
            <option value="Interview" ${n.type === "Interview" ? "selected" : ""}>Interview</option>
            <option value="Rejection" ${n.type === "Rejection" ? "selected" : ""}>Rejection</option>
            <option value="Other" ${n.type === "Other" || !n.type ? "selected" : ""}>Other</option>
          </select>
        </div>
      </div>

      <div class="note-row bottom">
        <div class="field">
          <label>Note</label>
          <textarea name="notes[${idx}][note]" placeholder="e.g. Phone screen with recruiter">${n.note || ""}</textarea>
        </div>
      </div>

      <div class="card-actions">
        <button type="button" class="btn danger" data-remove-note="${n.id}">
          Remove
        </button>
      </div>
    `;

    container.appendChild(card);

    card.querySelector(`[data-remove-note="${n.id}"]`)
      .addEventListener("click", () => {
        state.notes = state.notes.filter(x => x.id !== n.id);
        renderNotes();
      });
  });
}

function syncNotesFromDOM() {
  const container = document.getElementById("notesContainer");
  if (!container) return;

  state.notes.forEach((n, idx) => {
    const card = container.children[idx];
    if (!card) return;

    n.date = card.querySelector(`input[name="notes[${idx}][date]"]`)?.value || "";
    n.type = card.querySelector(`select[name="notes[${idx}][type]"]`)?.value || "Other";
    n.note = card.querySelector(`textarea[name="notes[${idx}][note]"]`)?.value || "";
  });
}

function addNote() {
  syncNotesFromDOM();
  state.notes.unshift({
    id: uid(),
    date: todayISO(),
    type: "Other",
    note: ""
  });
  renderNotes();
}

// ======================================================
// Validation
// ======================================================

function updateSaveButtonState() {
  const companyName = document.getElementById("companyName");
  const jobTitle = document.getElementById("jobTitle");
  const saveBtn = document.getElementById("saveBtn");

  if (!companyName || !jobTitle || !saveBtn) return;

  saveBtn.disabled =
    companyName.value.trim() === "" ||
    jobTitle.value.trim() === "";
}

function highlightEmptyFields() {
  const companyName = document.getElementById("companyName");
  const jobTitle = document.getElementById("jobTitle");

  if (!companyName || !jobTitle) return;

  companyName.style.borderColor =
    companyName.value.trim() ? "#d8d8e2" : "#b91c1c";

  jobTitle.style.borderColor =
    jobTitle.value.trim() ? "#d8d8e2" : "#b91c1c";
}

// ======================================================
// Status → Rejected Date Sync
// ======================================================

function syncRejectedField() {
  const status = document.getElementById("status");
  const dateRejected = document.getElementById("dateRejected");

  if (!status || !dateRejected) return;

  const isRejected = status.value === "Rejected";

  dateRejected.disabled = !isRejected;

  if (!isRejected) {
    dateRejected.value = "";
  }
}

// ======================================================
// Populate Form
// ======================================================

async function populateForm() {
  const recordEl = document.getElementById("record");
  if (!recordEl || !recordEl.value) return;

  const urlFetch = `./resources/xql/populate.xql?record=${encodeURIComponent(recordEl.value)}`;

  try {
    const response = await fetch(urlFetch, { cache: "no-store" });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);

    const xml = await response.text();
    const xmlDoc = new DOMParser().parseFromString(xml, "application/xml");

    const job = xmlDoc.querySelector("job");
    if (!job) return;

    document.getElementById("companyName").value =
      job.querySelector("company")?.textContent.trim() || "";

    document.getElementById("jobTitle").value =
      job.querySelector("title")?.textContent.trim() || "";

    document.getElementById("url").value =
      normalizeUrl(job.querySelector("url")?.textContent || "");

    const dates = job.querySelector("dates");
    if (dates) {
      document.getElementById("dateApplied").value =
        dates.getAttribute("applied") || "";

      document.getElementById("dateRejected").value =
        dates.getAttribute("rejected") || "";
    }

    const statusEl = document.getElementById("status");
    if (statusEl) {
      const raw = job.querySelector("status")?.textContent || "";
      const normalized = raw.trim().toLowerCase();

      const match = [...statusEl.options].find(
        o => o.value.trim().toLowerCase() === normalized
      );

      statusEl.value = match ? match.value : "Submitted";
    }

    syncRejectedField();

    // Contacts
    state.contacts = [];
    job.querySelectorAll("contacts contact").forEach(c => {
      state.contacts.push({
        id: uid(),
        name: c.getAttribute("name") || "",
        role: c.getAttribute("role") || "Other",
        mail: c.getAttribute("mail") || "",
        phone: c.getAttribute("phone") || ""
      });
    });

    // Notes
    state.notes = [];
    job.querySelectorAll("notes note").forEach(n => {
      state.notes.push({
        id: uid(),
        date: n.getAttribute("date") || "",
        type: n.getAttribute("type") || "Other",
        note: n.textContent.trim()
      });
    });

    renderContacts();
    renderNotes();
    updateSaveButtonState();
    highlightEmptyFields();

  } catch (err) {
    console.error("Failed to populate form:", err);
  }
}

// ======================================================
// Init
// ======================================================

window.addEventListener("DOMContentLoaded", () => {
  const recordEl = document.getElementById("record");
  const addNoteBtn = document.getElementById("addNoteBtn");
  const addContactBtn = document.getElementById("addContactBtn");
  const cancelBtn = document.getElementById("cancelBtn");
  const statusEl = document.getElementById("status");

  const recordParam = getParam("record");
  if (recordParam && recordEl) {
    recordEl.value = recordParam;
  }

  addNoteBtn?.addEventListener("click", addNote);
  addContactBtn?.addEventListener("click", addContact);
  statusEl?.addEventListener("change", syncRejectedField);

  document.getElementById("companyName")?.addEventListener("input", () => {
    updateSaveButtonState();
    highlightEmptyFields();
  });

  document.getElementById("jobTitle")?.addEventListener("input", () => {
    updateSaveButtonState();
    highlightEmptyFields();
  });

  cancelBtn?.addEventListener("click", () => {
    window.location.href = document.referrer || "./index.html";
  });

  renderContacts();
  renderNotes();
  syncRejectedField();
  updateSaveButtonState();
  highlightEmptyFields();

  populateForm();
});