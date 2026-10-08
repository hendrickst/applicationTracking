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
function renderContacts(){const c=qs("#contactsContainer");c.innerHTML="";state.contacts.forEach((x,i)=>c.appendChild(contactCard(x,i)));}
function sanitizeNoteHtml(value){
 const doc=new DOMParser().parseFromString(String(value??""),"text/html");
 const allowed=new Set(["P","BR","STRONG","B","EM","I","U","UL","OL","LI","BLOCKQUOTE","H2","H3","A"]);
 const clean=node=>{
  for(const child of [...node.childNodes]){
   if(child.nodeType===Node.ELEMENT_NODE){
    if(!allowed.has(child.tagName)){
     if(["SCRIPT","STYLE","IFRAME","OBJECT","SVG","MATH"].includes(child.tagName)){child.remove();continue;}
     child.replaceWith(...child.childNodes);continue;
    }
    const rawHref=child.tagName==="A"?(child.getAttribute("href")||""):"";
    for(const attr of [...child.attributes])child.removeAttribute(attr.name);
    if(child.tagName==="A"){
     if(/^https?:\/\//i.test(rawHref))child.setAttribute("href",rawHref);
     child.setAttribute("target","_blank");
     child.setAttribute("rel","noopener noreferrer");
    }
    clean(child);
   }else if(child.nodeType!==Node.TEXT_NODE){child.remove();}
  }
 };
 clean(doc.body);
 return doc.body.innerHTML;
}
function notePreview(v,maxLength=110){
 const t=String(v??"").replace(/<br\s*\/?\s*>/gi," ").replace(/<\/(p|li|h2|h3|blockquote)>/gi," ").replace(/<[^>]*>/g,"").replace(/&nbsp;/gi," ").replace(/&amp;/g,"&").replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/\s+/g," ").trim();
 if(!t)return "No note entered";
 return t.length<=maxLength?t:t.substring(0,maxLength).trimEnd()+"…";
}
function noteCard(x,i){
 const d=document.createElement("details");d.className="card note-card";
 d.innerHTML='<summary><span class="summary-main"><span class="summary-title">'+esc(x.type||"Note")+'</span><span class="summary-preview">'+esc(notePreview(x.note))+'</span></span><span class="summary-meta">'+esc(x.date||"")+'</span></summary><div class="note-grid"><div class="field"><label>Date</label><input type="date" name="notes['+i+'][date]" value="'+esc(x.date)+'"/></div><div class="field"><label>Type</label><select name="notes['+i+'][type]"><option>Initial</option><option>Interview</option><option>Rejection</option><option>Other</option></select></div><div class="field full"><label>Note</label><div class="note-toolbar" role="toolbar" aria-label="Note formatting"><button type="button" class="btn" data-command="bold" aria-label="Bold"><strong>B</strong></button><button type="button" class="btn" data-command="italic" aria-label="Italic"><em>I</em></button><button type="button" class="btn" data-command="underline" aria-label="Underline"><u>U</u></button><button type="button" class="btn" data-command="insertUnorderedList" aria-label="Bulleted list">• List</button><button type="button" class="btn" data-command="insertOrderedList" aria-label="Numbered list">1. List</button><button type="button" class="btn" data-command="formatBlock" data-value="h3" aria-label="Heading">Heading</button><button type="button" class="btn" data-command="createLink" aria-label="Insert link">Link</button></div><div class="note-editor" contenteditable="true" role="textbox" aria-label="Note content" aria-multiline="true"></div><input type="hidden" name="notes['+i+'][note]" value=""/></div></div><div class="card-actions"><button type="button" class="btn danger remove-note">Remove</button></div>';
 const editor=d.querySelector(".note-editor"),hidden=d.querySelector('input[type="hidden"]');
 const looksLikeMarkup=/<(p|br|strong|b|em|i|u|ul|ol|li|blockquote|h[2-3]|a)\b/i.test(x.note||"");
 if(looksLikeMarkup)editor.innerHTML=sanitizeNoteHtml(x.note);
 else editor.textContent=x.note||"";
 const sync=()=>{hidden.value=sanitizeNoteHtml(editor.innerHTML);d.querySelector(".summary-preview").textContent=notePreview(hidden.value);};
 editor.addEventListener("input",sync);
 d.querySelectorAll(".note-toolbar button").forEach(btn=>btn.addEventListener("mousedown",e=>e.preventDefault()));
 d.querySelectorAll(".note-toolbar button").forEach(btn=>btn.addEventListener("click",()=>{
  editor.focus();
  const command=btn.dataset.command;
  if(command==="createLink"){
   const url=prompt("Enter the link URL (https:// or http://):");
   if(url&&/^https?:\/\//i.test(url)){document.execCommand("createLink",false,url);sync();}
   return;
  }
  document.execCommand(command,false,btn.dataset.value||null);sync();
 }));
 sync();
 d.querySelector("select").value=x.type||"Other";
 d.querySelector(".remove-note").onclick=e=>{e.preventDefault();d.remove();renumberNotes();};
 return d;
}
function renumberNotes(){document.querySelectorAll(".note-card").forEach((d,i)=>d.querySelectorAll("input,select,textarea").forEach(el=>el.name=el.name.replace(/notes\[\d+\]/,"notes["+i+"]")));}
function renderNotes(){const c=qs("#notesContainer");c.innerHTML="";state.notes.forEach((x,i)=>c.appendChild(noteCard(x,i)));}

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
function addNote(){const c=qs("#notesContainer");if(c.querySelector(".empty"))c.innerHTML="";const n=noteCard({date:new Date().toISOString().slice(0,10),type:"Other",note:""},0);n.open=true;c.insertBefore(n,c.firstChild);renumberNotes();}
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
document.addEventListener("DOMContentLoaded",()=>{const record=new URLSearchParams(location.search).get("record")||"";qs("#record").value=record;qs("#addContactBtn").onclick=addContact;qs("#addNoteBtn").onclick=addNote;qs("#addDocumentBtn").onclick=addDocument;qs("#cancelBtn").onclick=()=>location.href="./index.html";qs("#jobForm").onsubmit=e=>{renumberContacts();renumberNotes();renumberDocuments();qs("#contactCount").value=document.querySelectorAll(".contact-card").length;qs("#noteCount").value=document.querySelectorAll(".note-card").length;qs("#documentCount").value=document.querySelectorAll(".document-card").length;if(!qs("#companyName").value.trim()||!qs("#jobTitle").value.trim()){e.preventDefault();alert("Company Name and Job Title are required.");}};if(!record)addDocument();populate();});