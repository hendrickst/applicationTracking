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
