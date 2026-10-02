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

function escapeHtml(value) {
  return String(value || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function formatDate(value) {
  if (!value) return "";
  const parts = value.split("-");
  if (parts.length !== 3) return value;
  return `${parts[1]}/${parts[2]}/${parts[0]}`;
}

function notePreview(value, maxLength = 110) {
  const text = String(value || "").replace(/\s+/g, " ").trim();
  if (!text) return "No note entered";
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength).trimEnd() + "…";
}

// ======================================================
// Global State
// ======================================================

const state = {
  notes: [],
  contacts: []
};

// ======================================================
// Contacts UI
// ======================================================

function renderContacts(openId = null) {
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
    const isExpanded = c.id === openId || c.expanded === true;

    card.className =
      "card contact-card collapsible-card" +
      (isExpanded ? " expanded" : "");

    const name = escapeHtml(c.name || "Unnamed contact");
    const role = escapeHtml(c.role || "Other");
    const mail = escapeHtml(c.mail || "");
    const phone = escapeHtml(c.phone || "");

    const summaryContact = c.name ? escapeHtml(c.name) : "Unnamed contact";
    const summaryRole = c.role ? escapeHtml(c.role) : "Other";
    const contactDetails = [];

    if (c.mail) contactDetails.push(escapeHtml(c.mail));
    if (c.phone) contactDetails.push(escapeHtml(c.phone));

    const summaryDetails = contactDetails.length
      ? contactDetails.join(' <span class="separator">•</span> ')
      : "No contact information";

    card.innerHTML = `
      <div class="card-summary" role="button" tabindex="0"
           aria-expanded="${isExpanded ? "true" : "false"}">
        <div class="card-summary-main">
          <div class="card-summary-title">${summaryContact}</div>
          <div class="card-summary-detail">
            <span>${summaryRole}</span>
            <span class="separator">•</span>
            <span>${summaryDetails}</span>
          </div>
        </div>
        <div class="card-summary-arrow" aria-hidden="true">▼</div>
      </div>

      <div class="card-body">
        <div class="card-body-inner">
          <div class="contact-row top">
            <div class="field name">
              <label>Name</label>
              <input type="text" name="contacts[${idx}][name]" value="${name}" placeholder="Full Name" />
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
              <input type="email" name="contacts[${idx}][mail]" value="${mail}" placeholder="email@company.com" />
            </div>
            <div class="field">
              <label>Phone</label>
              <input type="tel" name="contacts[${idx}][phone]" value="${phone}" placeholder="555-555-5555" />
            </div>
          </div>

          <div class="card-actions">
            <button type="button" class="btn danger" data-remove-contact="${c.id}">Remove</button>
          </div>
        </div>
      </div>
    `;

    container.appendChild(card);
    const summary = card.querySelector(".card-summary");

    function toggleCard() {
      syncContactsFromDOM();
      c.expanded = !card.classList.contains("expanded");
      renderContacts();
    }

    summary.addEventListener("click", toggleCard);
    summary.addEventListener("keydown", event => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        toggleCard();
      }
    });

    card.querySelector(`[data-remove-contact="${c.id}"]`)
      ?.addEventListener("click", event => {
        event.stopPropagation();
        state.contacts = state.contacts.filter(x => x.id !== c.id);
        renderContacts();
      });
  });
}

function syncContactsFromDOM() {
  const container = document.getElementById("contactsContainer");
  if (!container) return;

  state.contacts.forEach((c, idx) => {
    const card = container.querySelectorAll(".contact-card")[idx];
    if (!card) return;

    c.name = card.querySelector(`input[name="contacts[${idx}][name]"]`)?.value || "";
    c.role = card.querySelector(`select[name="contacts[${idx}][role]"]`)?.value || c.role;
    c.mail = card.querySelector(`input[name="contacts[${idx}][mail]"]`)?.value || "";
    c.phone = card.querySelector(`input[name="contacts[${idx}][phone]"]`)?.value || "";
  });
}

function addContact() {
  syncContactsFromDOM();
  state.contacts.forEach(c => { c.expanded = false; });

  const newContact = {
    id: uid(),
    name: "",
    role: "Recruiter",
    mail: "",
    phone: "",
    expanded: true
  };

  state.contacts.unshift(newContact);
  renderContacts(newContact.id);
}

// ======================================================
// Notes UI
// ======================================================

function renderNotes(openId = null) {
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
    const isExpanded = n.id === openId || n.expanded === true;

    card.className =
      "card note-card collapsible-card" +
      (isExpanded ? " expanded" : "");

    const noteType = escapeHtml(n.type || "Other");
    const noteDate = formatDate(n.date);
    const preview = escapeHtml(notePreview(n.note));
    const summaryDate = noteDate || "No date";

    card.innerHTML = `
      <div class="card-summary" role="button" tabindex="0"
           aria-expanded="${isExpanded ? "true" : "false"}">
        <div class="card-summary-main">
          <div class="card-summary-title">
            ${summaryDate} <span class="separator">•</span> ${noteType}
          </div>
          <div class="card-summary-detail"><span>${preview}</span></div>
        </div>
        <div class="card-summary-arrow" aria-hidden="true">▼</div>
      </div>

      <div class="card-body">
        <div class="card-body-inner">
          <div class="note-row top">
            <div class="field">
              <label>Date</label>
              <input type="date" name="notes[${idx}][date]" value="${escapeHtml(n.date || "")}" />
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
              <textarea name="notes[${idx}][note]" placeholder="e.g. Phone screen with recruiter">${escapeHtml(n.note || "")}</textarea>
            </div>
          </div>

          <div class="card-actions">
            <button type="button" class="btn danger" data-remove-note="${n.id}">Remove</button>
          </div>
        </div>
      </div>
    `;

    container.appendChild(card);
    const summary = card.querySelector(".card-summary");

    function toggleCard() {
      syncNotesFromDOM();
      n.expanded = !card.classList.contains("expanded");
      renderNotes();
    }

    summary.addEventListener("click", toggleCard);
    summary.addEventListener("keydown", event => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        toggleCard();
      }
    });

    card.querySelector(`[data-remove-note="${n.id}"]`)
      ?.addEventListener("click", event => {
        event.stopPropagation();
        state.notes = state.notes.filter(x => x.id !== n.id);
        renderNotes();
      });
  });
}

function syncNotesFromDOM() {
  const container = document.getElementById("notesContainer");
  if (!container) return;

  state.notes.forEach((n, idx) => {
    const card = container.querySelectorAll(".note-card")[idx];
    if (!card) return;

    n.date = card.querySelector(`input[name="notes[${idx}][date]"]`)?.value || "";
    n.type = card.querySelector(`select[name="notes[${idx}][type]"]`)?.value || "Other";
    n.note = card.querySelector(`textarea[name="notes[${idx}][note]"]`)?.value || "";
  });
}

function addNote() {
  syncNotesFromDOM();
  state.notes.forEach(n => { n.expanded = false; });

  const newNote = {
    id: uid(),
    date: todayISO(),
    type: "Other",
    note: "",
    expanded: true
  };

  state.notes.unshift(newNote);
  renderNotes(newNote.id);
}

// ======================================================
// Documents UI
// ======================================================

function renderDocumentsFromRows(rows, record) {
  const container = document.getElementById("documentsContainer");
  if (!container) return;

  container.innerHTML = "";

  rows.forEach(doc => {
    const row = document.createElement("div");
    row.className = "card";
    row.innerHTML = `
      <div class="card-summary">
        <div class="card-summary-main">
          <div class="card-summary-title">${escapeHtml(doc.label)}</div>
          <div class="card-summary-detail">${escapeHtml(doc.name)}</div>
        </div>
        <div class="card-actions">
          <a class="btn" href="./resources/xql/download.xql?record=${encodeURIComponent(record)}&amp;type=${encodeURIComponent(doc.type)}" target="_blank" rel="noopener">Open</a>
          <button type="button" class="btn danger" data-delete-document="${escapeHtml(doc.type)}">Delete</button>
        </div>
      </div>
    `;
    container.appendChild(row);

    row.querySelector("[data-delete-document]")?.addEventListener("click", async () => {
      if (!confirm(`Delete the stored ${doc.label.toLowerCase()}? This cannot be undone.`)) return;

      const button = row.querySelector("[data-delete-document]");
      if (button) {
        button.disabled = true;
        button.textContent = "Deleting…";
      }

      try {
        const response = await fetch("./resources/xql/delete.xql", {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
          body: new URLSearchParams({ record, type: doc.type })
        });

        const responseText = await response.text();
        if (!response.ok) throw new Error(responseText || `HTTP ${response.status}`);

        const xml = new DOMParser().parseFromString(responseText, "application/xml");
        const result = xml.querySelector("result");
        if (result?.getAttribute("success") !== "true") {
          throw new Error("The document could not be deleted.");
        }

        renderDocumentsFromRows(rows.filter(item => item.type !== doc.type), record);
      } catch (err) {
        console.error("Failed to delete document:", err);
        alert("The document could not be deleted. Please try again.");
        if (button) {
          button.disabled = false;
          button.textContent = "Delete";
        }
      }
    });
  });
}

function renderDocuments(job) {
  const documents = job.querySelector("documents");
  const record = getParam("record");
  const rows = [];

  if (documents) {
    const resume = documents.querySelector("resume");
    const posting = documents.querySelector("jobPosting");

    if (resume) {
      rows.push({
        label: "Resume",
        type: "resume",
        name: resume.getAttribute("originalName") || resume.getAttribute("file") || "Resume"
      });
    }

    if (posting) {
      rows.push({
        label: "Job Posting PDF",
        type: "jobPosting",
        name: posting.getAttribute("originalName") || posting.getAttribute("file") || "Job Posting PDF"
      });
    }
  }

  renderDocumentsFromRows(rows, record);
}

function showDocumentError() {
  const error = getParam("error");
  const container = document.getElementById("documentError");
  if (!container || !error) return;

  const messages = {
    resume: "The resume must be a PDF, DOC, or DOCX file.",
    posting: "The job posting must be a PDF file."
  };

  container.textContent = messages[error] || "The document could not be uploaded.";
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

  companyName.style.borderColor = companyName.value.trim() ? "#d8d8e2" : "#b91c1c";
  jobTitle.style.borderColor = jobTitle.value.trim() ? "#d8d8e2" : "#b91c1c";
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
  if (!isRejected) dateRejected.value = "";
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

    document.getElementById("companyName").value = job.querySelector("company")?.textContent.trim() || "";
    document.getElementById("jobTitle").value = job.querySelector("title")?.textContent.trim() || "";
    document.getElementById("url").value = normalizeUrl(job.querySelector("url")?.textContent || "");

    const dates = job.querySelector("dates");
    if (dates) {
      document.getElementById("dateApplied").value = dates.getAttribute("applied") || "";
      document.getElementById("dateRejected").value = dates.getAttribute("rejected") || "";
    }

    const statusEl = document.getElementById("status");
    if (statusEl) {
      const raw = job.querySelector("status")?.textContent || "";
      const normalized = raw.trim().toLowerCase();
      const match = [...statusEl.options].find(o => o.value.trim().toLowerCase() === normalized);
      statusEl.value = match ? match.value : "Submitted";
    }

    syncRejectedField();

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

    state.notes = [];
    job.querySelectorAll("notes note").forEach(n => {
      state.notes.push({
        id: uid(),
        date: n.getAttribute("date") || "",
        type: n.getAttribute("type") || "Other",
        note: n.textContent.trim()
      });
    });

    renderDocuments(job);
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
  if (recordParam && recordEl) recordEl.value = recordParam;

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
  showDocumentError();
  populateForm();
});
