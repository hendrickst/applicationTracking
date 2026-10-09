(() => {
  "use strict";
  const $ = selector => document.querySelector(selector);
  const params = new URLSearchParams(location.search);
  const record = params.get("record") || "";
  const storageKey = "jobs-gemini-settings";
  let messages = [];
  let job = {company:"", title:"", url:"", status:""};
  let busy = false;

  const esc = value => String(value ?? "").replace(/[&<>"']/g, ch => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[ch]));
  const localDate = () => new Date().toISOString();
  const setStatus = (text, error=false) => { $("#chatStatus").textContent = text; $("#chatStatus").classList.toggle("error", error); };

  function settings() {
    return { apiKey: $("#apiKey").value.trim(), model: $("#model").value.trim() || "gemini-3.5-flash-lite",
      temperature: Math.max(0, Math.min(1, Number($("#temperature").value || 0.4))) };
  }
  function loadSettings() {
    try {
      const saved = JSON.parse(localStorage.getItem(storageKey) || "{}");
      if (saved.model === "gemini-2.5-flash-lite") saved.model = "gemini-3.5-flash-lite";
      $("#apiKey").value = saved.apiKey || "";
      $("#model").value = saved.model || "gemini-3.5-flash-lite";
      $("#temperature").value = String(saved.temperature ?? 0.4);
      $("#settingsStatus").textContent = saved.apiKey ? "Settings loaded from this browser." : "Add an API key from Google AI Studio. The key is not saved in eXist-db.";
      const panel = $("#chatSettingsSection");
      if (panel) panel.open = !saved.apiKey;
    } catch (_) {}
  }
  function saveSettings() {
    const s = settings();
    if (!s.apiKey) { $("#settingsStatus").textContent = "Enter an API key first."; return; }
    localStorage.setItem(storageKey, JSON.stringify(s));
    $("#settingsStatus").textContent = "Settings saved in this browser.";
    const panel = $("#chatSettingsSection"); if (panel) panel.open = false;
  }
  async function loadJob() {
    if (!/^[A-Za-z0-9-]+$/.test(record)) throw new Error("Missing or invalid application record ID.");
    const editLink = $("#editJobLink"); if (editLink) editLink.href = "./update.html?record=" + encodeURIComponent(record);
    const embedded = $("#embeddedChatSection"); if (embedded) embedded.hidden = false;
    const response = await fetch("./resources/xql/populate.xql?record=" + encodeURIComponent(record), {cache:"no-store"});
    if (!response.ok) throw new Error("Could not load job details.");
    const xml = new DOMParser().parseFromString(await response.text(), "application/xml");
    if (xml.querySelector("parsererror")) throw new Error("The job record could not be read.");
    const notes = [...xml.querySelectorAll("job > notes > note")].map(node => {
      const date = node.getAttribute("date") || "";
      const type = node.getAttribute("type") || "Note";
      const text = (node.textContent || "").trim();
      return text ? (date ? "[" + date + "] " : "") + type + ": " + text : "";
    }).filter(Boolean);
    job = {company:xml.querySelector("job > company")?.textContent || "", title:xml.querySelector("job > title")?.textContent || "",
      url:xml.querySelector("job > url")?.textContent || "", status:xml.querySelector("job > status")?.textContent || "", notes};
    $("#chatTitle").textContent = (job.company || "Job") + (job.title ? " — " + job.title : "") + " · AI Chat";
    $("#chatSubtitle").textContent = "A saved conversation for " + (job.company || "this application") + ". Company, title, status, posting URL, and saved application notes are sent as context; uploaded documents and contact details are not sent automatically.";
  }
  async function persist() {
    const body = new URLSearchParams({record, action:"save", messages:JSON.stringify(messages)});
    const response = await fetch("./resources/xql/chat.xql", {method:"POST", headers:{"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"}, body});
    const text = await response.text();
    if (!response.ok || !text.includes('status="ok"')) throw new Error("Conversation could not be saved. " + text.slice(0,180));
  }
  async function loadMessages() {
    const response = await fetch("./resources/xql/chat.xql?record=" + encodeURIComponent(record) + "&action=load", {cache:"no-store"});
    if (!response.ok) throw new Error("Could not load saved conversation.");
    const xml = new DOMParser().parseFromString(await response.text(), "application/xml");
    if (xml.querySelector("parsererror")) throw new Error("Saved conversation has invalid XML.");
    messages = [...xml.querySelectorAll("conversation > message")].map(node => ({
      role: node.getAttribute("role") || "user", text:node.textContent || "", time:node.getAttribute("time") || ""
    }));
    renderMessages();
  }
  function appendInline(parent, text) {
    const pattern = /(\*\*[^*]+\*\*|__[^_]+__|\*[^*\n]+\*|_[^_\n]+_|\x60[^\x60]+\x60)/g;
    let last = 0, match;
    while ((match = pattern.exec(text)) !== null) {
      if (match.index > last) parent.appendChild(document.createTextNode(text.slice(last, match.index)));
      const token = match[0];
      let node;
      if (token.startsWith("**") || token.startsWith("__")) {
        node = document.createElement("strong"); node.textContent = token.slice(2, -2);
      } else if (token.charCodeAt(0) === 96) {
        node = document.createElement("code"); node.textContent = token.slice(1, -1);
      } else {
        node = document.createElement("em"); node.textContent = token.slice(1, -1);
      }
      parent.appendChild(node);
      last = match.index + token.length;
    }
    if (last < text.length) parent.appendChild(document.createTextNode(text.slice(last)));
  }
  function renderMarkdown(parent, value) {
    const lines = String(value ?? "").replace(/\r\n?/g, "\n").split("\n");
    let paragraph = [], list = null, listType = "";
    const closeList = () => { list = null; listType = ""; };
    const flushParagraph = () => {
      if (!paragraph.length) return;
      const p = document.createElement("p");
      paragraph.forEach((line, index) => { if (index) p.appendChild(document.createElement("br")); appendInline(p, line); });
      parent.appendChild(p); paragraph = [];
    };
    for (const line of lines) {
      const heading = line.match(/^\s{0,3}(#{1,4})\s+(.+)$/);
      const bullet = line.match(/^\s*[-*+]\s+(.+)$/);
      const numbered = line.match(/^\s*\d+[.)]\s+(.+)$/);
      if (!line.trim()) { flushParagraph(); closeList(); continue; }
      if (heading) {
        flushParagraph(); closeList();
        const h = document.createElement("h" + heading[1].length); appendInline(h, heading[2]); parent.appendChild(h); continue;
      }
      if (bullet || numbered) {
        flushParagraph();
        const type = bullet ? "ul" : "ol";
        if (!list || listType !== type) { closeList(); list = document.createElement(type); listType = type; parent.appendChild(list); }
        const li = document.createElement("li"); appendInline(li, (bullet || numbered)[1]); list.appendChild(li); continue;
      }
      closeList(); paragraph.push(line);
    }
    flushParagraph();
  }
  function renderMessages() {
    const host = $("#chatMessages");
    host.innerHTML = "";
    if (!messages.length) {
      const empty = document.createElement("div"); empty.className = "chat-empty";
      empty.textContent = "No messages yet. Ask a question to start this job's conversation."; host.appendChild(empty); return;
    }
    for (const message of messages) {
      const item = document.createElement("article");
      item.className = "chat-message " + (message.role === "model" ? "assistant-message" : "user-message");
      const heading = document.createElement("div"); heading.className = "chat-message-role"; heading.textContent = message.role === "model" ? "Gemini" : "You";
      const body = document.createElement("div"); body.className = "chat-message-text";
      if (message.role === "model") renderMarkdown(body, message.text);
      else body.textContent = message.text;
      const time = document.createElement("div"); time.className = "chat-message-time";
      if (message.time && !Number.isNaN(Date.parse(message.time))) time.textContent = new Date(message.time).toLocaleString();
      item.append(heading, body, time); host.appendChild(item);
    }
    host.scrollTop = host.scrollHeight;
  }
  function contextPrompt() {
    return "You are an assistant helping with one job application. Be practical, honest, concise, and grounded in facts the user provides. Do not invent experience or interview details. The app supplies these saved job details: company: " +
      (job.company || "not specified") + "; title: " + (job.title || "not specified") + "; status: " + (job.status || "not specified") +
      "; job posting URL: " + (job.url || "not provided") + ". Saved application notes:\n" + (job.notes && job.notes.length ? job.notes.join("\n") : "No application notes saved.") +
      "\nThe URL is provided as a reference link only; you have not been given the webpage contents and must not claim to have opened or read the posting. If the user asks about details from the posting, ask them to paste the relevant text or upload the job description. Uploaded documents and contact details are not included. Treat notes as user-provided context, not guaranteed facts; ask when clarification is needed.";
  }
  async function sendMessage(text) {
    const s = settings();
    if (!s.apiKey) throw new Error("Add your Gemini API key in the settings above.");
    if (!s.model) throw new Error("Enter a Gemini model name.");
    messages.push({role:"user", text, time:localDate()});
    renderMessages();
    await persist();
    const history = messages.slice(-24).map(m => (m.role === "model" ? "Assistant" : "User") + ": " + m.text).join("\n\n");
    const response = await fetch("https://generativelanguage.googleapis.com/v1beta/interactions", {
      method:"POST",
      headers:{"Content-Type":"application/json", "x-goog-api-key":s.apiKey},
      body:JSON.stringify({
        model:s.model,
        system_instruction:contextPrompt() + "\n\nUse the conversation transcript to maintain continuity. Respond to the latest user message.",
        input:history,
        store:false,
        generation_config:{temperature:s.temperature, max_output_tokens:2048}
      })
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(payload.error?.message || "Gemini request failed (HTTP " + response.status + "). Check the API key, model name, and free quota.");
    const answer = (payload.steps || []).filter(step => step.type === "model_output")
      .flatMap(step => step.content || []).map(part => part.text || "").join("").trim();
    if (!answer) throw new Error("Gemini returned no text. Check the model response or try again.");
    messages.push({role:"model", text:answer, time:localDate()});
    await persist();
    renderMessages();
  }
  async function copySummary() {
    const lines = messages.map(m => (m.role === "model" ? "Gemini" : "User") + ": " + m.text);
    const summary = "Job: " + (job.company || "") + " — " + (job.title || "") + "\nStatus: " + (job.status || "") + "\n\nConversation transcript:\n" + lines.join("\n\n");
    await navigator.clipboard.writeText(summary);
    setStatus("Conversation copied. Paste it wherever you want to keep a summary.");
  }
  async function clearChat() {
    if (!confirm("Delete this job's saved AI conversation? This cannot be undone.")) return;
    messages = []; await persist(); renderMessages(); setStatus("Conversation cleared.");
  }
  document.addEventListener("DOMContentLoaded", async () => {
    loadSettings();
    $("#saveSettingsBtn").addEventListener("click", saveSettings);
    const submitMessage = async () => {
      if (busy) return;
      const input = $("#userMessage"), text = input.value.trim(); if (!text) return;
      busy = true; $("#sendBtn").disabled = true; input.disabled = true; setStatus("Sending to Gemini…");
      try { input.value = ""; await sendMessage(text); setStatus("Response received and conversation saved."); }
      catch (error) { setStatus(error.message || "Something went wrong.", true); }
      finally { busy = false; $("#sendBtn").disabled = false; input.disabled = false; input.focus(); }
    };
    const chatForm = $("#chatForm");
    if (chatForm) chatForm.addEventListener("submit", event => { event.preventDefault(); submitMessage(); });
    else $("#sendBtn").addEventListener("click", submitMessage);
    $("#userMessage").addEventListener("keydown", event => {
      if (event.key === "Enter" && !event.shiftKey && !event.isComposing) {
        event.preventDefault(); if (chatForm) chatForm.requestSubmit(); else submitMessage();
      }
    });
    $("#copySummaryBtn").addEventListener("click", () => copySummary().catch(error => setStatus(error.message, true)));
    $("#clearChatBtn").addEventListener("click", () => clearChat().catch(error => setStatus(error.message, true)));
    if (!record && $("#embeddedChatSection")) return;
    try { await loadJob(); await loadMessages(); }
    catch (error) { $("#chatMessages").textContent = error.message; setStatus(error.message, true); }
  });
})();