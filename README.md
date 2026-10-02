# applicationTracking
eXist-db application for tracking job application status


## eXist-db package installation

The feature branch includes EXPath/eXist-db package descriptors and a post-install script. The package manager deploys the application under /db/apps/jobs, ensures /db/jobs exists, and migrates legacy application XML from /db/jobs/applications into per-application collections. After successful verification, the legacy collection is removed.

The GitHub Actions workflow builds an XAR artifact named applicationTracking-xar. Download the artifact from the workflow run; the downloaded artifact ZIP contains the XAR package contents at its root and can be renamed with a .xar extension for upload through the eXist-db Package Manager.


## Building an eXist-db XAR

GitHub's **Download ZIP** archive is a source archive and includes a top-level branch/repository directory. Simply renaming that ZIP to `.xar` does **not** create a valid eXist-db package.

After downloading and extracting the branch, build the XAR from the extracted repository root:

**Windows PowerShell**
```powershell
.\build-xar.ps1 -Source . -Output .\applicationTracking.xar
```

**macOS/Linux**
```bash
./build-xar.sh . ../applicationTracking.xar
```

The resulting XAR has `expath-pkg.xml`, `repo.xml`, `post-install.xql`, and the application files at the archive root. Upload that `.xar` through the eXist-db package manager.

The package installation creates `/db/jobs` if needed and migrates records from the former `/db/jobs/applications` collection before removing the legacy collection after verification.
