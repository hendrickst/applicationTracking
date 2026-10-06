const state={contacts:[],notes:[],documents:[]};
const qs=s=>document.querySelector(s);
const esc=v=>String(v??"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");

function contactCard(x,i){
 const d=document.createElement("details"); d.className="card contact-card"; if(!x.existing)d.open=true;
 d.innerHTML='<summary><span class="summary-title">'+esc(x.name||"New Contact")+'</span><span class="summary-meta">'+esc(x.role||"Other")+'</span></summary><div class="contact-grid"><div class="field"><label>Name</label><input name="contacts['+i+'][name]" value="'+esc(x.name)+'"/></div><div class="field"><label>Role</label><select name="contacts['+i+'][role]"><option>Recruiter</option><option>Hiring Manager</option><option>Referral</option><option>HR</option><option>Other</option></select></div><div class="field"><label>Email</label><input type="email" name="contacts['+i+'][mail]" value="'+esc(x.mail)+'"/></div><div class="field"><label>Phone</label><input name="contacts['+i+'][phone]" value="'+esc(x.phone)+'"/></div><div class="field full"><label>LinkedIn URL</label><input type="url" name="contacts['+i+'][linkedin]" value="'+esc(x.linkedin)+'" placeholder="https://www.linkedin.com/in/..."/></div><div class="field full"><label>Notes</label><textarea name="contacts['+i+'][notes]">'+esc(x.notes)+'</textarea></div></div><div class="card-actions"><button type="button" class="btn danger remove-contact">Remove</button></div>';
 d.querySelector("select").value=x.role||"Other";
 d.querySelector(".remove-contact").onclick=e=>{e.preventDefault();d.remove();renumberContacts();};
 d.querySelectorAll("input,select,textarea").forEach(el=>el.addEventListener("input",()=>{if(el.name.endsWith("[name]"))d.querySelector(".summary-title").textContent=el.value||"New Contact";}));
 return d;
}
function renumberContacts(){document.querySelectorAll(".contact-card").forEach((d,i)=>d.querySelectorAll("input,select,textarea").forEach(el=>el.name=el.name.replace(/contacts\[\d+\]/,"contacts["+i+"]")));}
function renderContacts(){const c=qs("#contactsContainer");c.innerHTML="";if(!state.contacts.length)c.innerHTML='<div class="card empty">No contacts yet.</div>';state.contacts.forEach((x,i)=>c.appendChild(contactCard(x,i)));}
function noteCard(x,i){
 const d=document.createElement("details");d.className="card note-card";
 d.innerHTML='<summary><span class="summary-title">'+esc(x.type||"Note")+'</span><span class="summary-meta">'+esc(x.date||"")+'</span></summary><div class="note-grid"><div class="field"><label>Date</label><input type="date" name="notes['+i+'][date]" value="'+esc(x.date)+'"/></div><div class="field"><label>Type</label><select name="notes['+i+'][type]"><option>Initial</option><option>Interview</option><option>Rejection</option><option>Other</option></select></div><div class="field full"><label>Note</label><textarea name="notes['+i+'][note]">'+esc(x.note)+'</textarea></div></div><div class="card-actions"><button type="button" class="btn danger remove-note">Remove</button></div>';
 d.querySelector("select").value=x.type||"Other";d.querySelector(".remove-note").onclick=e=>{e.preventDefault();d.remove();renumberNotes();};return d;
}
function renumberNotes(){document.querySelectorAll(".note-card").forEach((d,i)=>d.querySelectorAll("input,select,textarea").forEach(el=>el.name=el.name.replace(/notes\[\d+\]/,"notes["+i+"]")));}
function renderNotes(){const c=qs("#notesContainer");c.innerHTML="";if(!state.notes.length)c.innerHTML='<div class="card empty">No notes yet.</div>';state.notes.forEach((x,i)=>c.appendChild(noteCard(x,i)));}

function documentCard(x,i){
 const d=document.createElement("div");d.className="card document-card";d.dataset.index=i;
 if(x.existing)d.innerHTML='<div class="document-row existing-document"><div><strong>'+esc(x.originalName)+'</strong><div class="muted">'+esc(x.type)+'</div></div><a class="btn" target="_blank" href="'+esc(x.href)+'">Open</a><label class="delete-file"><input type="checkbox" name="documentDelete['+i+']" value="'+esc(x.storedName)+'"/> Delete</label></div>';
 else d.innerHTML='<div class="document-row"><div class="field"><label>Type</label><select name="documentType['+i+']"><option>Resume</option><option>Job Description</option></select></div><div class="field file-field"><label>File (PDF, DOC, DOCX)</label><input type="file" name="documentFile['+i+']" accept=".pdf,.doc,.docx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document"/></div><button type="button" class="btn danger remove-document">Remove</button></div>';
 if(!x.existing){d.querySelector("select").value=x.type||"Resume";d.querySelector(".remove-document").onclick=()=>{d.remove();renumberDocuments();};}
 return d;
}
function renumberDocuments(){document.querySelectorAll(".document-card").forEach((d,i)=>{d.dataset.index=i;d.querySelectorAll("input,select").forEach(el=>{el.name=el.name.replace(/(documentType|documentFile|documentDelete)\[\d+\]/,"$1["+i+"]");});});}
function renderDocuments(){const c=qs("#documentsContainer");c.innerHTML="";state.documents.forEach((x,i)=>c.appendChild(documentCard(x,i)));}
function addContact(){const c=qs("#contactsContainer");if(c.querySelector(".empty"))c.innerHTML="";const i=c.querySelectorAll(".contact-card").length;c.appendChild(contactCard({name:"",role:"Recruiter",mail:"",phone:"",linkedin:"",notes:""},i));}
function addNote(){const c=qs("#notesContainer");if(c.querySelector(".empty"))c.innerHTML="";const i=c.querySelectorAll(".note-card").length;c.appendChild(noteCard({date:new Date().toISOString().slice(0,10),type:"Other",note:""},i));}
function addDocument(){const c=qs("#documentsContainer");const i=c.querySelectorAll(".document-card").length;c.appendChild(documentCard({existing:false,type:"Resume"},i));}

async function populate(){
 const id=qs("#record").value;if(!id)return;
 const r=await fetch("./resources/xql/populate.xql?record="+encodeURIComponent(id),{cache:"no-store"});
 const xml=new DOMParser().parseFromString(await r.text(),"application/xml"),j=xml.querySelector("job");if(!j)return;
 qs("#companyName").value=j.querySelector("company")?.textContent||"";qs("#jobTitle").value=j.querySelector("title")?.textContent||"";qs("#url").value=j.querySelector("url")?.textContent||"";qs("#dateApplied").value=j.querySelector("dates")?.getAttribute("applied")||"";qs("#dateRejected").value=j.querySelector("dates")?.getAttribute("rejected")||"";qs("#status").value=j.querySelector("status")?.textContent||"Unsubmitted";
 state.contacts=[...j.querySelectorAll("contacts contact")].map(c=>({name:c.getAttribute("name")||"",role:c.getAttribute("role")||"Other",mail:c.getAttribute("mail")||"",phone:c.getAttribute("phone")||"",linkedin:c.getAttribute("linkedin")||"",notes:c.querySelector("notes")?.textContent||"",existing:true}));
 state.notes=[...j.querySelectorAll("notes note")].map(n=>({date:n.getAttribute("date")||"",type:n.getAttribute("type")||"Other",note:n.textContent||""}));
 state.documents=[...j.querySelectorAll("documents document")].map(x=>({existing:true,type:x.getAttribute("type"),originalName:x.getAttribute("originalName"),storedName:x.getAttribute("storedName"),href:"../../rest/db/jobs/"+encodeURIComponent(id)+"/"+encodeURIComponent(x.getAttribute("storedName"))}));
 renderContacts();renderNotes();renderDocuments();
}
document.addEventListener("DOMContentLoaded",()=>{qs("#record").value=new URLSearchParams(location.search).get("record")||"";qs("#addContactBtn").onclick=addContact;qs("#addNoteBtn").onclick=addNote;qs("#addDocumentBtn").onclick=addDocument;qs("#cancelBtn").onclick=()=>location.href="./index.html";qs("#jobForm").onsubmit=e=>{renumberContacts();renumberNotes();renumberDocuments();qs("#contactCount").value=document.querySelectorAll(".contact-card").length;qs("#noteCount").value=document.querySelectorAll(".note-card").length;qs("#documentCount").value=document.querySelectorAll(".document-card").length;if(!qs("#companyName").value.trim()||!qs("#jobTitle").value.trim()){e.preventDefault();alert("Company Name and Job Title are required.");}};populate();});