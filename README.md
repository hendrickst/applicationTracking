# applicationTracking
eXist-db application for tracking job application status


## eXist-db package installation

The feature branch includes EXPath/eXist-db package descriptors and a post-install script. The package manager deploys the application under /db/apps/jobs, ensures /db/jobs exists, and migrates legacy application XML from /db/jobs/applications into per-application collections. After successful verification, the legacy collection is removed.


## Building an eXist-db XAR

The repository includes an `xar` folder containing the files that belong at the root of the eXist-db package. This makes it easy to create a XAR without PowerShell, shell scripts, or GitHub Actions.

1. Download the branch from GitHub using **Code → Download ZIP**.
2. Extract the downloaded ZIP.
3. Open the extracted repository folder.
4. Open the **xar** folder.
5. Select **everything inside the xar folder**. Do not select the `xar` folder itself.
6. Right-click the selection and choose **Send to → Compressed (zipped) folder**.
7. Rename the resulting `.zip` file to `.xar`.
8. Upload the `.xar` file through the eXist-db Package Manager.

The important part is that `expath-pkg.xml`, `repo.xml`, `post-install.xql`, and the application files are at the **root of the XAR**. Do not include the outer GitHub repository folder or the `xar` folder itself in the archive.

The package installation creates `/db/jobs` if needed and migrates records from the former `/db/jobs/applications` collection before removing the legacy collection after verification.
