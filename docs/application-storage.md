# Application document storage

Applications are stored directly under /db/jobs, one collection per application.

## Layout

Each application uses its existing UUID as the collection name:

    /db/jobs/{application-id}/
        application.xml
        resume-{uuid}.pdf
        posting-{uuid}.pdf

The XML keeps the original uploaded filename and MIME type. The internal filenames are generated UUIDs so the same resume filename can be used for different applications without collisions.

The job posting is stored as PDF only. Resumes may be PDF, DOC, or DOCX.

## One-time migration

The repository includes resources/xql/migrate-applications.xql.

Run it first without parameters to copy the legacy XML records from /db/jobs/applications into the new per-application collections and verify the copies.

After verifying the result, run the same query with:

    ?removeLegacy=true

The script only removes the old /db/jobs/applications resources and collection after every legacy XML has a verified /db/jobs/{id}/application.xml copy.

The migration is intentionally separate from normal application editing so it is run once rather than on every request.

## Application URLs

Existing record URLs continue to use the same UUID:

    update.html?record={application-id}

The application editor now resolves the XML at:

    /db/jobs/{application-id}/application.xml

## Documents

The editor accepts a resume upload and a PDF job-posting upload. Re-uploading either document replaces the previous version for that application. The old binary is removed after the replacement is stored.

The original filename is retained in application.xml, while the stored binary uses a generated internal filename.

Documents are opened through resources/xql/download.xql, which validates the application ID and document type before streaming the binary resource.