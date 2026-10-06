# Job Application Tracker

Version 2 is a true eXist-db application package. Download the branch ZIP, re-zip its contents with package files at the archive root, rename the resulting ZIP to `.xar`, and install it with eXist-db Package Manager.

The package contains `expath-pkg.xml` and `repo.xml` and runs `post-install.xql` after deployment. If `/db/jobs/applications` exists, the migration moves each XML application into `/db/jobs/<application-id>/<application-id>.xml` and removes the legacy collection.

Uploaded files are stored beside the XML record with unique internal filenames; their original filenames are retained as XML metadata. Supported uploads are PDF, DOC, and DOCX. Google Docs should be exported to PDF or Word first.