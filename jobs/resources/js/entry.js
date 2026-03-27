// ---------- Helpers ----------
function getParam(name) {
  return new URLSearchParams(window.location.search).get(name) || "";
}

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
  notes: [],    // { id, date, type, note }
  contacts: []  // { id, role, mail, phone }
};

// ---------- Contacts UI ----------
function renderContacts() {
  const contactsContainer = document.getElementById("contactsContainer");
  if (!contactsContainer) return;

  contactsContainer.innerHTML = "";

  if (state.contacts.length === 0) {
    const empty = document.createElement("div");
    empty.className = "note-card empty";
    empty.textContent = "No contacts yet. Add one to track network leads.";
    contactsContainer.appendChild(empty);
    return;
  }

  state.contacts.forEach((c, idx) => {
    const card = document.createElement("div");
    card.className = "note-card";

    card.innerHTML = `
      <div class="note-grid three-col">
        <div class="field">
          <label>Role</label>
          <select name="contacts[${idx}][role]">
            <option value="Recruiter" ${c.role === "Recruiter" ? "selected" : ""}>Recruiter</option>
            <option value="Hiring Manager" ${c.role === "Hiring Manager" ? "selected" : ""}>Hiring Manager</option>
            <option value="Referral" ${c.role === "Referral" ? "selected" : ""}>Referral</option>
            <option value="HR" ${c.role === "HR" ? "selected" : ""}>HR/Internal</option>
            <option value="Other" ${c.role === "Other" || !c.role ? "selected" : ""}>Other</option>
          </select>
        </div>

        <div class="field">
          <label>Contact Email</label>
          <input type="email" name="contacts[${idx}][mail]" value="${c.mail || ""}" placeholder="email@company.com" />
        </div>

        <div class="field">
          <label>Contact Phone</label>
          <input type="tel" name="contacts[${idx}][phone]" value="${c.phone || ""}" placeholder="555-555-5555" />
        </div>
      </div>

      <div class="note-actions">
        <button type="button" class="btn danger" data-remove-contact="${c.id}">
          Remove
        </button>
      </div>
    `;

    contactsContainer.appendChild(card);

    const removeBtn = card.querySelector(`[data-remove-contact="${c.id}"]`);
    removeBtn.addEventListener("click", () => {
      state.contacts = state.contacts.filter(x => x.id !== c.id);
      renderContacts();
    });
  });
}

function syncContactsFromDOM() {
  const contactsContainer = document.getElementById("contactsContainer");
  if (!contactsContainer) return;

  state.contacts.forEach((c, idx) => {
    const contactCard = contactsContainer.children[idx];
    if (!contactCard) return;

    const roleInput = contactCard.querySelector(`select[name="contacts[${idx}][role]"]`);
    const mailInput = contactCard.querySelector(`input[name="contacts[${idx}][mail]"]`);
    const phoneInput = contactCard.querySelector(`input[name="contacts[${idx}][phone]"]`);

    if (roleInput) c.role = roleInput.value;
    if (mailInput) c.mail = mailInput.value;
    if (phoneInput) c.phone = phoneInput.value;
  });
}

function addContact() {
  syncContactsFromDOM();
  state.contacts.unshift({
    id: uid(),
    role: "Recruiter",
    mail: "",
    phone: ""
  });
  renderContacts();
}


// ---------- Notes UI ----------
function renderNotes() {
  const notesContainer = document.getElementById("notesContainer");
  if (!notesContainer) return;

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
  const notesContainer = document.getElementById("notesContainer");
  if (!notesContainer) return;

  state.notes.forEach((n, idx) => {
    const noteCard = notesContainer.children[idx];
    if (!noteCard) return;

    const dateInput = noteCard.querySelector(`input[name="notes[${idx}][date]"]`);
    const typeInput = noteCard.querySelector(`select[name="notes[${idx}][type]"]`); 
    const noteInput = noteCard.querySelector(`textarea[name="notes[${idx}][note]"]`);
    
    if (dateInput) n.date = dateInput.value;
    if (typeInput) n.type = typeInput.value; 
    if (noteInput) n.note = noteInput.value;
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

// ---------- Validation ----------
function updateSaveButtonState() {
  const companyName = document.getElementById("companyName");
  const jobTitle = document.getElementById("jobTitle");
  const saveBtn = document.getElementById("saveBtn");
  if (!companyName || !jobTitle || !saveBtn) return;

  const enabled = companyName.value.trim() !== "" && jobTitle.value.trim() !== "";
  saveBtn.disabled = !enabled;
}

function highlightEmptyFields() {
  const companyName = document.getElementById("companyName");
  const jobTitle = document.getElementById("jobTitle");
  if (!companyName || !jobTitle) return;

  companyName.style.borderColor = companyName.value.trim() ? "#d8d8e2" : "#b91c1c";
  jobTitle.style.borderColor = jobTitle.value.trim() ? "#d8d8e2" : "#b91c1c";
}

// ---------- Status behavior ----------
function syncRejectedField() {
  const status = document.getElementById("status");
  const dateRejected = document.getElementById("dateRejected");
  if (!status || !dateRejected) return;

  const rejected = status.value === "Rejected";
  dateRejected.disabled = !rejected;
  if (!rejected) dateRejected.value = "";
}

// ---------- Populate Form (Updated for <job> XML) ----------
async function populateForm() {
  const recordEl = document.getElementById("record");
  if (!recordEl) return;

  const recordId = recordEl.value || "";
  if (!recordId) return;

  const urlFetch = `./resources/xql/populate.xql?record=${encodeURIComponent(recordId)}`;

  try {
    const response = await fetch(urlFetch, { cache: "no-store" });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);

    const text = await response.text();
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(text, "application/xml");

    const job = xmlDoc.querySelector("job");
    if (!job) return;

    // ---- Standard simple fields ----
    const companyName = document.getElementById("companyName");
    const jobTitle = document.getElementById("jobTitle");
    const url = document.getElementById("url");

    if (companyName) companyName.value = job.querySelector("company")?.textContent.trim() || "";
    if (jobTitle) jobTitle.value = job.querySelector("title")?.textContent.trim() || "";
    if (url) url.value = normalizeUrl(job.querySelector("url")?.textContent || "");

    // ---- Dates ----
    const dateApplied = document.getElementById("dateApplied");
    const dateRejected = document.getElementById("dateRejected");
    const dates = job.querySelector("dates");

    if (dates) {
      if (dateApplied) dateApplied.value = dates.getAttribute("applied") || "";
      if (dateRejected) dateRejected.value = dates.getAttribute("rejected") || "";
    }

    // ---- Status ----
    const status = document.getElementById("status");
    const statusText = job.querySelector("status")?.textContent.trim() || "Submitted";

    if (status) {
      if ([...status.options].some(o => o.value === statusText)) {
        status.value = statusText;
      } else {
        status.value = "Submitted";
      }
    }

    syncRejectedField();

    // ---- Contacts Parsing ----
    state.contacts = [];
    job.querySelectorAll("contacts contact").forEach(c => {
      state.contacts.push({
        id: uid(),
        role: c.getAttribute("role") || "Other",
        mail: c.getAttribute("mail") || "",
        phone: c.getAttribute("phone") || ""
      });
    });

    // ---- Notes Parsing ----
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

// ---------- Init ----------
window.addEventListener("DOMContentLoaded", () => {
  console.log("DOM fully loaded. Starting initialization...");

  // 1. Grab elements FIRST
  const recordEl = document.getElementById("record");
  const companyName = document.getElementById("companyName");
  const jobTitle = document.getElementById("jobTitle");
  const status = document.getElementById("status");
  const addNoteBtn = document.getElementById("addNoteBtn");
  const addContactBtn = document.getElementById("addContactBtn");
  const cancelBtn = document.getElementById("cancelBtn");

  // 2. Process record parameter from URL query string SECOND
  const recordParam = getParam("record");
  if (recordParam && recordEl) {
    recordEl.value = recordParam;
  }

  // --- SAFE BINDINGS ---
  if (addNoteBtn) {
    addNoteBtn.addEventListener("click", addNote);
    console.log("✅ Notes button bound.");
  } else {
    console.warn("⚠️ Could not find 'addNoteBtn' in HTML.");
  }

  if (addContactBtn) {
    addContactBtn.addEventListener("click", addContact);
    console.log("✅ Contacts button bound.");
  } else {
    console.warn("⚠️ Could not find 'addContactBtn' in HTML.");
  }

  if (status) {
    status.addEventListener("change", syncRejectedField);
  }

  if (companyName) {
    companyName.addEventListener("input", () => {
      updateSaveButtonState();
      highlightEmptyFields();
    });
  }

  if (jobTitle) {
    jobTitle.addEventListener("input", () => {
      updateSaveButtonState();
      highlightEmptyFields();
    });
  }

  if (cancelBtn) {
    cancelBtn.addEventListener("click", () => {
      if (document.referrer) {
        window.location.href = document.referrer;
      } else {
        window.location.href = "./index.html";
      }
    });
  }

  // Initial draw
  renderContacts();
  renderNotes();
  syncRejectedField();
  updateSaveButtonState();
  highlightEmptyFields();

  populateForm();
});