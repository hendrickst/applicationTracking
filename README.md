# applicationTracking
eXist-db application for tracking job application status


## eXist-db package installation

The feature branch includes EXPath/eXist-db package descriptors and a post-install script. The package manager deploys the application under /db/apps/jobs, ensures /db/jobs exists, and migrates legacy application XML from /db/jobs/applications into per-application collections. After successful verification, the legacy collection is removed.

The GitHub Actions workflow builds an XAR artifact named applicationTracking-xar. Download the artifact from the workflow run; the downloaded artifact ZIP contains the XAR package contents at its root and can be renamed with a .xar extension for upload through the eXist-db Package Manager.
