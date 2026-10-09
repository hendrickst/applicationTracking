# Job Application Tracker

Version 2 is a true eXist-db application package. Download the branch ZIP, re-zip its contents with package files at the archive root, rename the resulting ZIP to `.xar`, and install it with eXist-db Package Manager.

The application stores each job at `/db/jobs/<application-id>/`, with the XML record named `<application-id>.xml`. The collection name never includes `.xml`.

On installation, the migration normalizes older layouts, including:
- `/db/jobs/applications/<id>.xml`
- `/db/jobs/<id>.xml/<id>.xml`
- XML resources stored directly under `/db/jobs`

Uploaded files in an older per-application collection are preserved when that collection is renamed. The legacy `/db/jobs/applications` collection is removed only after its XML resources have been copied successfully. The report and weekly pages also perform the same normalization as a recovery path if the package post-install hook was not run.

Uploaded files are stored beside the XML record with unique internal filenames; their original filenames are retained as XML metadata. Supported uploads are PDF, DOC, and DOCX. Google Docs should be exported to PDF or Word first.

The entry form supports multiple contacts, LinkedIn URLs and contact notes, repeating Resume/Job Description document rows, document deletion, and opening existing documents.

## Gemini job chat

Each application has a separate AI chat at `chat.html?record=<application-id>`. The conversation is persisted in that job's collection as `chat.xml`, separate from other applications. The chat is text-only and includes the saved company, title, status, posting URL, and application notes as context. It does not automatically transmit uploaded resumes or contact information.

### Setup

1. Create an API key in [Google AI Studio](https://aistudio.google.com/).
2. Open an application, then click **Open AI Chat** on its edit page and paste the key into the Gemini settings.
3. Confirm the privacy notice and save settings. The key is stored in this browser's local storage, not in eXist-db or the Git repository.
4. Send a message. Chat history is saved to eXist-db after each message and response.

The initial model is `gemini-3.5-flash-lite`. The chat uses Google's recommended Interactions API and sends `store:false`; the app keeps its own transcript in eXist-db. If Google no longer offers this model, change the model field to a currently available model in chat settings.

### Security and privacy notes

- This first version calls Gemini directly from the browser to avoid requiring a paid hosting service or server-side secret configuration. The API key is therefore accessible to anyone who can use the same browser profile or inspect its developer tools. Use an API key restricted in Google Cloud where possible, and do not use this approach on a public, multi-user installation.
- Google's unpaid Gemini API terms say submitted prompts and responses may be used to improve its products and may be reviewed by humans. Do not send personal, sensitive, or confidential information through the free tier. The app sends the job company, title, status, posting URL, and saved application notes as context; it does not automatically send resumes or contact details. The URL is sent as a link only—the app does not fetch the posting webpage contents.
- Free-tier quotas and model availability can change. This app does not enable paid billing or switch to a paid model automatically.
- The API key is saved in browser local storage. Clear it using the browser's site data settings if you want to remove it.
